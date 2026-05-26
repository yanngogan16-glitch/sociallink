@echo off
setlocal

REM SocialLink - run the Flutter app on an Android device or emulator.
if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
) else if exist "C:\Program Files\Eclipse Adoptium\jdk-25.0.2.10-hotspot\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-25.0.2.10-hotspot"
)

if not defined JAVA_HOME (
    echo ERREUR: Aucun JDK compatible trouve.
    echo Installez Android Studio ou corrigez JAVA_HOME.
    pause
    exit /b 1
)

echo JAVA_HOME=%JAVA_HOME%
echo.
echo Appareils disponibles:
flutter devices
echo.
echo Lancement de SocialLink sur Android...
flutter run -d android

pause
