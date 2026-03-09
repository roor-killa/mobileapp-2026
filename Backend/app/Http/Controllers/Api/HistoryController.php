<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HistoryController extends Controller
{
    /**
     * GET /api/history
     * Historique paginé des transactions de l'utilisateur connecté
     */
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type'     => ['nullable', 'in:transfer,recharge,qr_receive,qr_send'],
            'per_page' => ['nullable', 'integer', 'min:5', 'max:100'],
        ]);

        $user    = $request->user();
        $perPage = $validated['per_page'] ?? 20;

        $query = Transaction::with(['sender', 'receiver'])
            ->where(function ($q) use ($user) {
                $q->where('sender_id', $user->id)
                  ->orWhere('receiver_id', $user->id);
            })
            ->orderBy('created_at', 'desc');

        // Filtre optionnel par type
        if (!empty($validated['type'])) {
            $query->where('type', $validated['type']);
        }

        $transactions = $query->paginate($perPage);

        return response()->json([
            'data' => $transactions->map(function (Transaction $tx) use ($user) {
                return $this->formatForUser($tx, $user->id);
            }),
            'meta' => [
                'current_page' => $transactions->currentPage(),
                'last_page'    => $transactions->lastPage(),
                'per_page'     => $transactions->perPage(),
                'total'        => $transactions->total(),
            ],
        ]);
    }

    /**
     * GET /api/history/{id}
     * Détail d'une transaction
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $user = $request->user();

        $transaction = Transaction::with(['sender', 'receiver'])
            ->where(function ($q) use ($user) {
                $q->where('sender_id', $user->id)
                  ->orWhere('receiver_id', $user->id);
            })
            ->findOrFail($id);

        return response()->json([
            'transaction' => $this->formatForUser($transaction, $user->id),
        ]);
    }

    // ─── Helper ────────────────────────────────────────────────────────────────

    private function formatForUser(Transaction $tx, string $userId): array
    {
        $isDebit = $tx->sender_id === $userId;

        return [
            'id'        => $tx->id,
            'type'      => $tx->type,
            'status'    => $tx->status,
            'direction' => $isDebit ? 'debit' : 'credit',
            'amount'    => $tx->amount,
            'amount_formatted' => $tx->amount_in_euros,
            'reference' => $tx->reference,
            'note'      => $tx->note,
            'counterpart' => $isDebit
                ? ($tx->receiver ? ['full_name' => $tx->receiver->full_name, 'email' => $tx->receiver->email] : null)
                : ($tx->sender  ? ['full_name' => $tx->sender->full_name,   'email' => $tx->sender->email]   : null),
            'created_at'              => $tx->created_at->toIso8601String(),
            'blockchain_tx_id'        => $tx->blockchain_tx_id,
            'blockchain_explorer_url' => $tx->blockchain_explorer_url,
        ];
    }
}
