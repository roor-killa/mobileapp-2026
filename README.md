# mobileapp-2026
Création application mobile L3 2026

# BKN - Application de Paiement Étudiant

**Auteur** : Patrice Beausoleil  
**Version** : 2.0.0  
**Dépôt** : https://github.com/repl-fr/cbs-tp7-PatocheBSL

○ **Contenu du projet** :

    ■ Application mobile Flutter
    ■ API Backend FastAPI
    ■ Base de données PostgreSQL
    ■ Hébergement sur Render.com
    ■ Authentification JWT
    ■ Upload de photos de profil
    ■ Transactions BKN (1 BKN = 1€)
    ■ Achat/vente de cryptomonnaies
    ■ Paiement par QR code
    ■ Chatbot intégré


## 1. Prérequis

○ **Outils nécessaires** :

    ■ Flutter SDK (version 3.0 ou supérieure)
    ■ Python (version 3.11 ou supérieure)
    ■ Docker et Docker Compose
    ■ Git
    ■ PostgreSQL (optionnel, pour développement local)


## 2. Installation du backend

○ **Clonage du dépôt** :

```
git clone https://github.com/repl-fr/cbs-tp7-PatocheBSL.git
cd cbs-tp7-PatocheBSL/backend
```

○ **Installation des dépendances Python** :

```
pip install -r requirements.txt
```

○ **Configuration de la base de données** :

    ■ Créer un fichier .env avec les identifiants Render
    ```
    DB_HOST=dpg-d6nhn0nafjfc73flf4t0-a.oregon-postgres.render.com
    DB_PORT=5432
    DB_NAME=bkn_db
    DB_USER=bkn_user
    DB_PASSWORD=votre_mot_de_passe
    ```

○ **Lancement du serveur** :

```
python server.py
```

○ **Accès à l'API** :

    ■ API : http://10.142.232.211:8000
    ■ Documentation Swagger : http://10.142.232.211:8000/docs


## 3. Installation de l'application mobile

○ **Se placer dans le dossier Flutter** :

```
cd ../app_bkn
```

○ **Installer les dépendances Flutter** :

```
flutter pub get
```

○ **Configurer l'adresse du serveur** :

    ■ Modifier le fichier lib/services/api_helper.dart
    ■ Remplacer l'IP par celle de votre serveur
    ```dart
    static const String _manualFallbackIp = '10.142.232.211';
    ```

○ **Lancer l'application** :

```
flutter run
```


## 4. Base de données

○ **Schéma principal** :

    ■ Table users : stocke les informations utilisateur
    ■ Table transactions : historique des opérations BKN
    ■ Table crypto_transactions : achats/ventes de crypto
    ■ Table user_settings : préférences de sécurité
    ■ Table user_sessions : gestion des connexions

○ **Utilisateurs par défaut** :

    ■ john.doe@email.com / password123 (5000 BKN)
    ■ jane.smith@email.com / password123 (3000 BKN)
    ■ bob.martin@email.com / password123 (2000 BKN)


## 5. API Endpoints

○ **Authentification** :

    ■ POST /login - Connexion utilisateur
    ■ POST /register - Inscription

○ **Utilisateurs** :

    ■ GET /users - Liste des utilisateurs
    ■ GET /user/{id} - Détails d'un utilisateur
    ■ GET /balance/{id} - Solde BKN
    ■ PUT /user/{id} - Modifier le profil
    ■ POST /user/{id}/avatar - Upload photo

○ **Transactions** :

    ■ POST /transfer - Transférer des BKN
    ■ POST /buy - Acheter des BKN
    ■ POST /sell - Vendre des BKN
    ■ GET /history/{id} - Historique

○ **Cryptomonnaies** :

    ■ GET /crypto/prices - Prix actuels
    ■ POST /crypto/buy - Acheter crypto
    ■ POST /crypto/sell - Vendre crypto
    ■ GET /crypto/balance/{id} - Solde crypto
    ■ GET /crypto/history/{id} - Historique crypto

○ **Sécurité** :

    ■ GET /user/{id}/settings - Paramètres
    ■ PUT /user/{id}/settings - Modifier paramètres
    ■ GET /user/{id}/sessions - Sessions actives
    ■ DELETE /user/session/{id} - Déconnecter une session


## 6. Fonctionnalités de l'application

○ **Authentification** :

    ■ Page de connexion sécurisée
    ■ Inscription avec bonus de 100 BKN
    ■ Gestion de session automatique

○ **Profil utilisateur** :

    ■ Affichage des informations personnelles
    ■ Modification du profil
    ■ Upload de photo de profil
    ■ Paramètres de sécurité (notifications, biométrie, 2FA)

○ **Portefeuille BKN** :

    ■ Solde en temps réel (1 BKN = 1€)
    ■ Achat de BKN par carte bancaire
    ■ Vente de BKN
    ■ Transfert entre utilisateurs

○ **Cryptomonnaies supportées** :

    ■ Bitcoin (BTC)
    ■ Ethereum (ETH)
    ■ Solana (SOL)
    ■ Cardano (ADA)
    ■ Polkadot (DOT)
    ■ Avalanche (AVAX)

○ **Paiement mobile** :

    ■ Génération de QR code personnel
    ■ Scan de QR code pour payer
    ■ Transactions instantanées

○ **Assistant virtuel** :

    ■ Chatbot "Félicité" intégré
    ■ Réponses aux questions fréquentes
    ■ Aide contextuelle


## 7. Structure du projet

○ **Backend (FastAPI)** :

    server.py          : Point d'entrée de l'API
    requirements.txt   : Dépendances Python
    avatars/          : Photos de profil uploadées

○ **Application mobile (Flutter)** :

    lib/
    ├── main.dart                    : Point d'entrée
    ├── models/                      : Classes de données
    │   ├── crypto.dart
    │   ├── transaction.dart
    │   └── user.dart
    ├── providers/                    : State management
    │   ├── crypto_provider.dart
    │   ├── transaction_provider.dart
    │   └── user_provider.dart
    ├── screens/                       : Écrans de l'application
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── home_screen.dart
    │   ├── profile_screen.dart
    │   ├── buy_screen.dart
    │   ├── sell_screen.dart
    │   ├── transfer_screen.dart
    │   ├── crypto_screen.dart
    │   └── ...
    ├── services/                       : Communication API
    │   ├── api_service.dart
    │   └── api_helper.dart
    ├── theme/                          : Thème de l'application
    │   └── app_theme.dart
    └── widgets/                        : Composants réutilisables
        ├── balance_card.dart
        ├── action_grid.dart
        └── recent_transactions.dart


## 8. Déploiement avec Docker

○ **Fichier docker-compose.yml** :

```yaml
services:
  api:
    build: .
    container_name: bkn_api
    ports:
      - "8001:8000"
    environment:
      - DB_HOST=${DB_HOST}
      - DB_NAME=${DB_NAME}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
    volumes:
      - ./:/app
```

○ **Lancement des conteneurs** :

```
docker-compose up -d
```

○ **Arrêt des conteneurs** :

```
docker-compose down
```


## 9. Captures d'écran

○ **Écran de connexion** : Authentification utilisateur
○ **Accueil** : Solde et actions rapides
○ **Profil** : Informations personnelles et photo
○ **Achat de BKN** : Interface de paiement
○ **Portefeuille crypto** : Solde et graphiques
○ **QR Code** : Réception de paiement


## 10. Conclusion

○ **Fonctionnalités implémentées** :

    ✓ Authentification complète
    ✓ Gestion de profil avec avatar
    ✓ Transactions BKN (achat, vente, transfert)
    ✓ Intégration cryptomonnaies
    ✓ Paiement par QR code
    ✓ Assistant virtuel
    ✓ Paramètres de sécurité
    ✓ Historique des transactions

○ **Technologies utilisées** :

    ■ Flutter pour l'application mobile
    ■ FastAPI pour le backend
    ■ PostgreSQL pour la base de données
    ■ Render.com pour l'hébergement
    ■ Docker pour la conteneurisation

○ **Lien vers le dépôt GitHub** :

    
