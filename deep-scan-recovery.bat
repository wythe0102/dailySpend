@echo off
chcp 65001 >nul
title MySQL深度数据恢复扫描
echo.
echo =============================================
echo    MySQL深度数据恢复扫描
echo =============================================
echo.

REM 设置变量
set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0"
set "DATA_DIR=%MYSQL_PATH%\Data\spend"
set "LOG_DIR=%MYSQL_PATH%\Data"
set "BACKUP_DIR=%USERPROFILE%\Documents\MySQL-Recovery"

REM 创建恢复目录
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo 🔍 开始深度扫描...
echo 扫描时间：%date% %time%
echo.

REM 1. 扫描MySQL数据目录
echo 【1】扫描MySQL数据目录...
echo 数据目录：%DATA_DIR%
echo.

if exist "%DATA_DIR%" (
    echo ✅ 找到数据库目录
    
    REM 扫描所有相关文件
    echo 扫描文件列表...
    dir "%DATA_DIR%" /s /b /od > "%BACKUP_DIR%\file-list.txt"
    
    REM 查找可能的旧数据文件
    echo 查找可能的旧数据文件...
    findstr /i "daily_spend" "%BACKUP_DIR%\file-list.txt" > "%BACKUP_DIR%\daily_spend-files.txt"
    
    REM 检查文件大小和时间
    echo 检查文件详细信息...
    for %%f in ("%DATA_DIR%\daily_spend.*") do (
        echo 文件：%%~nxf  大小：%%~zf字节  时间：%%~tf >> "%BACKUP_DIR%\file-details.txt"
    )
    
) else (
    echo ❌ 未找到数据库目录
)

REM 2. 检查Windows卷影复制
echo.
echo 【2】检查Windows卷影复制...
vssadmin list shadows /for=C: > "%BACKUP_DIR%\shadow-copies.txt" 2>nul
if %errorlevel% equ 0 (
    echo ✅ 卷影复制信息已保存到 shadow-copies.txt
) else (
    echo ⚠️ 无法访问卷影复制信息
)

REM 3. 检查系统还原点
echo.
echo 【3】检查系统还原点...
if exist "%SYSTEMROOT%\System32\rstrui.exe" (
    echo ✅ 系统还原功能可用
    echo 查看还原点列表...
    wmic shadowcopy list brief > "%BACKUP_DIR%\system-restore-points.txt"
) else (
    echo ⚠️ 系统还原功能不可用
)

REM 4. 扫描磁盘上的SQL文件
echo.
echo 【4】扫描磁盘上的SQL备份文件...
echo 扫描整个磁盘...
for /r C:\ %%f in (*.sql) do (
    echo 找到SQL文件：%%f  大小：%%~zf字节  时间：%%~tf >> "%BACKUP_DIR%\sql-backups.txt"
)

REM 5. 检查MySQL错误日志
echo.
echo 【5】检查MySQL错误日志...
if exist "%LOG_DIR%\mysql.err" (
    echo ✅ 找到错误日志
    powershell -Command "Get-Content '%LOG_DIR%\mysql.err' -Tail 100" > "%BACKUP_DIR%\mysql-errors.txt"
    
    REM 查找数据相关错误
    findstr /i "innodb\|error\|warning\|crash" "%LOG_DIR%\mysql.err" >> "%BACKUP_DIR%\mysql-critical-errors.txt"
) else (
    echo ❌ 未找到错误日志
)

REM 6. 检查MySQL配置文件
echo.
echo 【6】检查MySQL配置...
if exist "%MYSQL_PATH%\my.ini" (
    echo ✅ 找到配置文件
    copy "%MYSQL_PATH%\my.ini" "%BACKUP_DIR%\mysql-config.ini" >nul
    
    REM 查找关键配置
    findstr /i "datadir\|log-bin\|innodb" "%MYSQL_PATH%\my.ini" > "%BACKUP_DIR%\mysql-config-analysis.txt"
) else (
    echo ❌ 未找到配置文件
)

REM 7. 检查是否有旧版本数据
echo.
echo 【7】检查可能的旧版本数据...
echo 检查文件系统...

REM 使用PowerShell检查文件历史记录
powershell -Command "
$path = 'C:\ProgramData\MySQL\MySQL Server 8.0\Data\spend'
if (Test-Path $path) {
    Get-ChildItem $path -Recurse -File | Where-Object {$_.Name -like '*daily_spend*'} | 
    Select-Object Name, Length, LastWriteTime, CreationTime, Directory | 
    Export-Csv -Path '%BACKUP_DIR%\file-history.csv' -NoTypeInformation
    Write-Host '文件历史已保存到 file-history.csv'
}
" >nul 2>nul

REM 8. 创建恢复报告
echo.
echo 【8】创建恢复报告...
echo MySQL数据恢复扫描报告 > "%BACKUP_DIR%\recovery-report.txt"
echo ================================= >> "%BACKUP_DIR%\recovery-report.txt"
echo 扫描时间：%date% %time% >> "%BACKUP_DIR%\recovery-report.txt"
echo 扫描目录：%DATA_DIR% >> "%BACKUP_DIR%\recovery-report.txt"
echo. >> "%BACKUP_DIR%\recovery-report.txt"

REM 添加文件统计
if exist "%BACKUP_DIR%\file-details.txt" (
    echo 文件详情： >> "%BACKUP_DIR%\recovery-report.txt"
    type "%BACKUP_DIR%\file-details.txt" >> "%BACKUP_DIR%\recovery-report.txt"
)

REM 9. 检查恢复可能性
echo.
echo 【9】评估恢复可能性...
echo.
echo 恢复可能性评估：
echo.

REM 检查是否有足够信息恢复
if exist "%BACKUP_DIR%\sql-backups.txt" (
    for %%f in ("%BACKUP_DIR%\sql-backups.txt") do (
        if %%~zf gtr 100 (
            echo ✅ 找到SQL备份文件，恢复可能性高
        ) else (
            echo ⚠️ SQL备份文件较小，恢复可能性中等
        )
    )
)

if exist "%BACKUP_DIR%\shadow-copies.txt" (
    for %%f in ("%BACKUP_DIR%\shadow-copies.txt") do (
        if %%~zf gtr 500 (
            echo ✅ 找到系统还原点，恢复可能性高
        ) else (
            echo ⚠️ 系统还原点信息有限
        )
    )
)

REM 10. 生成恢复建议
echo.
echo 【10】生成恢复建议...
echo.
echo 恢复建议已保存到：%BACKUP_DIR%\recovery-advice.txt
echo.
echo 建议查看的文件：
echo 1. %BACKUP_DIR%\recovery-report.txt - 完整扫描报告
echo 2. %BACKUP_DIR%\sql-backups.txt - 所有SQL备份文件
echo 3. %BACKUP_DIR%\file-history.csv - 文件历史记录
echo 4. %BACKUP_DIR%\shadow-copies.txt - 系统还原点
echo.

echo =============================================
echo    深度扫描完成！
echo 扫描结果保存在：%BACKUP_DIR%
echo =============================================
echo.
echo 按任意键打开恢复目录...
pause >nul
start explorer "%BACKUP_DIR%"