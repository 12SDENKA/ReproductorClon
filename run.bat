@echo off
echo ===================================
echo  ReproductorClon - Flutter App
echo ===================================
echo.

REM Add Flutter to PATH
set PATH=C:\flutter\bin;%PATH%

REM Check Flutter is installed
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found at C:\flutter\bin
    pause
    exit /b 1
)

echo.
echo Available options:
echo 1. Run in Chrome (web)
echo 2. Run in Windows desktop
echo 3. Build for web (release)
echo 4. Build APK for Android
echo 5. Analyze code
echo.
set /p choice="Select option (1-5): "

if "%choice%"=="1" flutter run -d chrome
if "%choice%"=="2" flutter run -d windows
if "%choice%"=="3" (
    flutter build web --release
    echo.
    echo Build complete. Open: C:\Users\xeno\ReproductorClon\build\web\index.html
    explorer "C:\Users\xeno\ReproductorClon\build\web\index.html"
)
if "%choice%"=="4" flutter build apk --release
if "%choice%"=="5" flutter analyze

pause
