@echo off
setlocal

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "APK=android\app\build\outputs\flutter-apk\app-debug.apk"

if not exist "%ADB%" (
    echo ERREUR: adb.exe introuvable.
    echo Installez Android Studio ou Android SDK Platform-Tools.
    pause
    exit /b 1
)

if not exist "%APK%" (
    echo ERREUR: APK introuvable.
    echo Lancez d'abord build_apk.bat.
    pause
    exit /b 1
)

echo Redemarrage du serveur ADB...
"%ADB%" kill-server
"%ADB%" start-server
echo.

echo Appareils detectes:
"%ADB%" devices -l
echo.

echo Installation de SocialLink...
"%ADB%" install -r "%APK%"
if %errorlevel% neq 0 (
    echo.
    echo ERREUR: installation impossible.
    echo Verifiez que le telephone est branche, deverrouille, et que le debogage USB est autorise.
    pause
    exit /b 1
)

echo.
echo Installation terminee.
pause
