@echo off
cd /d C:\Licence\Backend
echo ========================================
echo    DÉMARRAGE DU BACKEND BKN
echo ========================================

:: Vérifier si Docker est installé
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Docker n'est pas installé ou pas dans le PATH
    echo Télécharge Docker Desktop sur: https://www.docker.com/products/docker-desktop/
    pause
    exit /b
)

:: Vérifier si Docker Desktop est en cours d'exécution
docker info >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ Docker Desktop n'est pas démarré
    echo Lance Docker Desktop et réessaie
    pause
    exit /b
)

:: Vérifier si docker-compose.yml existe
if not exist docker-compose.yml (
    echo ❌ docker-compose.yml introuvable !
    pause
    exit /b
)

:: Vérifier si requirements.txt existe
if not exist requirements.txt (
    echo ⚠️ requirements.txt introuvable, création...
    echo fastapi==0.110.0 > requirements.txt
    echo uvicorn[standard]==0.27.1 >> requirements.txt
    echo psycopg2-binary==2.9.9 >> requirements.txt
    echo python-dotenv==1.0.1 >> requirements.txt
    echo pydantic==2.6.3 >> requirements.txt
    echo passlib==1.7.4 >> requirements.txt
    echo bcrypt==4.0.1 >> requirements.txt
    echo ✅ requirements.txt créé
)

:: Construire et démarrer les conteneurs
echo.
echo 🐳 Construction des images Docker...
docker-compose build

echo.
echo 🚀 Démarrage des conteneurs...
docker-compose up -d

:: Vérifier que les conteneurs sont démarrés
echo.
echo ⏳ Vérification du démarrage...
timeout /t 5 /nobreak >nul

docker-compose ps | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo ✅ Conteneurs démarrés avec succès !
) else (
    echo ❌ Problème de démarrage des conteneurs
    echo Vérifie les logs avec: docker-compose logs
)

:: Afficher les infos
echo.
echo ========================================
echo    SERVEUR BKN PRET !
echo ========================================
echo 📡 API: http://localhost:8000
echo 📊 Docs: http://localhost:8000/docs
echo 📈 Adminer: http://localhost:8081
echo ========================================
echo.
pause