@echo off
chcp 65001
echo.
echo =============================================
echo   MySQL数据恢复 - 一键执行版
echo =============================================
echo.

REM 检查Java环境
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未找到Java环境，请先安装Java
    pause
    exit /b 1
)

echo ✅ Java环境正常

REM 检查MySQL JDBC驱动
echo 检查MySQL驱动...
if exist "C:\Program Files\MySQL\MySQL Server 8.0\lib\mysql-connector-j-8.0.*.jar" (
    set "CLASSPATH=C:\Program Files\MySQL\MySQL Server 8.0\lib\mysql-connector-j-8.0.*.jar;.;"
) else if exist "C:\Program Files\MySQL\Connector J 8.0\mysql-connector-j-8.0.*.jar" (
    set "CLASSPATH=C:\Program Files\MySQL\Connector J 8.0\mysql-connector-j-8.0.*.jar;.;"
) else (
    echo ⚠️ 未找到MySQL驱动，尝试下载...
    powershell -Command "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar' -OutFile 'mysql-connector-java-8.0.33.jar'"
    set "CLASSPATH=mysql-connector-java-8.0.33.jar;.;"
)

echo ✅ 驱动配置完成

REM 编译并运行恢复工具
echo 正在编译恢复工具...
javac -cp "%CLASSPATH%" immediate-recovery.java
if %errorlevel% neq 0 (
    echo ❌ 编译失败，尝试简化版本...
    goto :simple_check
)

echo ✅ 编译成功，正在执行恢复检查...
java -cp "%CLASSPATH%" ImmediateRecovery

echo.
echo =============================================
echo   恢复检查完成！
echo =============================================
echo.
pause
exit /b

:simple_check
echo 使用简化检查...
echo 正在检查MySQL状态...

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -hlocalhost -uroot -proot -e "
USE spend;
SELECT '=== 数据状态检查 ===';
SELECT 
    'daily_spend表记录数：' as 描述, 
    COUNT(*) as 数量,
    MIN(date) as 最早记录,
    MAX(date) as 最新记录
FROM daily_spend;

SELECT 
    'users表记录数：' as 描述, 
    COUNT(*) as 数量 
FROM users;

SELECT 
    'type表记录数：' as 描述, 
    COUNT(*) as 数量 
FROM type;

SELECT '=== 检查二进制日志 ===';
SHOW VARIABLES LIKE 'log_bin';
SHOW BINARY LOGS;
"

echo.
echo 检查完成！
pause