@echo off
rem ------------------------------------------------------------
rem Build and run SmartInventory project
rem ------------------------------------------------------------

rem Set Java Home (adjust if your JDK path differs)
set "JAVA_HOME=C:\Program Files\Java\jdk-21"

rem Add Java and Maven to PATH
set "MAVEN_HOME=%~dp0maven\apache-maven-3.9.6"
set "PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%"

rem Disable SSL certificate validation for Maven (temporary workaround)
set "MAVEN_OPTS=-Dmaven.wagon.http.ssl.insecure=true"

rem Change to project directory
cd /d "%~dp0"

rem Clean and package the project (skip tests for speed)
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo Build failed with error %errorlevel%.
    exit /b %errorlevel%
)

rem Run the web application using embedded Jetty
call mvn jetty:run
if %errorlevel% neq 0 (
    echo Jetty failed with error %errorlevel%.
    exit /b %errorlevel%
)

rem End of script
