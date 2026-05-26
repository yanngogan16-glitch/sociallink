# SocialLink mobile

Le projet Flutter est configure pour fonctionner a la fois sur le web et sur mobile.

## Android

L'application Android est deja presente dans `android/` et connectee a Firebase via:

- `android/app/google-services.json`
- `lib/firebase_options.dart`

Commandes utiles:

```bash
flutter pub get
flutter run -d android
flutter build apk --release
flutter build appbundle --release
```

Sur Windows, vous pouvez aussi utiliser les scripts du depot:

```bat
run_android.bat
build_apk.bat
install_android_apk.bat
start_download_server.bat
```

Ces scripts corrigent automatiquement `JAVA_HOME` si Android Studio est installe dans
`C:\Program Files\Android\Android Studio\jbr`. Cela evite l'erreur Gradle:

```text
JAVA_HOME is set to an invalid directory
```

Les APK seront generes dans:

```text
android/app/build/outputs/flutter-apk/
```

Si `flutter run` ne detecte pas le telephone, utilisez:

```bat
install_android_apk.bat
```

Ce script installe directement l'APK debug via ADB.

Pour obtenir un lien de telechargement manuel depuis le telephone:

```bat
start_download_server.bat
```

Gardez la fenetre ouverte, puis ouvrez l'URL affichee sur le telephone.

Pour publier sur Google Play, il faudra remplacer la signature debug actuelle par une vraie cle de signature release.

## iOS

Le dossier `ios/` existe aussi, mais Firebase iOS n'est pas encore finalise dans ce depot. Pour activer iPhone/iPad:

1. Creer une app iOS dans Firebase avec le bundle id `com.example.sociallink` ou choisir un bundle id definitif.
2. Telecharger `GoogleService-Info.plist`.
3. Ajouter ce fichier dans `ios/Runner/GoogleService-Info.plist` via Xcode.
4. Regenerer `lib/firebase_options.dart` avec FlutterFire si le bundle id change.

Commandes utiles sur macOS:

```bash
flutter pub get
flutter run -d ios
flutter build ipa --release
```

## Notes importantes

- Android garde actuellement l'application id `com.example.sociallink`, car il correspond au fichier Firebase existant.
- Les permissions mobiles sont declarees pour internet, localisation, notifications, camera et galerie.
- La meme base Flutter continue de servir l'application web.
