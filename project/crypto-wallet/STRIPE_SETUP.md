# Configuration Stripe pour NodEX

Pour activer les paiements par carte sur l'écran **Acheter**, configurez Stripe.

## 1. Compte Stripe

1. Créez un compte sur [stripe.com](https://stripe.com)
2. Récupérez vos clés dans **Developers** → **API keys** :
   - **Clé publique** : `pk_test_...` (pour le frontend Flutter)
   - **Clé secrète** : `sk_test_...` (pour le backend NestJS)

## 2. Backend (NestJS)

Dans `backend/.env` :

```
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxx
```

Redémarrez le backend NestJS. Les paiements Stripe sont gérés par le backend NestJS (port 3000).

## 3. Flutter

Dans `flutter_app/lib/config/stripe_config.dart` :

```dart
static const String publishableKey = 'pk_test_xxxxxxxxxxxx';
```

L'URL des paiements pointe par défaut vers `http://localhost:3000`. Si votre backend NestJS est ailleurs, modifiez `paymentsBaseUrl`.

## 4. Test

- **Carte de test réussie** : `4242 4242 4242 4242`
- **Carte refusée** : `4000 0000 0000 0002`
- Date et CVC : n'importe quelle valeur future

## 5. Flux

1. L'utilisateur clique sur "Acheter" dans l'écran d'achat
2. Le backend crée un PaymentIntent Stripe
3. Flutter affiche le formulaire de paiement Stripe
4. Après paiement réussi, le backend crédite le portefeuille crypto

## Sans configuration

Si Stripe n'est pas configuré (clé vide), l'achat fonctionne en **mode simulation** (mise à jour locale uniquement, sans paiement réel).
