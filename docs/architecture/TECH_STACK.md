# IT运维门户系统技术栈规范

## 📋 版本管理规范

本文档定义了IT运维门户系统的标准技术栈版本，所有开发和部署必须严格遵循此规范。

**文档版本**: v2.0  
**更新日期**: 2025-01-09  
**适用范围**: 开发、测试、生产环境  

## 🎯 技术栈版本清单

### 后端技术栈

| 组件 | 版本 | 类型 | 说明 |
|------|------|------|------|
| **Java** | OpenJDK 17 LTS | 运行时 | 长期支持版本，稳定可靠 |
| **Spring Boot** | 3.2.11 | 框架 | LTS版本，生产环境推荐 |
| **Spring Security** | 6.2.1 | 安全框架 | 与Spring Boot 3.2兼容 |
| **Spring Data JPA** | 3.2.x | 数据访问 | 随Spring Boot版本 |
| **Maven** | 3.9.6 | 构建工具 | 最新稳定版本 |

### 数据存储技术栈

| 组件 | 版本 | 类型 | 说明 |
|------|------|------|------|
| **PostgreSQL** | 15.5 | 主数据库 | 稳定版本，性能优秀 |
| **Redis** | 7.2.4 | 缓存 | 最新稳定版本 |
| **Elasticsearch** | 8.15.3 | 搜索引擎 | 与Spring Data兼容 |
| **RabbitMQ** | 3.12.10 | 消息队列 | 最新稳定版本 |
| **MinIO** | RELEASE.2024-01-01T16-36-33Z | 对象存储 | 最新稳定版本 |

### 前端技术栈

| 组件 | 版本 | 类型 | 说明 |
|------|------|------|------|
| **Vue.js** | 3.4.15 | 前端框架 | 稳定版本，兼容性好 |
| **Vite** | 5.0.12 | 构建工具 | 最新稳定版本 |
| **Element Plus** | 2.4.4 | UI组件库 | 企业级UI组件 |
| **Pinia** | 2.1.7 | 状态管理 | Vue 3推荐状态管理 |
| **Vue Router** | 4.2.5 | 路由管理 | 与Vue 3兼容 |
| **ECharts** | 5.4.3 | 图表库 | 数据可视化 |
| **Vue-ECharts** | 6.6.0 | Vue图表组件 | ECharts的Vue封装 |
| **Axios** | 1.6.2 | HTTP客户端 | 稳定版本 |

### 基础设施技术栈

| 组件 | 版本 | 类型 | 说明 |
|------|------|------|------|
| **Colima** | 0.6.6 | 容器运行时 | macOS推荐方案 |
| **Docker CLI** | 24.0.7 | 容器工具 | 与Colima配合使用 |
| **Docker Compose** | 2.23.3 | 容器编排 | 多容器应用管理 |
| **Nginx** | 1.25.3 | 反向代理 | 高性能Web服务器 |
| **Prometheus** | 2.48.0 | 监控系统 | 指标收集和存储 |
| **Grafana** | 10.2.2 | 可视化 | 监控数据可视化 |

## 🔄 容器化方案

### 推荐方案：Colima + Docker CLI

**适用场景**: macOS开发环境，企业授权限制

**安装配置**:
```bash
# 安装Colima和Docker CLI
brew install colima docker docker-compose

# 启动Colima
colima start --cpu 4 --memory 8 --disk 60

# 验证安装
docker --version
docker-compose --version
```

**优势**:
- ✅ 100% Docker CLI兼容性
- ✅ 免费开源，无商业许可限制
- ✅ 优秀的性能表现
- ✅ 轻量级虚拟机

### 备选方案：Podman

**适用场景**: 高安全要求环境

**配置**:
```bash
# 安装Podman
brew install podman

# 初始化Podman机器
podman machine init
podman machine start

# 设置别名（可选）
alias docker=podman
alias docker-compose=podman-compose
```

## 🔧 开发环境配置

### Java环境
```bash
# 推荐使用SDKMAN管理Java版本
curl -s "https://get.sdkman.io" | bash
sdk install java 17.0.9-tem
sdk use java 17.0.9-tem
```

### Maven配置
```xml
<!-- settings.xml 推荐配置 -->
<settings>
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <name>Aliyun Maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

### Node.js环境
```bash
# 推荐使用nvm管理Node.js版本
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

## 📊 兼容性矩阵

### Spring Boot与组件兼容性

| Spring Boot | Spring Security | Spring Data JPA | Elasticsearch |
|-------------|-----------------|-----------------|---------------|
| 3.2.11 | 6.2.1 | 3.2.x | 8.15.3 |
| 3.1.x | 6.1.x | 3.1.x | 8.11.x |
| 3.0.x | 6.0.x | 3.0.x | 8.5.x |

### Vue.js生态兼容性

| Vue.js | Vue Router | Pinia | Element Plus | Vite |
|--------|------------|-------|--------------|------|
| 3.4.15 | 4.2.5 | 2.1.7 | 2.4.4 | 5.0.12 |
| 3.3.x | 4.2.x | 2.1.x | 2.3.x | 4.5.x |

## 🚨 版本升级策略

### 升级优先级

**P0 - 安全更新**
- 立即升级安全补丁
- 影响：安全漏洞修复

**P1 - 稳定性更新**
- 1个月内升级
- 影响：Bug修复、性能优化

**P2 - 功能更新**
- 3个月内评估升级
- 影响：新功能、API变更

**P3 - 主版本升级**
- 6个月内规划升级
- 影响：架构变更、兼容性

### 升级流程

1. **评估阶段**
   - 兼容性分析
   - 风险评估
   - 测试计划制定

2. **测试阶段**
   - 开发环境验证
   - 测试环境验证
   - 性能测试

3. **部署阶段**
   - 灰度发布
   - 监控观察
   - 回滚准备

## 📝 变更记录

| 版本 | 日期 | 变更内容 | 影响范围 |
|------|------|----------|----------|
| v2.0 | 2025-08-09 | 统一技术栈版本，容器化方案调整 | 全栈 |
| v1.1 | 2024-12-15 | Elasticsearch版本调整 | 后端 |
| v1.0 | 2024-11-01 | 初始版本 | 全栈 |

## 🔍 版本验证

### 自动化检查脚本

```bash
#!/bin/bash
# version-check.sh - 技术栈版本验证脚本

echo "=== 技术栈版本检查 ==="

# Java版本检查
java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
echo "Java版本: $java_version"

# Maven版本检查
mvn_version=$(mvn -version | head -n 1 | cut -d' ' -f3)
echo "Maven版本: $mvn_version"

# Node.js版本检查
node_version=$(node --version)
echo "Node.js版本: $node_version"

# Docker版本检查
docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
echo "Docker版本: $docker_version"

echo "=== 检查完成 ==="
```

### 依赖版本检查

```bash
# 后端依赖检查
mvn dependency:tree | grep -E "(spring-boot|spring-security|postgresql)"

# 前端依赖检查
npm list vue @vue/router pinia element-plus
```
