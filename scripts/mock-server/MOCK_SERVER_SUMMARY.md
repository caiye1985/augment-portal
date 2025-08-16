# IT运维门户系统 Mock Server 工具集总结

## 📁 创建的文件清单

### 核心启动脚本
- `scripts/start-mock-server.sh` - Shell版本启动脚本 (推荐)
- `scripts/start-mock-server.js` - Node.js版本启动脚本
- `scripts/package.json` - Node.js依赖配置

### 管理和控制脚本
- `scripts/mock-server-control.sh` - 后台运行控制脚本
- `scripts/setup-mock-server.sh` - 环境设置脚本
- `scripts/test-mock-server.sh` - 功能测试脚本

### Docker部署文件
- `scripts/Dockerfile.mock-server` - Docker镜像构建文件
- `scripts/docker-compose.mock-server.yml` - Docker Compose配置
- `scripts/nginx.mock.conf` - Nginx反向代理配置
- `scripts/docker-mock-server.sh` - Docker管理脚本

### 文档文件
- `scripts/README-mock-server.md` - 详细使用文档
- `scripts/MOCK_SERVER_SUMMARY.md` - 本总结文档

## 🚀 快速开始指南

### 1. 环境设置 (首次使用)

```bash
# 运行环境设置脚本
./scripts/setup-mock-server.sh

# 或者手动安装依赖
npm install -g @stoplight/prism-cli
```

### 2. 启动Mock Server

#### 方式一：直接启动 (推荐)
```bash
# 启动全局API Mock Server
./scripts/start-mock-server.sh

# 启动特定模块
./scripts/start-mock-server.sh -m REQ-016-客户关系管理模块

# 启动特定业务域
./scripts/start-mock-server.sh -d auth
```

#### 方式二：后台运行
```bash
# 后台启动
./scripts/mock-server-control.sh start

# 查看状态
./scripts/mock-server-control.sh status

# 查看日志
./scripts/mock-server-control.sh logs

# 停止服务
./scripts/mock-server-control.sh stop
```

#### 方式三：Docker部署
```bash
# 构建镜像
./scripts/docker-mock-server.sh build

# 启动所有服务
./scripts/docker-mock-server.sh up

# 查看状态
./scripts/docker-mock-server.sh status
```

### 3. 访问Mock API

```bash
# 本地访问
curl http://localhost:3000/api/v1/auth/login

# Docker多服务访问
curl http://localhost:3001/api/v1/auth/login  # 认证域
curl http://localhost:3002/api/v1/tickets    # 工单域
curl http://localhost:3003/api/v1/customers  # 客户模块
```

## 🛠️ 主要功能特性

### ✅ 多种部署方式
- **本地直接运行**: 使用Shell或Node.js脚本
- **后台服务**: 支持daemon模式运行
- **Docker容器**: 完整的容器化部署方案

### ✅ 灵活的API支持
- **全局API**: 聚合所有业务域的完整API
- **模块API**: 支持23个独立业务模块
- **域API**: 支持15个业务域独立部署

### ✅ 开发友好特性
- **热重载**: 文件变更自动重启
- **CORS支持**: 默认启用跨域支持
- **动态响应**: 智能生成Mock数据
- **错误模拟**: 支持HTTP错误状态码

### ✅ 运维管理功能
- **进程管理**: 启动、停止、重启、状态查询
- **日志管理**: 完整的运行日志记录
- **健康检查**: 自动检测服务状态
- **依赖检查**: 自动安装必要依赖

## 📋 使用场景

### 前端开发
```javascript
// 配置API基础URL
const API_BASE_URL = process.env.NODE_ENV === 'development' 
  ? 'http://localhost:3000' 
  : 'https://api.ops-portal.com';

// 使用Mock API进行开发
axios.get(`${API_BASE_URL}/api/v1/tickets`)
  .then(response => console.log(response.data));
```

### 自动化测试
```bash
# 测试脚本中启动Mock Server
./scripts/mock-server-control.sh start -p 3001
npm run test
./scripts/mock-server-control.sh stop
```

### 团队协作
```bash
# 团队成员快速启动开发环境
git clone <repository>
cd ops-portal
./scripts/setup-mock-server.sh
./scripts/start-mock-server.sh
```

### CI/CD集成
```yaml
# GitHub Actions示例
- name: Start Mock Server
  run: ./scripts/docker-mock-server.sh up -d

- name: Run Tests
  run: npm test

- name: Stop Mock Server
  run: ./scripts/docker-mock-server.sh down
```

## 🔧 配置选项

### 命令行参数
| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-p, --port` | 端口号 | 3000 |
| `-h, --host` | 主机地址 | 0.0.0.0 |
| `-m, --module` | 特定模块 | - |
| `-d, --domain` | 特定业务域 | - |
| `-w, --watch` | 文件监控 | false |
| `--cors` | CORS支持 | true |
| `--dynamic` | 动态响应 | false |
| `--errors` | 错误模拟 | false |

### 环境变量
```bash
export MOCK_SERVER_PORT=3001
export MOCK_SERVER_HOST=localhost
export NODE_ENV=development
```

### Docker配置
```yaml
# docker-compose.mock-server.yml
environment:
  - NODE_ENV=development
  - PORT=3000
  - HOST=0.0.0.0
```

## 🧪 测试和验证

### 运行完整测试
```bash
# 运行所有功能测试
./scripts/test-mock-server.sh

# 指定端口测试
./scripts/test-mock-server.sh --port 3002
```

### 手动验证
```bash
# 检查服务状态
curl -I http://localhost:3000

# 验证CORS支持
curl -H "Origin: http://localhost:8080" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS http://localhost:3000

# 测试API响应
curl http://localhost:3000/api/v1/auth/login
```

## 📚 相关文档

- **详细使用文档**: `scripts/README-mock-server.md`
- **API文档结构**: `docs/api/4.5.1/`
- **项目开发规则**: `.augment/rules/portal-project-rules.md`

## 🤝 贡献和支持

### 问题反馈
如果遇到问题，请检查：
1. Node.js版本是否 >= 14.0.0
2. Prism CLI是否正确安装
3. API文档文件是否存在
4. 端口是否被占用

### 功能扩展
可以通过以下方式扩展功能：
1. 修改OpenAPI规范添加新的API
2. 更新脚本支持新的启动选项
3. 添加新的Docker服务配置
4. 扩展测试用例覆盖

### 最佳实践
1. 使用版本控制管理API规范变更
2. 定期更新Mock数据保持真实性
3. 在CI/CD中集成Mock Server测试
4. 为不同环境配置不同的Mock策略

---

**🎉 现在您可以开始使用IT运维门户系统的Mock Server了！**

选择适合您的部署方式，开始高效的API开发和测试工作。
