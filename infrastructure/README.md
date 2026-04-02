# Infrastructure BKN — Documentation

Ce dossier contient tous les fichiers et guides liés à l'infrastructure du projet BKN :
déploiement cloud, base de données, Docker et configuration des environnements.

---

## Contenu du dossier infrastructure/

```
infrastructure/
│
├── README.md                      ← Ce fichier (vue d'ensemble)
│
├── database/
│   ├── schema.sql                 ← Création des 5 tables PostgreSQL + index
│   └── seed.sql                   ← Données de test (users, transactions, crypto)
│
├── deploy/
│   ├── render.md                  ← Historique + guide Render.com (BDD en ligne alternative)
│   └── supabase.md                ← Guide configuration Supabase (solution finale)
│
└── env/
    └── .env.example               ← Template des variables d'environnement
```

---

## Architecture actuelle

```
┌─────────────────────────────────────────────────┐
│           Application Flutter (Android)         │
│        lib/services/api_helper.dart             │
│   Découverte auto du serveur via mDNS (bonsoir) │
└─────────────────────┬───────────────────────────┘
                      │ HTTP REST (JSON)
                      ▼
┌─────────────────────────────────────────────────┐
│          Backend FastAPI — Python 3.11          │
│   server.py — 1400+ lignes — 35+ endpoints      │
│   Port local : 8000 | Docker : 8001             │
└─────────────────────┬───────────────────────────┘
                      │ SSL requis — psycopg2
                      │ Port 6543 (connection pooler)
                      ▼
┌─────────────────────────────────────────────────┐
│         Base de données PostgreSQL              │
│         Hébergée sur Supabase (finale)          │
│    aws-0-us-west-2.pooler.supabase.com          │
└─────────────────────────────────────────────────┘
```

---

## Evolution de l'infrastructure

○ **Phase 1 — Docker Desktop** *(développement local)* :

    ■ API FastAPI + PostgreSQL 15 Alpine dans des conteneurs Docker
    ■ Tout tourne en local sur la machine Windows avec Docker Desktop
    ■ Commande : cd Backend && docker-compose up -d
    ■ Port API : 8001 → 8000  |  Port BDD : 5432
    ■ Idéal pour développer sans connexion internet

○ **Phase 2 — Render.com** *(première BDD en ligne)* :

    ■ Migration de Docker Desktop vers Render.com pour une BDD accessible en ligne
    ■ Render.com propose une base PostgreSQL gratuite avec chaque compte
    ■ Host : dpg-XXXXXX.oregon-postgres.render.com (port 5432)
    ■ Limitation rencontrée : BDD mise en veille après inactivité → données parfois perdues
    ■ Raison du passage à Supabase : plus stable, toujours actif

○ **Phase 3 — Supabase** *(solution finale et actuelle)* :

    ■ Migration depuis Render vers Supabase pour plus de fiabilité
    ■ PostgreSQL hébergé sur AWS Oregon, jamais en veille
    ■ Connexion via Connection Pooler (port 6543, SSL obligatoire)
    ■ Backups automatiques quotidiens inclus
    ■ Interface web (Table Editor) pour voir et modifier les données facilement

---

## Détail des fichiers

### database/ — Schémas et données SQL

○ **schema.sql** — A exécuter pour créer la BDD :

    ■ Table users               — Comptes utilisateurs + solde BKN
    ■ Table transactions        — Historique (achat, vente, transfert, réception)
    ■ Table crypto_transactions — Achats/ventes de cryptomonnaies
    ■ Table user_settings       — Préférences de sécurité (biométrie, 2FA, notifs)
    ■ Table user_sessions       — Sessions actives et appareils connectés
    ■ 6 index de performance    — Sur les colonnes les plus interrogées

○ **seed.sql** — Données de test initiales :

    ■ 4 utilisateurs (john, jane, bob, alice) — mot de passe : password123
    ■ 4 transactions BKN de démonstration
    ■ 3 transactions crypto (bitcoin, ethereum, solana)
    ■ 3 sessions actives d'exemple
    ■ Paramètres de sécurité par défaut pour chaque user

### deploy/ — Guides de déploiement

○ **render.md** — Historique + guide Render.com :

    ■ Explication du rôle de Render.com dans le projet (BDD gratuite en ligne)
    ■ Problèmes rencontrés avec la BDD Render (mise en veille, données perdues)
    ■ Guide optionnel pour héberger l'API FastAPI sur Render

○ **supabase.md** — Solution finale (base de données) :

    ■ Création du projet Supabase
    ■ Récupération des informations de connexion (Connection Pooler port 6543)
    ■ Exécution du schema.sql via l'éditeur SQL Supabase
    ■ Pourquoi le port 6543 et pas 5432
    ■ Procédure de reset complet de la base

### env/ — Variables d'environnement

○ **.env.example** — Template à copier dans Backend/.env :

    ■ Variables de connexion Supabase (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD)
    ■ Clé secrète JWT (JWT_SECRET_KEY)
    ■ Clé API SendGrid (emails reset mot de passe)
    ■ Section commentée pour la configuration Docker locale

---

## Docker Desktop — Phase 1 (local)

○ **Prérequis** :

    ■ Docker Desktop installé et démarré
    ■ WSL2 activé recommandé sur Windows

○ **Lancer l'environnement complet** :

```bash
cd Backend
docker-compose up -d
```

○ **Conteneurs démarrés** :

    ■ bkn_postgres — PostgreSQL 15 Alpine (port 5432)
        - BDD locale, volume persistant : bkn_postgres_data
        - Indépendante de Supabase

    ■ bkn_api — Python 3.11-slim FastAPI (port 8001 → 8000)
        - Attend que PostgreSQL soit sain (healthcheck) avant de démarrer
        - Réseau interne : bkn_network (bridge)

○ **Commandes utiles** :

```bash
docker-compose ps           # Voir l'état des conteneurs
docker-compose logs api     # Logs de l'API
docker-compose down         # Arrêter
docker-compose down -v      # Arrêter + supprimer les volumes (reset BDD)
```

○ **Scripts Windows disponibles** :

    ■ Backend/lancer_serveur.bat   — Lance uniquement le serveur Python FastAPI (python server.py)
    ■ Backend/docker-start.bat     — Lance les conteneurs Docker (docker-compose build + up)
    ■ Backend/docker-stop-all.bat  — Arrête tous les conteneurs Docker

---

## Render.com — Phase 2 (1ère BDD en ligne)

○ **Ce qui a été utilisé** :

    ■ Base PostgreSQL gratuite fournie par Render.com
    ■ Accessible depuis n'importe où (pas juste en local)
    ■ Même région Oregon que Supabase — migration facile ensuite

○ **Limitation rencontrée** :

    ■ Mise en veille de la BDD après période d'inactivité
    ■ "Cold start" long (30-50 sec) au réveil
    ■ Migration vers Supabase pour plus de stabilité

---

## Supabase — Phase 3 (solution finale)

○ **Connexion (Connection Pooler)** :

    ■ Host     : aws-0-us-west-2.pooler.supabase.com
    ■ Port     : 6543 (pooler — mode Transaction)
    ■ Database : postgres
    ■ SSL      : require (obligatoire)

○ **Pourquoi Supabase est meilleur que Render pour la BDD ?** :

    ■ Jamais en veille — toujours disponible immédiatement
    ■ Connection Pooler (port 6543) = meilleure gestion des connexions simultanées
    ■ Interface web pour voir et modifier les données en temps réel
    ■ Backups automatiques quotidiens

---

## A FAIRE — Tâches restantes

○ **Priorité haute** :

    ■ [ ] Déplacer les credentials DB de server.py vers le fichier .env
    ■ [ ] Restreindre les CORS en production (pas allow_origins=["*"])
    ■ [ ] Implémenter les tokens JWT signés (python-jose est déjà installé)

○ **Priorité moyenne** :

    ■ [ ] Ajouter un fichier render.yaml (déploiement Infrastructure as Code)
    ■ [ ] Créer un Makefile racine (make start, make stop, make migrate)
    ■ [ ] Mettre en place un monitoring uptime (UptimeRobot gratuit)

○ **Améliorations futures** :

    ■ [ ] Système de migrations Alembic (évolution du schéma sans reset)
    ■ [ ] Pipeline CI/CD GitHub Actions (lint + tests + deploy auto)
    ■ [ ] Stocker les avatars sur Supabase Storage (au lieu de /avatars/ local)
    ■ [ ] Ajouter des tests unitaires pour les endpoints critiques

---

## Points de sécurité à corriger

○ **Credentials hardcodés dans server.py** :

    ■ Les informations de connexion Supabase sont actuellement écrites directement
      dans le code source de server.py (lignes 104-108)
    ■ A déplacer dans le fichier .env et charger avec python-dotenv
    ■ Risque : exposition des credentials sur GitHub si le fichier est commité

○ **CORS trop ouvert** :

    ■ allow_origins=["*"] autorise n'importe quel domaine à appeler l'API
    ■ En production, restreindre aux domaines autorisés uniquement

○ **Authentification sans JWT signé** :

    ■ Actuellement le login retourne les données brutes de l'utilisateur
    ■ Implémenter un vrai token JWT avec python-jose (déjà dans requirements.txt)
    ■ Protéger les endpoints sensibles avec un middleware d'authentification

---

*Dernière mise à jour : Avril 2026 | Auteur : Patrice Beausoleil*
