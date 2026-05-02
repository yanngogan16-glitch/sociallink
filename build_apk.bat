@echo off
REM Script de génération APK SocialLink
echo ========================================
echo    SocialLink - Génération APK
echo ========================================
echo.

echo Nettoyage du projet...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Erreur nettoyage
    pause
    exit /b 1
)

echo.
echo Récupération des dépendances...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Erreur dépendances
    pause
    exit /b 1
)

echo.
echo Génération de l'APK...
flutter build apk --split-per-abi
if %errorlevel% neq 0 (
    echo ❌ Erreur build APK
    pause
    exit /b 1
)

echo.
echo ✅ APK généré avec succès !
echo.
echo 📂 Fichiers APK créés dans :
echo    build\app\outputs\flutter-apk\
echo.
echo 📱 Pour installer sur Android :
echo 1. Transférez un fichier .apk sur votre téléphone
echo 2. Activez "Sources inconnues" dans Paramètres
echo 3. Ouvrez et installez l'APK
echo.
pause