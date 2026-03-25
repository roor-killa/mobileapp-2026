#!/bin/bash
# Script de test pour vérifier que l'API virements répond correctement.
# Prérequis : backend démarré (npm run start:dev)

BASE="http://localhost:3000"

echo "=== 1. Test Health (sans auth) ==="
curl -s -o /dev/null -w "Status: %{http_code}\n" "$BASE/health"
curl -s "$BASE/health" | head -c 200
echo -e "\n"

echo "=== 2. Test sans token (doit retourner 401) ==="
curl -s -o /dev/null -w "Status: %{http_code}\n" -X GET "$BASE/virements/balance" -H "Content-Type: application/json"

echo "=== 3. Test POST /virements/send sans token (doit retourner 401) ==="
curl -s -o /dev/null -w "Status: %{http_code}\n" -X POST "$BASE/virements/send" \
  -H "Content-Type: application/json" \
  -d '{"toIdentifier":"test","amount":10}'

echo ""
echo "Si le backend répond (health=200), l'API est accessible."
echo "Pour tester un virement réel, connectez-vous dans l'app Flutter"
echo "et utilisez le bouton 'Test connexion' sur l'écran Virement."
