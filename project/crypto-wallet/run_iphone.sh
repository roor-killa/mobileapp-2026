#!/bin/bash
# Lance NodEX depuis le BON dossier (là où se trouve pubspec.yaml).
# Usage :
#   ./run_iphone.sh
#   ./run_iphone.sh http://192.168.0.12:8000/api
#
# Sans argument : http://192.168.0.12:8000/api (comme `php artisan serve` par défaut).

set -e
cd "$(dirname "$0")/flutter_app"

API_URL="${1:-http://192.168.0.12:8000/api}"
echo "Dossier : $(pwd)"
echo "API_BASE_URL = $API_URL"
flutter run --dart-define="API_BASE_URL=$API_URL"
