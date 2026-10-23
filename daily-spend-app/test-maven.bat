@echo off
chcp 65001 > nul
echo 测试Maven环境...
mvn --version
echo.
echo Maven命令执行完毕，错误代码：%errorlevel%
pause