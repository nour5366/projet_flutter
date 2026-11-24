@echo off
echo ========================================================
echo Demarrage du Backend Spring Boot (Scol_A7) sur le port 8081
echo ========================================================
cd /d "%~dp0backend"
java -jar "target\Scol_A7-0.0.1-SNAPSHOT.jar"
pause
