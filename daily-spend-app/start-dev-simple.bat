@echo off
:: ==========================================================================
:: 日常记账系统 - 简化版开发环境启动器
:: 这个脚本提供了更直接的启动方式和详细的调试信息
:: ==========================================================================

:: 设置UTF-8编码
chcp 65001 > nul

echo ========================================
echo    日常记账系统 - 简化版开发环境启动器
echo ========================================

echo 📋 脚本信息：
echo - 这是一个简化版的启动脚本，专注于解决Maven环境问题
echo - 提供更详细的调试信息，帮助排查启动失败原因

echo.
:: ==========================================================================
:: 请根据您的实际安装情况修改下面的Maven路径
:: 例如: set "MAVEN_HOME=C:\Program Files\Apache\maven-3.8.6"
set "MAVEN_HOME=D:\apache-maven-3.6.0"
:: ==========================================================================

:: 如果设置了MAVEN_HOME，则将其添加到PATH
if not "%MAVEN_HOME%" == "" (
    set "PATH=%MAVEN_HOME%\bin;%PATH%"
    echo 📌 已添加Maven路径: %MAVEN_HOME%
) else (
    echo ⚠️  未设置MAVEN_HOME，将使用系统环境变量中的Maven
)

echo.
echo ========================================
echo          🔍 环境检测

echo.
echo 🔧 检查Maven环境...
:: 显示当前PATH
set "PATH=%PATH%"
echo 当前PATH: %PATH%

echo.
:: 查找Maven命令
where mvn > nul 2>&1
if %errorlevel% == 0 (
    echo ✅ 在PATH中找到Maven命令:
    where mvn
    mvn --version | findstr "Apache Maven"
) else (
    echo ❌ 在PATH中未找到Maven命令
    echo ℹ️  请确认Maven已正确安装并添加到系统环境变量
)

echo.
echo 🔧 检查Node.js环境...
node --version > nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未检测到Node.js环境
    echo ℹ️  请先安装Node.js
    pause
    exit /b 1
) else (
    echo ✅ Node.js环境检测通过
    node --version
)

echo.
echo ========================================
echo          🚀 启动服务

echo.
echo 🏃‍♂️ 正在启动后端服务...
start cmd /k "title 后端服务 && color 0B && echo 正在启动Spring Boot后端... && cd /d "%~dp0" && echo 当前目录: %~dp0 && echo 使用的Maven命令: mvn && mvn spring-boot:run"

echo ⏳ 等待后端服务启动... (20秒)
timeout /t 20 /nobreak > nul

echo.
echo 🏃‍♂️ 正在启动前端服务...
start cmd /k "title 前端服务 && color 0C && echo 正在启动Vite前端... && cd /d "%~dp0src\main\resources\static" && echo 当前目录: %~dp0src\main\resources\static && npm run dev"

echo ⏳ 等待前端服务启动... (10秒)
timeout /t 10 /nobreak > nul

echo.
echo ========================================
echo          🎉 启动完成！
echo ========================================
echo 📱 前端地址: http://localhost:3000/daily-spends
echo ⚙️  后端API: http://localhost:8081/api
echo 📝 数据库: 内置H2数据库
echo.
echo 💡 提示：
echo - 请查看后端和前端的命令窗口，确认服务是否正常启动
echo - 如果Maven命令执行失败，请检查上面的环境检测信息
echo - 关闭本窗口不会停止服务，请手动关闭各个命令窗口以停止服务
echo.
pause