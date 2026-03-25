#!/bin/bash
# Lance NodEX sur le simulateur iPhone (depuis le dossier qui contient pubspec.yaml).
# Usage :
#   ./run_ios_sim.sh
#   ./run_ios_sim.sh --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
#
# Ne pas taper « -d .. » ni « -d <identifiant> » : ce script choisit l’iPhone simulateur tout seul.

set -e
cd "$(dirname "$0")"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter introuvable dans le PATH."
  exit 1
fi

# Premier UUID dans la liste (souvent le simulateur iPhone en premier) ; sinon définir FLUTTER_IOS_DEVICE_ID
DEVICE="${FLUTTER_IOS_DEVICE_ID:-}"
if [ -z "$DEVICE" ]; then
  DEVICE=$(flutter devices 2>/dev/null | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
fi

if [ -z "$DEVICE" ]; then
  echo "Aucun simulateur iPhone détecté."
  echo "Ouvrez l’app Simulator (Xcode → Open Developer Tool → Simulator) puis relancez ce script."
  exit 1
fi

echo "Simulateur : $DEVICE"
exec flutter run -d "$DEVICE" "$@"
