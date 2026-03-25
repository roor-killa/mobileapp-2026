#!/bin/bash
# Déploie l'app Flutter dans Laravel (même origine = pas de CORS)
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$BACKEND_DIR")"
FLUTTER_DIR="$PROJECT_DIR/flutter_app"
echo "Build Flutter..."
cd "$FLUTTER_DIR"
flutter build web --base-href /
echo "Copie vers Laravel public/app..."
mkdir -p ../backend-laravel/public/app
cp -r build/web/* ../backend-laravel/public/app/
# Corriger le base href
sed -i '' 's|<base href="/">|<base href="/app/">|' ../backend-laravel/public/app/index.html 2>/dev/null || \
  sed -i 's|<base href="/">|<base href="/app/">|' ../backend-laravel/public/app/index.html
echo "OK. Exemple : cd backend-laravel && php artisan serve --host=0.0.0.0"
echo "Puis ouvrez l’URL affichée par artisan (souvent http://127.0.0.1:8000) ou servez derrière nginx sur le port 80."
