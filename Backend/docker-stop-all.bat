@echo off
setlocal enabledelayedexpansion

cd /d C:\Licence\Backend
cls
echo ========================================
echo    ARRÊT COMPLET DU BACKEND BKN
echo ========================================
echo.

:: 1. ARRÊTER LE SERVEUR PYTHON
echo 🐍 Arrêt du serveur Python...
echo --------------------------------

:: Méthode 1: Par le port 8000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000') do (
    echo    🔍 Processus trouvé sur le port 8000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 (
        echo    ✅ Serveur Python arrêté
    ) else (
        echo    ⚠️ Impossible d'arrêter le processus
    )
)

:: Méthode 2: Par le nom du fichier
taskkill /F /FI "WINDOWTITLE eq server.py" >nul 2>&1
if !errorlevel! equ 0 (
    echo    ✅ Fenêtre server.py fermée
)

echo.

:: 2. ARRÊTER LES CONTENEURS DOCKER
echo 🐳 Arrêt des conteneurs Docker...
echo --------------------------------

if not exist docker-compose.yml (
    echo    ⚠️ docker-compose.yml introuvable
) else (
    docker-compose stop >nul 2>&1
    if !errorlevel! equ 0 (
        echo    ✅ Conteneurs Docker arrêtés
    ) else (
        echo    ⚠️ Erreur lors de l'arrêt des conteneurs
    )
)

echo.

:: Vérification finale
docker ps -q 2>nul | findstr . >nul
if !errorlevel! equ 0 (
    echo    ⚠️ Des conteneurs sont encore en cours d'exécution
    docker ps --format "table {{.Names}}\t{{.Status}}"
) else (
    echo    ✅ Aucun conteneur en cours d'exécution
)

echo.
echo ========================================
echo    ✅ TOUT EST ARRÊTÉ !
echo ========================================
echo.
pause