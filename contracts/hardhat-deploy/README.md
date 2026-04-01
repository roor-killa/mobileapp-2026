# Déploiement réel du token BKN sur Base Sepolia

Ce dossier permet de déployer le contrat ERC-20 `BKNToken` sur **Base Sepolia** puis de mint des jetons de démonstration.

## 1) Installation

```bash
npm install
```

## 2) Configuration

Copie `.env.example` vers `.env` puis renseigne la clé privée d’un wallet **testnet** approvisionné.

### Windows CMD

```bat
copy .env.example .env
```

### Windows PowerShell

```powershell
Copy-Item .env.example .env
```

Valeurs minimales :

```env
PRIVATE_KEY=TON_TESTNET_PRIVATE_KEY
RPC_URL=https://sepolia.base.org
```

## 3) Déployer sur Base Sepolia

```bash
npm run deploy:base-sepolia
```

Résultat attendu :

```text
BKNToken deployed to: 0x...
Owner/deployer: 0x...
Network: baseSepolia
```

## 4) Reporter l’adresse du contrat dans l’application et le backend

### backend/.env

```env
EVM_RPC_URL=https://sepolia.base.org
EVM_CHAIN=base-sepolia
BKN_TOKEN_ADDRESS=0xTON_TOKEN_DEPLOYE
```

### mobile/.env.example ou `flutter run --dart-define`

```env
EVM_RPC_URL=https://sepolia.base.org
EVM_CHAIN=base-sepolia
BKN_TOKEN_ADDRESS=0xTON_TOKEN_DEPLOYE
EVM_BACKEND_BASE_URL=http://10.0.2.2:4000
```

## 5) Mint de jetons de démonstration

Après le déploiement, complète `.env` avec :

```env
BKN_TOKEN_ADDRESS=0xTON_TOKEN_DEPLOYE
MINT_TO=0xWALLET_DESTINATAIRE
MINT_AMOUNT=1000
```

Puis exécute :

```bash
npm run mint:base-sepolia
```

## 6) Vérifier dans l’application

Ouvre l’action **Crypto / On-chain** depuis l’écran d’accueil et envoie des tokens entre deux wallets de test.

## Sécurité

- Flux réservé au **testnet**.
- Ne mets jamais une vraie clé privée de production dans l’application mobile.
- La route backend `/evm/erc20/transfer` reste une route de démonstration, pas un flux de production.
