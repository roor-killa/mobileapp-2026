# Etape 3 — Blockchain Algorand

## Qu'est-ce qu'une blockchain ?

Une blockchain est une **liste de blocs enchaînés** où chaque bloc contient :
- Des données (une transaction)
- L'empreinte numérique (hash) du bloc précédent

Si quelqu'un modifie un bloc, son hash change → tous les blocs suivants deviennent invalides. C'est ce qui rend la blockchain **immuable**.

```
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│   BLOC #61237001  │    │   BLOC #61237002  │    │   BLOC #61237003  │
│───────────────────│    │───────────────────│    │───────────────────│
│ prev: 0000...     │───▶│ prev: a3f7c8...   │───▶│ prev: 9c2b1e...   │
│ data: {           │    │ data: {           │    │ data: {           │
│  alice→bob        │    │  recharge 20€     │    │  alice→bob        │
│  1€, ref: TRF-... │    │  pi_3T8k...       │    │  1€, ref: TRF-... │
│ }                 │    │ }                 │    │ }                 │
│ hash: a3f7c8...   │    │ hash: 9c2b1e...   │    │ hash: 7d4a3f...   │
└───────────────────┘    └───────────────────┘    └───────────────────┘
```

---

## Pourquoi Algorand ?

| Critère | Algorand | Bitcoin | Ethereum |
|---------|----------|---------|----------|
| Vitesse | ~4 secondes | ~10 minutes | ~12 secondes |
| Finalité | **Immédiate** | 6 confirmations | ~15 min |
| Frais | ~0,001 € | Variables | Variables (gas) |
| Éco-responsable | Oui (Pure PoS) | Non (PoW) | Moyen |
| Utilisation finance | CBDC, USDC | Investissement | DeFi |

**Algorand** a été recommandé par notre professeur pour ses performances et ses faibles frais, idéal pour une application de paiement.

---

## Comment Algorand fonctionne dans notre app

### Vue d'ensemble

```
Transfert effectué (base de données)
        │
        ▼
AlgorandService::recordTransaction()
        │
        ▼
┌───────────────────────────────────┐
│ 1. Construire la transaction      │
│    - type: "pay"                  │
│    - sender: notre wallet         │
│    - receiver: notre wallet       │
│    - amount: 0 ALGO               │
│    - note: {alice→bob, 1€, ref}   │
└───────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────┐
│ 2. Signer avec Ed25519 (sodium)   │
│    signature = sign(TX, privateKey)│
└───────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────┐
│ 3. Encoder en MessagePack         │
│    (format binaire standard)      │
└───────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────┐
│ 4. Soumettre à AlgoNode API       │
│    POST /v2/transactions          │
└───────────────────────────────────┘
        │
        ▼
TX ID retourné → Stocké en base
Vérifiable sur lora.algokit.io
```

---

## Implémentation technique

### Compte Algorand de l'application

Au premier démarrage, un compte Algorand est généré :

```php
// Génération d'une paire de clés Ed25519 (cryptographie à courbe elliptique)
$keypair    = sodium_crypto_sign_keypair();
$privateKey = sodium_crypto_sign_secretkey($keypair); // 64 octets
$publicKey  = sodium_crypto_sign_publickey($keypair); // 32 octets

// Adresse Algorand = base32(clé_publique + checksum)
$address = base32_encode($publicKey . $checksum);
// Exemple : FBSU3PG36Z5NMFSGA64GRAWSFOG5CW2SAD3ZPUJ2TCBRLCGE2GQCRJY6TE
```

Le compte est financé via le **faucet Algorand testnet** (10 ALGO gratuits pour payer les frais de transaction).

### Construction de la transaction

```php
$txnFields = [
    'fee'  => 1000,                           // 0.001 ALGO (frais minimaux)
    'fv'   => $lastRound,                     // Premier round valide
    'gen'  => 'testnet-v1.0',                 // Réseau testnet
    'gh'   => base64_decode($genesisHash),    // Hash du bloc genesis
    'lv'   => $lastRound + 1000,              // Dernier round valide
    'note' => json_encode([                   // Données de notre transfert
        'app'      => 'PayFlow',
        'type'     => 'transfer',
        'amount'   => '1 EUR',
        'sender'   => 'alice@test.com',
        'receiver' => 'bob@test.com',
        'ref'      => 'TRF-9AYYHOCCI8',
    ]),
    'rcv'  => $publicKeyBytes,                // Destinataire (notre wallet)
    'snd'  => $publicKeyBytes,                // Expéditeur (notre wallet)
    'type' => 'pay',                          // Type payment
];
```

> **Pourquoi envoyer à soi-même ?**
> On n'a pas besoin de transférer des ALGO — on utilise le champ `note` pour stocker les données de notre transfert EUR. C'est une technique courante d'ancrage de données sur blockchain.

### Signature Ed25519

```php
// Algorand exige le préfixe "TX" avant de signer
$toSign    = 'TX' . MessagePack::pack($txnFields);
$signature = sodium_crypto_sign_detached($toSign, $privateKey);
```

### Encodage MessagePack

Algorand utilise **MessagePack** (format binaire compact, comme JSON mais plus léger) :

```php
// Les adresses et hashes sont encodés en binaire (Bin), pas en string
$txnFields = [
    'gh'   => new \MessagePack\Type\Bin($genesisHash),   // binaire
    'rcv'  => new \MessagePack\Type\Bin($receiverBytes), // binaire
    'snd'  => new \MessagePack\Type\Bin($publicKey),     // binaire
    'note' => new \MessagePack\Type\Bin($note),          // binaire
    'type' => 'pay',                                      // string
    'fee'  => 1000,                                       // entier
    // ...
];
```

### Soumission à AlgoNode

```php
// AlgoNode = accès gratuit aux nœuds Algorand sans clé API
$response = Http::withHeaders(['Content-Type' => 'application/x-binary'])
    ->post('https://testnet-api.algonode.cloud/v2/transactions', [
        'body' => $signedTxnBytes,
    ]);

$txId = $response->json('txId');
// Exemple : "COBUHLC5RRW4EO3FHS3KOC57HSXG5RBB67R6PO4ODPHALBXN233Q"
```

---

## Vérification sur Lora Explorer

Chaque transaction est vérifiable publiquement :

**URL :** `https://lora.algokit.io/testnet/transaction/{TX_ID}`

```
Transaction confirmée sur Lora :

Transaction ID  COBUHLC5RRW4EO3FHS3KO...
Type            Payment
Timestamp       Sun, 08 March 2026 18:09:54
Block           61237003
Fee             0.001 Ⱥ

Note (UTF-8) :
{
    "app": "PayFlow",
    "type": "transfer",
    "amount": "1 EUR",
    "sender": "alice@test.com",
    "receiver": "bob@test.com",
    "ref": "TRF-9AYYHOCCI8",
    "timestamp": "2026-03-08T18:09:53+00:00"
}
```

---

## Dans l'application Flutter

### Badge dans l'historique

```dart
// Chaque transaction avec blockchain_tx_id affiche un badge cliquable
if (tx.hasBlockchain)
    InkWell(
        onTap: () => launchUrl(Uri.parse(tx.blockchainExplorerUrl!)),
        child: Row(children: [
            Icon(Icons.verified_outlined, color: Color(0xFF00B4AB)),
            Text('Vérifié sur Algorand · ${tx.blockchainTxId}'),
            Icon(Icons.open_in_new),
        ]),
    )
```

---

## Configuration requise

### `.env` Backend

```env
ALGORAND_MNEMONIC=m3sf+oxg/Gn5GBoeRsKRnbwlgVTMU48VqXGxUAajVcI=
ALGORAND_ADDRESS=FBSU3PG36Z5NMFSGA64GRAWSFOG5CW2SAD3ZPUJ2TCBRLCGE2GQCRJY6TE
```

### Dépendance PHP

```json
"rybakit/msgpack": "^0.9.2"
```

### Extension PHP requise

```
sodium  ← Signature Ed25519 (disponible nativement en PHP 8.x)
```

---

## Résumé de ce que garantit la blockchain

| Garantie | Sans blockchain | Avec Algorand |
|----------|----------------|---------------|
| Preuve qu'un transfert a eu lieu | Non (base SQL modifiable) | Oui (TX immuable) |
| Horodatage certifié | Non | Oui (ancré dans un bloc) |
| Vérification publique | Non | Oui (lora.algokit.io) |
| Falsification possible | Oui (par un admin) | Non (mathématiquement impossible) |
| Traçabilité complète | Partielle | Totale |

---

## Compte Algorand testnet du projet

```
Adresse  : FBSU3PG36Z5NMFSGA64GRAWSFOG5CW2SAD3ZPUJ2TCBRLCGE2GQCRJY6TE
Réseau   : Algorand Testnet
Solde    : 10 ALGO (obtenus via le faucet Lora)
Explorer : https://lora.algokit.io/testnet/account/FBSU3PG36...
```
