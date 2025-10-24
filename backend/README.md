# Agrilend Backend - Plateforme de Tokenisation Agricole

## Vue d'ensemble

Agrilend est une plateforme innovante de tokenisation des récoltes agricoles utilisant la blockchain Hedera Hashgraph. Cette solution permet aux agriculteurs de tokeniser leurs récoltes, aux acheteurs de passer des commandes sécurisées avec un système de séquestre, et aux administrateurs de gérer l'ensemble du processus de validation et de distribution.

## Architecture

### Composants Principaux

L'architecture suit le diagramme de composants fourni dans les spécifications :

- **Frontend** : Applications React.js (Back Office), Flutter (Mobile), et Site Vitrine
- **Backend** : API Gateway Spring Boot avec services métier
- **DLT** : Intégration Hedera Hashgraph (HTS, HSCS, HCS)
- **Base de données** : MySQL pour la persistance des données

### Services Backend

1. **Service Utilisateurs** : Gestion des comptes et authentification
2. **Service Produits** : Catalogue des produits agricoles
3. **Service Commandes** : Gestion des commandes et du séquestre
4. **Service Logistique** : Suivi des livraisons
5. **Service Notifications** : Système de notifications
6. **Service Hedera** : Intégration blockchain complète

## Fonctionnalités Principales

### Pour les Agriculteurs
- Création et gestion des offres de produits
- Livraison des récoltes à l'entrepôt
- Suivi du processus de tokenisation
- Réception des paiements via tokens

### Pour les Acheteurs
- Recherche et consultation des produits disponibles
- Passage de commandes avec paiement sécurisé
- Système de séquestre 
- Confirmation de livraison et libération des fonds

### Pour les Administrateurs
- Validation des reçus d'entrepôt
- Gestion du processus de tokenisation
- Supervision des transactions Hedera
- Administration générale de la plateforme



## Technologies Utilisées

- **Framework** : Spring Boot 3.2.0
- **Base de données** : MySQL 8.0 / H2 (tests)
- **DLT** : Hedera Hashgraph SDK 2.30.0
- **Sécurité** : Spring Security + JWT
- **Documentation** :  Swagger
- **Build** : Maven
- **Java** : OpenJDK 17

## Installation et Configuration

### Prérequis
- Java 17+
- Maven 3.6+
- MySQL 8.0+ (optionnel, H2 inclus pour les tests)

### Configuration Hedera
Configurez les variables d'environnement suivantes :

```properties
HEDERA_NETWORK=testnet
HEDERA_OPERATOR_ACCOUNT_ID=0.0.YOUR_ACCOUNT
HEDERA_OPERATOR_PRIVATE_KEY=YOUR_PRIVATE_KEY
HEDERA_TREASURY_ACCOUNT_ID=0.0.YOUR_TREASURY
```

### Démarrage
```bash
# Cloner le projet
git clone <repository-url>
cd agrilend-backend

# Compiler et démarrer
mvn spring-boot:run
```

L'application sera accessible sur `http://localhost:8080`

## Documentation API

### Swagger UI
Accédez à la documentation interactive : `http://localhost:8080/swagger-ui.html`

### Endpoints Principaux

#### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `POST /api/auth/refresh` - Renouvellement du token


#### Offres et Commandes
- `GET /api/offers` - Lister les offres
- `POST /api/offers` - Créer une offre
- `POST /api/orders` - Passer une commande
- `GET /api/orders/{id}` - Détails d'une commande

## Tests avec Postman

### Collection Postman Incluse

Le projet inclut une collection Postman complète avec :
- Tests d'authentification
- Scénarios de tokenisation complets
- Tests des commandes avec séquestre
- Validation des intégrations Hedera

### Scénarios de Test

1. **Inscription et Connexion**
   - Créer un compte agriculteur
   - Créer un compte acheteur
   - Obtenir les tokens JWT

2. **Processus de Tokenisation**
   - Créer un reçu d'entrepôt
   - Valider le reçu (admin)
   - Préparer la transaction programmée
   - Signer et exécuter le minting

3. **Commandes et Séquestre**
   - Rechercher des produits
   - Passer une commande
   - Vérifier le séquestre automatique
   - Confirmer la livraison

## Sécurité

### Authentification JWT
- Tokens sécurisés avec HS512
- Expiration configurable (24h par défaut)
- Refresh tokens (7 jours par défaut)

### Autorisation par Rôles
- `FARMER` : Gestion des offres et récoltes
- `BUYER` : Passage de commandes
- `ADMIN` : Administration complète
- `AUDITOR` : Validation et audit

### Sécurité DLT
- Clés privées chiffrées
- Transactions signées

## Monitoring et Logs


### Logs Structurés
- Logs détaillés des transactions Hedera
- Traçabilité complète des opérations
- Alertes automatiques en cas d'erreur

## Déploiement

### Environnement de Production
1. Configurer MySQL en production
2. Définir les variables d'environnement Hedera
3. Configurer les certificats SSL
4. Déployer avec Docker (Dockerfile inclus)

### Variables d'Environnement
```bash
DB_USERNAME=agrilend_user
DB_PASSWORD=secure_password
JWT_SECRET=your_jwt_secret_key
HEDERA_NETWORK=mainnet
HEDERA_OPERATOR_ACCOUNT_ID=0.0.production_account
```

## Support et Maintenance



### Standards de Code
- Respect des conventions Spring Boot
- Tests unitaires obligatoires

### Roadmap
- [ ] Interface mobile Flutter
- [ ] Marketplace décentralisée


## Contact

Pour toute question technique ou commerciale :
- Email : dev@agrilend.com

