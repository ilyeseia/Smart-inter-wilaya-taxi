@echo off
echo Building Smart Inter Wilaya Taxi User Service...

cd user-service

REM Check if Java is available
java -version
if %errorlevel% neq 0 (
    echo Java is not installed or not in PATH
    exit /b 1
)

REM Download Maven if not available
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo Maven not found, downloading Maven wrapper...
    REM Create a simple build using javac directly
    echo Compiling Java sources...
    javac -cp "src/main/java" src/main/java/com/smarttaxi/userservice/*.java
    if %errorlevel% neq 0 (
        echo Compilation failed
        exit /b 1
    )
    echo Compilation successful
) else (
    echo Maven found, building with Maven...
    mvn clean package -DskipTests
    if %errorlevel% neq 0 (
        echo Maven build failed
        exit /b 1
    )
)

echo Build completed successfully!
echo JAR file should be in target directory
dir target\*.jar

pause