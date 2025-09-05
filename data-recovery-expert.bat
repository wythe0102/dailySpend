@echo off
chcp 65001 >nul
title MySQL数据恢复专家工具

:main
cls
echo.
echo =============================================
echo    MySQL数据恢复专家工具
echo =============================================
echo.
echo 当前时间：%date% %time%
echo.
echo 选择恢复方案：
echo.
echo [1] 检查当前数据状态
echo [2] 二进制日志恢复（binlog）
echo [3] InnoDB表空间恢复（ibd）
echo [4] 查找本地备份
echo [5] 检查Windows系统还原点
echo [6] 检查MySQL错误日志
echo [7] 创建紧急备份
echo [8] 专业数据恢复建议
echo [9] 退出
echo.
set /p choice=请输入选项(1-9): 

if "%choice%"=="1" goto :check_status
if "%choice%"=="2" goto :binlog_recovery
if "%choice%"=="3" goto :ibd_recovery
if "%choice%"=="4" goto :find_backup
if "%choice%"=="5" goto :system_restore
if "%choice%"=="6" goto :error_log
if "%choice%"=="7" goto :emergency_backup
if "%choice%"=="8" goto :expert_advice
if "%choice%"=="9" goto :exit

goto :main

:check_status
echo.
echo 🔍 检查当前数据状态...
echo.
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -hlocalhost -uroot -proot -e "
USE spend;
SELECT '=== 数据状态检查 ===';
SELECT 
    'daily_spend表记录数：' as 描述, 
    COUNT(*) as 数量,
    CONCAT('最早：', MIN(date)) as 最早记录,
    CONCAT('最新：', MAX(date)) as 最新记录
FROM daily_spend;

SELECT 
    'users表记录数：' as 描述, 
    COUNT(*) as 数量 
FROM users;

SELECT 
    'type表记录数：' as 描述, 
    COUNT(*) as 数量 
FROM type;

SELECT '=== 表结构信息 ===';
SELECT 
    table_name,
    table_rows,
    ROUND(data_length/1024/1024,2) as 数据大小_MB,
    create_time,
    update_time
FROM information_schema.tables 
WHERE table_schema = 'spend';
"
echo.
pause
goto :main

:binlog_recovery
echo.
echo 🔍 二进制日志恢复方案...
echo.
echo 检查二进制日志状态：
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -hlocalhost -uroot -proot -e "
SHOW VARIABLES LIKE 'log_bin';
SHOW BINARY LOGS;
"

echo.
echo 检查可用的binlog文件...
if exist "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql-bin.000001" (
    echo ✅ 找到binlog文件
    dir "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql-bin.*"
    
    echo.
    echo 查看最近的daily_spend相关操作：
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqlbinlog.exe" --start-datetime="2024-09-01 00:00:00" "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql-bin.000001" | findstr /i "daily_spend"
    
    echo.
    echo 恢复命令示例：
    echo mysqlbinlog --start-datetime="2024-09-03 00:00:00" --stop-datetime="2024-09-04 12:00:00" mysql-bin.000001 ^> recovery.sql
) else (
    echo ❌ 未找到binlog文件，可能未启用二进制日志
)
echo.
pause
goto :main

:ibd_recovery
echo.
echo 🔍 InnoDB表空间恢复方案...
echo.
echo 检查InnoDB文件：
echo MySQL数据目录：C:\ProgramData\MySQL\MySQL Server 8.0\Data

if exist "C:\ProgramData\MySQL\MySQL Server 8.0\Data\spend" (
    echo ✅ 找到数据库目录
    dir "C:\ProgramData\MySQL\MySQL Server 8.0\Data\spend\*.ibd" /s
    
    echo.
    echo 检查是否有旧的ibd文件：
    for /f "tokens=*" %%f in ('dir "C:\ProgramData\MySQL\MySQL Server 8.0\Data\spend\*.ibd" /s /b') do (
        echo 文件：%%f
        echo 大小：%%~zf 字节
        echo 修改时间：%%~tf
    )
    
    echo.
    echo ibd恢复步骤：
    echo 1. 停止MySQL服务：net stop MySQL80
    echo 2. 备份当前ibd文件
    echo 3. 替换为旧ibd文件
    echo 4. 启动MySQL服务：net start MySQL80
    echo 5. 执行表修复：ALTER TABLE daily_spend IMPORT TABLESPACE;
) else (
    echo ❌ 未找到数据库目录
)
echo.
pause
goto :main

:find_backup
echo.
echo 🔍 查找本地备份...
echo.
echo 检查当前目录备份：
for /r %%f in (*.sql) do (
    echo 找到SQL文件：%%~nxf (%%~tf)
)

echo.
echo 检查MySQL备份目录：
if exist "C:\ProgramData\MySQL\MySQL Server 8.0\Backups" (
    dir "C:\ProgramData\MySQL\MySQL Server 8.0\Backups\*.sql" /s
) else (
    echo 未找到MySQL备份目录
)

echo.
echo 检查Windows备份：
vssadmin list shadows /for=C: 2>nul
if %errorlevel% equ 0 (
    echo ✅ 找到系统还原点
) else (
    echo 未找到系统还原点
)
echo.
pause
goto :main

:system_restore
echo.
echo 🔍 Windows系统还原点检查...
echo.
echo 检查系统还原点：
vssadmin list shadows /for=C:

echo.
echo 检查卷影复制：
shadowcopy list

echo.
echo 恢复步骤：
echo 1. 右键点击数据库文件夹
echo 2. 选择"还原以前的版本"
echo 3. 选择包含数据的还原点
echo 4. 复制旧数据文件
echo.
pause
goto :main

:error_log
echo.
echo 🔍 检查MySQL错误日志...
echo.
echo MySQL错误日志位置：
echo C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql.err

if exist "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql.err" (
    echo ✅ 找到错误日志
    echo.
    echo 查看最近错误：
    powershell -Command "Get-Content 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql.err' -Tail 20"
    
    echo.
    echo 查找数据相关错误：
    findstr /i "error\|warning\|innodb" "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql.err" | tail -20
) else (
    echo ❌ 未找到错误日志
)
echo.
pause
goto :main

:emergency_backup
echo.
echo 🔍 创建紧急备份...
echo.
echo 正在创建完整备份...
set "BACKUP_FILE=emergency-backup-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%.sql"
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" -hlocalhost -uroot -proot --databases spend --routines --triggers --events > "d:\github\dailySpend\%BACKUP_FILE%"

if %errorlevel% equ 0 (
    echo ✅ 紧急备份创建成功：%BACKUP_FILE%
) else (
    echo ❌ 备份创建失败
)
echo.
pause
goto :main

:expert_advice
echo.
echo 📋 专业数据恢复建议
echo.
echo 当前数据丢失情况分析：
echo.
echo 【紧急措施】
echo 1. 立即停止使用该数据库
echo 2. 创建完整备份（即使数据不完整）
echo 3. 检查是否有其他应用访问数据库
echo.
echo 【恢复方案优先级】
echo 1. 二进制日志恢复（如果启用）
echo 2. 系统还原点恢复
echo 3. 专业数据恢复工具
echo 4. 联系数据恢复服务
echo.
echo 【专业工具推荐】
echo • MySQL Enterprise Backup
echo • Percona XtraBackup
echo • 数据恢复软件：R-Studio, EaseUS Data Recovery
echo.
echo 【联系支持】
echo • MySQL官方支持
echo • 专业数据恢复公司
echo • 数据库管理员社区
pause
goto :main

:exit
echo.
echo 数据恢复工具退出
echo 如需帮助，请保留当前状态并联系专业人士
pause