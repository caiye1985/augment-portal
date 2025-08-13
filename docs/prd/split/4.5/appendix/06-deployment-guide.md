# 附录F：部署指南与运维手册

## F.1 环境配置要求

### F.1.1 硬件配置要求

| 环境类型 | CPU | 内存 | 存储 | 网络 | 节点数 |
|----------|-----|------|------|------|--------|
| 开发环境 | 4核 | 8GB | 100GB SSD | 100Mbps | 1 |
| 测试环境 | 8核 | 16GB | 500GB SSD | 1Gbps | 3 |
| 生产环境 | 16核 | 32GB | 1TB SSD | 10Gbps | 5+ |

### F.1.2 软件依赖要求

| 组件 | 版本要求 | 用途 | 备注 |
|------|----------|------|------|
| Docker | 20.10+ | 容器化部署 | 支持BuildKit |
| Kubernetes | 1.25+ | 容器编排 | 生产环境必需 |
| Helm | 3.10+ | 包管理 | 用于应用部署 |
| PostgreSQL | 15+ | 主数据库 | 支持分区表 |
| Redis | 7+ | 缓存数据库 | 支持集群模式 |
| Nginx | 1.20+ | 反向代理 | 支持HTTP/2 |

## F.2 分环境部署架构

### F.2.1 开发环境
**目标**：快速启动，便于开发调试

| 组件 | 部署方式 | 配置 | 说明 |
|------|----------|------|------|
| **应用服务** | Docker Compose | 单实例 | 支持热重载 |
| **数据库** | PostgreSQL容器 | 单实例 | 开发数据 |
| **缓存** | Redis容器 | 单实例 | 本地缓存 |
| **前端** | 开发服务器 | Vite Dev Server | 支持HMR |
| **外部依赖** | Mock服务 | WireMock | 模拟第三方API |

**启动命令**：
```bash
docker-compose -f docker-compose.dev.yml up -d
npm run dev
```

### F.2.2 测试环境
**目标**：模拟生产环境，支持集成测试

| 组件 | 部署方式 | 配置 | 说明 |
|------|----------|------|------|
| **应用服务** | Kubernetes | 2副本 | 支持滚动更新 |
| **数据库** | 独立实例 | 主从复制 | 测试数据隔离 |
| **缓存** | Redis集群 | 3节点 | 高可用配置 |
| **负载均衡** | Nginx Ingress | 多实例 | SSL终止 |
| **监控** | Prometheus+Grafana | 完整监控 | 性能测试支持 |

### F.2.3 生产环境
**目标**：高可用、高性能、高安全性

| 组件 | 部署方式 | 配置 | 说明 |
|------|----------|------|------|
| **应用服务** | Kubernetes | 3+副本 | 多可用区部署 |
| **数据库** | PostgreSQL集群 | 主从+读写分离 | 自动故障转移 |
| **缓存** | Redis集群 | 6节点 | 分片+副本 |
| **负载均衡** | 云负载均衡器 | 多层负载均衡 | 健康检查 |
| **CDN** | 云CDN服务 | 全球加速 | 静态资源缓存 |
| **备份** | 自动化备份 | 每日备份 | 异地容灾 |

## F.3 部署步骤指南

### F.3.1 开发环境部署

1. **环境准备**
   ```bash
   # 安装Docker和Docker Compose
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER

   # 克隆项目代码
   git clone <repository-url>
   cd ops-portal
   ```

2. **配置文件准备**
   ```bash
   # 复制配置模板
   cp .env.example .env.dev
   cp docker-compose.example.yml docker-compose.dev.yml

   # 编辑配置文件
   vim .env.dev
   ```

3. **启动服务**
   ```bash
   # 启动基础服务
   docker-compose -f docker-compose.dev.yml up -d postgres redis

   # 初始化数据库
   ./scripts/init-db.sh

   # 启动应用服务
   ./mvnw spring-boot:run

   # 启动前端服务
   cd frontend && npm run dev
   ```

### F.3.2 生产环境部署

1. **Kubernetes集群准备**
   ```bash
   # 创建命名空间
   kubectl create namespace ops-portal

   # 创建配置映射
   kubectl create configmap app-config --from-file=config/

   # 创建密钥
   kubectl create secret generic app-secrets --from-env-file=.env.prod
   ```

2. **数据库部署**
   ```bash
   # 部署PostgreSQL集群
   helm install postgres bitnami/postgresql-ha -n ops-portal

   # 部署Redis集群
   helm install redis bitnami/redis-cluster -n ops-portal
   ```

3. **应用部署**
   ```bash
   # 部署后端服务
   helm install ops-portal-backend ./charts/backend -n ops-portal

   # 部署前端服务
   helm install ops-portal-frontend ./charts/frontend -n ops-portal

   # 配置Ingress
   kubectl apply -f k8s/ingress.yml
   ```

## F.4 安全配置指南

### F.4.1 网络安全
- **防火墙配置**：仅开放必要端口（80, 443, 22）
- **VPC隔离**：数据库和应用服务分别部署在不同子网
- **SSL/TLS**：全站HTTPS，使用有效证书
- **API安全**：实施API限流和访问控制

### F.4.2 数据安全
- **数据加密**：数据库连接加密，敏感数据字段加密
- **访问控制**：基于RBAC的细粒度权限控制
- **审计日志**：记录所有关键操作的审计日志
- **备份加密**：备份数据加密存储

### F.4.3 应用安全
- **容器安全**：使用非root用户运行容器
- **镜像安全**：定期扫描容器镜像漏洞
- **密钥管理**：使用Kubernetes Secrets管理敏感信息
- **安全更新**：定期更新依赖包和基础镜像

## F.5 监控与运维

### F.5.1 监控指标

| 监控类型 | 关键指标 | 告警阈值 | 监控工具 |
|----------|----------|----------|----------|
| **应用监控** | 响应时间、错误率、QPS | >500ms, >1%, >1000 | Prometheus |
| **系统监控** | CPU、内存、磁盘、网络 | >80%, >85%, >90%, >80% | Node Exporter |
| **数据库监控** | 连接数、慢查询、锁等待 | >80%, >100ms, >5s | PostgreSQL Exporter |
| **业务监控** | 工单处理量、用户活跃度 | 自定义阈值 | 自定义指标 |

### F.5.2 日志管理
- **日志收集**：使用Fluentd收集应用和系统日志
- **日志存储**：Elasticsearch集群存储，保留30天
- **日志分析**：Kibana可视化分析，支持全文搜索
- **日志告警**：基于关键词和错误率设置告警

### F.5.3 备份策略
- **数据库备份**：每日全量备份，每小时增量备份
- **文件备份**：每日备份上传文件和配置文件
- **备份验证**：定期验证备份文件完整性
- **恢复演练**：每季度进行灾难恢复演练

## F.6 故障处理指南

### F.6.1 常见故障及处理

| 故障类型 | 症状 | 排查步骤 | 解决方案 |
|----------|------|----------|----------|
| **服务无响应** | 接口超时 | 检查Pod状态、资源使用 | 重启Pod、扩容 |
| **数据库连接失败** | 连接超时 | 检查数据库状态、网络 | 重启数据库、检查配置 |
| **内存溢出** | OOMKilled | 检查内存使用、GC日志 | 调整内存限制、优化代码 |
| **磁盘空间不足** | 写入失败 | 检查磁盘使用率 | 清理日志、扩容磁盘 |

### F.6.2 应急响应流程
1. **故障发现**：监控告警或用户反馈
2. **影响评估**：确定故障影响范围和严重程度
3. **应急处理**：执行临时解决方案，恢复服务
4. **根因分析**：深入分析故障原因
5. **永久修复**：实施永久解决方案
6. **复盘总结**：记录故障处理过程，优化预防措施

### F.6.3 联系方式
- **技术支持**：tech-support@company.com
- **运维值班**：ops-oncall@company.com
- **紧急联系**：+86-xxx-xxxx-xxxx

## F.7 性能优化建议

### F.7.1 应用层优化
- **数据库优化**：索引优化、查询优化、连接池调优
- **缓存策略**：Redis缓存热点数据，减少数据库压力
- **异步处理**：使用消息队列处理耗时操作
- **代码优化**：JVM参数调优、垃圾回收优化

### F.7.2 基础设施优化
- **资源配置**：根据监控数据调整CPU和内存配置
- **网络优化**：使用CDN加速静态资源访问
- **存储优化**：使用SSD存储，配置合适的IOPS
- **负载均衡**：合理配置负载均衡策略

参考：详细技术架构见附录E《架构图表与业务价值分析》
