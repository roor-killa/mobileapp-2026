<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\User;
use App\Services\AlgorandService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class TransactionController extends Controller
{
    /**
     * POST /api/transfer
     * Transférer de l'argent à un autre utilisateur
     */
    public function transfer(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'receiver_email' => ['required', 'email', 'exists:users,email'],
            'amount'         => ['required', 'integer', 'min:100'], // min 1,00 €
            'pin'            => ['required', 'digits:6'],
            'note'           => ['nullable', 'string', 'max:255'],
        ]);

        $sender = $request->user();

        // Vérification : pas de transfert à soi-même
        if ($sender->email === $validated['receiver_email']) {
            return response()->json([
                'message' => 'Vous ne pouvez pas vous transférer de l\'argent à vous-même.',
            ], 422);
        }

        // Vérification du PIN
        if (!$sender->verifyPin($validated['pin'])) {
            return response()->json([
                'message' => 'PIN incorrect.',
            ], 403);
        }

        // Vérification du solde
        if (!$sender->hasSufficientBalance($validated['amount'])) {
            return response()->json([
                'message' => 'Solde insuffisant.',
                'balance' => $sender->balance,
            ], 422);
        }

        $receiver = User::where('email', $validated['receiver_email'])->firstOrFail();

        // Transaction atomique : débit/crédit simultané
        $transaction = DB::transaction(function () use ($sender, $receiver, $validated) {
            $senderBalanceBefore   = $sender->balance;
            $receiverBalanceBefore = $receiver->balance;

            // Débit de l'expéditeur
            $sender->decrement('balance', $validated['amount']);
            $sender->refresh();

            // Crédit du destinataire
            $receiver->increment('balance', $validated['amount']);
            $receiver->refresh();

            // Enregistrement de la transaction
            return Transaction::create([
                'sender_id'             => $sender->id,
                'receiver_id'           => $receiver->id,
                'amount'                => $validated['amount'],
                'type'                  => 'transfer',
                'status'                => 'completed',
                'reference'             => 'TRF-' . strtoupper(Str::random(10)),
                'note'                  => $validated['note'] ?? null,
                'sender_balance_before' => $senderBalanceBefore,
                'sender_balance_after'  => $sender->balance,
                'receiver_balance_before' => $receiverBalanceBefore,
                'receiver_balance_after'  => $receiver->balance,
            ]);
        });

        // ─── Enregistrement sur Algorand (asynchrone, n'impact pas la réponse) ──
        $algorand = new AlgorandService();
        $txId = $algorand->recordTransaction([
            'type'      => 'transfer',
            'amount'    => $validated['amount'] / 100 . ' EUR',
            'sender'    => $sender->email,
            'receiver'  => $receiver->email,
            'reference' => $transaction->reference,
        ]);

        if ($txId) {
            $transaction->update([
                'blockchain_tx_id'       => $txId,
                'blockchain_explorer_url' => AlgorandService::getExplorerUrl($txId),
            ]);
        }

        return response()->json([
            'message'     => 'Transfert effectué avec succès.',
            'transaction' => $this->formatTransaction($transaction->fresh()),
            'new_balance' => $sender->fresh()->balance,
            'new_balance_formatted' => $sender->fresh()->balance_in_euros,
        ], 201);
    }

    // ─── Helper ────────────────────────────────────────────────────────────────

    public function formatTransaction(Transaction $transaction): array
    {
        return [
            'id'        => $transaction->id,
            'type'      => $transaction->type,
            'status'    => $transaction->status,
            'amount'    => $transaction->amount,
            'amount_formatted' => $transaction->amount_in_euros,
            'reference' => $transaction->reference,
            'note'      => $transaction->note,
            'sender'    => $transaction->sender ? [
                'id'        => $transaction->sender->id,
                'full_name' => $transaction->sender->full_name,
                'email'     => $transaction->sender->email,
            ] : null,
            'receiver'  => $transaction->receiver ? [
                'id'        => $transaction->receiver->id,
                'full_name' => $transaction->receiver->full_name,
                'email'     => $transaction->receiver->email,
            ] : null,
            'created_at'              => $transaction->created_at,
            'blockchain_tx_id'        => $transaction->blockchain_tx_id,
            'blockchain_explorer_url' => $transaction->blockchain_explorer_url,
        ];
    }
}
