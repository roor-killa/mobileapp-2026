# Sécurité — PayFlow

## Vue d'ensemble

La sécurité de PayFlow repose sur **5 couches** complémentaires. Chaque couche protège contre une menace spécifique.

```
┌─────────────────────────────────────────────────────────┐
│  Couche 5 — Blockchain Algorand (Immuabilité)           │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Couche 4 — QR Code HMAC + TTL (Anti-replay)     │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  Couche 3 — Stripe Webhook (Anti-fraude)   │  │  │
│  │  │  ┌───────────────────────────────────────┐  │  │  │
│  │  │  │  Couche 2 — PIN bcrypt (Autorisation) │  │  │  │
│  │  │  │  ┌─────────────────────────────────┐  │  │  │  │
│  │  │  │  │  Couche 1 — Sanctum (AuthN)    │  │  │  │  │
│  │  │  │  └─────────────────────────────────┘  │  │  │  │
│  │  │  └───────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Couche 1 — Authentification (Laravel Sanctum)

### Comment ça fonctionne

```
Inscription / Connexion
        │
        ▼
Laravel Sanctum génère un token unique
        │
        ▼
Token stocké en base (hashé SHA-256)
        │
        ▼
Flutter stocke le token (SharedPreferences)
        │
        ▼
Chaque requête → Header : Authorization: Bearer {token}
        │
        ▼
Sanctum middleware → Vérifie le token → Retourne l'utilisateur
```

### Caractéristiques

| Propriété | Valeur |
|-----------|--------|
| Format | `{id}\|{token_en_clair}` |
| Stockage en base | SHA-256 du token |
| Stockage mobile | SharedPreferences (local) |
| Révocation | `DELETE personal_access_tokens` |
| Expiration | À la déconnexion (token révoqué) |

### Protection mise en place

```php
// Tous les endpoints sensibles sont protégés
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/transfer', ...);
    Route::get('/history', ...);
    // ...
});
```

**Règle :** à la déconnexion, tous les tokens existants sont révoqués, forçant une reconnexion.

```php
// Connexion → révocation des anciens tokens
$user->tokens()->delete();
$token = $user->createToken('auth_token')->plainTextToken;
```

---

## Couche 2 — PIN de confirmation (Transferts)

### Pourquoi un PIN séparé du mot de passe ?

Le mot de passe sert à **s'identifier** (qui es-tu ?).
Le PIN sert à **autoriser** une action sensible (tu confirmes vraiment ?).

Même si un attaquant vole le Bearer Token, il ne peut pas effectuer de transfert sans connaître le PIN.

### Implémentation

```
Utilisateur saisit le PIN (6 chiffres)
        │
        ▼
Controller → $user->verifyPin($pin)
        │
        ▼
password_verify($pin, $user->pin_hash)   ← bcrypt
        │
    ┌───┴───┐
   OUI      NON
    │        │
  Suite    403 Forbidden
```

```php
// Modèle User
public function verifyPin(string $pin): bool
{
    return password_verify($pin, $this->pin_hash);
}
```

### Stockage sécurisé

```php
// À l'inscription — PIN hashé avec bcrypt
'pin_hash' => Hash::make($validated['pin'])

// Jamais retourné dans les réponses API
protected $hidden = ['password', 'pin_hash', 'remember_token'];
```

---

## Couche 3 — Webhook Stripe (Anti-fraude)

### Problème

Sans vérification, n'importe qui pourrait appeler `POST /recharge/webhook` avec un faux payload et créditer un compte frauduleusement.

### Solution : Signature HMAC-SHA256

```
Stripe envoie le webhook
        │
        ├── Header : Stripe-Signature: t=timestamp,v1=signature
        │
        ▼
Laravel → Webhook::constructEvent($payload, $signature, $secret)
        │
        ├── Reconstruit la signature attendue
        ├── Compare avec la signature reçue
        │
    ┌───┴───┐
  Valide   Invalide
    │        │
  Suite    400 Bad Request (ignoré)
```

```php
try {
    $event = Webhook::constructEvent($payload, $sigHeader, $secret);
} catch (\Exception $e) {
    return response()->json(['message' => 'Invalid signature.'], 400);
}
```

### Idempotence (protection contre le double crédit)

```php
// Si le TX Stripe a déjà été traité → ignorer
if (Transaction::where('reference', $paymentIntent->id)->exists()) {
    return response()->json(['message' => 'Already processed.'], 200);
}
```

---

## Couche 4 — QR Code HMAC + TTL (Anti-replay)

### Problème

Un QR Code statique peut être photographié et réutilisé indéfiniment.

### Solution : Token HMAC éphémère

```
Génération (Utilisateur A)
        │
        ▼
Payload = {user_id, amount, nonce, timestamp}
        │
        ▼
Signature HMAC-SHA256 avec clé secrète
        │
        ▼
Token = base64(payload + "." + signature)
        │
        ▼
Stocké en base avec expires_at = now() + 10 secondes
```

```
Scan (Utilisateur B)
        │
        ▼
Récupérer le QrToken depuis la base
        │
        ├── expires_at < now()  → Expiré → 422
        ├── is_used = true      → Déjà utilisé → 422
        │
        ▼
Effectuer le paiement
        │
        ▼
Marquer is_used = true  ← Ne peut plus être réutilisé
```

### Triple protection

| Vérification | Protection contre |
|-------------|-------------------|
| `expires_at` (10s TTL) | QR Code ancien/volé |
| `is_used = true` | Rejeu (scan multiple) |
| `nonce` aléatoire | Collision de token |

---

## Couche 5 — Blockchain Algorand (Immuabilité)

### Problème

Une base de données SQL peut être modifiée par un administrateur sans laisser de trace. Comment prouver qu'un transfert a bien eu lieu ?

### Solution : Enregistrement on-chain

```
Transfert effectué en base de données
        │
        ▼
AlgorandService::recordTransaction()
        │
        ▼
Construction d'une transaction Algorand :
 - sender: alice@test.com
 - receiver: bob@test.com
 - amount: 1 EUR
 - reference: TRF-XXXXXXXXXX
 - timestamp: 2026-03-08T18:09:53Z
        │
        ▼
Signature Ed25519 (sodium PHP)
        │
        ▼
Soumission au testnet Algorand (AlgoNode API)
        │
        ▼
TX ID retourné → Stocké dans transactions.blockchain_tx_id
        │
        ▼
Vérifiable publiquement sur lora.algokit.io
```

### Pourquoi c'est infalsifiable

```
Bloc Algorand confirmé
    │
    ├── Le TX ID est unique et immuable
    ├── La signature Ed25519 lie le TX à notre compte
    ├── Le timestamp est ancré dans la blockchain
    └── Toute modification invalide la signature
```

```
[Base de données]          [Blockchain Algorand]
transactions.id ────────▶  TX COBUHLC5RRW4EO3...
    amount: 100             Note: {alice→bob, 1€}
    status: completed       Round: 61237003
    blockchain_tx_id ──────▶ Confirmé à jamais
```

---

## Autres protections

### Transactions atomiques (SQL)

```php
// Débit et crédit se font dans la même transaction SQL
// Si l'une échoue, l'autre est annulée → impossible de perdre de l'argent
DB::transaction(function () use ($sender, $receiver, $amount) {
    $sender->decrement('balance', $amount);
    $receiver->increment('balance', $amount);
    Transaction::create([...]);
});
```

### Validation des entrées

```php
// Chaque requête est validée côté serveur (jamais côté client seul)
$validated = $request->validate([
    'amount' => ['required', 'integer', 'min:100'],  // min 1,00€
    'pin'    => ['required', 'digits:6'],
    'email'  => ['required', 'email', 'exists:users,email'],
]);
```

### Solde en centimes (pas de virgule flottante)

```php
// Mauvais : 0.1 + 0.2 = 0.30000000000000004 en float
// Bon : tout est stocké en centimes (INTEGER)
// 1000 centimes = 10,00 €
// Aucun risque d'erreur d'arrondi sur des montants financiers
$table->bigInteger('balance')->default(0)->unsigned();
```

### Protection contre le transfert à soi-même

```php
if ($sender->email === $validated['receiver_email']) {
    return response()->json([
        'message' => 'Vous ne pouvez pas vous transférer de l\'argent à vous-même.',
    ], 422);
}
```

---

## Tableau récapitulatif des menaces

| Menace | Protection | Couche |
|--------|-----------|--------|
| Accès non authentifié | Bearer Token Sanctum | 1 |
| Token volé → transfert frauduleux | PIN bcrypt obligatoire | 2 |
| Faux webhook Stripe | Signature HMAC vérifiée | 3 |
| QR Code volé / réutilisé | TTL 10s + usage unique | 4 |
| Falsification de l'historique | Blockchain Algorand | 5 |
| Débit sans crédit (perte d'argent) | Transaction SQL atomique | Base |
| Injection SQL | Eloquent ORM (requêtes préparées) | Base |
| Double crédit Stripe | Idempotence par référence | Base |
| Transfert négatif | Validation `min:100` centimes | Base |
| Accès aux mots de passe | bcrypt (irréversible) | Base |
