# 🚀 BKN Wallet

BKN Wallet est une application financière mobile full-stack permettant de gérer un portefeuille principal, des sous-comptes (Pockets), et d'interagir avec un assistant IA financier exclusif.

## 🌟 Fonctionnalités Principales
* **Authentification Sécurisée :** Inscription, connexion et gestion du profil (Sanctum).
* **Tableau de Bord (Live Balance) :** Affichage en temps réel du solde principal et des Pockets.
* **Gestion des Pockets :** Création de sous-comptes et transferts instantanés depuis/vers le compte principal.
* **Marché Crypto BKN :** Suivi de l'évolution du BKN, achat et vente avec mise à jour immédiate du portefeuille.
* **Assistant IA (Agent-BKN) :** Chatbot propulsé par Google Gemini, conscient du contexte de l'utilisateur (il connaît en temps réel le solde et les sous-comptes de l'utilisateur pour lui répondre de manière personnalisée).
* **Sécurité :** Modification du mot de passe via une interface sécurisée.

## 🛠️ Stack Technique
* **Frontend :** Flutter (Dart)
* **Backend :** Laravel (PHP)
* **Base de données :** PostgreSQL
* **Infrastructure :** Docker & Docker Compose (Nginx, PHP, DB)
* **IA :** API Google Gemini (Modèle 1.5/2.5 Flash)

## ⚙️ Installation & Lancement

### 1. Backend (Docker / Laravel)
```bash
cd backend
cp .env.example .env
# Remplir les variables d'environnement (DB, GEMINI_API_KEY)
docker compose up -d
docker compose exec app php artisan migrate
