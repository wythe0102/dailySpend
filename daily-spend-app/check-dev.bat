@echo off
title 开发环境状态检查
color 0E

echo 检查日常记账开发环境状态...
echo ========================================

echo 📅 检查时间: %date% %time%
echo.

:: 检查端口
echo 🔍 端口状态检查:
echo.

:: 后端端口8081
echo 后端服务 (端口8081):
netstat -ano | findstr ":8081" > nul
if %errorlevel% == 0 (
    echo   ✅ 端口8081已占用 - 后端服务运行中
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081"') do (
        tasklist /FI "PID eq %%a" 2>nul | findstr /v "信息" | findstr /v "="
    )
) else (
    echo   ❌ 端口8081未占用 - 后端服务未运行
)

echo.

:: 前端端口3000
echo 前端服务 (端口3000):
netstat -ano | findstr ":3000" > nul
if %errorlevel% == 0 (
    echo   ✅ 端口3000已占用 - 前端服务运行中
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
        tasklist /FI "PID eq %%a" 2>nul | findstr /v "信息" | findstr /v "="
    )
) else (
    echo   ❌ 端口3000未占用 - 前端服务未运行
)

echo.
echo 🌐 访问地址:
echo   前端: http://localhost:3000/daily-spends
echo   后端API: http://localhost:8081/api/daily-spends
echo   后端文档: http://localhost:8081/swagger-ui.html (如果启用)

echo.
echo 💡 使用说明:
echo   启动服务: 双击 start-dev.bat
echo   停止服务: 双击 stop-dev.bat
echo   检查状态: 双击 check-dev.bat
pause