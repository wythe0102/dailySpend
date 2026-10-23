# 日常记账系统开发环境使用指南

## 🚀 快速开始

### 一键启动开发环境

在项目根目录下，我们为您准备了3个一键脚本：

#### 1. 启动开发环境
```bash
双击运行: start-dev.bat
```
- 自动检查环境依赖
- 启动后端服务 (端口8081)
- 启动前端服务 (端口3000)
- 自动打开浏览器访问前端页面

#### 2. 停止所有服务
```bash
双击运行: stop-dev.bat
```
- 一键停止所有相关进程
- 清理Java和Node.js进程

#### 3. 检查服务状态
```bash
双击运行: check-dev.bat
```
- 检查端口占用情况
- 显示服务运行状态
- 提供访问地址

## 📁 文件结构

```
daily-spend-app/
├── start-dev.bat      # 启动开发环境
├── stop-dev.bat       # 停止所有服务
├── check-dev.bat      # 检查服务状态
├── README-DEV.md      # 开发环境文档
├── src/
│   ├── main/
│   │   ├── java/      # 后端Java代码
│   │   └── resources/ # 配置文件
│   │       └── static/ # 前端代码
└── pom.xml           # Maven配置
```

## 🔧 环境要求

### 必需软件
- **Java 8+** (推荐Java 11或17)
- **Maven 3.6+** (已包含Maven Wrapper)
- **Node.js 14+** (推荐16或18)
- **npm** (通常随Node.js安装)

### 端口配置
- **后端服务**: http://localhost:8081
- **前端服务**: http://localhost:3000

## 🌐 访问地址

启动成功后，您可以通过以下地址访问：

- **前端页面**: http://localhost:3000/daily-spends
- **后端API**: http://localhost:8081/api/daily-spends
- **Swagger文档**: http://localhost:8081/swagger-ui.html

## 🐛 常见问题

### 端口被占用
如果端口被占用，请：
1. 运行 `check-dev.bat` 查看占用情况
2. 运行 `stop-dev.bat` 停止占用进程
3. 重新运行 `start-dev.bat`

### 服务启动失败
1. **检查环境**: 确保Java、Maven、Node.js已正确安装
2. **查看日志**: 检查启动窗口中的错误信息
3. **重启服务**: 先运行 `stop-dev.bat`，再运行 `start-dev.bat`

### 前端依赖问题
如果前端依赖未安装：
```bash
cd daily-spend-app/src/main/resources/static
npm install
```

## 📱 使用流程

1. **首次使用**: 双击 `start-dev.bat`
2. **日常开发**: 双击 `start-dev.bat`
3. **结束工作**: 双击 `stop-dev.bat`
4. **状态检查**: 双击 `check-dev.bat`

## 📝 开发提示

- 后端使用Spring Boot，支持热重载
- 前端使用Vite，支持快速热更新
- 数据库使用H2内存数据库，重启后数据会重置
- 所有日志会在启动窗口中显示

## 🎯 快捷操作

- **Win + R**: 输入 `cmd` 打开命令行
- **Ctrl + C**: 在启动窗口中停止服务
- **Alt + Tab**: 快速切换窗口