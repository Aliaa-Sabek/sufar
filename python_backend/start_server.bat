@echo off
title Sufar AI Travel Planner - Server
color 0A
echo ============================================
echo   Sufar AI Travel Planner - Server Running
echo ============================================
echo.
echo Server is running at: http://127.0.0.1:5000
echo Open your browser and go to that address.
echo.
echo DO NOT close this window while using the app.
echo To stop the server, close this window.
echo.
cd /d "%~dp0"
python app.py
pause
