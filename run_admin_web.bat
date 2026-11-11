@echo off
echo ========================================================
echo  HUNGR OPERATIONS WEB COMMAND - KHAMMAM MORNING ENGINE
echo ========================================================
echo  Opening web server on: http://localhost:8080
echo  Press Ctrl+C to stop the server
echo ========================================================
cd /d "%~dp0\web_admin"
python -m http.server 8080
