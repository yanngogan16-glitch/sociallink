# SocialLink - Guide de Déploiement

## 🚀 Déploiement Automatique avec Firebase Hosting

### Prérequis
- Node.js installé (version 14 ou supérieure)
- Compte Google/Firebase
- Flutter installé

### Étape 1: Installation de Firebase CLI
```bash
npm install -g firebase-tools
```

### Étape 2: Connexion à Firebase
```bash
firebase login
```
Cela ouvrira une fenêtre de navigateur pour vous connecter à votre compte Google.

### Étape 3: Création du projet Firebase
1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Créer un projet"
3. Nommez-le "sociallink-app" (ou votre nom préféré)
4. Activez Google Analytics si souhaité
5. Cliquez sur "Créer le projet"

### Étape 4: Configuration du projet
Dans le fichier `.firebaserc`, remplacez "sociallink-app" par l'ID réel de votre projet Firebase.

### Étape 5: Build de l'application web
```bash
flutter build web --release
```

### Étape 6: Déploiement
```bash
firebase deploy --only hosting
```

### Étape 7: Configuration du domaine personnalisé (Optionnel)
1. Dans Firebase Console, allez dans Hosting
2. Cliquez sur "Ajouter un domaine personnalisé"
3. Entrez "sociallink.app" ou votre domaine
4. Suivez les instructions DNS

## 📱 Fonctionnalités PWA

L'application inclut:
- ✅ Installation automatique sur mobile
- ✅ Mode hors ligne avec cache
- ✅ Notifications push
- ✅ Interface adaptative
- ✅ Sécurité avancée

## 🔧 Structure des fichiers

```
web/
├── index.html          # Point d'entrée PWA avec installation auto
├── landing.html        # Page d'accueil professionnelle
├── manifest.json       # Configuration PWA
├── flutter_service_worker.js  # Service worker personnalisé
└── icons/              # Icônes de l'application
```

## 🌐 URLs importantes

- **Page d'accueil**: `https://votre-projet.firebaseapp.com/`
- **Application**: `https://votre-projet.firebaseapp.com/app/`
- **Domaine personnalisé**: `https://sociallink.app/`

## 📊 Métriques et Analytics

L'application inclut Google Analytics pour suivre:
- Nombre d'utilisateurs
- Taux d'installation PWA
- Engagement utilisateur
- Performances

## 🔒 Sécurité

- Content Security Policy configuré
- Headers de sécurité avancés
- Authentification Firebase
- Chiffrement des données

## 🆘 Dépannage

### Problème: "Project not found"
- Vérifiez que le nom du projet dans `.firebaserc` correspond à votre projet Firebase

### Problème: "Permission denied"
- Assurez-vous d'être connecté avec `firebase login`
- Vérifiez que vous avez les droits sur le projet

### Problème: Build échoue
- Exécutez `flutter clean` puis `flutter build web --release`
- Vérifiez que toutes les dépendances sont installées

## 📞 Support

Pour toute question, consultez:
- [Documentation Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Documentation Flutter Web](https://flutter.dev/docs/get-started/web)
- [Guide PWA Flutter](https://docs.flutter.dev/development/platform-integration/web)