# 🚀 SocialLink - Application Web PWA

Plateforme sociale sécurisée pour connecter les communautés : bailleurs de fonds, ONG et bénéficiaires.

## ✨ Fonctionnalités

- 🔐 **Authentification sécurisée** avec Firebase (Email/Mot de passe + Google)
- 👥 **Rôles utilisateurs** : Bailleurs, ONG, Bénéficiaires, Administrateurs
- 💬 **Chat en temps réel** entre utilisateurs
- 🎯 **Gestion des programmes** et dons
- 📍 **Cartes interactives** pour la localisation
- 📊 **Tableaux de bord** personnalisés
- 📱 **PWA complète** avec installation sur mobile
- 🔒 **Sécurité avancée** avec CSP et headers sécurisés

## 🌐 Déploiement en ligne (Firebase)

### 🚀 Déploiement Rapide (3 minutes)

**Option la plus simple :**
```bash
# Double-cliquez sur deploy_rapide.bat
# ou dans un terminal :
./deploy_rapide.bat
```

**Scripts npm disponibles :**
```bash
npm run build      # Build l'application
npm run deploy     # Déploiement complet
npm run login      # Connexion Firebase
```

### 📋 Configuration Firebase Requise

Avant le déploiement, vous devez :

1. **Créer un projet Firebase :**
   - Allez sur [Firebase Console](https://console.firebase.google.com/)
   - Créez un projet nommé `sociallink-app`
   - Activez : Authentication, Firestore, Storage, Hosting

2. **Mettre à jour la configuration :**
   - Dans `lib/main.dart`, remplacez la config Firebase
   - Obtenez les clés depuis Project Settings

3. **Règles et Index :**
   - ✅ Automatiquement déployés avec `firestore/rules.firestore`
   - ✅ Index optimisés dans `firestore/indexes.json`

### 📱 URLs après déploiement

- **🏠 Page d'accueil** : `https://sociallink-app.web.app/`
- **📱 Application** : `https://sociallink-app.web.app/app/`
- **🔧 Console Admin** : `https://console.firebase.google.com/`

### 📞 Installation sur téléphone

1. Ouvrez l'URL sur votre téléphone
2. La page d'accueil s'affiche automatiquement
3. Cliquez "Lancer l'Application"
4. Acceptez l'installation PWA
5. L'app s'ajoute à votre écran d'accueil

## 🔧 Développement local

### Prérequis
- Flutter 3.0+
- Dart 3.0+
- Node.js (pour Firebase CLI)

### Installation
```bash
# Cloner le projet
git clone <votre-repo>
cd sociallink

# Installer les dépendances
flutter pub get

# Configurer Firebase
# - Créer un projet Firebase
# - Ajouter google-services.json (Android)
# - Mettre à jour lib/main.dart avec la config

# Lancer en mode développement
flutter run -d chrome
```

### Build pour production
```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS (sur macOS)
flutter build ios --release
```

## 📊 Architecture

```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
├── screens/                  # Interfaces utilisateur
│   ├── auth/                # Écrans d'authentification
│   ├── dashboards/          # Tableaux de bord par rôle
│   └── shared/              # Composants partagés
├── services/                # Services (Firebase, API)
├── widgets/                 # Composants réutilisables
└── theme/                   # Thème et styles

web/
├── index.html              # App Flutter (avec redirection)
├── landing.html            # Page d'accueil professionnelle
├── manifest.json           # Configuration PWA
└── icons/                  # Icônes de l'application
```

## 🔒 Sécurité

- **Content Security Policy** configuré
- **Headers de sécurité** avancés
- **Authentification Firebase** obligatoire
- **Chiffrement des données** en transit
- **Validation des entrées** côté client et serveur

## 📈 Performance

- **Lazy loading** des images
- **Cache intelligent** avec service worker
- **Compression Gzip** activée
- **Optimisation des assets** statiques
- **Code splitting** automatique

## 🐛 Dépannage

### Problème: Build échoue
```bash
flutter clean
flutter pub cache repair
flutter pub get
flutter build web --release
```

### Problème: PWA ne s'installe pas
- Vérifiez que le site est en HTTPS
- Vérifiez `manifest.json`
- Testez sur un vrai téléphone (pas un émulateur)

### Problème: Erreurs Firebase
- Vérifiez la configuration dans `main.dart`
- Assurez-vous que les règles Firestore sont correctes
- Vérifiez les quotas Firebase

## 📞 Support

- 📧 Email: support@sociallink.app
- 📚 Docs: [Documentation complète](docs/)
- 🐛 Issues: [GitHub Issues](issues/)

## 📄 Licence

MIT License - Voir [LICENSE](LICENSE) pour plus de détails.

---

**SocialLink** - Connecter les communautés pour un impact durable 🚀
