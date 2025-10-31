# Agrilend : Plateforme Décentralisée de Financement Agricole

## Introduction

Agrilend est une plateforme agro-financière décentralisée innovante, conçue pour transformer le secteur agricole africain. Basée sur la technologie Hedera Hashgraph, elle vise à résoudre les problèmes d'exclusion financière, d'accès limité aux marchés mondiaux, de paiements lents et de manque de traçabilité qui affectent les agriculteurs africains.

En permettant la tokenisation de la production agricole et la vente directe aux acheteurs, Agrilend garantit la transparence, la sécurité des paiements et une traçabilité complète du produit, du champ à l'acheteur.

Ce projet a été développé dans le cadre du **Hedera Africa Hackathon 2025 – DoraHacks**, sur la piste "Sub-track 2 – Agriculture & Agri-Finance".

## Problématique Addréssée

En Afrique, de nombreux agriculteurs sont confrontés à des défis majeurs :

- **Exclusion financière :** Difficulté d'accès aux circuits de financement modernes.
- **Accès limité au marché :** Dépendance vis-à-vis de multiples intermédiaires qui captent une grande partie de la valeur.
- **Paiements lents et incertains :** Opacité dans la chaîne de valeur et délais de paiement importants.
- **Manque de traçabilité :** Limite la confiance et la valorisation des produits.

Agrilend apporte une solution à ces problèmes en créant un pont commercial direct et équitable entre les producteurs locaux et les acheteurs internationaux.

## Objectifs du Projet

- **O1 : Adoption par les Agriculteurs :** Enrôler et former 5 000 agriculteurs maliens sur la plateforme Agrilend d'ici fin 2026.
- **O2 : Volume de Tokenisation :** Tokeniser 500 tonnes de produits agricoles (cacao, café, coton) via le Hedera Token Service (HTS) au cours des 18 premiers mois.
- **O3 : Financement Sécurisé :** Faciliter 5 millions de dollars de transactions de financement sécurisé entre acheteurs internationaux et agriculteurs d'ici fin 2027.
- **O4 : Réduction des Délais de Paiement :** Réduire le délai de paiement moyen à moins de 48 heures après la vérification de la livraison, à partir du T3 2026.

## Pourquoi Hedera ?

Le choix d'Hedera Hashgraph repose sur ses caractéristiques techniques uniques, idéales pour l'agro-commerce africain :

- **Faible Coût Fixe et Prévisible :** Frais de transaction extrêmement bas et fixes, essentiels pour les microtransactions.
- **Haute Scalabilité et Débit :** Des milliers de transactions par seconde avec une finalité rapide, supportant un volume élevé d'opérations.
- **Efficacité Énergétique :** Alignement avec les engagements de développement durable.

### Services Hedera Utilisés

- **Hedera Token Service (HTS) :** Pour la tokenisation des actifs (1 Token = 1 kg de produit agricole).
- **Hedera Smart Contract Service (HSCS) :** Pour le financement sécurisé (Pool HBAR, libération conditionnelle des fonds).
- **Hedera Consensus Service (HCS) :** Pour la traçabilité et la vérification (horodatage, ordre immuable des événements).

## Proposition de Valeur Unique

Agrilend se distingue en combinant :

- **Contrats intelligents conditionnels :** Paiement lié à la conformité du produit.
- **Tokenisation fongible :** Des produits agricoles avec preuve de propriété.
- **Pool HBAR :** Garantit la disponibilité du financement.
- **Accès direct au marché mondial :** Sans intermédiaires abusifs.
- **Technologie optimisée :** Pour les zones rurales (faible bande passante).

## Architecture Technique

La plateforme Agrilend est basée sur une architecture distribuée :

- **Frontend :** Flutter (Dart) pour les applications mobiles (Android/iOS).
- **Backend :** Spring Boot (Java) pour la logique métier et les API.
- **Blockchain :** Intégration directe avec le réseau Hedera via les SDK JavaScript et Java.
- **Mirror Nodes :** Utilisés pour la lecture des transactions et la vérification des états.
- **Smart Contracts :** Assurent l'automatisation des paiements, du scoring de crédit et de la traçabilité.

## Structure du Projet

Le projet Flutter est organisé de manière modulaire :

```
.
├── lib/
│   ├── main.dart                 # Point d'entrée de l'application
│   ├── core/                     # Fonctionnalités de base (thème, routeur, constantes)
│   │   ├── constants/
│   │   ├── providers/
│   │   ├── router/
│   │   │   └── app_router.dart   # Configuration des routes (GoRouter)
│   │   └── theme/
│   ├── features/                 # Modules spécifiques aux fonctionnalités
│   │   ├── agent/
│   │   ├── auth/                 # Authentification, Enregistrement, KYC, Onboarding
│   │   ├── buyer/                # Fonctionnalités spécifiques à l'acheteur
│   │   │   ├── providers/
│   │   │   ├── screens/          # Écrans de l'acheteur (Dashboard, Commandes, Portefeuille, Produits, Dépôt HBAR, etc.)
│   │   │   └── widgets/
│   │   ├── farmer/               # Fonctionnalités spécifiques à l'agriculteur
│   │   ├── notification/
│   │   ├── onboarding/
│   │   ├── profile/              # Gestion du profil, paramètres
│   │   ├── transactions/         # Historique des transactions, requêtes de paiement
│   │   └── wallet/               # Gestion du portefeuille (écrans génériques)
│   ├── models/                   # Modèles de données (produits, commandes, utilisateurs, etc.)
│   ├── services/                 # Couche d'abstraction API et logique métier
│   │   ├── api_service.dart      # Configuration de Dio, intercepteurs
│   │   ├── auth_service.dart     # Services d'authentification
│   │   ├── buyer_service.dart    # Services spécifiques à l'acheteur (incluant le portefeuille)
│   │   ├── hedera_service.dart   # Interactions avec Hedera (signature, soumission)
│   │   ├── order_service.dart    # Services de commande
│   │   └── product_service.dart  # Services de produits
│   └── ... (autres services et fichiers)
├── assets/                       # Ressources (images, icônes, polices)
├── android/                      # Configuration Android
├── ios/                          # Configuration iOS
├── pubspec.yaml                  # Dépendances et métadonnées du projet
└── ...
```

## Technologies Clés

- **Frontend :** Flutter (Dart)
- **Backend :** Spring Boot (Java)
- **Blockchain :** Hedera Hashgraph (HBAR)
- **Gestion d'état :** Riverpod
- **Requêtes HTTP :** Dio
- **Routage :** GoRouter
- **Stockage sécurisé :** `flutter_secure_storage`
- **Communication Native :** Platform Channels (pour l'interaction avec les SDK Hedera natifs)

## Fonctionnalités Implémentées (MVP)

Le MVP fonctionnel déployé sur le Hedera Testnet inclut :

- Création de Tokens Fongibles HTS représentant une quantité agricole.
- Création d’un Pool HBAR pour sécuriser le paiement acheteur.
- Smart contract contrôlant la libération conditionnelle du paiement.
- Interface Web simplifiée (enregistrement agriculteur/acheteur, visualisation tokens, simulation vente/livraison).

**Fonctionnalités spécifiques à l'application mobile (Buyer Wallet Endpoints) :**

- **Dépôt HBAR :** Préparation et confirmation des dépôts HBAR via `deposit_hbar_screen.dart`.
- **Association de Tokens :** Préparation de l'association de tokens AgriTokens via `associate_token_screen.dart`.
- **Échange d'AgriTokens :** Échange d'AgriTokens contre des biens physiques via `redeem_agritokens_screen.dart`.
- **Soumission de Transactions Hedera :** Gestion de la signature et soumission des transactions Hedera.

## Installation et Lancement

1.  **Cloner le dépôt :**
    ```bash
    git clone https://github.com/Artifique/AgrilendHedera.git
    cd AgrilendHedera
    ```
2.  **Installer les dépendances Flutter :**
    ```bash
    flutter pub get
    ```
3.  **Lancer l'application :**
    Assurez-vous d'avoir un émulateur ou un appareil physique connecté.
    ```bash
    flutter run
    ```

## Plan d'Évolution (vers le Mainnet)

- **Tests de Résilience :** Novembre 2025 → Janvier 2026 (charge, montée en échelle, sécurité, audits smart contracts).
- **Ajout Modules Qualité :** Février 2026 → Avril 2026 (oracles qualité, KYC partenaires).
- **Déploiement sur Mainnet :** Mai 2026 (activation paiements HBAR → FCFA, ouverture aux premiers acheteurs).
- **Expansion Régionale :** Juillet 2026 → Juin 2027 (Burkina Faso & Niger).
- **Intégration IA :** À partir de Janvier 2027 (modèles prédictifs).

## Défis Techniques et Solutions

- **Connectivité limitée en zones rurales :** Application optimisée pour faible bande passante + synchronisation différée.
- **Adoption de la blockchain par les producteurs :** Formation terrain + interface simplifiée + paiement en monnaie locale.
- **Sécurisation des paiements :** Smart contract paiement conditionnel + burn token non conforme.
- **Logistique & traçabilité :** Oracles qualité + partenaires logistiques contractuels.

## Contact

Pour toute question ou contribution, veuillez contacter l'équipe Agrilend.

---

**Code source :** `https://github.com/Artifique/AgrilendHedera`

**Glossaire :** HTS = Hedera Token Service, HCS = Hedera Consensus Service.
