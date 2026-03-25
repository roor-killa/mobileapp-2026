<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\ResolvesNodexUser;
use App\Models\NodexUser;
use App\Models\UserCard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * API carte virtuelle NodEX - génère numéro, CVC, PIN par utilisateur.
 */
class CardController extends Controller
{
    use ResolvesNodexUser;

    /**
     * GET /api/card - Retourne ou crée la carte de l'utilisateur.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $this->nodexUser($request);
        if (!$user) {
            return response()->json(['error' => 'Non authentifié ou compte non synchronisé. Rechargez la page.'], 401);
        }

        $userId = $user->id;

        $card = UserCard::where('userId', $userId)->first();

        if (!$card) {
            $card = $this->createCard($userId);
        }

        $expiryMonth = str_pad((string) $card->expiryMonth, 2, '0', STR_PAD_LEFT);
        $expiryYear = str_pad((string) $card->expiryYear, 2, '0', STR_PAD_LEFT);

        return response()->json([
            'cardNumber' => trim(preg_replace('/(.{4})/', '$1 ', $card->cardNumber)),
            'last4' => $card->last4,
            'expiryMonth' => $expiryMonth,
            'expiryYear' => $expiryYear,
            'expiry' => "{$expiryMonth}/{$expiryYear}",
            'cvv' => $card->cvv,
            'pin' => $card->pin,
            'holderName' => strtoupper($user->name ?? 'TITULAIRE'),
        ]);
    }

    private function createCard(string $userId): UserCard
    {
        $cardNumber = $this->generateCardNumber($userId);
        $last4 = substr($cardNumber, -4);
        ['month' => $month, 'year' => $year] = $this->generateExpiry($userId);
        $cvv = $this->generateCvv($userId);
        $pin = $this->generatePin($userId);

        return UserCard::create([
            'userId' => $userId,
            'cardNumber' => $cardNumber,
            'last4' => $last4,
            'expiryMonth' => $month,
            'expiryYear' => $year,
            'cvv' => $cvv,
            'pin' => $pin,
        ]);
    }

    private function luhnCheckDigit(string $partial): int
    {
        $digits = array_map('intval', str_split($partial));
        $sum = 0;
        for ($i = count($digits) - 1; $i >= 0; $i--) {
            $d = $digits[$i];
            if ((count($digits) - $i) % 2 === 0) {
                $d *= 2;
                if ($d > 9) $d -= 9;
            }
            $sum += $d;
        }
        return (10 - ($sum % 10)) % 10;
    }

    private function generateCardNumber(string $userId): string
    {
        $hash = hash('sha256', $userId);
        $digits = '';
        for ($i = 0; $i < 15; $i++) {
            $digits .= hexdec($hash[$i] ?? '0') % 10;
        }
        $prefix = '4' . $digits;
        $check = $this->luhnCheckDigit($prefix);
        return $prefix . $check;
    }

    private function generateCvv(string $userId): string
    {
        $hash = hash('sha256', $userId . 'cvv');
        $n = hexdec(substr($hash, 0, 3)) % 900 + 100;
        return (string) $n;
    }

    private function generatePin(string $userId): string
    {
        $hash = hash('sha256', $userId . 'pin');
        $n = hexdec(substr($hash, 0, 4)) % 9000 + 1000;
        return (string) $n;
    }

    private function generateExpiry(string $userId): array
    {
        $hash = hash('sha256', $userId . 'exp');
        $month = (hexdec(substr($hash, 0, 2)) % 12) + 1;
        $yearOffset = (hexdec(substr($hash, 2, 2)) % 4) + 2;
        $year = (int) date('y') + $yearOffset;
        return ['month' => $month, 'year' => $year];
    }

}
