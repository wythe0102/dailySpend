@echo off
:: ==========================================================================
:: 请根据您的实际安装情况修改下面的Maven路径
:: 例如: set "MAVEN_HOME=C:\Program Files\Apache\maven-3.8.6"
set "MAVEN_HOME="
:: ==========================================================================

:: 如果设置了MAVEN_HOME，则将其添加到PATH
echo 🔍 检查Maven路径设置...
if not "%MAVEN_HOME%" == "" (
    set "PATH=%MAVEN_HOME%\bin;%PATH%"
    echo ℹ️  已添加Maven路径: %MAVEN_HOME%
)

title 日常记账开发环境启动
color 0A

echo ========================================
echo    日常记账系统开发环境启动器
echo ========================================

:: 设置UTF-8编码
chcp 65001 > nul

:: 获取当前脚本所在目录
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo 📁 当前工作目录: %SCRIPT_DIR%

:: 检查Maven
echo 🔍 检查Maven环境...
:: 优先检查系统环境变量中的Maven
mvn --version > nul 2>&1
if errorlevel 1 (
    :: 如果系统中没有Maven，检查当前目录下的Maven包装器
    if not exist "%SCRIPT_DIR%mvnw.cmd" (
        echo ❌ 错误: 未检测到Maven环境
        pause
        exit /b 1
    )
    echo ℹ️  使用当前目录的Maven包装器
) else (
    echo ✅ 系统Maven环境检测通过
)
echo ✅ Maven环境检测通过

:: 检查Node.js
echo 🔍 检查Node.js环境...
node --version > nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未检测到Node.js环境
    pause
    exit /b 1
)
echo ✅ Node.js环境检测通过

:: 检查端口
echo 🔍 检查端口占用...
netstat -ano | findstr ":8081" > nul
if %errorlevel% == 0 (
    echo ⚠️  端口8081已被占用，可能是后端服务已在运行
)

netstat -ano | findstr ":3000" > nul
if %errorlevel% == 0 (
    echo ⚠️  端口3000已被占用，可能是前端服务已在运行
)

:: 启动后端服务
echo.
echo 🚀 正在启动后端服务...
start cmd /k "title 后端服务:8081 && color 0B && echo 正在启动Spring Boot后端... && cd /d "%SCRIPT_DIR%" && mvn spring-boot:run"

:: 等待后端启动
echo ⏳ 等待后端服务启动... (15秒)
timeout /t 15 /nobreak > nul

:: 启动前端服务
echo.
echo 🚀 正在启动前端服务...
start cmd /k "title 前端服务:3000 && color 0C && echo 正在启动Vite前端... && cd /d "%SCRIPT_DIR%src\main\resources\static" && npm run dev"

:: 等待前端启动
echo ⏳ 等待前端服务启动... (8秒)
timeout /t 8 /nobreak > nul

echo.
echo ========================================
echo    🎉 开发环境启动完成！
echo ========================================
echo 📱 前端地址: http://localhost:3000/daily-spends
echo ⚙️  后端API: http://localhost:8081/api
echo 📝 数据库: 内置H2数据库
echo.
echo 💡 提示：关闭本窗口不会停止服务，请使用 stop-dev.bat 停止服务
echo.
pause