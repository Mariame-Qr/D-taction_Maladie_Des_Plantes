@echo off
REM Script de démarrage du backend FastAPI
REM Assurez-vous que Python 3.10+ est installé

echo ========================================
echo Plant Disease Detection - Backend
echo ========================================
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo Erreur: Python n'est pas installé ou n'est pas dans le PATH
    echo Veuillez installer Python 3.10+ depuis https://www.python.org
    pause
    exit /b 1
)

REM Créer un environnement virtuel si nécessaire
if not exist "venv" (
    echo Création de l'environnement virtuel...
    python -m venv venv
)

REM Activer l'environnement virtuel
echo Activation de l'environnement virtuel...
call venv\Scripts\activate.bat

REM Installer les dépendances
echo Installation des dépendances...
pip install -r requirements.txt

REM Lancer le serveur
echo.
echo ========================================
echo Démarrage du serveur FastAPI...
echo ========================================
echo API disponible sur: http://localhost:8000
echo Documentation: http://localhost:8000/docs
echo.

python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

pause
