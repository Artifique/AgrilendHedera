# Agrilend Backend - Plateforme de Tokenisation Agricole

## Vue d'ensemble

Agrilend est une plateforme innovante de tokenisation des récoltes agricoles, exploitant la puissance de la blockchain Hedera Hashgraph. Ce backend Spring Boot est le cœur de la solution, orchestrant l'ensemble du cycle de vie des produits agricoles, de la ferme au consommateur. Il permet aux agriculteurs de numériser leurs récoltes en AgriTokens, aux acheteurs de s'engager dans des transactions sécurisées via un système de séquestre basé sur HBAR, et aux administrateurs de superviser et de valider l'ensemble du processus. L'intégration profonde avec Hedera Hashgraph, via ses services de tokenisation (HTS) et de contrats intelligents, assure transparence, efficacité et sécurité pour toutes les parties prenantes.

## Architecture

### Composants Principaux

L'architecture est conçue pour être modulaire et scalable :

-   **Frontend** : Applications clientes (Back Office React.js, Mobile Flutter, Site Vitrine) interagissant avec cette API.
-   **Backend (Ce Projet)** : Une API Gateway robuste développée avec Spring Boot, exposant des services RESTful pour la gestion métier.
-   **DLT (Distributed Ledger Technology)** : Intégration poussée avec Hedera Hashgraph pour la tokenisation (Hedera Token Service - HTS), les messages de consensus (Hedera Consensus Service - HCS) et les contrats intelligents (Hedera Smart Contract Service).
-   **Base de données** : MySQL pour la persistance des données relationnelles et la gestion des états de l'application.

### Services Backend

Le backend est structuré autour de plusieurs services métier :

1.  **Service d'Authentification et Utilisateurs** : Gère l'inscription, la connexion (JWT), la gestion des profils (agriculteurs, acheteurs, administrateurs) et la liaison des comptes Hedera.
2.  **Service Produits** : Gère le catalogue des produits agricoles disponibles sur la plateforme.
3.  **Service Offres** : Permet aux agriculteurs de créer, gérer et soumettre des offres de récoltes, qui sont ensuite validées par les administrateurs.
4.  **Service Commandes** : Gère le processus de commande, y compris le système de séquestre HBAR et la confirmation de livraison.
5.  **Service de Tokenisation** : Orchestre la création de reçus d'entrepôt, la frappe (minting) et la destruction (burning) des AgriTokens sur Hedera, et la gestion des dépôts HBAR.
6.  **Service Hedera** : Interface directe avec le SDK Hedera pour toutes les opérations blockchain (création de tokens, transactions, appels de contrats).
7.  **Service Notifications** : Gère les notifications internes pour les utilisateurs.
8.  **Service Admin Dashboard** : Fournit des statistiques et des indicateurs clés pour la supervision administrative.

## Fonctionnalités Principales

### Pour les Agriculteurs (Rôle FARMER)
-   Création et gestion des offres de produits agricoles.
-   Soumission des récoltes pour la création de reçus d'entrepôt.
-   Suivi du processus de tokenisation de leurs récoltes.
-   Réception des paiements en HBAR ou AgriTokens.
-   Gestion de leur profil et liaison de compte Hedera.

### Pour les Acheteurs (Rôle BUYER)
-   Recherche et consultation des offres de produits disponibles.
-   Dépôt de HBAR dans un HarvestVault pour sécuriser les achats.
-   Passage de commandes avec un système de séquestre automatique.
-   Confirmation de livraison pour libérer les fonds.
-   Rachat d'AgriTokens contre des biens physiques.
-   Gestion de leur profil et liaison de compte Hedera.

### Pour les Administrateurs (Rôle ADMIN)
-   Validation des reçus d'entrepôt et des offres.
-   Gestion complète des utilisateurs et des produits.
-   Supervision des transactions Hedera et des processus de tokenisation.
-   Accès à un tableau de bord avec des statistiques détaillées (revenus, commandes, etc.).
-   Déploiement et interaction avec les contrats intelligents Hedera.

## Contrats Intelligents Hedera

Deux contrats intelligents Solidity sont au cœur de la logique de tokenisation :

1.  **`HbarToTokenPoolHTS.sol` (HarvestVault)** :
    *   **Rôle** : Permet aux acheteurs de déposer des HBAR dans un pool pendant une période définie. Une fois cette période terminée, un "entrepôt" (généralement l'agriculteur ou une entité autorisée) peut distribuer des tokens HTS (AgriTokens) aux acheteurs, proportionnellement à leurs dépôts HBAR.
    *   **Fonctionnalités clés** : Dépôt de HBAR, distribution de récompenses en tokens HTS, association du contrat avec un token, financement du contrat en tokens par l'entrepôt.
    *   **Intégration Hedera** : Utilise le precompile Hedera Token Service (HTS) pour les transferts et associations de tokens.

2.  **`PoolFactory.sol`** :
    *   **Rôle** : Sert de fabrique pour déployer et suivre de multiples instances du contrat `HbarToTokenPoolHTS`.
    *   **Fonctionnalités clés** : Création de nouveaux pools (HarvestVaults) avec des paramètres spécifiques (nom, token de récompense, durée de dépôt, récompense par HBAR).

Ces contrats garantissent un mécanisme transparent et automatisé pour la gestion des fonds et la distribution des AgriTokens, renforçant la confiance entre agriculteurs et acheteurs.

## Technologies Utilisées

-   **Langage** : Java 17
-   **Framework** : Spring Boot 3.2.0 (Web, Data JPA, Security, Validation, Mail, Actuator)
-   **Base de données** : MySQL 8.0 (production), H2 Database (tests)
-   **Blockchain/DLT** : Hedera Hashgraph SDK 2.30.0, gRPC
-   **Sécurité** : Spring Security, JSON Web Tokens (JWT) avec `jjwt`
-   **Mapping d'objets** : ModelMapper
-   **Utilitaires** : Apache Commons Lang3
-   **Documentation API** : SpringDoc OpenAPI (Swagger UI)
-   **Build Tool** : Apache Maven
-   **Déploiement** : Docker (Dockerfile inclus)

## Installation et Configuration

### Prérequis
-   Java Development Kit (JDK) 17 ou supérieur
-   Apache Maven 3.6 ou supérieur
-   Un serveur MySQL 8.0+ en cours d'exécution (ou utilisation de H2 pour le développement/tests)
-   Un compte Hedera (testnet ou mainnet) avec un Account ID et une clé privée pour l'opérateur et le trésorier.

### Configuration de la Base de Données
Assurez-vous que votre serveur MySQL est configuré et que les informations de connexion dans `src/main/resources/application.properties` sont correctes. Le backend tentera de créer la base de données `db_agrilend` si elle n'existe pas.

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/db_agrilend?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
```

### Configuration Hedera
Les identifiants Hedera sont essentiels pour interagir avec le réseau. **Pour des raisons de sécurité, ne stockez JAMAIS de clés privées directement dans le code source en production.** Utilisez des variables d'environnement ou un système de gestion de secrets.

Dans `src/main/resources/application.properties` (pour le développement local) ou via des variables d'environnement :

```properties
hedera.network=testnet # ou mainnet
hedera.operator.account-id=0.0.XXXXXX
hedera.operator.private-key=302e020100300506032b657004220420... # Votre clé privée encodée en hex
hedera.treasury.account-id=0.0.YYYYYY
hedera.treasury.private.key=302e020100300506032b657004220420... # Clé privée du compte trésorier
hedera.harvest-vault.contract-id=0.0.ZZZZZZ # ID du contrat HarvestVault déployé (à configurer après déploiement)
```

### Démarrage de l'Application

1.  **Cloner le dépôt :**
    ```bash
    git clone <URL_DU_DEPOT>
    cd agrilend-backend
    ```
2.  **Compiler et démarrer l'application :**
    ```bash
    mvn clean install
    mvn spring-boot:run
    ```
    L'application sera accessible sur `http://localhost:8080`.

### Accès à la Documentation API (Swagger UI)
Une fois l'application démarrée, accédez à la documentation interactive de l'API via Swagger UI :
`http://localhost:8080/swagger-ui.html`

## API Endpoints Overview

L'API est organisée par domaines fonctionnels :

-   **`/api/auth` (Authentication)** : Inscription, connexion, rafraîchissement de tokens JWT.
-   **`/api/user` (User Management)** : Gestion du profil utilisateur, liaison/création de comptes Hedera, soumission de transactions Hedera signées.
-   **`/api/admin` (Admin)** : Gestion complète des utilisateurs, produits, offres, commandes, reçus d'entrepôt et statistiques du tableau de bord (accès restreint aux administrateurs).
-   **`/api/admin/hedera` (Admin Hedera)** : Opérations spécifiques à Hedera pour les administrateurs, incluant la création de tokens, le déploiement de contrats, le minting/burning de tokens (AgriTokens), et le paiement des agriculteurs.
-   **`/api/farmer` (Farmer)** : Gestion des offres de l'agriculteur, consultation des commandes reçues, gestion du profil.
-   **`/api/buyer` (Buyer)** : Consultation des offres, préparation et confirmation des dépôts HBAR, création de commandes, confirmation de livraison, rachat d'AgriTokens, gestion du profil.
-   **`/api/common/products` (Common Products)** : Consultation et recherche de produits (accessible aux agriculteurs et acheteurs).
-   **`/api/notifications` (Notifications)** : Gestion des notifications utilisateur.

## Sécurité

-   **Authentification JWT** : Utilisation de tokens JWT pour sécuriser l'accès aux endpoints.
-   **Autorisation par Rôles** : Contrôle d'accès basé sur les rôles (`ADMIN`, `FARMER`, `BUYER`).
-   **Sécurité Hedera** : Les clés privées ne sont pas stockées côté backend pour les comptes utilisateurs. Les transactions sensibles sont préparées par le backend et doivent être signées côté client.

## Déploiement

Un `Dockerfile` est inclus pour faciliter le déploiement de l'application dans un environnement conteneurisé.

## Support et Maintenance

Pour toute question ou support, veuillez contacter l'équipe de développement.

---