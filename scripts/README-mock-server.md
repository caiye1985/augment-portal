# IT运维门户系统 Mock Server 工具集

本工具集提供了基于 OpenAPI 规范的 Mock Server 启动和管理功能，支持全局API索引和模块独立API文件。

## 🚀 快速开始

### 1. 安装依赖

```bash
# 安装 Node.js (如果未安装)
# 推荐使用 Node.js 16+ 版本

# 安装 Prism CLI (全局安装)
npm install -g @stoplight/prism-cli

# 或者使用本地安装
cd scripts
npm install
```

### 2. 启动 Mock Server

```bash
# 方式1: 使用 Shell 脚本 (推荐)
./scripts/start-mock-server.sh

# 方式2: 使用 Node.js 脚本
node scripts/start-mock-server.js

# 方式3: 使用控制脚本 (后台运行)
./scripts/mock-server-control.sh start
```

## 📋 功能特性

- ✅ **多种启动模式**: 支持全局API、特定模块、特定业务域
- ✅ **热重载**: 文件变更时自动重启服务器
- ✅ **CORS支持**: 默认启用跨域支持
- ✅ **动态响应**: 支持动态生成Mock数据
- ✅ **错误模拟**: 支持HTTP错误状态码模拟
- ✅ **进程管理**: 支持后台运行、停止、重启
- ✅ **日志记录**: 完整的启动和运行日志
- ✅ **依赖检查**: 自动检查和安装必要依赖

## 🛠️ 使用方法

### Shell 脚本版本 (`start-mock-server.sh`)

```bash
# 启动全局API Mock Server (默认端口3000)
./scripts/start-mock-server.sh

# 指定端口启动
./scripts/start-mock-server.sh -p 3001

# 启动特定模块
./scripts/start-mock-server.sh -m REQ-016-客户关系管理模块

# 启动特定业务域
./scripts/start-mock-server.sh -d auth

# 启用文件监控和动态响应
./scripts/start-mock-server.sh -w --dynamic --errors

# 列出所有可用模块和域
./scripts/start-mock-server.sh -l

# 查看帮助
./scripts/start-mock-server.sh --help
```

### Node.js 脚本版本 (`start-mock-server.js`)

```bash
# 启动全局API Mock Server
node scripts/start-mock-server.js

# 使用npm scripts
cd scripts
npm run start
npm run start:auth
npm run start:customer
npm run list
```

### 控制脚本 (`mock-server-control.sh`)

```bash
# 启动 (后台运行)
./scripts/mock-server-control.sh start

# 启动特定模块 (后台运行)
./scripts/mock-server-control.sh start -m REQ-016-客户关系管理模块

# 查看状态
./scripts/mock-server-control.sh status

# 查看日志
./scripts/mock-server-control.sh logs

# 停止服务器
./scripts/mock-server-control.sh stop

# 重启服务器
./scripts/mock-server-control.sh restart

# 清理临时文件
./scripts/mock-server-control.sh clean
```

### Docker 版本 (`docker-mock-server.sh`)

```bash
# 构建Docker镜像
./scripts/docker-mock-server.sh build

# 启动所有Mock Server服务
./scripts/docker-mock-server.sh up

# 启动特定服务
./scripts/docker-mock-server.sh up mock-server-global

# 查看服务状态
./scripts/docker-mock-server.sh status

# 查看服务日志
./scripts/docker-mock-server.sh logs mock-server-auth

# 停止所有服务
./scripts/docker-mock-server.sh down

# 重启服务
./scripts/docker-mock-server.sh restart mock-server-customer

# 进入容器
./scripts/docker-mock-server.sh shell mock-server-global

# 清理环境
./scripts/docker-mock-server.sh clean
```

## 📁 API 文档结构

```
docs/api/4.5.1/
├── global-api-index.yaml          # 全局API索引文件
├── domains/                       # 业务域API文件
│   ├── auth-domain.yaml
│   ├── ticket-domain.yaml
│   ├── customer-domain.yaml
│   └── ...
└── modules/                       # 模块API文件
    ├── REQ-001-基础架构模块/
    │   └── openapi.yaml
    ├── REQ-016-客户关系管理模块/
    │   └── openapi.yaml
    └── ...
```

## ⚙️ 配置选项

### 命令行参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-p, --port` | 指定端口号 | 3000 |
| `-h, --host` | 指定主机地址 | 0.0.0.0 |
| `-m, --module` | 启动特定模块 | - |
| `-d, --domain` | 启动特定业务域 | - |
| `-g, --global` | 启动全局API | true |
| `-w, --watch` | 启用文件监控 | false |
| `--cors` | 启用CORS支持 | true |
| `--dynamic` | 启用动态响应 | false |
| `--errors` | 启用错误模拟 | false |
| `-v, --verbose` | 详细输出 | false |

### 环境变量

可以通过环境变量覆盖默认配置：

```bash
export MOCK_SERVER_PORT=3001
export MOCK_SERVER_HOST=localhost
./scripts/start-mock-server.sh
```

## 🔧 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   lsof -i :3000
   
   # 使用其他端口
   ./scripts/start-mock-server.sh -p 3001
   ```

2. **Prism CLI 未安装**
   ```bash
   # 全局安装
   npm install -g @stoplight/prism-cli
   
   # 验证安装
   prism --version
   ```

3. **API文件验证失败**
   ```bash
   # 手动验证API文件
   prism validate docs/api/4.5.1/global-api-index.yaml
   
   # 查看详细错误信息
   ./scripts/start-mock-server.sh --verbose
   ```

4. **权限问题**
   ```bash
   # 给脚本添加执行权限
   chmod +x scripts/*.sh
   ```

### 日志查看

```bash
# 实时查看日志 (控制脚本模式)
./scripts/mock-server-control.sh logs

# 查看完整日志文件
tail -f /tmp/ops-portal-mock-server.log
```

## 🌐 访问Mock API

### 本地部署访问

启动成功后，可以通过以下方式访问Mock API：

```bash
# 查看API文档 (Swagger UI)
curl http://localhost:3000

# 测试API端点
curl http://localhost:3000/api/v1/auth/login
curl http://localhost:3000/api/v1/tickets
curl http://localhost:3000/api/v1/customers

# 查看OpenAPI规范
curl http://localhost:3000/__spec
```

### Docker部署访问

Docker版本提供多个服务端点：

```bash
# 全局API (端口3000)
curl http://localhost:3000/api/v1/auth/login

# 认证域API (端口3001)
curl http://localhost:3001/api/v1/auth/login

# 工单域API (端口3002)
curl http://localhost:3002/api/v1/tickets

# 客户模块API (端口3003)
curl http://localhost:3003/api/v1/customers

# 统一入口 - Nginx代理 (端口8080)
curl http://localhost:8080/api/v1/auth/login
curl http://localhost:8080/api/v1/tickets
curl http://localhost:8080/api/v1/customers
```

### 域名访问 (Docker + hosts配置)

在 `/etc/hosts` 中添加以下配置：

```
127.0.0.1 mock-global.localhost
127.0.0.1 mock-auth.localhost
127.0.0.1 mock-ticket.localhost
127.0.0.1 mock-customer.localhost
127.0.0.1 api.localhost
```

然后可以通过域名访问：

```bash
curl http://mock-global.localhost:8080
curl http://mock-auth.localhost:8080
curl http://mock-ticket.localhost:8080
curl http://mock-customer.localhost:8080
curl http://api.localhost:8080/api/v1/auth/login
```

## 🔄 集成到开发流程

### 1. 前端开发

```javascript
// 在前端项目中配置API基础URL
const API_BASE_URL = process.env.NODE_ENV === 'development' 
  ? 'http://localhost:3000' 
  : 'https://api.ops-portal.com';
```

### 2. 自动化测试

```bash
# 在测试脚本中启动Mock Server
./scripts/mock-server-control.sh start -p 3001
npm run test
./scripts/mock-server-control.sh stop
```

### 3. CI/CD 集成

```yaml
# GitHub Actions 示例
- name: Start Mock Server
  run: |
    ./scripts/mock-server-control.sh start -p 3000
    sleep 5

- name: Run Tests
  run: npm test

- name: Stop Mock Server
  run: ./scripts/mock-server-control.sh stop
```

## 📝 开发指南

### 添加新的API模块

1. 在 `docs/api/4.5.1/modules/` 下创建新模块目录
2. 添加 `openapi.yaml` 文件
3. 更新 `global-api-index.yaml` 中的引用
4. 重启Mock Server

### 自定义Mock数据

在OpenAPI规范中添加示例数据：

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: "张三"
```

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

## 📄 许可证

MIT License
