# Agrilend - Plateforme Décentralisée de Financement Agricole

Agrilend est une plateforme innovante de tokenisation des récoltes agricoles utilisant la blockchain Hedera Hashgraph. Cette solution vise à moderniser le commerce agricole africain en rendant les échanges plus rapides, transparents, équitables et accessibles. Elle permet aux agriculteurs de tokeniser leurs récoltes, aux acheteurs de passer des commandes sécurisées avec un système de séquestre, et aux administrateurs de gérer l'ensemble du processus de validation et de distribution.

## Fonctionnalités Clés

*   **Tokenisation des Récoltes**: Convertir les produits agricoles en tokens numériques sur Hedera.
*   **Financement Sécurisé**: Utilisation de pools HBAR et de smart contracts pour des paiements conditionnels.
*   **Traçabilité Complète**: Du champ à l'acheteur, assurant transparence et réduction des fraudes.
*   **Accès au Marché Mondial**: Connexion directe entre agriculteurs et acheteurs internationaux.
*   **Réduction des Délais de Paiement**: Paiements rapides et automatisés.

## Diagramme d'Architecture (Conceptuel)

Le projet Agrilend est une architecture microservices distribuée, où chaque composant joue un rôle spécifique et communique via des APIs REST ou des interactions directes avec la blockchain Hedera.

```
+-------------------+       +-------------------+       +-------------------+
|   Mobile App      |       |   Backoffice Web  |       |   Site Vitrine    |
| (Flutter/Dart)    |       |  (React/TypeScript)|       |    (React.js)     |
+-------------------+       +-------------------+       +-------------------+
      |       ^                     |       ^                     |
      |       |                     |       |                     |
      |       | (API REST)          |       | (API REST)          |
      v       |                     v       |                     v
+-------------------------------------------------------------------+
|                     Backend (Java/Spring Boot)                    |
|             (API Gateway, Logique Métier, Authentification)       |
+-------------------------------------------------------------------+
      |       ^
      |       | (SDK Hedera)
      v       |
+-------------------------------------------------------------------+
|                     Hedera Hashgraph Network                      |
|             (HTS, HSCS, HCS, Smart Contracts Solidity)            |
+-------------------------------------------------------------------+
      |       ^
      |       |
      v       |
+-------------------+
|    Base de Données  |
|       (MySQL)     |
+-------------------+
```

*   **Mobile App**: Application native pour les agriculteurs, interagissant avec le Backend pour les données et directement avec Hedera via Web3Dart pour certaines opérations blockchain.
*   **Backoffice Web**: Interface d'administration pour la gestion de la plateforme, communiquant avec le Backend.
*   **Site Vitrine**: Site web public pour la présentation du projet, indépendant des autres modules pour sa logique métier.
*   **Backend**: Le point central de l'API, gérant la logique métier, l'authentification, et l'intégration avec Hedera.
*   **Hedera Hashgraph Network**: La blockchain sous-jacente pour la tokenisation, les smart contracts et la traçabilité.
*   **Base de Données (MySQL)**: Stockage persistant des données du Backend.

## Structure Détaillée du Projet

Le projet est organisé en plusieurs répertoires racines, chacun représentant un module distinct de l'application.

```
AgrilendHedera/
├── Agrilend_Documentation_Technique_Hedera_Hackathon_2025.pdf
├── README.md
├── .git/
├── backend/
├── backoffice/
├── mobile/
└── site_vitrine/
```

### 1. `backend/` (Java/Spring Boot)

Ce répertoire contient le code source du serveur backend, responsable de la logique métier, de l'API REST et de l'intégration avec Hedera.

*   **Technologies**: Java 17, Spring Boot, Maven, MySQL, Hedera SDK, JWT, OpenAPI (Swagger).
*   **Fichiers Clés**:
    *   `pom.xml`: Fichier de configuration Maven, listant les dépendances (Spring Boot starters, Hedera SDK, MySQL connector, JWT, etc.) et les plugins de build.
    *   `Dockerfile`: Instructions pour construire l'image Docker de l'application backend.
    *   `.dockerignore`: Fichiers et répertoires à ignorer lors de la construction de l'image Docker.
    *   `compile.js`: Script JavaScript potentiellement utilisé pour la compilation de smart contracts ou d'autres tâches liées à la blockchain.
    *   `contracts/`: Contient les fichiers Solidity (`.sol`) des smart contracts déployés sur Hedera.
        *   `HbarToTokenPoolHTS.sol`: Contrat pour la gestion des pools HBAR et la tokenisation.
        *   `PoolFactory.sol`: Contrat pour la création de pools.
*   **Structure des Dossiers Importante**:
    *   `src/main/java/com/agrilend/...`: Code source Java de l'application Spring Boot (contrôleurs, services, dépôts, entités, configuration de sécurité, etc.).
    *   `src/main/resources/`: Fichiers de configuration (ex: `application.properties` ou `application.yml`), scripts SQL, etc.
    *   `build/`: Contient les artefacts compilés des smart contracts (ABI, BIN).
    *   `target/`: Répertoire de sortie de Maven, contenant le JAR exécutable de l'application.

### 2. `backoffice/` (React.js/TypeScript)

Ce répertoire héberge l'application web d'administration, permettant de gérer les utilisateurs, les transactions et les données de la plateforme.

*   **Technologies**: React.js, TypeScript, Vite, Tailwind CSS, Zustand (gestion d'état), `@tanstack/react-query` (gestion des données asynchrones), `react-router-dom` (routage), `axios` (client HTTP).
*   **Fichiers Clés**:
    *   `package.json`: Liste des dépendances npm et scripts pour le développement et le build.
    *   `tsconfig.json`: Configuration TypeScript.
    *   `vite.config.ts`: Configuration de Vite, incluant le proxy pour l'API backend.
    *   `tailwind.config.js`: Configuration de Tailwind CSS.
    *   `src/App.tsx`: Composant racine de l'application.
    *   `src/main.tsx`: Point d'entrée de l'application React.
*   **Structure des Dossiers Importante**:
    *   `src/assets/`: Images, icônes et autres ressources statiques.
    *   `src/components/`: Composants React réutilisables (boutons, formulaires, tableaux, etc.).
    *   `src/config/`: Fichiers de configuration spécifiques à l'application frontend.
    *   `src/constants/`: Constantes utilisées dans l'application.
    *   `src/contexts/`: Contextes React pour la gestion d'état global.
    *   `src/hooks/`: Hooks React personnalisés.
    *   `src/pages/`: Composants représentant les différentes pages de l'application.
    *   `src/services/`: Logique pour l'interaction avec l'API backend.
    *   `src/store/`: Modules de gestion d'état avec Zustand.
    *   `src/types/`: Définitions de types TypeScript.
    *   `src/utils/`: Fonctions utilitaires.
    *   `src/validators/`: Logique de validation des données.

### 3. `mobile/` (Flutter/Dart)

Ce répertoire contient l'application mobile multiplateforme pour Android et iOS, destinée aux agriculteurs.

*   **Technologies**: Flutter, Dart, Riverpod (gestion d'état), GoRouter (navigation), Web3Dart (interaction blockchain), Hive (base de données locale), Dio (client HTTP), `local_auth` (authentification biométrique), `geolocator` (géolocalisation), `mobile_scanner` (scan QR).
*   **Fichiers Clés**:
    *   `pubspec.yaml`: Fichier de configuration Flutter, listant les dépendances, les assets et les configurations spécifiques à Flutter.
    *   `lib/main.dart`: Point d'entrée de l'application Flutter.
    *   `android/`: Fichiers spécifiques à la plateforme Android.
    *   `ios/`: Fichiers spécifiques à la plateforme iOS.
*   **Structure des Dossiers Importante**:
    *   `lib/core/`: Code partagé, abstractions, services de base.
    *   `lib/features/`: Modules fonctionnels de l'application (ex: authentification, gestion des récoltes).
    *   `lib/models/`: Modèles de données.
    *   `lib/screens/`: Widgets représentant les différentes vues/écrans de l'application.
    *   `lib/services/`: Services pour l'interaction avec les APIs ou la blockchain.
    *   `assets/animations/`: Animations Lottie.
    *   `assets/fonts/`: Polices personnalisées (Inter).
    *   `assets/icons/`: Icônes SVG.
    *   `assets/images/`: Images.
    *   `assets/logos/`: Logos.

### 4. `site_vitrine/` (React.js)

Ce répertoire contient le site web public d'Agrilend, servant de vitrine pour le projet.

*   **Technologies**: React.js, Create React App, Framer Motion (animations), React Intersection Observer (effets de défilement), Formspree (formulaires), Font Awesome (icônes).
*   **Fichiers Clés**:
    *   `package.json`: Liste des dépendances npm et scripts pour le développement et le build.
    *   `public/index.html`: Le fichier HTML principal.
    *   `src/App.js`: Composant racine de l'application.
    *   `src/index.js`: Point d'entrée de l'application React.
*   **Structure des Dossiers Importante**:
    *   `public/`: Contient les ressources statiques (favicon, manifest, images, etc.).
    *   `src/`: Code source des composants React, styles CSS, etc.

## Technologies Principales Utilisées

*   **Blockchain**: Hedera Hashgraph (Hedera Token Service, Hedera Smart Contract Service, Hedera Consensus Service)
*   **Backend**: Java 17, Spring Boot, MySQL
*   **Frontend Web**: React.js, TypeScript, Vite, Tailwind CSS
*   **Mobile**: Flutter, Dart
*   **Smart Contracts**: Solidity
*   **Outils de Build**: Maven, npm/Yarn, Vite, Create React App
*   **Autres**: JWT, OpenAPI, Zustand, Riverpod, GoRouter, Web3Dart, Hive, Framer Motion, Formspree, Font Awesome.

## Installation et Démarrage

Pour démarrer le projet Agrilend, vous devrez configurer chaque module indépendamment. Chaque répertoire de module contient un fichier `README.md` avec des instructions détaillées.

### Prérequis Généraux

Assurez-vous d'avoir installé les éléments suivants sur votre machine :

*   **Git**
*   **Java Development Kit (JDK) 17** ou plus récent
*   **Maven**
*   **Node.js** (avec npm ou Yarn)
*   **Flutter SDK**
*   **Docker** (optionnel, pour le déploiement du backend)

### Étapes Générales

1.  **Cloner le dépôt**:
    ```bash
    git clone https://github.com/Artifique/AgrilendHedera.git
    cd AgrilendHedera
    ```
2.  **Configuration du Backend**:
    *   Naviguez vers `cd backend/`.
    *   Suivez les instructions dans `backend/README.md` pour configurer la base de données MySQL, les variables d'environnement Hedera et démarrer l'application Spring Boot.
    *   Exemple de démarrage (après configuration) : `mvn spring-boot:run`
3.  **Configuration du Backoffice**:
    *   Naviguez vers `cd backoffice/`.
    *   Suivez les instructions dans `backoffice/README.md`.
    *   Exemple de démarrage : `npm install && npm run dev`
4.  **Configuration de l'Application Mobile**:
    *   Naviguez vers `cd mobile/`.
    *   Suivez les instructions dans `mobile/README.md`.
    *   Exemple de démarrage : `flutter pub get && flutter run`
5.  **Configuration du Site Vitrine**:
    *   Naviguez vers `cd site_vitrine/`.
    *   Suivez les instructions dans `site_vitrine/README.md`.
    *   Exemple de démarrage : `npm install && npm start`




## Liens des certificats:
Boubacar Diallo: https://drive.google.com/file/d/1tS3dXci_9WFxCQG-5AIH33AwkelX410P/view?usp=sharing
Daouda Fomba: https://drive.google.com/file/d/1JVI7c3icBhQwEbrJVBaqX2V8l7KolCRj/view?usp=sharing
Michel Isaac Foutou: https://drive.google.com/file/d/1pNzcR3dstJRYo9dhnXDcuJqndnWhWtwP/view?usp=sharing
Mohamed Traore: https://drive.google.com/file/d/1HZue1bWNb9-BxBiRA-7KsZMXxEw5wq2L/view?usp=sharing 
