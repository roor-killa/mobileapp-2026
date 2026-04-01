@echo off
setlocal
cd /d %~dp0\..
echo === Starting backend (Docker) ===
start "UAPay Backend" cmd /k "docker compose up --build"
timeout /t 3 >nul
echo === Starting Flutter app ===
start "UAPay Mobile" cmd /k "cd mobile && flutter pub get && flutter run"
echo Done.
