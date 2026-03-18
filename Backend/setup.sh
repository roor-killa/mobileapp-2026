#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════════════
#   MoneyTransferApp - Script de démarrage
#   Usage: ./setup.sh [--fresh]
#   --fresh : recrée la base de données depuis zéro
# ═══════════════════════════════════════════════════════════════════

FRESH=${1:-""}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     MoneyTransferApp - Backend Setup     ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── Vérification de Docker ───────────────────────────────────────────────────
if ! command -v docker &> /dev/null; then
    echo "[ERREUR] Docker n'est pas installé."
    echo "→ Téléchargez Docker Desktop : https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "[ERREUR] Docker n'est pas démarré. Lancez Docker Desktop d'abord."
    exit 1
fi

echo "[OK] Docker est disponible."

# ─── Copier .env si absent ────────────────────────────────────────────────────
if [ ! -f .env ]; then
    echo "[INFO] Création du fichier .env..."
    cp .env.example .env
    echo "[OK] .env créé. Pensez à renseigner vos clés Stripe dans .env"
fi

# ─── Build et démarrage des containers ───────────────────────────────────────
echo ""
echo "[INFO] Construction et démarrage des containers Docker..."
docker-compose up -d --build

echo ""
echo "[INFO] Attente du démarrage des services (30s)..."
sleep 30

# ─── Vérifier que le container app est up ─────────────────────────────────────
if ! docker-compose ps | grep -q "moneytransfer_app.*Up"; then
    echo "[ERREUR] Le container app n'a pas démarré correctement."
    echo "Vérifiez les logs : docker-compose logs app"
    exit 1
fi

echo "[OK] Containers démarrés."

# ─── Migrations ───────────────────────────────────────────────────────────────
echo ""
if [ "$FRESH" = "--fresh" ]; then
    echo "[INFO] Remise à zéro de la base de données..."
    docker-compose exec app php artisan migrate:fresh --seed --force
else
    echo "[INFO] Exécution des migrations + seeders..."
    docker-compose exec app php artisan migrate --seed --force
fi

# ─── Installer Ollama LLaMA 3.2 ───────────────────────────────────────────────
echo ""
echo "[INFO] Téléchargement du modèle Ollama (llama3.2)..."
echo "       (Cette opération peut prendre plusieurs minutes selon votre connexion)"
docker-compose exec ollama ollama pull llama3.2 || echo "[WARN] Impossible de télécharger llama3.2, faites-le manuellement."

# ─── Résumé ───────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   SETUP TERMINÉ !                           ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  API Laravel    →  http://localhost:8000/api/v1             ║"
echo "║  PgAdmin        →  http://localhost:5050                    ║"
echo "║    Email: admin@moneytransfer.local / MDP: admin            ║"
echo "║  Ollama         →  http://localhost:11434                   ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Comptes de test :                                          ║"
echo "║    alice@test.com / password / PIN: 123456 (1000,00 €)      ║"
echo "║    bob@test.com   / password / PIN: 123456 (500,00 €)       ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Commandes utiles :                                         ║"
echo "║    docker-compose logs -f app     → Logs Laravel            ║"
echo "║    docker-compose exec app bash   → Shell Laravel           ║"
echo "║    docker-compose down            → Arrêter                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
