# SocialLink - Application Web Sécurisée

Une plateforme sociale moderne et sécurisée construite avec Flutter pour le web et mobile.

## 🚀 Accès à l'Application

### Depuis votre téléphone :
**http://10.58.79.218:8080**

### Installation comme Application Mobile :
1. Ouvrez le lien sur votre téléphone
2. **Chrome Android** : Menu (3 points) → "Ajouter à l'écran d'accueil"
3. **Safari iOS** : Partager → "Sur l'écran d'accueil"
4. Lancez l'app depuis l'écran d'accueil - elle s'ouvrira en plein écran !

## 🔒 Fonctionnalités de Sécurité

### Sécurité Intégrée :
- ✅ **Content Security Policy (CSP)** - Protection contre les attaques XSS
- ✅ **Headers de sécurité avancés** - X-Frame-Options, X-Content-Type-Options
- ✅ **Service Worker** - Cache hors ligne et performances optimisées
- ✅ **Progressive Web App (PWA)** - Installation comme application native
- ✅ **Compression automatique** - Ressources optimisées
- ✅ **Cache intelligent** - Fonctionnement hors ligne partiel

### Authentification :
- 🔐 Connexion Google sécurisée
- 🔐 Authentification Firebase
- 🔐 Gestion des rôles utilisateurs (Bailleurs, ONG, Bénéficiaires)

## 📱 Fonctionnalités

### Pour les Bailleurs :
- 📊 Dashboard personnalisé
- 💰 Gestion des dons
- 👥 Suivi des bénéficiaires

### Pour les ONG :
- 📈 Tableaux de bord analytiques
- 🎯 Gestion des programmes
- 📍 Cartes interactives

### Pour les Bénéficiaires :
- 🎁 Accès aux dons
- 📋 Gestion des programmes
- 💬 Chat en temps réel

## 🛠️ Technologies Utilisées

- **Framework** : Flutter 3.41.2
- **Langage** : Dart 3.11.0
- **Backend** : Firebase (Auth, Firestore, Storage, Messaging)
- **Cartes** : Flutter Map avec OpenStreetMap
- **Notifications** : Firebase Cloud Messaging
- **Géolocalisation** : Geolocator
- **Stockage** : SQLite local + Cloud Storage

## 🚀 Déploiement

### Serveur Local (Développement) :
```bash
cd build/web
python -m http.server 8080
```

### Production (Recommandé) :
- **Firebase Hosting** : `firebase deploy`
- **Vercel** : Import du dossier `build/web`
- **Netlify** : Drag & drop du dossier `build/web`

## 🔧 Configuration de Sécurité

### Headers de Sécurité Automatiques :
- `Content-Security-Policy`
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection`
- `Referrer-Policy`

### Cache Optimisé :
- Assets statiques : 1 mois
- API responses : Cache intelligent
- Service Worker : Mise à jour automatique

## 📊 Performance

- ⚡ **Chargement optimisé** : Tree-shaking des polices et assets
- 💾 **Cache hors ligne** : Fonctionnement partiel sans connexion
- 📱 **PWA complète** : Installation et notifications push
- 🔄 **Mises à jour automatiques** : Service worker intelligent

## 🔐 Confidentialité et Sécurité

- 🔒 **Données chiffrées** : Toutes les communications avec Firebase
- 🛡️ **CSP stricte** : Protection contre les injections
- 🚫 **Pas de trackers** : Respect de la vie privée
- ✅ **Conforme RGPD** : Gestion des données utilisateurs

## 📞 Support

Pour toute question ou problème :
- Vérifiez que votre téléphone est sur le même réseau WiFi
- Le serveur doit rester actif sur l'ordinateur
- L'application fonctionne comme une vraie app mobile !

---

**SocialLink** - Connecter les communautés en toute sécurité 🤝</content>
<parameter name="filePath">c:\Users\HP\Desktop\SocialLink_Project\sociallink\README.md