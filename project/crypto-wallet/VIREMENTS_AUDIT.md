# Audit du flux de virement NodEX

## 1. Flutter (Front-end)

| Point critique | Statut | Détail |
|----------------|--------|--------|
| `await` sur l'appel API | ✅ | `await _api.post('/virements/send', ...)` |
| Vérification du code HTTP | ✅ | Succès uniquement si `statusCode == 200 || 201` |
| Pas de "succès simulé" | ✅ | L'UI ne se met à jour que si le serveur confirme |
| Gestion des erreurs 4xx/5xx | ✅ | Retourne le message d'erreur, affiche une dialog |
| Gestion des erreurs réseau | ✅ | Catch + message "Backend inaccessible" |

**Fichier** : `flutter_app/lib/providers/wallet_provider.dart` → `bankSendToNodEX()`

---

## 2. Backend (NestJS)

| Point critique | Statut | Détail |
|----------------|--------|--------|
| Transaction atomique | ✅ | `prisma.$transaction()` — rollback si une étape échoue |
| Vérification solde | ✅ | `if (fromBalance < amount) throw BadRequestException` |
| Vérification destinataire | ✅ | `if (!toUser) throw NotFoundException` |
| Anti auto-virement | ✅ | `if (toUser.id === fromUserId) throw BadRequestException` |
| Débit + Crédit + Historique | ✅ | Les 3 opérations dans la même transaction |

**Fichier** : `backend/src/modules/virements/virements.service.ts` → `sendToUser()`

---

## 3. Flux de la transaction (Backend)

```
1. Vérifier montant > 0
2. Charger compte expéditeur (fromUser)
3. Vérifier solde suffisant
4. Trouver destinataire (IBAN / pseudonyme / email)
5. Vérifier destinataire existe et ≠ expéditeur
6. DÉMARRER TRANSACTION (une seule opération atomique)
   ├─ Étape 1 : Débiter compte A (balanceEur -= amount)
   ├─ Étape 2 : Créditer compte B (balanceEur += amount)  ← Le destinataire reçoit ici
   └─ Étape 3 : Créer enregistrement VirementEur (historique)
7. Si une étape échoue → ROLLBACK (rien n'est enregistré)
8. Si tout OK → COMMIT
9. Vérification : relire les soldes A et B pour confirmer
10. Retourner { newBalance, recipientNewBalance } (preuve que B a reçu)
```

---

## 4. Tester l'API

```bash
cd project/crypto-wallet/backend
chmod +x scripts/test-virement-api.sh
./scripts/test-virement-api.sh
```

Le backend doit être démarré (`npm run start:dev`).
