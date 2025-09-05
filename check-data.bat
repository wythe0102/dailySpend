@echo off
echo 正在检查MySQL数据库中的数据...
echo.

set CLASSPATH=.;%USERPROFILE%\.m2\repository\mysql\mysql-connector-java\8.0.33\mysql-connector-java-8.0.33.jar

javac -cp "%CLASSPATH%" check-data.java
if %errorlevel% neq 0 (
    echo 编译失败，请确保已安装JDK
    pause
    exit /b 1
)

java -cp ".;%CLASSPATH%" CheckData

echo.
echo 检查完成！
pause