# mobileapp-2026
Création application mobile L3 2026

# BKN - Application de Paiement Étudiant

**Auteur** : Patrice Beausoleil  
**Version** : 2.0.0  
**Dépôt** : https://github.com/roor-killa/mobileapp-2026/tree/beausoleil

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

    ■ Android Studio (dernière version)
        - SDK Android
        - Émulateur Android (optionnel)
    
    ■ Un smartphone Android physique
        - Modèle de test : Samsung Galaxy S10
        - Mode développeur activé
        - Débogage USB activé
    
    ■ Flutter SDK (version 3.0 ou supérieure)
    
    ■ Python (version 3.11 ou supérieure)
    
    ■ Docker Desktop (pour les tests en local)
        - Windows : Docker Desktop for Windows
        - WSL2 activé recommandé
    
    ■ Git
    
    ■ PostgreSQL (optionnel, pour développement local)
    
    ■ Comptes en ligne requis :
        - Supabase (base de données alternative)
        - Render.com (hébergement backend)
        - GitHub (gestion de version)


## 2. Structure du Backend

○ **Arborescence complète** :

```
Backend/
│
├── server.py                           
├── requirements.txt                    
├── .env                                
├── .gitignore                          
│
├── avatars/                            
│   ├── avatar_1_8c489415.jpg
│   ├── avatar_1_461855a0.jpg
│   └── avatar_2_501faaf6.jpg
│
├── docker-compose.yml                   
├── Dockerfile                           
├── docker-start.bat                     
├── docker-stop-all.bat                  
│
├── test_connexion.py                    
├── fix_avatar.py                         
├── check_avatar_db.py                    
├── copy_avatar_to_jane.py                
│
└── __pycache__/                          
```

○ **Fichiers de configuration** :

    ■ server.py :
        - 1200+ lignes de code
        - 30+ endpoints REST
        - Authentification JWT
        - Gestion des uploads
        - Connexion PostgreSQL
    
    ■ requirements.txt :
```
fastapi==0.110.0
uvicorn[standard]==0.27.1
psycopg2-binary==2.9.9
python-dotenv==1.0.1
pydantic==2.6.3
passlib==1.7.4
bcrypt==4.0.1
ifaddr==0.2.0
zeroconf==0.148.0
python-multipart==0.0.22
python-jose[cryptography]==3.5.0
tenacity==8.2.2
```

○ **Docker** :

    ■ docker-compose.yml :
```yaml
services:
  api:
    build: .
    container_name: bkn_api
    restart: unless-stopped
    ports:
      - "8001:8000"
    environment:
      - DB_HOST=${DB_HOST}
      - DB_PORT=5432
      - DB_NAME=${DB_NAME}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
    volumes:
      - ./:/app
```

    ■ Dockerfile :
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
```

○ **Scripts utilitaires** :

    ■ test_connexion.py : Vérifie la connexion à la base de données
    ■ fix_avatar.py : Corrige les URLs d'avatar en base
    ■ check_avatar_db.py : Affiche les URLs d'avatar stockées
    ■ copy_avatar_to_jane.py : Copie un avatar d'un utilisateur à un autre


## 3. Structure de l'application mobile

○ **Arborescence Flutter** :

```
app_bkn/
│
├── pubspec.yaml                          
├── pubspec.lock                           
│
├── lib/
│   ├── main.dart                          
│   │
│   ├── models/                            
│   │   ├── crypto.dart                     
│   │   ├── transaction.dart                 
│   │   ├── user.dart                       
│   │   └── wallet.dart                      
│   │
│   ├── providers/                          
│   │   ├── crypto_provider.dart             
│   │   ├── transaction_provider.dart         
│   │   └── user_provider.dart                
│   │
│   ├── screens/                             
│   │   ├── login_screen.dart                 
│   │   ├── register_screen.dart               
│   │   ├── splash_screen.dart                 
│   │   ├── home_screen.dart                   
│   │   ├── profile_screen.dart                 
│   │   ├── edit_profile_screen.dart            
│   │   ├── security_screen.dart                
│   │   ├── buy_screen.dart                     
│   │   ├── sell_screen.dart                    
│   │   ├── transfer_screen.dart                
│   │   ├── crypto_screen.dart                  
│   │   ├── history_screen.dart                 
│   │   ├── analytics_screen.dart                
│   │   ├── scan_screen.dart                    
│   │   ├── qr_receive_screen.dart              
│   │   └── chatbot_screen.dart                  
│   │
│   ├── services/                            
│   │   ├── api_service.dart                   
│   │   └── api_helper.dart                     
│   │
│   ├── theme/                                
│   │   └── app_theme.dart                      
│   │
│   └── widgets/                              
│       ├── balance_card.dart                   
│       ├── action_grid.dart                     
│       └── recent_transactions.dart             
│
├── android/                                 
├── ios/                                     
├── build/                                   
└── .dart_tool/                              
```


## 4. Installation du backend

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
    JWT_SECRET_KEY=une_clé_très_longue_et_aléatoire_32_caractères_minimum
    ```

○ **Lancement du serveur** :

```
python server.py
```

○ **Accès à l'API** :

    ■ API : http://10.142.232.211:8000
    ■ Documentation Swagger : http://10.142.232.211:8000/docs


## 5. Installation de l'application mobile

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

○ **Préparer le smartphone Android** :

    ■ Activer le mode développeur sur le Samsung Galaxy S10
        - Paramètres > À propos du téléphone > Numéro de build (taper 7 fois)
    
    ■ Activer le débogage USB
        - Paramètres > Options développeurs > Débogage USB
    
    ■ Connecter le téléphone en USB
    ■ Vérifier la connexion :
    ```
    flutter devices
    ```
    Le Samsung Galaxy S10 doit apparaître dans la liste

○ **Lancer l'application** :

```
flutter run
```


## 6. Tests en local avec Docker Desktop

○ **Démarrer Docker Desktop** :

    ■ Lancer Docker Desktop depuis le menu Démarrer
    ■ Vérifier que Docker fonctionne :
    ```
    docker --version
    docker-compose --version
    ```

○ **Lancer le backend avec Docker** :

```
cd C:\Licence\Backend
docker-compose up -d
```

○ **Vérifier les conteneurs** :

```
docker-compose ps
```

○ **Arrêter les conteneurs** :

```
docker-compose down
```


## 7. Base de données

○ **Options d'hébergement** :

    ■ Render.com (utilisé en production)
        - Base PostgreSQL gratuite
        - SSL requis
        - Backup automatiques
        - Host : dpg-d6nhn0nafjfc73flf4t0-a.oregon-postgres.render.com
    
    ■ Supabase (alternative)
        - Interface graphique
        - Authentification intégrée
        - Stockage fichiers
        - Idéal pour le développement

○ **Schéma principal** (table users) :

```sql
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    pseudo VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    solde DECIMAL(15,2) DEFAULT 1500.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_level VARCHAR(50) DEFAULT 'Niveau 1',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    avatar_url TEXT
);
```

○ **Tables supplémentaires** :

    ■ transactions : Historique des opérations BKN
    ■ crypto_transactions : Achats/ventes de crypto
    ■ user_settings : Préférences de sécurité
    ■ user_sessions : Gestion des connexions

○ **Utilisateurs par défaut** :

    ■ ID 1 : john.doe@email.com / password123 (5000 BKN)
    ■ ID 2 : jane.smith@email.com / password123 (3000 BKN)
    ■ ID 3 : bob.martin@email.com / password123 (2000 BKN)
    ■ ID 4 : alice.wonder@email.com / password123 (4500 BKN)


## 8. API Endpoints

○ **Authentification** :

    ■ POST /login - Connexion utilisateur
    ■ POST /register - Inscription (bonus 100 BKN)

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


## 9. Fonctionnalités de l'application

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

    ■ Bitcoin (BTC) : 45000 €
    ■ Ethereum (ETH) : 2800 €
    ■ Solana (SOL) : 98 €
    ■ Cardano (ADA) : 0.45 €
    ■ Polkadot (DOT) : 6.50 €
    ■ Avalanche (AVAX) : 35 €

○ **Paiement mobile** :

    ■ Génération de QR code personnel
    ■ Scan de QR code pour payer
    ■ Transactions instantanées

○ **Assistant virtuel** :

    ■ Chatbot "Félicité" intégré
    ■ Réponses aux questions fréquentes
    ■ Aide contextuelle


## 10. Captures d'écran

○ **Écran de connexion** : Authentification utilisateur
○ **Accueil** : Solde et actions rapides
○ **Profil** : Informations personnelles et photo
○ **Achat de BKN** : Interface de paiement
○ **Portefeuille crypto** : Solde et graphiques
○ **QR Code** : Réception de paiement


## 11. Conclusion

○ **Fonctionnalités implémentées** :

    ✓ Authentification complète
    ✓ Gestion de profil avec avatar
    ✓ Transactions BKN (achat, vente, transfert)
    ✓ Intégration cryptomonnaies
    ✓ Paiement par QR code
    ✓ Assistant virtuel
    ✓ Paramètres de sécurité
    ✓ Historique des transactions

○ **Environnements de test** :

    ■ Développement local : Docker Desktop
    ■ Base de données : Render.com / Supabase
    ■ Mobile : Samsung Galaxy S10 (physique)
    ■ Émulateur : Android Studio (optionnel)

○ **Technologies utilisées** :

    ■ Flutter pour l'application mobile
    ■ FastAPI pour le backend
    ■ PostgreSQL pour la base de données
    ■ Render.com pour l'hébergement
    ■ Docker pour la conteneurisation
    ■ Supabase (optionnel)

○ **Lien vers le dépôt GitHub** :

    https://github.com/roor-killa/mobileapp-2026/tree/beausoleil
