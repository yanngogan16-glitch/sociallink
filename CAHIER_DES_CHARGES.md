# Cahier Des Charges - SocialLink

## 1. Presentation Du Projet

SocialLink est une application web/mobile de type PWA developpee avec Flutter et Firebase. Elle vise a connecter les principaux acteurs du secteur humanitaire : les ONG, les bailleurs/donateurs, les beneficiaires et les personnes ressources.

L'application permet aux ONG de publier des programmes d'aide, aux donateurs de soutenir financierement ces programmes, aux beneficiaires de s'inscrire aux actions disponibles, et aux experts/personnes ressources de proposer leurs competences aux organisations. Elle integre egalement une messagerie, une carte interactive, des statistiques et un espace d'administration.

## 2. Contexte Et Problematique

Dans le domaine humanitaire, il existe souvent un manque de coordination entre les ONG, les donateurs, les beneficiaires et les experts disponibles. Les informations sont parfois dispersees, les dons difficiles a suivre, les beneficiaires ont peu de visibilite sur les programmes existants, et les ONG peuvent manquer d'outils pour gerer leurs actions.

La problematique principale du projet est donc la suivante :

Comment creer une plateforme numerique centralisee, fiable et accessible permettant de mettre en relation les acteurs humanitaires, de suivre les programmes d'aide, de faciliter les dons et d'ameliorer la transparence des actions sociales ?

SocialLink repond a cette problematique en proposant une solution simple, structuree et securisee, accessible via navigateur ou installable comme application mobile grace au mode PWA.

## 3. Objectifs De L'application

L'objectif general de SocialLink est de faciliter la collaboration humanitaire entre les ONG, les donateurs, les beneficiaires et les personnes ressources.

Les objectifs specifiques sont :

- Centraliser les programmes humanitaires disponibles.
- Permettre aux ONG de creer, gerer et suivre leurs programmes.
- Permettre aux beneficiaires de consulter les programmes et de s'y inscrire.
- Permettre aux donateurs de soutenir financierement les programmes.
- Suivre les dons avec un systeme de validation par l'ONG.
- Mettre en relation les utilisateurs grace a une messagerie en temps reel.
- Faciliter la recherche de programmes et d'experts.
- Localiser les programmes grace a une carte interactive.
- Donner aux administrateurs une vue globale de la plateforme.
- Renforcer la confiance grace a des niveaux de fiabilite attribues aux ONG.

## 4. Fonctionnalites Principales Attendues

### 4.1 Authentification Et Gestion Des Roles

L'application doit permettre l'inscription et la connexion des utilisateurs avec Firebase Authentication. Les roles prevus sont :

- ONG
- Donateur / Bailleur
- Beneficiaire
- Administrateur
- Personne ressource, rattachee principalement au parcours donateur

Chaque utilisateur est redirige vers un tableau de bord adapte a son role.

### 4.2 Espace ONG

Une ONG doit pouvoir :

- Creer un compte avec nom, pays, description, email et mot de passe.
- Creer un programme humanitaire.
- Definir le titre, la description, la categorie, la localisation, l'objectif financier et le nombre de places disponibles.
- Voir ses programmes.
- Suivre les beneficiaires inscrits.
- Consulter les dons en attente.
- Valider ou rejeter les dons recus.
- Acceder a des statistiques.
- Rechercher des personnes ressources.
- Communiquer avec les autres utilisateurs par messagerie.

### 4.3 Espace Donateur / Bailleur

Un donateur doit pouvoir :

- Creer un compte personnel.
- Consulter les programmes disponibles.
- Filtrer les programmes par categorie.
- Voir les details d'un programme.
- Faire un don en FCFA.
- Ajouter un message au don.
- Suivre l'historique de ses dons.
- Devenir personne ressource en renseignant ses competences.
- Communiquer avec les ONG via messagerie.

### 4.4 Espace Beneficiaire

Un beneficiaire doit pouvoir :

- Creer un compte avec nom, ville/quartier, besoin principal, email et mot de passe.
- Consulter les programmes d'aide disponibles.
- Voir les details d'un programme.
- S'inscrire a un programme si des places sont disponibles.
- Rechercher des programmes selon ses besoins.
- Communiquer avec les autres acteurs si necessaire.

### 4.5 Gestion Des Dons

Le systeme de dons doit permettre :

- La creation d'un don lie a un programme.
- L'enregistrement du montant, du donateur, de l'ONG, du programme et du moyen de paiement.
- La mise en attente du don avant confirmation.
- La notification de l'ONG.
- La confirmation ou le rejet du don par l'ONG ou l'administrateur.
- La mise a jour du montant collecte apres confirmation.
- L'envoi automatique d'un message au donateur apres validation ou rejet.

### 4.6 Gestion Des Programmes Humanitaires

Un programme contient :

- Titre
- Description
- Categorie
- Localisation
- ONG responsable
- Montant cible
- Montant collecte
- Nombre de places disponibles
- Nombre de beneficiaires inscrits
- Statut
- Coordonnees geographiques eventuelles

Les categories prevues incluent notamment : alimentation, education, sante, eau potable, formation, logement et autre.

### 4.7 Personnes Ressources

Un utilisateur peut s'inscrire comme personne ressource en indiquant :

- Nom
- Biographie / experience
- Ville / pays
- Telephone
- Specialite
- Mode d'intervention : presentiel, en ligne ou les deux
- Type de participation : benevole, remunere ou flexible
- Disponibilites

Les ONG peuvent ensuite rechercher ces personnes ressources selon la specialite, le mode d'intervention et la localisation.

### 4.8 Messagerie En Temps Reel

La plateforme doit permettre :

- La creation de conversations entre deux utilisateurs.
- L'envoi de messages texte.
- L'envoi d'images.
- L'envoi de fichiers.
- Le suivi du dernier message.
- Le comptage des messages non lus.
- La communication automatique liee aux dons.

### 4.9 Recherche Et Filtres

L'application doit proposer une recherche sur :

- Les programmes humanitaires.
- Les personnes ressources.

Les filtres prevus concernent :

- Le texte de recherche.
- La categorie du programme.
- La localisation.
- La specialite.
- Le mode d'intervention.

### 4.10 Carte Interactive

L'application integre une carte basee sur OpenStreetMap permettant de :

- Afficher la position de l'utilisateur.
- Afficher les programmes ayant des coordonnees.
- Filtrer les programmes par categorie.
- Acceder au detail d'un programme depuis la carte.

### 4.11 Administration

L'administrateur dispose d'un espace de supervision permettant de :

- Consulter les statistiques globales.
- Voir le nombre d'utilisateurs, programmes, dons et personnes ressources.
- Voir le montant total des dons confirmes.
- Consulter les utilisateurs par role.
- Consulter les programmes.
- Consulter les dons.
- Confirmer ou rejeter certains dons.
- Contacter les utilisateurs par messagerie.

### 4.12 Niveaux De Confiance

Un systeme de confiance est prevu pour les ONG. Les niveaux sont :

- Bronze
- Argent
- Or
- Platine

Le niveau depend du nombre de programmes crees et du nombre de beneficiaires touches. Ce mecanisme permet de renforcer la credibilite des ONG aupres des donateurs et des beneficiaires.

## 5. Cible Et Utilisateurs Vises

Les utilisateurs vises sont :

- Les ONG humanitaires souhaitant publier et gerer des programmes d'aide.
- Les bailleurs de fonds et donateurs souhaitant financer des projets sociaux.
- Les beneficiaires recherchant une aide concrete proche de leur situation.
- Les personnes ressources comme medecins, psychologues, juristes, formateurs, techniciens ou experts sociaux.
- Les administrateurs de la plateforme charges de superviser l'ecosysteme.

La cible geographique principale semble etre l'Afrique, plus precisement l'Afrique de l'Ouest, avec un usage en FCFA et une localisation initiale centree sur Cotonou, Benin.

## 6. Contraintes Techniques Identifiees

Le projet repose sur :

- Flutter pour l'interface web/mobile.
- Firebase Authentication pour la connexion.
- Cloud Firestore pour la base de donnees.
- Firebase Storage pour les fichiers et images.
- Firebase Messaging et notifications locales.
- Flutter Map / OpenStreetMap pour la carte.
- Geolocator pour la position utilisateur.
- Architecture orientee services, modeles, ecrans et widgets reutilisables.
- Deploiement prevu en PWA via Firebase Hosting ou Netlify.

## 7. Resultat Attendu

Le resultat attendu est une plateforme humanitaire complete, responsive, securisee et installable sur mobile, capable de connecter efficacement les ONG, les donateurs, les beneficiaires et les experts autour de programmes sociaux suivis, visibles et tracables.
