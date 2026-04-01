# Etape 3 — Intégration Stripe

## Objectif

Permettre aux utilisateurs de recharger leur compte avec une vraie carte bancaire, en utilisant Stripe comme prestataire de paiement. Le solde est crédité automatiquement après confirmation du paiement.

---

## Pourquoi Stripe ?

| Critère | Stripe |
|---------|--------|
| Sécurité | PCI DSS Level 1 (niveau maximum) |
| Intégration mobile | SDK Flutter officiel |
| Webhooks | Notifications temps réel |
| Test | Cartes de test sans argent réel |
| Popularité | Utilisé par Amazon, Shopify, Lyft... |

---

## Architecture du paiement

```
Flutter                 Laravel                    Stripe
  │                        │                          │
  │  1. POST               │                          │
  │  /recharge/create-intent─▶                        │
  │                        │  2. PaymentIntent.create─▶
  │                        │◀─ client_secret ─────────│
  │◀─ {client_secret} ─────│                          │
  │                        │                          │
  │  3. initPaymentSheet() │                          │
  │  presentPaymentSheet() │                          │
  │  [Saisie carte]        │                          │
  │  ─────────────────────────────────────────────────▶
  │                        │                          │ 4. Paiement
  │                        │◀─ Webhook ───────────────│    confirmé
  │                        │  5. Vérifier signature   │
  │                        │  6. Créditer le compte   │
  │                        │  7. Créer transaction    │
  │                        │                          │
  │  8. refreshUser()──────▶                          │
  │◀─ Nouveau solde ────────│                          │
```

---

## Configuration

### Clés Stripe (`.env`)

```env
STRIPE_KEY=pk_test_...              ← Clé publique (Flutter)
STRIPE_SECRET=sk_test_...           ← Clé secrète (Laravel)
STRIPE_WEBHOOK_SECRET=whsec_...     ← Secret webhook (Stripe CLI)
```

> Les clés `test` permettent de simuler des paiements sans argent réel.
> Pour la production, remplacer par les clés `live`.

### Clé publique Flutter (`stripe_constants.dart`)

```dart
class StripeConstants {
    static const String publishableKey = 'pk_test_...';
}
```

### Initialisation dans `main.dart`

```dart
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = StripeConstants.publishableKey;
    await Stripe.instance.applySettings();
    runApp(const PayFlowApp());
}
```

---

## Backend — RechargeController

### Etape 1 : Créer le PaymentIntent

```php
// POST /api/v1/recharge/create-intent
public function createPaymentIntent(Request $request): JsonResponse
{
    $validated = $request->validate([
        'amount' => ['required', 'integer', 'min:100', 'max:1000000'],
    ]);

    $paymentIntent = PaymentIntent::create([
        'amount'   => $validated['amount'],  // en centimes
        'currency' => 'eur',
        'metadata' => [
            'user_id'    => $request->user()->id,
            'user_email' => $request->user()->email,
        ],
    ]);

    return response()->json([
        'client_secret' => $paymentIntent->client_secret,
    ]);
}
```

### Etape 2 : Traiter le Webhook

```php
// POST /api/v1/recharge/webhook (route publique)
public function webhook(Request $request): JsonResponse
{
    // 1. Vérifier la signature Stripe
    $event = Webhook::constructEvent(
        $request->getContent(),
        $request->header('Stripe-Signature'),
        config('services.stripe.webhook_secret')
    );

    // 2. Traiter uniquement les paiements réussis
    if ($event->type === 'payment_intent.succeeded') {
        $paymentIntent = $event->data->object;
        $userId = $paymentIntent->metadata->user_id;
        $amount = $paymentIntent->amount;

        // 3. Idempotence — éviter le double crédit
        if (Transaction::where('reference', $paymentIntent->id)->exists()) {
            return response()->json(['message' => 'Already processed.']);
        }

        // 4. Créditer le compte
        DB::transaction(function () use ($userId, $amount, $paymentIntent) {
            $user = User::findOrFail($userId);
            $user->increment('balance', $amount);

            Transaction::create([
                'receiver_id' => $user->id,
                'amount'      => $amount,
                'type'        => 'recharge',
                'status'      => 'completed',
                'reference'   => $paymentIntent->id,
            ]);
        });
    }

    return response()->json(['message' => 'Webhook traité.']);
}
```

---

## Frontend — RechargeScreen

### Flux complet Flutter

```dart
Future<void> _recharge() async {
    // 1. Créer le PaymentIntent côté serveur
    final intentData = await api.createPaymentIntent(amountCents);
    final clientSecret = intentData['client_secret'];

    // 2. Initialiser la Payment Sheet
    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'PayFlow',
            // Ne pas demander le code postal
            billingDetailsCollectionConfiguration:
                const BillingDetailsCollectionConfiguration(
                    address: AddressCollectionMode.never,
                ),
        ),
    );

    // 3. Afficher la Payment Sheet native
    await Stripe.instance.presentPaymentSheet();

    // 4. Attendre le webhook (~3s) puis rafraîchir
    await Future.delayed(const Duration(seconds: 3));
    await authProvider.refreshUser();
}
```

### Payment Sheet native Stripe

La Payment Sheet est fournie par Stripe — elle gère nativement :
- Saisie sécurisée du numéro de carte
- Validation du CVC et de la date d'expiration
- 3D Secure si nécessaire
- Conformité PCI DSS (les données de carte ne transitent jamais par notre serveur)

---

## Webhook local — Stripe CLI

En développement, Stripe ne peut pas appeler `localhost` directement. Le Stripe CLI fait le pont.

```bash
# Installation (Windows)
cd C:\stripe
.\stripe.exe login

# Rediriger les webhooks vers le backend local
.\stripe.exe listen --forward-to http://localhost:8000/api/v1/recharge/webhook
```

```
Output :
> Ready! Your webhook signing secret is whsec_645cc056ae...
2026-03-08 18:00:49  --> payment_intent.succeeded
2026-03-08 18:00:49 <-- [200] POST http://localhost:8000/...
```

---

## Sécurité

### Vérification de signature

```php
// Sans cette vérification, n'importe qui pourrait simuler
// un paiement réussi et créditer un compte frauduleusement
try {
    $event = Webhook::constructEvent($payload, $signature, $secret);
} catch (\Exception $e) {
    return response()->json(['message' => 'Invalid signature.'], 400);
}
```

### Idempotence

```php
// Si le même paiement est envoyé deux fois (retry Stripe)
// → on ne crédite pas deux fois
if (Transaction::where('reference', $paymentIntent->id)->exists()) {
    return response()->json(['message' => 'Already processed.'], 200);
}
```

### Jamais de données de carte côté serveur

```
Flutter ──(carte)──▶ Stripe SDK ──▶ Serveurs Stripe
                                              │
                                        Webhook (notification)
                                              │
                                        Laravel (crédit compte)
```

Notre backend ne voit **jamais** les données de carte bancaire.

---

## Carte de test

| Numéro | Résultat |
|--------|----------|
| 4242 4242 4242 4242 | Paiement accepté |
| 4000 0000 0000 0002 | Paiement refusé |
| 4000 0025 0000 3155 | Requiert 3D Secure |

Date d'expiration : n'importe quelle date future
CVC : n'importe quels 3 chiffres

---

## Résultat

Après un paiement réussi, la transaction apparaît dans l'historique :

```json
{
    "type": "recharge",
    "status": "completed",
    "amount": 2000,
    "amount_formatted": "20,00 €",
    "reference": "pi_3T8kSkJ3tWCwrLkg...",
    "metadata": {
        "stripe_payment_intent": "pi_3T8kSkJ3tWCwrLkg...",
        "payment_method": "pm_1T8kSk..."
    }
}
```
