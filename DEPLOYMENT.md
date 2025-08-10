# IT运维门户系统部署指南

## 📋 部署概述

本指南提供IT运维门户系统的完整部署方案，支持开发、测试、生产环境的标准化部署。

**部署版本**: v2.0  
**更新日期**: 2025-01-09  
**技术栈**: 参考 [TECH_STACK.md](TECH_STACK.md)

## 🎯 部署架构选择

### 容器化方案对比

| 方案 | 适用场景 | 优势 | 劣势 |
|------|----------|------|------|
| **Colima + Docker CLI** | macOS开发环境 | 免费、兼容性好 | 仅限macOS |
| **Podman** | 高安全要求环境 | 无守护进程、更安全 | 生态相对较小 |
| **Docker Desktop** | 企业授权环境 | 功能完整、生态丰富 | 商业许可费用 |

### 推荐部署方案

#### 开发环境: Colima + Docker CLI
```bash
# 安装Colima和Docker CLI
brew install colima docker docker-compose

# 启动Colima (针对Apple Silicon优化)
colima start --cpu 4 --memory 8 --disk 60 --arch aarch64 --vm-type=vz --vz-rosetta

# 验证安装
docker --version
docker-compose --version
```

#### 生产环境: Kubernetes + Docker
```yaml
容器平台: Kubernetes 1.28+
容器运行时: containerd
镜像仓库: Harbor/Docker Registry
服务网格: Istio (可选)
```

## 🚀 快速部署

### 一键启动开发环境

```bash
# 1. 克隆项目
git clone https://github.com/caiye1985/ops-portal.git
cd ops-portal

# 2. 启动基础设施服务
docker-compose up -d postgres redis elasticsearch rabbitmq minio

# 3. 等待服务启动完成
./scripts/wait-for-services.sh

# 4. 构建并启动后端
cd portal-start
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 5. 启动前端 (新终端)
cd portal-frontend
npm install
npm run dev
```

### 服务访问地址

| 服务 | 地址 | 用户名/密码 |
|------|------|-------------|
| **前端应用** | http://localhost:3000 | - |
| **后端API** | http://localhost:8080 | - |
| **API文档** | http://localhost:8080/swagger-ui.html | - |
| **PostgreSQL** | localhost:5432 | portal/portal123 |
| **Redis** | localhost:6379 | - |
| **Elasticsearch** | http://localhost:9200 | - |
| **RabbitMQ管理** | http://localhost:15672 | portal/portal123 |
| **MinIO管理** | http://localhost:9001 | portal/portal123 |

## 🔧 环境配置

### 系统要求

#### 最低配置
```yaml
开发环境:
  CPU: 4核心
  内存: 8GB
  存储: 50GB
  操作系统: macOS 12+, Ubuntu 20.04+, Windows 10+

生产环境:
  CPU: 8核心
  内存: 16GB
  存储: 200GB SSD
  操作系统: Ubuntu 20.04 LTS, CentOS 8+
```

#### 软件依赖
```yaml
必需软件:
  - Java: OpenJDK 17 LTS
  - Maven: 3.9.6+
  - Node.js: 20 LTS
  - Docker: 24.0.7+
  - Docker Compose: 2.23.3+

可选软件:
  - Git: 2.40+
  - Nginx: 1.25+ (生产环境)
  - Prometheus: 2.48+ (监控)
  - Grafana: 10.2+ (可视化)
```

### 环境变量配置

#### 开发环境 (.env.dev)
```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=portal
DB_USERNAME=portal
DB_PASSWORD=portal123

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Elasticsearch配置
ES_HOST=localhost
ES_PORT=9200
ES_USERNAME=
ES_PASSWORD=

# 应用配置
SPRING_PROFILES_ACTIVE=dev
SERVER_PORT=8080
LOG_LEVEL=DEBUG

# 集成配置
NETBOX_API_URL=http://netbox.example.com
NETBOX_API_TOKEN=your_netbox_token
NIGHTINGALE_API_URL=http://nightingale.example.com
NIGHTINGALE_API_KEY=your_nightingale_key
```

#### 生产环境 (.env.prod)
```bash
# 数据库配置 (使用环境变量或密钥管理)
DB_HOST=${DB_HOST}
DB_PORT=5432
DB_NAME=portal_prod
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

# Redis配置
REDIS_HOST=${REDIS_HOST}
REDIS_PORT=6379
REDIS_PASSWORD=${REDIS_PASSWORD}

# 应用配置
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
LOG_LEVEL=INFO

# 安全配置
JWT_SECRET=${JWT_SECRET}
ENCRYPTION_KEY=${ENCRYPTION_KEY}
```

## 📦 Docker部署

### Docker Compose配置

#### 开发环境 (docker-compose.dev.yml)
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15.5
    environment:
      POSTGRES_DB: portal
      POSTGRES_USER: portal
      POSTGRES_PASSWORD: portal123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql

  redis:
    image: redis:7.2.4-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  elasticsearch:
    image: elasticsearch:8.15.3
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ports:
      - "9200:9200"
    volumes:
      - es_data:/usr/share/elasticsearch/data

  rabbitmq:
    image: rabbitmq:3.12.10-management
    environment:
      RABBITMQ_DEFAULT_USER: portal
      RABBITMQ_DEFAULT_PASS: portal123
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq

  minio:
    image: minio/minio:latest
    environment:
      MINIO_ROOT_USER: portal
      MINIO_ROOT_PASSWORD: portal123
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"

volumes:
  postgres_data:
  redis_data:
  es_data:
  rabbitmq_data:
  minio_data:
```

#### 生产环境 (docker-compose.prod.yml)
```yaml
version: '3.8'

services:
  portal:
    image: portal:latest
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_HOST=postgres
      - REDIS_HOST=redis
      - ES_HOST=elasticsearch
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
      - elasticsearch
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:1.25.3
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - portal
    restart: unless-stopped

  postgres:
    image: postgres:15.5
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backup:/backup
    restart: unless-stopped

  redis:
    image: redis:7.2.4-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    restart: unless-stopped

  elasticsearch:
    image: elasticsearch:8.15.3
    environment:
      - cluster.name=portal-cluster
      - node.name=portal-node-1
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  es_data:
```

### Dockerfile配置

```dockerfile
# 多阶段构建
FROM maven:3.9.6-openjdk-17 AS builder

WORKDIR /app
COPY pom.xml .
COPY portal-*/pom.xml ./portal-*/
RUN mvn dependency:go-offline

COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:17-jre-slim

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/portal-start/target/portal-start-*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

## ☸️ Kubernetes部署

### 命名空间配置
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: portal-system
  labels:
    name: portal-system
```

### 应用部署配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portal-app
  namespace: portal-system
spec:
  replicas: 3
  selector:
    matchLabels:
      app: portal-app
  template:
    metadata:
      labels:
        app: portal-app
    spec:
      containers:
      - name: portal
        image: portal:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: portal-secrets
              key: db-host
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

### 服务配置
```yaml
apiVersion: v1
kind: Service
metadata:
  name: portal-service
  namespace: portal-system
spec:
  selector:
    app: portal-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
```

## 🔍 监控部署

### Prometheus配置
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'portal-app'
    static_configs:
      - targets: ['portal-service:8080']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 30s
```

### Grafana仪表板
```json
{
  "dashboard": {
    "title": "Portal System Monitoring",
    "panels": [
      {
        "title": "Application Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"portal-app\"}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "http_server_requests_seconds{job=\"portal-app\"}"
          }
        ]
      }
    ]
  }
}
```

## 🔒 安全配置

### SSL/TLS配置
```nginx
server {
    listen 443 ssl http2;
    server_name portal.example.com;
    
    ssl_certificate /etc/nginx/ssl/portal.crt;
    ssl_certificate_key /etc/nginx/ssl/portal.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    location / {
        proxy_pass http://portal-backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 防火墙配置
```bash
# 开放必要端口
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8080/tcp  # 应用端口 (内网)

# 限制数据库端口访问
ufw allow from 10.0.0.0/8 to any port 5432  # PostgreSQL
ufw allow from 10.0.0.0/8 to any port 6379  # Redis

# 启用防火墙
ufw enable
```

## 📊 性能优化

### JVM调优
```bash
# 生产环境JVM参数
JAVA_OPTS="-Xms2g -Xmx4g \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/app/logs/ \
  -Dspring.profiles.active=prod"
```

### 数据库优化
```sql
-- PostgreSQL性能优化
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;

-- 重载配置
SELECT pg_reload_conf();
```

## 🔄 备份恢复

### 数据库备份
```bash
#!/bin/bash
# 数据库备份脚本

BACKUP_DIR="/backup/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="portal"

# 创建备份
pg_dump -h localhost -U portal -d $DB_NAME > $BACKUP_DIR/portal_$DATE.sql

# 保留最近7天的备份
find $BACKUP_DIR -name "portal_*.sql" -mtime +7 -delete
```

### 应用备份
```bash
#!/bin/bash
# 应用配置备份脚本

BACKUP_DIR="/backup/config"
DATE=$(date +%Y%m%d_%H%M%S)

# 备份配置文件
tar -czf $BACKUP_DIR/config_$DATE.tar.gz \
  /app/config/ \
  /app/logs/ \
  /etc/nginx/

# 保留最近30天的备份
find $BACKUP_DIR -name "config_*.tar.gz" -mtime +30 -delete
```

## 📞 故障排查

### 常见问题

| 问题 | 症状 | 解决方案 |
|------|------|----------|
| **服务启动失败** | 端口占用、依赖缺失 | 检查端口、安装依赖 |
| **数据库连接失败** | 连接超时、认证失败 | 检查网络、验证凭据 |
| **内存不足** | OOM错误、性能下降 | 调整JVM参数、扩容 |
| **磁盘空间不足** | 写入失败、日志丢失 | 清理日志、扩容存储 |

### 日志查看
```bash
# 应用日志
docker logs -f portal-app

# 系统日志
journalctl -u portal-service -f

# Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

**维护团队**: IT运维门户部署团队  
**技术支持**: deployment-support@company.com  
**最后更新**: 2025-01-09
