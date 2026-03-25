<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\ResolvesNodexUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * API wallets crypto NodEX - compatible avec Flutter (format NestJS).
 */
class WalletController extends Controller
{
    use ResolvesNodexUser;

    private const CHAINS = [
        'ETH' => ['name' => 'Ethereum', 'blockchain' => 'Ethereum'],
        'BTC' => ['name' => 'Bitcoin', 'blockchain' => 'Bitcoin'],
        'SOL' => ['name' => 'Solana', 'blockchain' => 'Solana'],
        'ALGO' => ['name' => 'Algorand', 'blockchain' => 'Algorand'],
    ];

    /**
     * GET /api/wallets - Retourne les wallets crypto de l'utilisateur.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $this->nodexUser($request);
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        $userId = $user->id;
        $balances = $this->getCryptoBalances($userId);
        $wallets = [];
        foreach (self::CHAINS as $symbol => $meta) {
            $wallets[] = [
                'id' => "wallet-{$userId}-{$symbol}",
                'symbol' => $symbol,
                'chain' => $symbol,
                'blockchain' => $meta['blockchain'],
                'address' => $this->fakeAddress($userId, $symbol),
                'balance' => $balances[$symbol] ?? 0,
            ];
        }

        return response()->json(['wallets' => $wallets]);
    }

    private function getCryptoBalances(string $userId): array
    {
        $key = "nodex_crypto_{$userId}";
        $stored = cache()->get($key);
        if (is_array($stored)) {
            return $stored;
        }
        return ['ETH' => 0, 'BTC' => 0, 'SOL' => 0, 'ALGO' => 0];
    }

    private function fakeAddress(string $userId, string $symbol): string
    {
        $hash = hash('sha256', $userId . $symbol);
        $prefix = match ($symbol) {
            'BTC' => 'bc1',
            'ETH' => '0x',
            'SOL' => '',
            'ALGO' => '',
            default => '',
        };
        return $prefix . substr($hash, 0, $symbol === 'BTC' ? 34 : 40);
    }

}
