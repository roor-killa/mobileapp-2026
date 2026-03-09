<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use MessagePack\MessagePack;

/**
 * Service Algorand — Enregistre les transactions sur le testnet Algorand
 *
 * Architecture :
 *   MoneyTransferApp → AlgorandService → AlgoNode API (testnet) → Blockchain Algorand
 *
 * Chaque transfert d'argent dans l'app génère une transaction Algorand
 * dont le TX ID sert de preuve immuable sur la blockchain.
 */
class AlgorandService
{
    // ─── AlgoNode API — Accès gratuit au testnet sans clé API ─────────────────
    private const ALGOD_URL    = 'https://testnet-api.algonode.cloud';
    private const INDEXER_URL  = 'https://testnet-idx.algonode.cloud';
    private const EXPLORER_URL = 'https://lora.algokit.io/testnet/transaction/';

    // ─── Constantes Algorand ──────────────────────────────────────────────────
    private const MIN_FEE        = 1000;  // 0.001 ALGO (en microAlgos)
    private const GENESIS_ID     = 'testnet-v1.0';
    private const GENESIS_HASH   = 'SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=';

    // ─── Compte de l'application (chargé depuis .env) ─────────────────────────
    private string $privateKeyHex;
    private string $publicKeyHex;
    private string $address;

    public function __construct()
    {
        $mnemonic = config('services.algorand.mnemonic');

        if (empty($mnemonic) || $mnemonic === 'GENERATE_ME') {
            // Mode sans compte configuré — les transactions sont simulées
            $this->privateKeyHex = '';
            $this->publicKeyHex  = '';
            $this->address       = '';
        } else {
            [$this->privateKeyHex, $this->publicKeyHex, $this->address] =
                $this->mnemonicToKeys($mnemonic);
        }
    }

    // ─── Méthode principale ────────────────────────────────────────────────────

    /**
     * Enregistre une transaction MoneyTransfer sur Algorand
     * Retourne le TX ID Algorand ou null en cas d'échec
     */
    public function recordTransaction(array $data): ?string
    {
        if (empty($this->address)) {
            Log::warning('Algorand: aucun compte configuré, transaction non enregistrée.');
            return null;
        }

        try {
            // 1. Récupérer les paramètres réseau actuels
            $params = $this->getSuggestedParams();
            if (!$params) return null;

            // 2. Construire la note (données de la transaction MoneyTransfer)
            $note = json_encode([
                'app'       => 'MoneyTransferApp',
                'type'      => $data['type'],
                'amount'    => $data['amount'],
                'sender'    => $data['sender']    ?? null,
                'receiver'  => $data['receiver']  ?? null,
                'ref'       => $data['reference'] ?? null,
                'timestamp' => now()->toIso8601String(),
            ]);

            // 3. Construire et signer la transaction
            $signedTxn = $this->buildAndSignTransaction($params, $note);
            if (!$signedTxn) return null;

            // 4. Soumettre à Algorand testnet
            $txId = $this->submitTransaction($signedTxn);

            if ($txId) {
                Log::info("Algorand TX enregistré: {$txId} | type={$data['type']} | amount={$data['amount']}");
            }

            return $txId;

        } catch (\Exception $e) {
            Log::error('Algorand error: ' . $e->getMessage());
            return null;
        }
    }

    // ─── Génération de compte ─────────────────────────────────────────────────

    /**
     * Génère un nouveau compte Algorand (à faire une seule fois)
     * Retourne [address, mnemonic]
     */
    public static function generateAccount(): array
    {
        // Générer une paire de clés Ed25519 via sodium
        $keypair    = sodium_crypto_sign_keypair();
        $privateKey = sodium_crypto_sign_secretkey($keypair);
        $publicKey  = sodium_crypto_sign_publickey($keypair);

        // Adresse Algorand = base32(publicKey + checksum)
        $address  = self::publicKeyToAddress($publicKey);
        $mnemonic = self::privateKeyToMnemonic($privateKey);

        return [
            'address'  => $address,
            'mnemonic' => $mnemonic,
        ];
    }

    // ─── AlgoNode API ─────────────────────────────────────────────────────────

    /**
     * Récupère les paramètres réseau suggérés (round, fee, etc.)
     */
    private function getSuggestedParams(): ?array
    {
        $response = Http::timeout(10)
            ->get(self::ALGOD_URL . '/v2/transactions/params');

        if (!$response->successful()) {
            Log::error('Algorand: impossible de récupérer les params réseau: ' . $response->status());
            return null;
        }

        return $response->json();
    }

    /**
     * Soumet une transaction signée au réseau
     */
    private function submitTransaction(string $signedTxnBytes): ?string
    {
        $response = Http::timeout(15)
            ->withHeaders(['Content-Type' => 'application/x-binary'])
            ->send('POST', self::ALGOD_URL . '/v2/transactions', [
                'body' => $signedTxnBytes,
            ]);

        if (!$response->successful()) {
            Log::error('Algorand submit error: ' . $response->body());
            return null;
        }

        return $response->json('txId') ?? $response->json('txid');
    }

    // ─── Construction et signature de transaction ──────────────────────────────

    /**
     * Construit une transaction de type "payment" et la signe
     * (On envoie 0 ALGO à soi-même avec une note contenant les données)
     */
    private function buildAndSignTransaction(array $params, string $note): ?string
    {
        $packer = new \MessagePack\Packer();

        $privateKey    = hex2bin($this->privateKeyHex);
        $publicKey     = hex2bin($this->publicKeyHex);
        $receiverBytes = self::addressToPublicKey($this->address);
        $genesisHash   = base64_decode(self::GENESIS_HASH);

        // Construction du corps de la transaction
        // Algorand exige des champs triés alphabétiquement
        // Les adresses et hashes DOIVENT être encodés en MessagePack "bin" (bytes)
        // Algorand omet les champs à valeur zéro/vide dans le MessagePack
        // 'amt' = 0 doit être OMIS (convention Algorand)
        $txnFields = [
            'fee'  => self::MIN_FEE,
            'fv'   => (int) $params['last-round'],
            'gen'  => self::GENESIS_ID,
            'gh'   => new \MessagePack\Type\Bin($genesisHash),
            'lv'   => (int) $params['last-round'] + 1000,
            'note' => new \MessagePack\Type\Bin($note),
            'rcv'  => new \MessagePack\Type\Bin($receiverBytes),
            'snd'  => new \MessagePack\Type\Bin($publicKey),
            'type' => 'pay',
        ];

        // Encodage MessagePack de la transaction (pour la signature)
        $txnBytes = $packer->pack($txnFields);

        // Préfixe "TX" requis par Algorand avant de signer
        $toSign    = 'TX' . $txnBytes;
        $signature = sodium_crypto_sign_detached($toSign, $privateKey);

        // Transaction signée : sig (bin) + txn (map)
        $signedTxn = [
            'sig' => new \MessagePack\Type\Bin($signature),
            'txn' => $txnFields,
        ];

        return $packer->pack($signedTxn);
    }

    // ─── Utilitaires cryptographiques ─────────────────────────────────────────

    /**
     * Convertit une clé publique Ed25519 en adresse Algorand
     */
    private static function publicKeyToAddress(string $publicKey): string
    {
        // Checksum = sha512/256 des 4 derniers octets du hash de la clé publique
        $hash     = hash('sha512/256', $publicKey, true);
        $checksum = substr($hash, -4);
        // Supprimer le padding '=' de base32 (adresses Algorand sans padding)
        return rtrim(strtoupper(base32_encode($publicKey . $checksum)), '=');
    }

    /**
     * Convertit une adresse Algorand en clé publique brute
     */
    private static function addressToPublicKey(string $address): string
    {
        $decoded = base32_decode(strtoupper($address));
        return substr($decoded, 0, 32); // 32 premiers octets = clé publique
    }

    /**
     * Convertit le mnemonic (25 mots) en clés privée/publique + adresse
     */
    private function mnemonicToKeys(string $mnemonic): array
    {
        // Le mnemonic stocké est le seed base64-encodé (32 octets)
        // On le décode directement sans re-hasher
        $seed       = base64_decode($mnemonic);
        $keypair    = sodium_crypto_sign_seed_keypair($seed);
        $privateKey = sodium_crypto_sign_secretkey($keypair);
        $publicKey  = sodium_crypto_sign_publickey($keypair);
        $address    = self::publicKeyToAddress($publicKey);

        return [bin2hex($privateKey), bin2hex($publicKey), $address];
    }

    /**
     * Convertit une clé privée en mnemonic (représentation simplifiée)
     */
    private static function privateKeyToMnemonic(string $privateKey): string
    {
        return base64_encode(substr($privateKey, 0, 32));
    }

    // ─── URL publique ─────────────────────────────────────────────────────────

    public static function getExplorerUrl(string $txId): string
    {
        return self::EXPLORER_URL . $txId;
    }

    public function getAddress(): string
    {
        return $this->address;
    }

    public function isConfigured(): bool
    {
        return !empty($this->address);
    }
}

// ─── Fonctions base32 (Algorand en a besoin) ──────────────────────────────────

if (!function_exists('base32_encode')) {
    function base32_encode(string $data): string
    {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $binary   = '';
        foreach (str_split($data) as $char) {
            $binary .= str_pad(decbin(ord($char)), 8, '0', STR_PAD_LEFT);
        }
        $result = '';
        foreach (str_split(str_pad($binary, ceil(strlen($binary) / 5) * 5, '0'), 5) as $chunk) {
            $result .= $alphabet[bindec($chunk)];
        }
        return str_pad($result, ceil(strlen($result) / 8) * 8, '=');
    }
}

if (!function_exists('base32_decode')) {
    function base32_decode(string $data): string
    {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $data     = rtrim($data, '=');
        $binary   = '';
        foreach (str_split($data) as $char) {
            $pos     = strpos($alphabet, $char);
            $binary .= str_pad(decbin($pos), 5, '0', STR_PAD_LEFT);
        }
        $result = '';
        foreach (str_split(substr($binary, 0, floor(strlen($binary) / 8) * 8), 8) as $byte) {
            $result .= chr(bindec($byte));
        }
        return $result;
    }
}
