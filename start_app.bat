@echo off
setlocal enabledelayedexpansion

echo ================================================
echo Plant Disease Detection - Configuration Complete
echo ================================================
echo.

REM Vérifier Flutter
echo Checking Flutter installation...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)
echo [OK] Flutter installed

REM Vérifier Python
echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Python not found. Backend will not work.
) else (
    echo [OK] Python installed
)

echo.
echo ================================================
echo Select an option:
echo ================================================
echo 1. Start Flutter app (debug mode)
echo 2. Start FastAPI backend
echo 3. Start both (Flutter + Backend)
echo 4. Install dependencies only
echo 5. Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    call :start_flutter
) else if "%choice%"=="2" (
    call :start_backend
) else if "%choice%"=="3" (
    call :start_both
) else if "%choice%"=="4" (
    call :install_deps
) else if "%choice%"=="5" (
    exit /b 0
) else (
    echo Invalid choice
    pause
    exit /b 1
)

pause
exit /b 0

:start_flutter
echo.
echo ================================================
echo Starting Flutter application...
echo ================================================
echo.
flutter run
exit /b 0

:start_backend
echo.
echo ================================================
echo Starting FastAPI backend...
echo ================================================
echo.
cd backend
call start.bat
cd ..
exit /b 0

:start_both
echo.
echo [INFO] Démarrage du backend...
echo [INFO] Une nouvelle fenêtre s'ouvrira pour le backend
echo [INFO] Attendez que le backend soit prêt avant de lancer Flutter
echo.
pause

REM Démarrer le backend dans une nouvelle fenêtre
start cmd /k "cd backend && call start.bat"

echo.
echo [INFO] Backend en cours de démarrage...
echo [INFO] Attendez 10 secondes...
timeout /t 10 /nobreak

echo.
echo [INFO] Démarrage de Flutter...
flutter run
exit /b 0

:install_deps
echo.
echo ================================================
echo Installing dependencies...
echo ================================================
echo.
echo Installing Flutter packages...
flutter pub get

echo.
echo Installing Python dependencies...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..

echo.
echo [OK] All dependencies installed!
exit /b 0
