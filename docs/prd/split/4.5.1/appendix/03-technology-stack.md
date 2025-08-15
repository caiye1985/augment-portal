# 附录C：技术栈与架构选型 v4.5.1

## 版本更新说明

**v4.5.1版本技术栈优化：**
- 确认所有技术组件版本与REQ-006工程师管理模块的技术要求一致
- 优化数据库设计以支持工程师管理的复杂业务逻辑
- 增强缓存策略以支持实时状态管理
- 完善消息队列配置以支持事件驱动架构

## C.1 技术选型原则

| 原则 | 说明 | 权重 | v4.5.1考虑 |
|------|------|------|------------|
| 技术成熟度 | 选择经过生产环境验证的稳定技术 | 高 | 所有组件均为LTS版本 |
| 社区活跃度 | 优先选择社区活跃、文档完善的技术 | 高 | 确保长期技术支持 |
| 团队熟悉度 | 考虑团队现有技术栈和学习成本 | 中 | 基于现有技术栈优化 |
| 性能表现 | 满足系统性能和扩展性要求 | 高 | 支持1000+并发用户 |
| 维护成本 | 考虑长期维护和升级的便利性 | 中 | 自动化运维友好 |
| 多租户支持 | 支持SaaS多租户架构要求 | 高 | **v4.5.1新增考虑** |

## C.2 核心技术栈

### 后端技术栈

| 技术组件 | 版本 | 选择理由 | 备注 | v4.5.1优化 |
|----------|------|----------|------|------------|
| **开发语言** | Java 17 LTS | LTS版本，性能优异，生态成熟 | 支持最新语言特性 | 确认版本一致性 |
| **应用框架** | Spring Boot 3.2.11 | 企业级框架，开发效率高 | 内置多种starter | 支持工程师管理复杂业务 |
| **安全框架** | Spring Security 6.2.1 | 与Spring Boot深度集成 | 支持OAuth2、JWT | 增强多租户权限控制 |
| **数据访问** | Spring Data JPA 3.2.x | 简化数据库操作，支持多租户 | 配合Hibernate使用 | 优化工程师数据查询 |
| **主数据库** | PostgreSQL 15.5 | 开源关系型数据库，支持JSON | 支持分区表、并行查询 | 优化工程师数据存储 |
| **缓存数据库** | Redis 7.2.4 | 高性能内存数据库 | 支持集群模式 | 工程师状态实时缓存 |
| **搜索引擎** | Elasticsearch 8.15.3 | 全文搜索和日志分析 | 支持分布式部署 | 工程师技能搜索优化 |
| **消息队列** | RabbitMQ 3.12.10 | 可靠的消息传递 | 支持多种消息模式 | 工程师状态变更通知 |
| **文件存储** | MinIO RELEASE.2024-01-01T16-36-33Z | 兼容S3 API的对象存储 | 支持分布式部署 | 工程师证书文件存储 |

### 前端技术栈

| 技术组件 | 版本 | 选择理由 | 备注 | v4.5.1优化 |
|----------|------|----------|------|------------|
| **开发框架** | Vue.js 3.4.15 | 组合式API，性能优异 | 支持TypeScript | 工程师管理界面优化 |
| **构建工具** | Vite 5.0.12 | 快速的开发构建工具 | 支持热更新 | 开发效率提升 |
| **UI组件库** | Element Plus 2.4.4 | 企业级UI组件库 | 与Vue 3兼容 | 丰富的表单组件 |
| **状态管理** | Pinia 2.1.7 | Vue 3官方推荐状态管理 | 替代Vuex | 工程师状态管理 |
| **路由管理** | Vue Router 4.2.5 | Vue官方路由解决方案 | 支持动态路由 | 权限路由控制 |
| **HTTP客户端** | Axios 1.6.2 | 功能完善的HTTP库 | 支持拦截器 | API调用优化 |

### 基础设施技术栈

| 技术组件 | 版本 | 选择理由 | 备注 | v4.5.1优化 |
|----------|------|----------|------|------------|
| **容器化** | Docker CLI 24.0.7 | 标准化部署环境 | 支持多架构 | 微服务部署 |
| **容器编排** | Docker Compose 2.23.3 | 本地开发环境管理 | 简化配置 | 开发环境一致性 |
| **虚拟化** | Colima 0.6.6 | macOS Docker替代方案 | 轻量级 | 开发环境支持 |
| **反向代理** | Nginx 1.25.3 | 高性能Web服务器 | 负载均衡 | API网关功能 |

## C.3 工程师管理模块技术要求（v4.5.1特别说明）

### 数据库设计优化

**PostgreSQL配置优化**
```sql
-- 工程师管理相关配置
shared_preload_libraries = 'pg_stat_statements'
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB

-- 支持JSON查询优化
gin_pending_list_limit = 4MB
```

**索引策略**
```sql
-- 工程师表核心索引
CREATE INDEX CONCURRENTLY idx_engineers_tenant_status ON engineers(tenant_id, status);
CREATE INDEX CONCURRENTLY idx_engineers_online_status ON engineers(tenant_id, online_status);
CREATE INDEX CONCURRENTLY idx_engineers_skills_gin ON engineer_skills USING GIN(skill_codes);
CREATE INDEX CONCURRENTLY idx_schedules_date_range ON work_schedules(tenant_id, schedule_date);
```

### Redis缓存策略

**工程师状态缓存**
```yaml
# Redis配置
maxmemory: 2gb
maxmemory-policy: allkeys-lru
timeout: 300

# 缓存键设计
engineer:status:{tenant_id}:{engineer_id}: 300s  # 工程师在线状态
engineer:skills:{tenant_id}:{engineer_id}: 3600s # 工程师技能信息
engineer:workload:{tenant_id}:{engineer_id}: 600s # 工程师工作负载
schedule:conflicts:{tenant_id}:{date}: 1800s     # 排班冲突检测
```

### 消息队列配置

**RabbitMQ交换机设计**
```yaml
exchanges:
  - name: engineer.events
    type: topic
    durable: true
    
queues:
  - name: engineer.status.changed
    routing_key: engineer.status.*
  - name: engineer.skill.updated  
    routing_key: engineer.skill.*
  - name: schedule.conflict.detected
    routing_key: schedule.conflict.*
```

## C.4 性能优化策略

### 数据库性能优化

**连接池配置**
```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

**JPA优化配置**
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true
        batch_versioned_data: true
```

### 缓存性能优化

**多级缓存策略**
```java
@Configuration
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        RedisCacheManager.Builder builder = RedisCacheManager
            .RedisCacheManagerBuilder
            .fromConnectionFactory(redisConnectionFactory())
            .cacheDefaults(cacheConfiguration());
        return builder.build();
    }
    
    private RedisCacheConfiguration cacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
}
```

## C.5 安全技术配置

### Spring Security配置

**JWT认证配置**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/engineers/**").hasRole("ENGINEER_MANAGER")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer().jwt();
        return http.build();
    }
}
```

### 数据加密配置

**敏感数据加密**
```java
@Configuration
public class EncryptionConfig {
    
    @Bean
    public AESUtil aesUtil() {
        return new AESUtil("AES/CBC/PKCS5Padding", 
                          environment.getProperty("app.encryption.key"));
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
```

## C.6 监控和运维技术

### 应用监控

**Micrometer + Prometheus配置**
```yaml
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
```

### 日志配置

**Logback配置**
```xml
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
            <providers>
                <timestamp/>
                <logLevel/>
                <loggerName/>
                <message/>
                <mdc/>
                <arguments/>
                <stackTrace/>
            </providers>
        </encoder>
    </appender>
    
    <logger name="com.fxtech.portal.engineer" level="DEBUG"/>
    <root level="INFO">
        <appender-ref ref="STDOUT"/>
    </root>
</configuration>
```

## C.7 开发工具链

### 开发环境

| 工具 | 版本 | 用途 | 配置要求 |
|------|------|------|----------|
| IntelliJ IDEA | 2024.1+ | Java开发IDE | 8GB+ RAM |
| VS Code | 1.85+ | 前端开发 | 插件：Vue、ESLint |
| Docker Desktop | 4.26+ | 容器化开发 | 16GB+ RAM |
| Postman | 10.20+ | API测试 | 团队协作版 |
| DBeaver | 23.3+ | 数据库管理 | PostgreSQL驱动 |

### CI/CD工具

```yaml
# GitHub Actions配置示例
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Run tests
        run: ./mvnw test
      - name: Build application
        run: ./mvnw clean package
```

## C.8 技术债务管理

### 代码质量工具

**SonarQube配置**
```yaml
sonar:
  projectKey: ops-portal
  organization: fxtech
  host:
    url: https://sonarcloud.io
  
quality_gates:
  - coverage: 80%
  - duplicated_lines_density: 3%
  - maintainability_rating: A
  - reliability_rating: A
  - security_rating: A
```

### 依赖管理

**Maven依赖检查**
```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.4.3</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>
```

参考：详细的部署配置见附录F《部署指南与运维手册》。
