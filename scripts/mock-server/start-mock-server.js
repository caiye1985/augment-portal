#!/usr/bin/env node

/**
 * IT运维门户系统 Mock Server 启动脚本 (Node.js版本)
 * 基于 Prism CLI 启动 OpenAPI Mock Server
 * 支持全局API索引和模块独立API文件
 */

const fs = require('fs');
const path = require('path');
const { spawn, exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

// 默认配置
const DEFAULT_CONFIG = {
    port: 3000,
    host: '0.0.0.0',
    apiDocsDir: 'docs/api/4.5.1',
    cors: true,
    dynamic: false,
    errors: false,
    watch: false,
    verbose: false
};

// 颜色输出
const colors = {
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    reset: '\x1b[0m'
};

// 日志函数
const log = {
    info: (msg) => console.log(`${colors.blue}[INFO]${colors.reset} ${msg}`),
    success: (msg) => console.log(`${colors.green}[SUCCESS]${colors.reset} ${msg}`),
    warning: (msg) => console.log(`${colors.yellow}[WARNING]${colors.reset} ${msg}`),
    error: (msg) => console.log(`${colors.red}[ERROR]${colors.reset} ${msg}`)
};

// 显示帮助信息
function showHelp() {
    console.log(`
IT运维门户系统 Mock Server 启动脚本 (Node.js版本)

用法: node start-mock-server.js [选项]

选项:
  -p, --port <PORT>         指定端口号 (默认: ${DEFAULT_CONFIG.port})
  -h, --host <HOST>         指定主机地址 (默认: ${DEFAULT_CONFIG.host})
  -m, --module <MODULE>     启动特定模块的Mock Server
  -d, --domain <DOMAIN>     启动特定业务域的Mock Server
  -g, --global              启动全局聚合API Mock Server (默认)
  -l, --list                列出所有可用的模块和域
  -v, --verbose             详细输出模式
  -w, --watch               启用文件监控和热重载
  --cors                    启用CORS支持 (默认启用)
  --no-cors                 禁用CORS支持
  --dynamic                 启用动态响应模式
  --errors                  启用错误模拟
  --help                    显示此帮助信息

示例:
  node start-mock-server.js                                    # 启动全局API Mock Server
  node start-mock-server.js -p 3001                           # 在端口3001启动
  node start-mock-server.js -m REQ-016-客户关系管理模块        # 启动客户关系管理模块
  node start-mock-server.js -d auth                           # 启动认证业务域
  node start-mock-server.js -w --dynamic --errors             # 启用监控、动态响应和错误模拟
`);
}

// 列出可用模块和域
function listAvailable() {
    const modulesDir = path.join(DEFAULT_CONFIG.apiDocsDir, 'modules');
    const domainsDir = path.join(DEFAULT_CONFIG.apiDocsDir, 'domains');

    log.info('可用的业务模块:');
    if (fs.existsSync(modulesDir)) {
        const modules = fs.readdirSync(modulesDir)
            .filter(item => fs.statSync(path.join(modulesDir, item)).isDirectory())
            .filter(item => item.startsWith('REQ-'))
            .sort();
        
        modules.forEach(module => {
            console.log(`  - ${module}`);
        });
    } else {
        log.warning(`模块目录不存在: ${modulesDir}`);
    }

    console.log();
    log.info('可用的业务域:');
    if (fs.existsSync(domainsDir)) {
        const domains = fs.readdirSync(domainsDir)
            .filter(item => item.endsWith('-domain.yaml'))
            .map(item => item.replace('-domain.yaml', ''))
            .sort();
        
        domains.forEach(domain => {
            console.log(`  - ${domain}`);
        });
    } else {
        log.warning(`域目录不存在: ${domainsDir}`);
    }
}

// 检查依赖
async function checkDependencies() {
    log.info('检查依赖...');
    
    try {
        // 检查 Node.js
        const nodeVersion = process.version;
        log.success(`Node.js 版本: ${nodeVersion}`);
        
        // 检查 Prism CLI
        try {
            const { stdout } = await execAsync('prism --version');
            log.success(`Prism CLI 已安装: ${stdout.trim()}`);
        } catch (error) {
            log.warning('Prism CLI 未安装，正在安装...');
            try {
                await execAsync('npm install -g @stoplight/prism-cli');
                log.success('Prism CLI 安装成功');
            } catch (installError) {
                log.error('Prism CLI 安装失败');
                throw installError;
            }
        }
    } catch (error) {
        log.error(`依赖检查失败: ${error.message}`);
        process.exit(1);
    }
}

// 验证API文件
async function validateApiFile(apiFile) {
    if (!fs.existsSync(apiFile)) {
        log.error(`API文件不存在: ${apiFile}`);
        return false;
    }
    
    log.info(`验证API文件: ${apiFile}`);
    
    try {
        await execAsync(`prism validate "${apiFile}"`);
        log.success(`API文件验证通过: ${apiFile}`);
        return true;
    } catch (error) {
        log.warning(`API文件验证失败，但将继续启动: ${apiFile}`);
        return true;
    }
}

// 构建Prism命令参数
function buildPrismArgs(apiFile, config) {
    const args = ['mock', apiFile];
    
    // 端口和主机
    args.push('--port', config.port.toString());
    args.push('--host', config.host);
    
    // CORS支持
    if (config.cors) {
        args.push('--cors');
    }
    
    // 动态响应
    if (config.dynamic) {
        args.push('--dynamic');
    }
    
    // 错误模拟
    if (config.errors) {
        args.push('--errors');
    }
    
    // 文件监控
    if (config.watch) {
        args.push('--watch');
    }
    
    // 详细输出
    if (config.verbose) {
        args.push('--verbose');
    }
    
    return args;
}

// 启动Mock Server
async function startMockServer(apiFile, config, serverName) {
    log.info(`启动 ${serverName} Mock Server...`);
    log.info(`API文件: ${apiFile}`);
    log.info(`地址: http://${config.host}:${config.port}`);
    
    // 验证API文件
    const isValid = await validateApiFile(apiFile);
    if (!isValid) {
        process.exit(1);
    }
    
    // 构建命令参数
    const args = buildPrismArgs(apiFile, config);
    
    log.info(`执行命令: prism ${args.join(' ')}`);
    console.log();
    log.success('Mock Server 启动成功!');
    log.info(`访问地址: http://${config.host}:${config.port}`);
    log.info('按 Ctrl+C 停止服务器');
    console.log();
    
    // 启动Prism进程
    const prismProcess = spawn('prism', args, {
        stdio: 'inherit',
        shell: true
    });
    
    // 处理进程退出
    prismProcess.on('close', (code) => {
        if (code !== 0) {
            log.error(`Mock Server 退出，代码: ${code}`);
        } else {
            log.info('Mock Server 已停止');
        }
    });
    
    // 处理错误
    prismProcess.on('error', (error) => {
        log.error(`启动失败: ${error.message}`);
        process.exit(1);
    });
    
    // 处理中断信号
    process.on('SIGINT', () => {
        log.info('正在停止 Mock Server...');
        prismProcess.kill('SIGINT');
    });
    
    process.on('SIGTERM', () => {
        log.info('正在停止 Mock Server...');
        prismProcess.kill('SIGTERM');
    });
}

// 解析命令行参数
function parseArgs() {
    const args = process.argv.slice(2);
    const config = { ...DEFAULT_CONFIG };
    let module = '';
    let domain = '';
    let useGlobal = true;
    
    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        
        switch (arg) {
            case '-p':
            case '--port':
                config.port = parseInt(args[++i]);
                break;
            case '-h':
            case '--host':
                config.host = args[++i];
                break;
            case '-m':
            case '--module':
                module = args[++i];
                useGlobal = false;
                break;
            case '-d':
            case '--domain':
                domain = args[++i];
                useGlobal = false;
                break;
            case '-g':
            case '--global':
                useGlobal = true;
                break;
            case '-l':
            case '--list':
                listAvailable();
                process.exit(0);
                break;
            case '-v':
            case '--verbose':
                config.verbose = true;
                break;
            case '-w':
            case '--watch':
                config.watch = true;
                break;
            case '--cors':
                config.cors = true;
                break;
            case '--no-cors':
                config.cors = false;
                break;
            case '--dynamic':
                config.dynamic = true;
                break;
            case '--errors':
                config.errors = true;
                break;
            case '--help':
                showHelp();
                process.exit(0);
                break;
            default:
                log.error(`未知参数: ${arg}`);
                showHelp();
                process.exit(1);
        }
    }
    
    return { config, module, domain, useGlobal };
}

// 主函数
async function main() {
    try {
        const { config, module, domain, useGlobal } = parseArgs();
        
        // 检查依赖
        await checkDependencies();
        
        // 确定API文件和服务器名称
        let apiFile = '';
        let serverName = '';
        
        if (useGlobal) {
            apiFile = path.join(config.apiDocsDir, 'global-api-index.yaml');
            serverName = '全局API';
        } else if (module) {
            apiFile = path.join(config.apiDocsDir, 'modules', module, 'openapi.yaml');
            serverName = `模块 ${module}`;
        } else if (domain) {
            apiFile = path.join(config.apiDocsDir, 'domains', `${domain}-domain.yaml`);
            serverName = `业务域 ${domain}`;
        } else {
            log.error('必须指定全局API、模块或业务域');
            showHelp();
            process.exit(1);
        }
        
        // 启动Mock Server
        await startMockServer(apiFile, config, serverName);
        
    } catch (error) {
        log.error(`启动失败: ${error.message}`);
        process.exit(1);
    }
}

// 脚本入口
if (require.main === module) {
    main();
}

module.exports = {
    startMockServer,
    checkDependencies,
    validateApiFile,
    listAvailable
};
