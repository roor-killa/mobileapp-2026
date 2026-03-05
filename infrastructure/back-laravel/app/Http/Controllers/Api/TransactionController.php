<?php

namespace App\Http\Controllers\Api;

use App\Models\Account;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TransactionController extends \App\Http\Controllers\Controller
{
    /**
     * Récupérer tous les virements d'un compte
     */
    public function getTransactions(Request $request)
    {
        $accountIds = $request->user()->accounts()->pluck('id')->all();

        $transactions = Transaction::query()
            ->with([
                'fromAccount:id,user_id,account_type,iban,account_number,currency',
                'toAccount:id,user_id,account_type,iban,account_number,currency',
                'fromAccount.user:id,name,first_name,last_name',
                'toAccount.user:id,name,first_name,last_name',
            ])
            ->whereIn('from_account_id', $accountIds)
            ->orWhereIn('to_account_id', $accountIds)
            ->orderByDesc('transaction_date')
            ->limit(200)
            ->get()
            ->map(function (Transaction $t) use ($accountIds) {
                // Vente bourse/crypto : crédit sur le compte (affiché comme entrant)
                if ($t->transaction_type === 'bourse_credit') {
                    $direction = 'incoming';
                } else {
                    $isOutgoing = in_array($t->from_account_id, $accountIds, true) && (! $t->to_account_id || ! in_array($t->to_account_id, $accountIds, true));
                    $isIncoming = $t->to_account_id && in_array($t->to_account_id, $accountIds, true) && (! in_array($t->from_account_id, $accountIds, true));
                    $isInternal = $t->to_account_id && in_array($t->from_account_id, $accountIds, true) && in_array($t->to_account_id, $accountIds, true);
                    $direction = $isInternal ? 'internal' : ($isIncoming ? 'incoming' : ($isOutgoing ? 'outgoing' : 'unknown'));
                }

                return [
                    'id' => $t->id,
                    'from_account_id' => $t->from_account_id,
                    'to_account_id' => $t->to_account_id,
                    'transaction_type' => $t->transaction_type,
                    'amount' => $t->amount,
                    'description' => $t->description,
                    'status' => $t->status,
                    'reference_number' => $t->reference_number,
                    'transaction_date' => $t->transaction_date?->toIso8601String(),
                    'direction' => $direction,
                    'from_account' => $t->fromAccount ? [
                        'id' => $t->fromAccount->id,
                        'account_type' => $t->fromAccount->account_type,
                        'iban' => $t->fromAccount->iban,
                        'account_number' => $t->fromAccount->account_number,
                        'currency' => $t->fromAccount->currency,
                        'owner' => [
                            'id' => $t->fromAccount->user?->id,
                            'name' => $t->fromAccount->user?->full_name ?? $t->fromAccount->user?->name,
                        ],
                    ] : null,
                    'to_account' => $t->toAccount ? [
                        'id' => $t->toAccount->id,
                        'account_type' => $t->toAccount->account_type,
                        'iban' => $t->toAccount->iban,
                        'account_number' => $t->toAccount->account_number,
                        'currency' => $t->toAccount->currency,
                        'owner' => [
                            'id' => $t->toAccount->user?->id,
                            'name' => $t->toAccount->user?->full_name ?? $t->toAccount->user?->name,
                        ],
                    ] : null,
                ];
            })
            ->values();

        return response()->json([
            'transactions' => $transactions,
        ]);
    }

    /**
     * Effectuer un virement
     */
    public function transfer(Request $request)
    {
        $validated = $request->validate([
            'from_account_id' => 'required|exists:accounts,id',
            'to_account_id' => 'required|exists:accounts,id',
            'amount' => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:255',
        ]);

        if ((int) $validated['from_account_id'] === (int) $validated['to_account_id']) {
            return response()->json([
                'message' => 'Les comptes source et destination doivent être différents',
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $transaction = DB::transaction(function () use ($validated, $request) {
                $fromAccount = Account::query()
                    ->whereKey($validated['from_account_id'])
                    ->lockForUpdate()
                    ->firstOrFail();

                $toAccount = Account::query()
                    ->whereKey($validated['to_account_id'])
                    ->lockForUpdate()
                    ->firstOrFail();

                // Vérifier que l'utilisateur est propriétaire du compte source
                if ($fromAccount->user_id !== $request->user()->id) {
                    throw new \RuntimeException('Non autorisé', Response::HTTP_FORBIDDEN);
                }

                $amount = (float) $validated['amount'];

                // Vérifier les fonds disponibles
                if ((float) $fromAccount->balance < $amount) {
                    throw new \RuntimeException('Solde insuffisant', Response::HTTP_UNPROCESSABLE_ENTITY);
                }

                $fromAccount->balance = (float) $fromAccount->balance - $amount;
                $fromAccount->save();

                $toAccount->balance = (float) $toAccount->balance + $amount;
                $toAccount->save();

                return Transaction::create([
                    'from_account_id' => $fromAccount->id,
                    'to_account_id' => $toAccount->id,
                    'transaction_type' => 'transfer',
                    'amount' => $amount,
                    'description' => $validated['description'] ?? 'Virement bancaire',
                    'status' => 'completed',
                    'reference_number' => 'TRF' . Str::upper(Str::random(12)),
                    'transaction_date' => now(),
                ]);
            });
        } catch (\RuntimeException $e) {
            $code = $e->getCode();
            $status = ($code >= 400 && $code <= 599) ? $code : Response::HTTP_BAD_REQUEST;

            return response()->json([
                'message' => $e->getMessage(),
            ], $status);
        }

        return response()->json([
            'message' => 'Virement effectué avec succès',
            'transaction' => $transaction,
        ], Response::HTTP_CREATED);
    }

    /**
     * Récupérer les virements d'un compte spécifique
     */
    public function getAccountTransactions(Request $request, Account $account)
    {
        // Vérifier que l'utilisateur est propriétaire du compte
        if ($account->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé',
            ], Response::HTTP_FORBIDDEN);
        }

        $transactions = Transaction::query()
            ->with([
                'fromAccount:id,user_id,account_type,iban,account_number,currency',
                'toAccount:id,user_id,account_type,iban,account_number,currency',
            ])
            ->where('from_account_id', $account->id)
            ->orWhere('to_account_id', $account->id)
            ->orderByDesc('transaction_date')
            ->paginate(20);

        return response()->json([
            'account' => $account,
            'transactions' => $transactions,
        ]);
    }
}
