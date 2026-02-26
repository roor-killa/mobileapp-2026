<?php

namespace App\Http\Controllers\Api;

use App\Models\Account;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Str;

class TransactionController extends \App\Http\Controllers\Controller
{
    /**
     * Récupérer tous les virements d'un compte
     */
    public function getTransactions(Request $request)
    {
        $user = $request->user();
        $accounts = $user->accounts()->with('allTransactions')->get();

        $transactions = [];
        foreach ($accounts as $account) {
            $transactions = array_merge($transactions, $account->allTransactions()->get()->toArray());
        }

        usort($transactions, function ($a, $b) {
            return strtotime($b['transaction_date']) - strtotime($a['transaction_date']);
        });

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

        $fromAccount = Account::find($validated['from_account_id']);
        $toAccount = Account::find($validated['to_account_id']);

        // Vérifier que l'utilisateur est propriétaire du compte source
        if ($fromAccount->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé',
            ], Response::HTTP_FORBIDDEN);
        }

        // Vérifier les fonds disponibles
        if ($fromAccount->balance < $validated['amount']) {
            return response()->json([
                'message' => 'Solde insuffisant',
                'available' => $fromAccount->balance,
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        // Vérifier les comptes ne sont pas les mêmes
        if ($fromAccount->id === $toAccount->id) {
            return response()->json([
                'message' => 'Les comptes source et destination doivent être différents',
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        // Effectuer le virement
        $fromAccount->balance -= $validated['amount'];
        $fromAccount->save();

        $toAccount->balance += $validated['amount'];
        $toAccount->save();

        // Enregistrer la transaction
        $transaction = Transaction::create([
            'from_account_id' => $fromAccount->id,
            'to_account_id' => $toAccount->id,
            'transaction_type' => 'transfer',
            'amount' => $validated['amount'],
            'description' => $validated['description'] ?? 'Virement bancaire',
            'status' => 'completed',
            'reference_number' => 'TRF' . Str::upper(Str::random(12)),
            'transaction_date' => now(),
        ]);

        return response()->json([
            'message' => 'Virement effectué avec succès',
            'transaction' => $transaction,
            'from_account' => $fromAccount,
            'to_account' => $toAccount,
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

        $transactions = $account->allTransactions()->paginate(20);

        return response()->json([
            'account' => $account,
            'transactions' => $transactions,
        ]);
    }
}
