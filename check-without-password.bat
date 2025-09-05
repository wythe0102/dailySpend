@echo off
chcp 65001
echo.
echo =============================================
echo   MySQL数据恢复 - 无密码检查版
echo =============================================
echo.

REM 检查MySQL服务状态
echo 检查MySQL服务状态...
sc query MySQL80 >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL80服务未找到，检查其他服务...
    sc query mysql >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ MySQL服务未运行
        goto :check_files
    ) else (
        echo ✅ MySQL服务正在运行
        set "SERVICE_NAME=mysql"
    )
) else (
    echo ✅ MySQL80服务正在运行
    set "SERVICE_NAME=MySQL80"
)

echo.

:check_files
echo 检查数据文件...
echo.

REM 检查MySQL数据目录
set "DATA_PATH=C:\ProgramData\MySQL\MySQL Server 8.0\Data\spend"
if exist "%DATA_PATH%" (
    echo ✅ 找到数据库目录: %DATA_PATH%
    
    REM 检查daily_spend相关文件
    echo.
    echo daily_spend相关文件:
    dir "%DATA_PATH%\daily_spend*" /s
    
    echo.
    echo 文件详情:
    for %%f in ("%DATA_PATH%\daily_spend.*") do (
        echo   %%~nxf - 大小: %%~zf bytes - 修改时间: %%~tf
    )
    
    REM 检查是否有备份文件
    echo.
    echo 检查可能的备份文件:
    for /r "%DATA_PATH%" %%f in (*.ibd *.frm *.ibk) do (
        echo   找到文件: %%f - 大小: %%~zf bytes - 时间: %%~tf
    )
    
) else (
    echo ❌ 未找到默认数据目录，检查其他位置...
    
    REM 检查其他常见位置
    set "OTHER_PATHS=C:\Program Files\MySQL\MySQL Server 8.0\Data\spend C:\xampp\mysql\data\spend C:\wamp\bin\mysql\mysql*\data\spend"
    for %%p in (%OTHER_PATHS%) do (
        if exist "%%p" (
            echo ✅ 找到数据目录: %%p
            dir "%%p\daily_spend*" /s
        )
    )
)

echo.
echo 检查本地备份文件...
for /r . %%f in (*.sql *.bak *.dump) do (
    echo 找到备份: %%~nxf - 大小: %%~zf bytes - 时间: %%~tf
)

echo.
echo 检查Windows系统还原点...
vssadmin list shadows /for=C: > recovery-shadows.txt 2>&1
if exist recovery-shadows.txt (
    echo ✅ 系统还原点信息已保存到 recovery-shadows.txt
    type recovery-shadows.txt | findstr "Shadow Copy"
)

echo.
echo =============================================
echo 下一步操作：
echo =============================================
echo.
echo 1. 检查MySQL密码是否正确
echo 2. 使用MySQL Workbench连接检查数据
echo 3. 手动检查数据文件：
echo    C:\ProgramData\MySQL\MySQL Server 8.0\Data\spend\
echo 4. 检查是否有系统还原点
echo 5. 查找本地SQL备份文件

pause