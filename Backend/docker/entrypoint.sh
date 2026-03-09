#!/bin/bash
set -e

echo "========================================"
echo "  MoneyTransferApp - Laravel Backend"
echo "========================================"

# ─── Installer Laravel si le projet n'existe pas encore ──────────────────────
if [ ! -f /var/www/artisan ]; then
    echo "[INFO] Aucun projet Laravel détecté. Installation en cours..."
    composer create-project laravel/laravel /tmp/laravel --prefer-dist --no-interaction

    # -n = no-clobber : ne jamais écraser nos fichiers custom déjà présents
    # (routes/api.php, app/Models/, app/Http/Controllers/, bootstrap/app.php...)
    cp -rn /tmp/laravel/. /var/www/
    rm -rf /tmp/laravel
    echo "[OK] Projet Laravel installé."
fi

# ─── Synchroniser les dépendances Composer ────────────────────────────────────
echo "[INFO] Synchronisation des dépendances Composer..."
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
echo "[OK] Dépendances installées."

# ─── Configuration .env ───────────────────────────────────────────────────────
if [ ! -f /var/www/.env ]; then
    echo "[INFO] Création du fichier .env..."
    cp /var/www/.env.example /var/www/.env
fi

# ─── Générer la clé d'application ─────────────────────────────────────────────
if ! grep -q "APP_KEY=base64:" /var/www/.env 2>/dev/null; then
    echo "[INFO] Génération de la clé applicative..."
    php /var/www/artisan key:generate --force
fi

# ─── Permissions storage/ ────────────────────────────────────────────────────
chmod -R 775 /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true

# ─── Attendre PostgreSQL ───────────────────────────────────────────────────────
echo "[INFO] Attente de PostgreSQL..."
until php -r "
try {
    \$pdo = new PDO(
        'pgsql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT') . ';dbname=' . getenv('DB_DATABASE'),
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD')
    );
    echo 'Connected';
} catch (Exception \$e) {
    exit(1);
}
" 2>/dev/null; do
    echo "[INFO] PostgreSQL pas encore prêt, nouvelle tentative dans 3s..."
    sleep 3
done
echo "[OK] PostgreSQL disponible."

# ─── Migrations (--graceful ignore les tables déjà existantes) ────────────────
echo "[INFO] Exécution des migrations..."
php /var/www/artisan migrate --force --graceful --no-interaction
echo "[OK] Migrations terminées."

# ─── Cache de configuration ───────────────────────────────────────────────────
php /var/www/artisan config:cache --no-interaction 2>/dev/null || true
php /var/www/artisan route:cache --no-interaction 2>/dev/null || true

echo "[OK] Application prête sur http://localhost:8000"
echo "========================================"

# ─── Démarrer PHP-FPM ─────────────────────────────────────────────────────────
exec "$@"
