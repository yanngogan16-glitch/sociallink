# 🚀 SocialLink - Configuration Firebase Complète

## 📋 Prérequis

Avant de déployer, assurez-vous d'avoir :
- ✅ Node.js installé (version 14+)
- ✅ Flutter installé et configuré
- ✅ Un compte Google/Firebase

## 🔥 Étape 1: Créer le projet Firebase

### Via la Console Web (Recommandé)

1. **Allez sur [Firebase Console](https://console.firebase.google.com/)**

2. **Créez un nouveau projet :**
   - Cliquez sur "Créer un projet"
   - Nom : `sociallink-app`
   - Activez Google Analytics (optionnel mais recommandé)

3. **Activez les services nécessaires :**
   - **Authentication** : Activez Email/Mot de passe et Google
   - **Firestore Database** : Créez une base de données en mode production
   - **Storage** : Activez Firebase Storage
   - **Hosting** : Activez Firebase Hosting

4. **Configuration Authentication :**
   - Allez dans Authentication > Sign-in method
   - Activez "Email/Password"
   - Activez "Google" et configurez avec votre projet Google

5. **Configuration Firestore :**
   - Créez une base de données Firestore
   - Choisissez "Commencer en mode production"
   - Région : `europe-west` (ou votre région préférée)

## 🔧 Étape 2: Configuration du projet local

### Mettre à jour la configuration Firebase

1. **Dans `lib/main.dart`, remplacez la configuration :**
   ```dart
   const FirebaseOptions web = FirebaseOptions(
     apiKey: "votre-api-key",
     authDomain: "sociallink-app.firebaseapp.com",
     projectId: "sociallink-app",
     storageBucket: "sociallink-app.appspot.com",
     messagingSenderId: "votre-sender-id",
     appId: "votre-app-id",
   );
   ```

2. **Obtenir les clés depuis Firebase Console :**
   - Allez dans Project Settings > General > Your apps
   - Ajoutez une app Web si nécessaire
   - Copiez la configuration

## 📊 Étape 3: Règles Firestore et Index

Les règles et index sont déjà configurés dans :
- `firestore/rules.firestore` - Règles de sécurité
- `firestore/indexes.json` - Index pour les requêtes

### Règles principales :
- ✅ Utilisateurs peuvent lire tous les profils
- ✅ Utilisateurs peuvent modifier leur propre profil
- ✅ ONG peuvent créer/gérer des programmes
- ✅ Utilisateurs authentifiés peuvent faire des dons
- ✅ Chat sécurisé entre utilisateurs
- ✅ Admins ont tous les droits

## 🚀 Étape 4: Déploiement

### Option A: Script automatique (Recommandé)
```bash
# Double-cliquez sur deploy_rapide.bat
# ou exécutez dans un terminal :
./deploy_rapide.bat
```

### Option B: Déploiement manuel
```bash
# Build l'application
flutter build web --release

# Connexion Firebase
npx firebase-tools login

# Déploiement
npx firebase-tools deploy --only hosting,firestore
```

## 🌐 Étape 5: URLs et Accès

Après déploiement réussi :

### URLs principales :
- **Page d'accueil** : `https://sociallink-app.web.app/`
- **Application** : `https://sociallink-app.web.app/app/`
- **Console Firebase** : `https://console.firebase.google.com/`

### Installation PWA :
1. Ouvrez l'URL sur mobile
2. Cliquez "Lancer l'Application"
3. Acceptez l'installation
4. L'app s'ajoute à l'écran d'accueil

## 🔒 Étape 6: Sécurité et Permissions

### Vérifier les règles Firestore :
1. Allez dans Firebase Console > Firestore > Rules
2. Les règles sont automatiquement déployées
3. Testez avec le simulateur de règles

### Permissions utilisateur :
- **Bailleurs** : Peuvent faire des dons, voir les programmes
- **ONG** : Peuvent créer des programmes, gérer leurs projets
- **Bénéficiaires** : Peuvent recevoir des dons, participer aux programmes
- **Administrateurs** : Accès complet à la gestion

## 📈 Étape 7: Monitoring et Analytics

### Activer Analytics (Optionnel) :
1. Dans Firebase Console > Analytics
2. Suivez les métriques d'utilisation
3. Configurez des événements personnalisés

### Monitoring des erreurs :
1. Allez dans Firebase Console > Crashlytics (si activé)
2. Surveillez les performances
3. Déboguer les problèmes utilisateurs

## 🌍 Étape 8: Domaine personnalisé (Optionnel)

Pour avoir `sociallink.app` au lieu de `sociallink-app.web.app` :

1. **Achetez un domaine** chez un registrar (GoDaddy, Namecheap, etc.)
2. **Dans Firebase Console > Hosting :**
   - Cliquez "Ajouter un domaine personnalisé"
   - Entrez votre domaine (ex: sociallink.app)
   - Suivez les instructions DNS
3. **Attendez la propagation DNS** (peut prendre 24-48h)

## 🐛 Dépannage

### Problème: "Project not found"
- Vérifiez que le projet existe sur Firebase Console
- Vérifiez l'ID dans `.firebaserc`

### Problème: "Permission denied"
- Assurez-vous d'être connecté avec `firebase login`
- Vérifiez que vous êtes propriétaire du projet

### Problème: Règles Firestore rejetées
- Testez les règles dans le simulateur
- Vérifiez la syntaxe dans `firestore/rules.firestore`

### Problème: PWA ne s'installe pas
- Vérifiez que le site est en HTTPS
- Vérifiez `web/manifest.json`
- Testez sur un vrai téléphone

## 📞 Support

- 📚 **Documentation** : `README.md`
- 🐛 **Issues** : Signalez les problèmes rencontrés
- 💬 **Chat** : Utilisez la fonctionnalité chat de l'app

---

**🎉 Félicitations ! Votre plateforme SocialLink est maintenant opérationnelle !**