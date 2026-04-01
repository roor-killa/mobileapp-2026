# Infrastructure — PayFlow

## Vue d'ensemble

L'infrastructure repose entièrement sur **Docker** et **Docker Compose**. Chaque service tourne dans son propre container isolé, communicant via un réseau interne dédié.

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                           │
│                   (moneytransfer_network)                       │
│                                                                 │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐    │
│  │  nginx   │   │   app    │   │ postgres │   │  redis   │    │
│  │  :8000   │──▶│  :9000   │──▶│  :5432   │   │  :6379   │    │
│  │          │   │ (PHP-FPM)│   │          │   │          │    │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘    │
│                                                                 │
│  ┌──────────┐   ┌──────────┐                                   │
│  │  ollama  │   │ pgadmin  │                                   │
│  │  :11434  │   │  :5050   │                                   │
│  └──────────┘   └──────────┘                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Services Docker

### 1. `app` — Application Laravel (PHP-FPM)

| Propriété | Valeur |
|-----------|--------|
| Image | `php:8.2-fpm` (custom) |
| Port interne | 9000 (PHP-FPM) |
| Dépendances | `postgres` (healthy), `redis` (healthy) |
| Volume | `.:/var/www` (code source monté) |

**Extensions PHP installées :**
- `pdo_pgsql` — Connexion PostgreSQL
- `sodium` — Signature Ed25519 (Algorand)
- `redis` — Cache et sessions
- `bcmath` — Calculs financiers précis
- `gd`, `zip`, `mbstring`, `exif`, `pcntl`

**Bootstrap automatique (`entrypoint.sh`) :**
1. Installation Laravel si absent
2. `composer install` — dépendances
3. Génération de la clé applicative
4. Attente PostgreSQL (health check)
5. `php artisan migrate --graceful` — migrations
6. `php artisan config:cache` + `route:cache`
7. Démarrage PHP-FPM

---

### 2. `nginx` — Serveur Web

| Propriété | Valeur |
|-----------|--------|
| Image | `nginx:1.25-alpine` |
| Port exposé | **8000** → 80 |
| Configuration | `nginx/default.conf` |

**Rôle :** Reçoit les requêtes HTTP, les transmet à PHP-FPM via FastCGI.

**Configuration clé :**
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
location ~ \.php$ {
    fastcgi_pass app:9000;
}
```

---

### 3. `postgres` — Base de données

| Propriété | Valeur |
|-----------|--------|
| Image | `postgres:16-alpine` |
| Port exposé | **5432** |
| Base de données | `moneytransfer` |
| Volume | `postgres_data` (persistant) |

**Health check :**
```yaml
test: ["CMD-SHELL", "pg_isready -U moneytransfer_user"]
interval: 10s
retries: 5
```

Le container `app` ne démarre qu'une fois PostgreSQL déclaré **healthy**.

---

### 4. `redis` — Cache & Sessions

| Propriété | Valeur |
|-----------|--------|
| Image | `redis:7-alpine` |
| Port exposé | **6379** |
| Rôle | Cache config, sessions utilisateurs, queues |

**Configuration Laravel (`.env`) :**
```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

---

### 5. `ollama` — IA Locale (Chatbot)

| Propriété | Valeur |
|-----------|--------|
| Image | `ollama/ollama:latest` |
| Port exposé | **11434** |
| Modèle | LLaMA 3.2 |
| Volume | `ollama_data` (modèles persistants) |

**Téléchargement du modèle :**
```bash
docker exec moneytransfer_ollama ollama pull llama3.2
```

> Le modèle LLaMA 3.2 tourne entièrement **en local** — aucune donnée ne quitte le serveur.

---

### 6. `pgadmin` — Interface graphique PostgreSQL

| Propriété | Valeur |
|-----------|--------|
| Image | `dpage/pgadmin4:latest` |
| Port exposé | **5050** |
| Email | admin@admin.com |
| Mot de passe | admin |

Accessible sur : **http://localhost:5050**

---

## Volumes Docker

| Volume | Contenu | Persistant |
|--------|---------|------------|
| `postgres_data` | Données PostgreSQL | Oui |
| `ollama_data` | Modèles IA téléchargés | Oui |

---

## Réseau Docker

Tous les containers communiquent via le réseau interne `moneytransfer_network` (bridge). Seuls les ports **explicitement exposés** sont accessibles depuis l'hôte.

```yaml
networks:
  moneytransfer_network:
    driver: bridge
```

---

## Variables d'environnement (`.env`)

```env
# Application
APP_NAME=PayFlow
APP_ENV=local
APP_KEY=base64:...
APP_URL=http://localhost:8000

# Base de données
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=moneytransfer
DB_USERNAME=moneytransfer_user
DB_PASSWORD=secret

# Redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
REDIS_PORT=6379

# Stripe
STRIPE_KEY=pk_test_...
STRIPE_SECRET=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Ollama
OLLAMA_HOST=http://ollama:11434
OLLAMA_MODEL=llama3.2

# Algorand
ALGORAND_MNEMONIC=...
ALGORAND_ADDRESS=...

# QR Code
QR_TOKEN_TTL=10
QR_HMAC_SECRET=...
```

---

## Commandes utiles

```bash
# Démarrer tous les services
docker-compose up -d --build

# Arrêter tous les services
docker-compose down

# Voir les logs en temps réel
docker-compose logs -f app

# Accéder au shell Laravel
docker-compose exec app bash

# Exécuter une commande Artisan
docker-compose exec app php artisan migrate

# Remettre à zéro la base de données
docker-compose exec app php artisan migrate:fresh --seed

# Voir le statut des containers
docker-compose ps
```

---

## Premier démarrage

```bash
cd Backend
cp .env.example .env
# Renseigner les clés Stripe et Algorand dans .env
chmod +x setup.sh
./setup.sh
```

Le script `setup.sh` :
1. Vérifie que Docker est démarré
2. Build et lance les containers
3. Attend 30 secondes
4. Exécute les migrations et les seeders
5. Télécharge le modèle Ollama llama3.2
6. Affiche un résumé avec les URLs et les comptes de test
