@echo off
setlocal

REM SocialLink - Android APK build helper.
REM Uses Android Studio's bundled JDK first because Gradle is configured for it.
if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
) else if exist "C:\Program Files\Eclipse Adoptium\jdk-25.0.2.10-hotspot\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-25.0.2.10-hotspot"
)

echo ========================================
echo    SocialLink - Generation APK Android
echo ========================================
echo.

if not defined JAVA_HOME (
    echo ERREUR: Aucun JDK compatible trouve.
    echo Installez Android Studio ou corrigez JAVA_HOME.
    pause
    exit /b 1
)

echo JAVA_HOME=%JAVA_HOME%
echo.

echo Recuperation des dependances...
flutter pub get
if %errorlevel% neq 0 (
    echo ERREUR: impossible de recuperer les dependances.
    pause
    exit /b 1
)

echo.
echo Generation de l'APK debug...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ERREUR: build APK debug echoue.
    pause
    exit /b 1
)

echo.
echo APK genere avec succes:
echo android\app\build\outputs\flutter-apk\app-debug.apk
echo.
echo Pour installer sur un telephone connecte:
echo flutter install
echo.
pause
