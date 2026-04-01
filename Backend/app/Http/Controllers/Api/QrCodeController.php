<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QrToken;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class QrCodeController extends Controller
{
    /**
     * POST /api/qr/generate
     * Génère un QR Code avec un token HMAC valable 10 secondes
     */
    public function generate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => ['required', 'integer', 'min:100'], // minimum 1,00 €
        ]);

        $user = $request->user();

        // Invalider les anciens tokens non utilisés de cet utilisateur
        QrToken::where('user_id', $user->id)
               ->where('is_used', false)
               ->delete();

        // Construire le payload du token
        $payload = [
            'user_id'   => $user->id,
            'amount'    => $validated['amount'],
            'nonce'     => Str::random(16),
            'issued_at' => now()->timestamp,
        ];

        // Signer avec HMAC-SHA256
        $payloadJson = json_encode($payload);
        $signature   = hash_hmac('sha256', $payloadJson, config('app.qr_hmac_secret'));
        $token       = base64_encode($payloadJson . '.' . $signature);

        $expiresAt = now()->addSeconds(config('app.qr_token_ttl', 30));

        $qrToken = QrToken::create([
            'user_id'    => $user->id,
            'amount'     => $validated['amount'],
            'token'      => $token,
            'expires_at' => $expiresAt,
        ]);

        return response()->json([
            'token'             => $token,
            'expires_at'        => $expiresAt->toIso8601String(),
            'expires_in_seconds' => config('app.qr_token_ttl', 30),
            'amount'            => $validated['amount'],
            'amount_formatted'  => number_format($validated['amount'] / 100, 2, ',', ' ') . ' €',
            'receiver'          => [
                'id'        => $user->id,
                'full_name' => $user->full_name,
            ],
        ]);
    }

    /**
     * POST /api/qr/scan
     * Scanner et valider un QR Code → effectue le paiement
     */
    public function scan(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => ['required', 'string'],
            'pin'   => ['required', 'digits:6'],
        ]);

        $sender = $request->user();

        // Vérifier le PIN de l'expéditeur
        if (!$sender->verifyPin($validated['pin'])) {
            return response()->json([
                'message' => 'PIN incorrect.',
            ], 403);
        }

        // Retrouver le token valide en base
        $qrToken = QrToken::valid()
                          ->where('token', $validated['token'])
                          ->with('user')
                          ->first();

        if (!$qrToken) {
            return response()->json([
                'message' => 'QR Code invalide ou expiré. Demandez un nouveau code.',
            ], 422);
        }

        $receiver = $qrToken->user;

        // Vérifier que l'expéditeur n'est pas le receveur
        if ($sender->id === $receiver->id) {
            return response()->json([
                'message' => 'Vous ne pouvez pas scanner votre propre QR Code.',
            ], 422);
        }

        // Vérifier le solde de l'expéditeur
        if (!$sender->hasSufficientBalance($qrToken->amount)) {
            return response()->json([
                'message' => 'Solde insuffisant.',
                'required' => $qrToken->amount,
                'balance'  => $sender->balance,
            ], 422);
        }

        // Transaction atomique
        $transaction = DB::transaction(function () use ($sender, $receiver, $qrToken) {
            $senderBalanceBefore   = $sender->balance;
            $receiverBalanceBefore = $receiver->balance;

            $sender->decrement('balance', $qrToken->amount);
            $receiver->increment('balance', $qrToken->amount);

            $transaction = Transaction::create([
                'sender_id'               => $sender->id,
                'receiver_id'             => $receiver->id,
                'amount'                  => $qrToken->amount,
                'type'                    => 'qr_send',
                'status'                  => 'completed',
                'reference'               => 'QR-' . strtoupper(Str::random(10)),
                'sender_balance_before'   => $senderBalanceBefore,
                'sender_balance_after'    => $sender->fresh()->balance,
                'receiver_balance_before' => $receiverBalanceBefore,
                'receiver_balance_after'  => $receiver->fresh()->balance,
            ]);

            // Marquer le token comme utilisé
            $qrToken->update([
                'is_used'        => true,
                'transaction_id' => $transaction->id,
            ]);

            return $transaction;
        });

        return response()->json([
            'message'     => 'Paiement QR Code effectué avec succès.',
            'transaction' => [
                'id'               => $transaction->id,
                'amount'           => $transaction->amount,
                'amount_formatted' => $transaction->amount_in_euros,
                'receiver'         => $receiver->full_name,
                'reference'        => $transaction->reference,
                'created_at'       => $transaction->created_at->toIso8601String(),
            ],
            'new_balance'           => $sender->fresh()->balance,
            'new_balance_formatted' => $sender->fresh()->balance_in_euros,
        ]);
    }
}
