@echo off
setlocal

set "PORT=8000"
set "APK=downloads\SocialLink.apk"

if not exist "%APK%" (
    echo ERREUR: %APK% introuvable.
    echo Lancez d'abord build_apk.bat ou verifiez que l'APK existe.
    pause
    exit /b 1
)

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /C:"Adresse IPv4"') do (
    set "LOCAL_IP=%%A"
    goto :got_ip
)

:got_ip
set "LOCAL_IP=%LOCAL_IP: =%"

echo ========================================
echo    SocialLink - Telechargement APK
echo ========================================
echo.
echo Lien depuis ce PC:
echo http://localhost:%PORT%/%APK:\=/%
echo.
if defined LOCAL_IP (
    echo Lien depuis votre telephone, meme Wi-Fi:
    echo http://%LOCAL_IP%:%PORT%/%APK:\=/%
    echo.
)
echo Gardez cette fenetre ouverte pendant le telechargement.
echo Appuyez sur Ctrl+C pour arreter le serveur.
echo.

python -m http.server %PORT% --bind 0.0.0.0
