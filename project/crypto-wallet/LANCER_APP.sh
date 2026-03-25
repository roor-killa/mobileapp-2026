#!/bin/bash
# NodEX — lance Flutter depuis le dossier flutter_app (obligatoire : pubspec.yaml y est).
# Backend : même machine, API en http://127.0.0.1/api (port 80) ou URL dans Réglages → Serveur NodEX.

cd "$(dirname "$0")/flutter_app"
echo "Lancement de l'app NodEX sur Chrome (dossier : $(pwd))..."
flutter run -d chrome
