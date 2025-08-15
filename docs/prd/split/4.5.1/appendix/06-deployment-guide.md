# 附录F：部署指南与运维手册 v4.5.1

## 版本更新说明

**v4.5.1版本部署优化：**
- 更新工程师管理模块的部署配置
- 优化数据库迁移脚本，支持REQ-006模块整合
- 增强监控配置，支持工程师管理相关指标
- 完善运维手册，包含新模块的运维要点

## F.1 环境要求

### F.1.1 硬件要求

| 环境类型 | CPU | 内存 | 存储 | 网络 | 备注 |
|----------|-----|------|------|------|------|
| **开发环境** | 4核+ | 8GB+ | 100GB SSD | 100Mbps | 单机部署 |
| **测试环境** | 8核+ | 16GB+ | 200GB SSD | 1Gbps | 模拟生产 |
| **生产环境** | 16核+ | 32GB+ | 500GB SSD | 10Gbps | 高可用集群 |

### F.1.2 软件要求

| 组件 | 版本要求 | 安装方式 | 配置要求 |
|------|----------|----------|----------|
| **操作系统** | Ubuntu 22.04 LTS / CentOS 8+ | 标准安装 | 最小化安装 |
| **Java运行时** | OpenJDK 17 LTS | 包管理器 | JAVA_HOME配置 |
| **Docker** | 24.0.7+ | 官方脚本 | 用户组配置 |
| **Docker Compose** | 2.23.3+ | 官方下载 | 可执行权限 |
| **PostgreSQL** | 15.5+ | Docker镜像 | 数据持久化 |
| **Redis** | 7.2.4+ | Docker镜像 | 内存配置 |
| **Nginx** | 1.25.3+ | Docker镜像 | SSL证书 |

## F.2 部署架构

### F.2.1 单机部署（开发/测试环境）

```yaml
# docker-compose.yml
version: '3.8'

services:
  # 数据库服务
  postgres:
    image: postgres:15.5
    container_name: ops-postgres
    environment:
      POSTGRES_DB: ops_portal
      POSTGRES_USER: ops_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    restart: unless-stopped

  # 缓存服务
  redis:
    image: redis:7.2.4
    container_name: ops-redis
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped

  # 搜索引擎
  elasticsearch:
    image: elasticsearch:8.15.3
    container_name: ops-elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    restart: unless-stopped

  # 消息队列
  rabbitmq:
    image: rabbitmq:3.12.10-management
    container_name: ops-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: ${MQ_USER}
      RABBITMQ_DEFAULT_PASS: ${MQ_PASSWORD}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    restart: unless-stopped

  # 对象存储
  minio:
    image: minio/minio:RELEASE.2024-01-01T16-36-33Z
    container_name: ops-minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_USER}
      MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    restart: unless-stopped

  # 应用服务
  ops-portal:
    image: ops-portal/app:v4.5.1
    container_name: ops-portal-app
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DATABASE_URL=jdbc:postgresql://postgres:5432/ops_portal
      - DATABASE_USERNAME=ops_user
      - DATABASE_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=redis
      - REDIS_PASSWORD=${REDIS_PASSWORD}
      - ELASTICSEARCH_HOST=elasticsearch:9200
      - RABBITMQ_HOST=rabbitmq
      - RABBITMQ_USERNAME=${MQ_USER}
      - RABBITMQ_PASSWORD=${MQ_PASSWORD}
      - MINIO_ENDPOINT=http://minio:9000
      - MINIO_ACCESS_KEY=${MINIO_USER}
      - MINIO_SECRET_KEY=${MINIO_PASSWORD}
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
      - elasticsearch
      - rabbitmq
      - minio
    restart: unless-stopped

  # 反向代理
  nginx:
    image: nginx:1.25.3
    container_name: ops-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
      - ./dist:/usr/share/nginx/html
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - ops-portal
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  es_data:
  rabbitmq_data:
  minio_data:
```

### F.2.2 集群部署（生产环境）

```yaml
# docker-stack.yml
version: '3.8'

services:
  # 应用服务集群
  ops-portal:
    image: ops-portal/app:v4.5.1
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role == worker
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DATABASE_URL=jdbc:postgresql://postgres-cluster:5432/ops_portal
      - REDIS_CLUSTER_NODES=redis-1:6379,redis-2:6379,redis-3:6379
    networks:
      - ops-network

  # 负载均衡
  nginx:
    image: nginx:1.25.3
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == manager
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - nginx_config:/etc/nginx
    networks:
      - ops-network

networks:
  ops-network:
    driver: overlay
    attachable: true

volumes:
  nginx_config:
```

## F.3 数据库初始化

### F.3.1 数据库迁移脚本（v4.5.1）

```sql
-- V4.5.1__engineer_module_integration.sql
-- 工程师管理模块整合迁移脚本

-- 1. 创建新的统一工程师表
CREATE TABLE IF NOT EXISTS engineers (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tenant_id BIGINT NOT NULL,
    employee_no VARCHAR(50) NOT NULL,
    user_id BIGINT,
    real_name VARCHAR(50) NOT NULL,
    gender TINYINT,
    birth_date DATE,
    id_card VARCHAR(255), -- AES-256加密
    phone VARCHAR(255),    -- AES-256加密
    email VARCHAR(100),
    address TEXT,
    emergency_contact VARCHAR(50),
    emergency_phone VARCHAR(255), -- AES-256加密
    department_id BIGINT,
    position VARCHAR(100),
    level TINYINT DEFAULT 1,
    hire_date DATE,
    status TINYINT DEFAULT 1,
    work_location VARCHAR(200),
    current_workload INT DEFAULT 0,
    online_status VARCHAR(20) DEFAULT 'offline',
    last_active_time TIMESTAMP,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_updated_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    
    CONSTRAINT uk_tenant_employee_no UNIQUE (tenant_id, employee_no)
);

-- 2. 创建索引
CREATE INDEX idx_engineers_tenant_status ON engineers(tenant_id, status);
CREATE INDEX idx_engineers_online_status ON engineers(tenant_id, online_status);
CREATE INDEX idx_engineers_department ON engineers(tenant_id, department_id);
CREATE INDEX idx_engineers_workload ON engineers(current_workload);
CREATE INDEX idx_engineers_location ON engineers(latitude, longitude);
CREATE INDEX idx_engineers_last_active ON engineers(last_active_time);

-- 3. 创建工程师技能表
CREATE TABLE IF NOT EXISTS engineer_skills (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tenant_id BIGINT NOT NULL,
    engineer_id BIGINT NOT NULL,
    skill_code VARCHAR(50) NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    skill_level TINYINT NOT NULL,
    experience_years DECIMAL(4,1),
    certification_status TINYINT DEFAULT 0,
    certification_date DATE,
    certification_expiry DATE,
    certification_authority VARCHAR(100),
    certificate_url VARCHAR(255),
    last_used_date DATE,
    proficiency_score DECIMAL(5,2),
    self_assessment TINYINT,
    manager_assessment TINYINT,
    peer_assessment DECIMAL(3,1),
    assessment_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_tenant_engineer_skill UNIQUE (tenant_id, engineer_id, skill_code),
    CONSTRAINT fk_engineer_skills_engineer FOREIGN KEY (engineer_id) REFERENCES engineers(id) ON DELETE CASCADE
);

-- 4. 创建排班计划表
CREATE TABLE IF NOT EXISTS work_schedules (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tenant_id BIGINT NOT NULL,
    engineer_id BIGINT NOT NULL,
    schedule_date DATE NOT NULL,
    shift_type VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    work_location VARCHAR(200),
    priority_level TINYINT DEFAULT 1,
    required_skills JSON,
    status TINYINT DEFAULT 1,
    conflict_status TINYINT DEFAULT 0,
    auto_assigned BOOLEAN DEFAULT FALSE,
    assignment_reason TEXT,
    notes TEXT,
    created_by BIGINT,
    approved_by BIGINT,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_tenant_engineer_datetime UNIQUE (tenant_id, engineer_id, schedule_date, start_time),
    CONSTRAINT fk_work_schedules_engineer FOREIGN KEY (engineer_id) REFERENCES engineers(id) ON DELETE CASCADE
);

-- 5. 创建绩效评估表
CREATE TABLE IF NOT EXISTS performance_evaluations (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tenant_id BIGINT NOT NULL,
    engineer_id BIGINT NOT NULL,
    evaluation_period VARCHAR(20) NOT NULL,
    evaluation_type TINYINT NOT NULL,
    
    -- 工作质量指标
    ticket_completion_rate DECIMAL(5,2),
    ticket_quality_score DECIMAL(5,2),
    customer_satisfaction DECIMAL(5,2),
    sla_compliance_rate DECIMAL(5,2),
    
    -- 工作效率指标
    avg_resolution_time DECIMAL(8,2),
    first_call_resolution_rate DECIMAL(5,2),
    productivity_score DECIMAL(5,2),
    
    -- 技能发展指标
    skill_improvement_score DECIMAL(5,2),
    training_completion_rate DECIMAL(5,2),
    certification_count INT DEFAULT 0,
    
    -- 团队协作指标
    teamwork_score DECIMAL(5,2),
    knowledge_sharing_score DECIMAL(5,2),
    mentoring_score DECIMAL(5,2),
    
    -- 360度反馈评分
    self_score DECIMAL(5,2),
    supervisor_score DECIMAL(5,2),
    peer_score DECIMAL(5,2),
    subordinate_score DECIMAL(5,2),
    
    -- 综合评估结果
    final_score DECIMAL(5,2),
    performance_level VARCHAR(20),
    ranking_percentile DECIMAL(5,2),
    
    -- 评估内容
    strengths TEXT,
    improvements TEXT,
    goals_next_period TEXT,
    development_plan TEXT,
    
    -- 评估流程
    evaluator_id BIGINT,
    status TINYINT DEFAULT 1,
    submitted_at TIMESTAMP,
    reviewed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_performance_evaluations_engineer FOREIGN KEY (engineer_id) REFERENCES engineers(id) ON DELETE CASCADE
);

-- 6. 数据迁移（如果存在旧表）
-- INSERT INTO engineers SELECT ... FROM old_engineers_table;
-- INSERT INTO engineer_skills SELECT ... FROM old_skills_table;

-- 7. 创建触发器（更新时间自动更新）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_engineers_updated_at BEFORE UPDATE ON engineers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_engineer_skills_updated_at BEFORE UPDATE ON engineer_skills
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. 插入基础数据
INSERT INTO skill_dictionary (skill_code, skill_name, category, description) VALUES
('linux', 'Linux系统管理', '操作系统', 'Linux服务器管理和维护'),
('docker', 'Docker容器技术', '容器化', 'Docker容器部署和管理'),
('kubernetes', 'Kubernetes编排', '容器编排', 'K8s集群管理和应用部署'),
('mysql', 'MySQL数据库', '数据库', 'MySQL数据库管理和优化'),
('postgresql', 'PostgreSQL数据库', '数据库', 'PostgreSQL数据库管理'),
('redis', 'Redis缓存', '缓存', 'Redis缓存服务管理'),
('nginx', 'Nginx服务器', 'Web服务器', 'Nginx配置和负载均衡'),
('java', 'Java开发', '编程语言', 'Java应用开发和调优'),
('python', 'Python开发', '编程语言', 'Python脚本和应用开发'),
('monitoring', '系统监控', '监控运维', '系统监控和告警配置');
```

### F.3.2 配置文件模板

```yaml
# application-prod.yml
spring:
  application:
    name: ops-portal
  
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true

  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 20
        max-idle: 10
        min-idle: 5

  rabbitmq:
    host: ${RABBITMQ_HOST:localhost}
    port: ${RABBITMQ_PORT:5672}
    username: ${RABBITMQ_USERNAME:guest}
    password: ${RABBITMQ_PASSWORD:guest}
    virtual-host: /
    listener:
      simple:
        concurrency: 5
        max-concurrency: 10
        retry:
          enabled: true
          max-attempts: 3

# 工程师管理模块配置
engineer:
  management:
    # 排班配置
    scheduling:
      max-consecutive-days: 5
      min-rest-hours: 12
      max-weekly-hours: 40
      conflict-detection: true
      auto-assignment: true
    
    # 绩效评估配置
    performance:
      evaluation-periods: [Q1, Q2, Q3, Q4, H1, H2, ANNUAL]
      360-feedback: true
      auto-data-collection: true
      
    # 技能管理配置
    skills:
      certification-reminder-days: 30
      skill-levels: [1, 2, 3, 4, 5]
      auto-skill-matching: true

# 监控配置
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
    distribution:
      percentiles-histogram:
        http.server.requests: true

# 日志配置
logging:
  level:
    com.fxtech.portal: INFO
    com.fxtech.portal.engineer: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: /var/log/ops-portal/application.log
    max-size: 100MB
    max-history: 30
```

## F.4 运维监控

### F.4.1 监控指标配置

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'ops-portal'
    static_configs:
      - targets: ['ops-portal:8080']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 10s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### F.4.2 告警规则

```yaml
# alert_rules.yml
groups:
  - name: ops-portal-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"

      - alert: DatabaseConnectionHigh
        expr: hikaricp_connections_active / hikaricp_connections_max > 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database connection pool usage high"
          description: "Connection pool usage is {{ $value | humanizePercentage }}"

      - alert: EngineerServiceDown
        expr: up{job="ops-portal"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Engineer service is down"
          description: "Engineer management service has been down for more than 1 minute"
```

## F.5 备份与恢复

### F.5.1 数据备份策略

```bash
#!/bin/bash
# backup.sh - 数据备份脚本

# 配置变量
BACKUP_DIR="/backup/ops-portal"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="ops_portal"
DB_USER="ops_user"
DB_HOST="localhost"

# 创建备份目录
mkdir -p $BACKUP_DIR/$DATE

# 数据库备份
echo "Starting database backup..."
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -f $BACKUP_DIR/$DATE/database.sql
gzip $BACKUP_DIR/$DATE/database.sql

# Redis备份
echo "Starting Redis backup..."
redis-cli --rdb $BACKUP_DIR/$DATE/redis.rdb

# MinIO备份
echo "Starting MinIO backup..."
mc mirror minio/ops-portal $BACKUP_DIR/$DATE/files/

# 压缩备份
echo "Compressing backup..."
tar -czf $BACKUP_DIR/ops-portal-backup-$DATE.tar.gz -C $BACKUP_DIR $DATE

# 清理临时文件
rm -rf $BACKUP_DIR/$DATE

# 保留最近30天的备份
find $BACKUP_DIR -name "ops-portal-backup-*.tar.gz" -mtime +30 -delete

echo "Backup completed: ops-portal-backup-$DATE.tar.gz"
```

### F.5.2 灾难恢复流程

```bash
#!/bin/bash
# restore.sh - 数据恢复脚本

BACKUP_FILE=$1
RESTORE_DIR="/tmp/restore"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# 解压备份文件
echo "Extracting backup file..."
mkdir -p $RESTORE_DIR
tar -xzf $BACKUP_FILE -C $RESTORE_DIR

# 恢复数据库
echo "Restoring database..."
gunzip $RESTORE_DIR/*/database.sql.gz
psql -h localhost -U ops_user -d ops_portal < $RESTORE_DIR/*/database.sql

# 恢复Redis
echo "Restoring Redis..."
redis-cli FLUSHALL
redis-cli --rdb $RESTORE_DIR/*/redis.rdb

# 恢复文件
echo "Restoring files..."
mc mirror $RESTORE_DIR/*/files/ minio/ops-portal

# 清理临时文件
rm -rf $RESTORE_DIR

echo "Restore completed successfully"
```

## F.6 性能调优

### F.6.1 JVM调优参数

```bash
# JVM启动参数
JAVA_OPTS="-Xms2g -Xmx4g \
           -XX:+UseG1GC \
           -XX:MaxGCPauseMillis=200 \
           -XX:+UseStringDeduplication \
           -XX:+PrintGCDetails \
           -XX:+PrintGCTimeStamps \
           -Xloggc:/var/log/ops-portal/gc.log \
           -XX:+UseGCLogFileRotation \
           -XX:NumberOfGCLogFiles=5 \
           -XX:GCLogFileSize=100M \
           -Djava.security.egd=file:/dev/./urandom"
```

### F.6.2 数据库调优

```sql
-- PostgreSQL性能调优
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET work_mem = '4MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;

-- 重新加载配置
SELECT pg_reload_conf();
```

参考：更多运维细节和故障排除指南见系统管理模块文档。
