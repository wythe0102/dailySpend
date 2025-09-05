@echo off
chcp 65001 >nul
echo.
echo =============================================
echo   MySQL真实数据恢复方案 - 专业版
echo =============================================
echo.

REM 设置MySQL路径
set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin"
set "MYSQL_CMD=%MYSQL_PATH%\mysql.exe"
set "MYSQL_DUMP=%MYSQL_PATH%\mysqldump.exe"
set "MYSQL_DATA_DIR=C:\ProgramData\MySQL\MySQL Server 8.0\Data"

REM 检查MySQL命令
if not exist "%MYSQL_CMD%" (
    echo ❌ 未找到MySQL命令，请确认安装路径：%MYSQL_PATH%
    pause
    exit /b 1
)

echo ✅ 找到MySQL命令：%MYSQL_CMD%
echo.

REM 1. 立即备份当前状态
echo 🔍 步骤1：创建当前状态备份...
set "BACKUP_FILE=recovery-backup-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.sql"
"%MYSQL_DUMP%" -hlocalhost -uroot -proot --databases spend > "d:\github\dailySpend\%BACKUP_FILE%"
if %errorlevel% neq 0 (
    echo ⚠️ 备份失败，继续检查...
) else (
    echo ✅ 已创建备份：%BACKUP_FILE%
)

echo.

REM 2. 检查数据库状态
echo 🔍 步骤2：检查当前数据库状态...
echo.
echo 数据库列表：
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "SHOW DATABASES;"

echo.
echo 表状态检查：
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "USE spend; SELECT 'daily_spend表记录数：', COUNT(*) FROM daily_spend;"
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "USE spend; SELECT 'users表记录数：', COUNT(*) FROM users;"
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "USE spend; SELECT 'type表记录数：', COUNT(*) FROM type;"

echo.

REM 3. 检查二进制日志
echo 🔍 步骤3：检查二进制日志状态...
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "SHOW VARIABLES LIKE 'log_bin';"
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "SHOW BINARY LOGS;"

echo.

REM 4. 检查数据文件
echo 🔍 步骤4：检查数据文件...
echo MySQL数据目录：%MYSQL_DATA_DIR%
if exist "%MYSQL_DATA_DIR%\spend" (
    echo ✅ 找到数据库目录：%MYSQL_DATA_DIR%\spend
    dir "%MYSQL_DATA_DIR%\spend\daily_spend*" /s
) else (
    echo ⚠️ 未找到数据库目录
)

echo.

REM 5. 检查可能的恢复源
echo 🔍 步骤5：寻找可恢复的数据源...
echo.

REM 检查是否有旧备份
echo 检查本地备份文件...
for %%f in ("d:\github\dailySpend\*.sql") do (
    echo 找到备份文件：%%~nxf
)

REM 检查MySQL备份目录
if exist "%MYSQL_DATA_DIR%..\Backups" (
    echo 找到MySQL备份目录：%MYSQL_DATA_DIR%..\Backups
    dir "%MYSQL_DATA_DIR%..\Backups\*.sql" /s
)

echo.

REM 6. 执行恢复检查
echo 🔍 步骤6：执行详细恢复检查...
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "USE spend; SOURCE d:\github\dailySpend\real-recovery-plan.sql;"

echo.
echo =============================================
echo   恢复选项：
echo =============================================
echo.
echo 选项1：从二进制日志恢复（如果启用）
echo 选项2：从ibd文件恢复（检查旧版本）
echo 选项3：从备份文件恢复（查找本地备份）
echo 选项4：检查Windows系统还原点
echo.

set /p choice=请选择恢复选项(1-4)或直接回车查看详细信息：

if "%choice%"=="1" goto :binlog_recovery
if "%choice%"=="2" goto :ibd_recovery
if "%choice%"=="3" goto :backup_recovery
if "%choice%"=="4" goto :system_restore

goto :detailed_check

:binlog_recovery
echo.
echo 正在检查二进制日志恢复...
"%MYSQL_CMD%" -hlocalhost -uroot -proot -e "SHOW BINARY LOGS;"
echo 使用mysqlbinlog工具查看可恢复时间点...
"%MYSQL_PATH%\mysqlbinlog.exe" --start-datetime="2024-09-01 00:00:00" "C:\ProgramData\MySQL\MySQL Server 8.0\Data\mysql-bin.000001" | findstr "daily_spend"
goto :end

:ibd_recovery
echo.
echo 检查ibd文件恢复...
echo 查找可能的旧ibd文件...
dir "%MYSQL_DATA_DIR%\spend\*.ibd" /s
echo 如需ibd恢复，需要：
echo 1. 停止MySQL服务
echo 2. 替换旧的ibd文件
echo 3. 执行表修复
pause
goto :end

:backup_recovery
echo.
echo 检查本地备份恢复...
echo 查找可用的备份文件...
for /r %%f in (*.sql) do (
    echo 找到备份：%%f
    set /p restore=是否恢复此备份？(y/n): 
    if /i "!restore!"=="y" (
        echo 正在恢复：%%f
        "%MYSQL_CMD%" -hlocalhost -uroot -proot < "%%f"
        goto :end
    )
)
goto :end

:system_restore
echo.
echo 检查Windows系统还原点...
echo 这可能包含旧的MySQL数据...
vssadmin list shadows /for=C:
goto :end

:detailed_check
echo.
echo 详细检查完成！
echo.
echo 下一步建议：
echo 1. 检查MySQL错误日志：%MYSQL_DATA_DIR%\mysql.err
echo 2. 检查Windows事件查看器中的MySQL相关事件
echo 3. 使用数据恢复工具扫描磁盘
echo 4. 联系专业数据恢复服务

:end
echo.
echo 恢复检查完成！
pause