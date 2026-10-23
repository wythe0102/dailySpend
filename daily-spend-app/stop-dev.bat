@echo off
title 停止开发环境服务
color 0C

echo 正在停止日常记账开发环境服务...
echo ========================================

:: 查找并停止Java进程(Spring Boot)
echo 🔍 查找Spring Boot进程...
tasklist /FI "IMAGENAME eq java.exe" /FI "WINDOWTITLE eq *后端服务*" 2>nul | findstr /i "java.exe" >nul
if %errorlevel% == 0 (
    echo 🛑 停止后端服务...
    taskkill /f /im java.exe 2>nul
    echo ✅ 后端服务已停止
) else (
    echo ℹ️  后端服务未运行
)

:: 查找并停止Node进程(Vite)
echo 🔍 查找Node.js进程...
tasklist /FI "IMAGENAME eq node.exe" /FI "WINDOWTITLE eq *前端服务*" 2>nul | findstr /i "node.exe" >nul
if %errorlevel% == 0 (
    echo 🛑 停止前端服务...
    taskkill /f /im node.exe 2>nul
    echo ✅ 前端服务已停止
) else (
    echo ℹ️  前端服务未运行
)

:: 清理CMD窗口
echo 🔍 清理残留窗口...
taskkill /f /fi "windowtitle eq 后端服务*" 2>nul
taskkill /f /fi "windowtitle eq 前端服务*" 2>nul

echo.
echo ========================================
echo    ✅ 所有服务已停止！
echo ========================================
pause