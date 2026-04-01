# mobileapp-2026
Création application mobile L3 2026

# MyWallet

### Auteur : Mathis Rénac
#### Présentation dans le fichier MyWallet.pdf
---

## Description

MyWallet est une application mobile de type portefeuille financier développée avec Flutter. Elle permet de gérer des utilisateurs, d’effectuer des transferts d’argent et de consulter l’historique des transactions.

Le projet repose sur une architecture avec un backend Laravel, une base de données PostgreSQL et une infrastructure conteneurisée via Docker.

---

## Stack technique

- Frontend mobile : Flutter  
- Backend : Laravel (API REST)  
- Base de données : PostgreSQL  
- Infrastructure : Docker (docker-compose)  
- Proxy : Nginx  
- Frontend : Next.js  

---

## Fonctionnalités

- Authentification (login et register)  
- Transfert d’argent entre utilisateurs  
- Historique des transactions  
- Dashboard administrateur  
- Ajout d’argent par l’administrateur  
- Gestion et affichage des utilisateurs  

---

## Architecture du projet

### Frontend Flutter (`/lib`)

Structure :
```
lib/
│
├── models/
│ └── transfer_response.dart
│
├── screens/
│ ├── login_screen.dart
│ ├── transfer_screen.dart
│ └── admin_screen.dart
│
├── services/
│ └── api_service.dart
│
└── main.dart
```
---
## Communication

L’application Flutter communique avec le backend via une API REST en JSON.

Base URL :
http://localhost:8001/api/


---

## API Endpoints

Principaux endpoints utilisés :

- POST /login : connexion utilisateur  
- POST /register : création de compte  
- POST /transfer : transfert d’argent  
- GET /users : liste des utilisateurs  
- GET /user/{id} : récupération d’un utilisateur  

Exemple :
http://localhost:8001/api/users?is_admin=true

---

## Infrastructure Docker

Les services sont gérés via Docker Compose dans le dossier :
Infrastructure/


Services inclus :

- nginx_proxy  
- laravel_backend  
- postgres_db  
- nextjs_frontend  

---

## Installation et lancement

Depuis le dossier :
Infrastructue/infra/

Exécuter la commande :

```bash 
docker compose up -d --build
```


Une fois les conteneurs lancés, l'api est accessible sur :

http://localhost:8001

---

## Remarques

- L’application nécessite que les conteneurs Docker soient en cours d’exécution. 
- Les échanges entre Flutter et Laravel se font via des requêtes HTTP.
- PostgreSQL est utilisé pour la persistance des données.

---
## Améliorations possibles

- Authentification sécurisée avec tokens (Sanctum ou JWT)
- Gestion des rôles avancée
- Amélioration de l’interface utilisateur
- Notifications en temps réel
