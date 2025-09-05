@echo off
chcp 65001
echo.
echo =============================================
echo   🚨 紧急二进制日志恢复 🚨
echo =============================================
echo.
echo 当前时间: %date% %time%
echo.

REM 设置MySQL路径
set "MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin"
set "DATA_DIR=C:\ProgramData\MySQL\MySQL Server 8.0\Data"

REM 1. 立即创建当前状态备份
echo 🔍 步骤1: 创建紧急备份...
set "BACKUP_TIME=%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%"
set "BACKUP_DIR=recovery-backup-%BACKUP_TIME%"
mkdir "%BACKUP_DIR%"

"%MYSQL_BIN%\mysqldump.exe" -h localhost -u root -ppassword --databases spend > "%BACKUP_DIR%\spend-backup-%BACKUP_TIME%.sql"
if %errorlevel% equ 0 (
    echo ✅ 备份创建成功: %BACKUP_DIR%\spend-backup-%BACKUP_TIME%.sql
) else (
    echo ⚠️ 备份创建失败，继续恢复...
)

echo.

REM 2. 分析二进制日志
echo 🔍 步骤2: 分析二进制日志...
echo.

echo 检查可用的二进制日志...
"%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword -e "SHOW BINARY LOGS;"

echo.
echo 查找daily_spend相关操作...
echo.

REM 检查最近的日志文件中的操作
echo 检查最近的删除操作...
for %%f in ("%DATA_DIR%\WYTHE-DESKTOP-bin.*") do (
    echo 分析文件: %%~nxf
    "%MYSQL_BIN%\mysqlbinlog.exe" "%%f" | findstr /i /c:"DELETE FROM daily_spend" /c:"TRUNCATE TABLE daily_spend" /c:"DROP TABLE daily_spend" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ 在 %%~nxf 中找到删除操作！
        echo 详细分析: %%~nxf
        "%MYSQL_BIN%\mysqlbinlog.exe" "%%f" | findstr /n /i /c:"daily_spend" /c:"DELETE" /c:"TRUNCATE" /c:"DROP"
        goto :found_operations
    )
)

echo.
echo 🔍 步骤3: 生成恢复SQL...
echo.

REM 3. 生成恢复SQL
echo 从二进制日志提取插入操作...
set "RECOVERY_FILE=%BACKUP_DIR%\recovery-from-binlog.sql"
echo -- 从二进制日志恢复的daily_spend数据 > "%RECOVERY_FILE%"
echo -- 恢复时间: %date% %time% >> "%RECOVERY_FILE%"
echo. >> "%RECOVERY_FILE%"

REM 查找包含插入操作的日志文件
echo 正在提取插入操作...
for %%f in ("%DATA_DIR%\WYTHE-DESKTOP-bin.*") do (
    "%MYSQL_BIN%\mysqlbinlog.exe" --start-datetime="2024-08-25 00:00:00" --stop-datetime="2024-08-26 23:59:59" "%%f" | findstr /i "INSERT INTO daily_spend" >> "%RECOVERY_FILE%" 2>nul
)

REM 4. 检查恢复文件大小
if exist "%RECOVERY_FILE%" (
    for %%f in ("%RECOVERY_FILE%") do (
        if %%~zf gtr 100 (
            echo ✅ 找到可恢复数据！文件大小: %%~zf bytes
            echo 恢复文件: %RECOVERY_FILE%
            
            REM 5. 执行恢复
            echo.
            echo 🔍 步骤4: 执行恢复...
            echo.
            echo 准备执行恢复...
            echo 当前daily_spend记录数:
            "%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT COUNT(*) as 当前记录数 FROM daily_spend;"
            
            echo.
            set /p confirm=确认执行恢复？(y/n): 
            if "%confirm%"=="y" (
                echo 执行恢复...
                "%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword < "%RECOVERY_FILE%"
                echo ✅ 恢复完成！
                echo 恢复后记录数:
                "%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT COUNT(*) as 恢复后记录数 FROM daily_spend;"
            ) else (
                echo 恢复已取消，手动检查恢复文件: %RECOVERY_FILE%
            )
            
            goto :recovery_complete
        ) else (
            echo ⚠️ 恢复文件较小，可能需要检查更多日志
        )
    )
) else (
    echo ⚠️ 未找到可恢复数据
)

:found_operations
echo.
echo 🔍 发现删除操作！正在分析时间点...
echo.

REM 手动恢复步骤
echo 手动恢复步骤:
echo 1. 查看完整日志:
echo    mysqlbinlog --start-datetime="2024-08-25 00:00:00" --stop-datetime="2024-08-26 23:59:59" WYTHE-DESKTOP-bin.000911 ^> full-recovery.sql
echo.
echo 2. 提取特定时间点:
echo    mysqlbinlog --start-datetime="2024-08-25 19:00:00" --stop-datetime="2024-08-25 19:30:00" WYTHE-DESKTOP-bin.000911 ^> specific-recovery.sql
echo.
echo 3. 执行恢复:
echo    mysql -u root -ppassword < recovery.sql

:recovery_complete
echo.
echo =============================================
echo   恢复完成！
echo =============================================
echo.
echo 备份和恢复文件保存在: %BACKUP_DIR%
echo.
echo 下一步:
echo 1. 检查恢复结果
echo 2. 验证数据完整性
echo 3. 创建新的完整备份
pause

REM 打开恢复目录
start explorer "%BACKUP_DIR%"