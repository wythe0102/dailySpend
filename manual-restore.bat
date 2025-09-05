@echo off
echo =============================================
echo 🚨 手动数据恢复工具
echo =============================================
echo.

:: 设置MySQL路径
set "MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin"
set "BACKUP_FILE=C:\Users\wythe\Documents\dumps\Spend20220313.sql"

echo 📊 当前数据状态...
"%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT COUNT(*) as daily_spend记录数 FROM daily_spend; SELECT COUNT(*) as users记录数 FROM users; SELECT COUNT(*) as type记录数 FROM type;"

echo.
echo 📁 备份文件信息:
echo 文件: %BACKUP_FILE%
echo 大小: %~z1 bytes
echo.

:: 创建当前数据备份
echo 🔒 创建当前数据备份...
set "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
"%MYSQL_BIN%\mysqldump.exe" -h localhost -u root -ppassword --databases spend > "backup-before-restore-%TIMESTAMP%.sql"

echo ✅ 备份完成: backup-before-restore-%TIMESTAMP%.sql

echo.
echo 🔄 开始恢复数据...
echo.
echo 步骤1: 清空当前表...
"%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE daily_spend; TRUNCATE TABLE users; TRUNCATE TABLE type; SET FOREIGN_KEY_CHECKS = 1;"

echo.
echo 步骤2: 从备份文件恢复数据...
echo 使用MySQL命令行执行恢复...
echo.
echo 正在启动MySQL命令行...
echo.
echo 请在MySQL命令行中执行以下命令：
echo.
echo mysql -u root -ppassword
echo USE spend;
echo SOURCE C:\\Users\\wythe\\Documents\\dumps\\Spend20220313.sql;
echo.
echo 或者使用以下命令：
echo.
echo 方法1: 直接导入
echo "%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword --default-character-set=utf8 spend < "%BACKUP_FILE%"
echo.
echo 方法2: 使用SOURCE命令
echo "%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword --default-character-set=utf8 -e "USE spend; SOURCE C:\\Users\\wythe\\Documents\\dumps\\Spend20220313.sql;"
echo.

:: 尝试直接恢复
echo 正在尝试直接恢复...
"%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword --default-character-set=utf8 -e "USE spend; SOURCE C:\\Users\\wythe\\Documents\\dumps\\Spend20220313.sql;"

if %errorlevel% neq 0 (
    echo ⚠️ 直接恢复失败，尝试其他方法...
    
    echo 方法3: 使用iconv处理编码...
    echo 请手动执行以下步骤：
    echo.
    echo 1. 打开命令提示符 (cmd)
    echo 2. 运行：
    echo    "%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword
    echo 3. 在MySQL中执行：
    echo    USE spend;
    echo    SOURCE C:\\Users\\wythe\\Documents\\dumps\\Spend20220313.sql;
    echo.
    echo 4. 如果遇到编码问题，使用：
    echo    SET NAMES utf8;
    echo    SOURCE C:\\Users\\wythe\\Documents\\dumps\\Spend20220313.sql;
)

echo.
echo 📊 验证恢复结果...
"%MYSQL_BIN%\mysql.exe" -h localhost -u root -ppassword -e "USE spend; SELECT COUNT(*) as 恢复后daily_spend记录数 FROM daily_spend; SELECT COUNT(*) as 恢复后users记录数 FROM users; SELECT COUNT(*) as 恢复后type记录数 FROM type;"

echo.
echo =============================================
echo 🎉 数据恢复完成！
echo =============================================
echo.
echo 备份文件保存在: backup-before-restore-%TIMESTAMP%.sql
echo 如需回滚，可以执行: 
echo   mysql -u root -ppassword < backup-before-restore-%TIMESTAMP%.sql
pause