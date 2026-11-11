@echo off
title Hungr Operations Web Command - Khammam Admin Portal
echo ====================================================================
echo        HUNGR OPERATIONS WEB COMMAND - KHAMMAM PORTAL
echo ====================================================================
echo Starting local web server on http://localhost:8080 ...
echo.

where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo Python detected. Launching web server at http://localhost:8080 ...
    start "" http://localhost:8080
    python -m http.server 8080
    goto end
)

where py >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo Python launcher detected. Launching web server at http://localhost:8080 ...
    start "" http://localhost:8080
    py -m http.server 8080
    goto end
)

echo Python not found in PATH. Opening standalone index.html directly in browser...
start "" "%~dp0index.html"

:end
