<?php

namespace App\Http\Controllers\Api;

use App\Models\Account;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AccountController extends \App\Http\Controllers\Controller
{
    /**
     * Récupérer tous les comptes de l'utilisateur
     */
    public function getAccounts(Request $request)
    {
        $accounts = $request->user()->accounts()->get();

        return response()->json([
            'accounts' => $accounts,
            'total_balance' => $accounts->sum('balance'),
        ]);
    }

    /**
     * Récupérer un compte spécifique
     */
    public function getAccount(Request $request, Account $account)
    {
        if ($account->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé',
            ], 403);
        }

        return response()->json([
            'account' => $account,
        ]);
    }

    /**
     * Liste des bénéficiaires (comptes d'autres utilisateurs)
     */
    public function getBeneficiaries(Request $request)
    {
        $accounts = Account::query()
            ->where('user_id', '!=', $request->user()->id)
            ->where('is_active', true)
            ->with('user:id,name,first_name,last_name,email')
            ->orderBy('user_id')
            ->orderBy('account_type')
            ->limit(50)
            ->get();

        $beneficiaries = $accounts->map(function (Account $account) {
            $ownerName = $account->user?->full_name ?? $account->user?->name ?? 'Bénéficiaire';

            return [
                'id' => $account->id,
                'account_type' => $account->account_type,
                'iban' => $account->iban,
                'account_number' => $account->account_number,
                'currency' => $account->currency,
                'owner' => [
                    'id' => $account->user?->id,
                    'name' => $ownerName,
                ],
            ];
        })->values();

        return response()->json([
            'beneficiaries' => $beneficiaries,
        ]);
    }

    /**
     * Créer un nouveau compte (Épargne, etc)
     */
    public function createAccount(Request $request)
    {
        $validated = $request->validate([
            'account_type' => 'required|string|in:Compte Chèques,Compte d\'Épargne,Compte Titre',
        ]);

        $account = $request->user()->accounts()->create([
            'account_number' => 'ACC' . str_pad($request->user()->id, 10, '0', STR_PAD_LEFT) . random_int(100, 999),
            'account_type' => $validated['account_type'],
            'balance' => 0,
            'currency' => 'EUR',
            'iban' => $this->generateIBAN($request->user()->id),
        ]);

        return response()->json([
            'message' => 'Compte créé avec succès',
            'account' => $account,
        ], 201);
    }

    /**
     * Supprimer un compte (uniquement si solde = 0)
     */
    public function deleteAccount(Request $request, Account $account)
    {
        if ($account->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        if ((float) $account->balance !== 0.0) {
            return response()->json([
                'message' => 'Impossible de supprimer un compte avec un solde non nul. Videz le compte avant de le supprimer.',
            ], 422);
        }

        $account->delete();
        return response()->json(['message' => 'Compte supprimé avec succès']);
    }

    /**
     * Débiter un compte (ex. achat bourse / crypto). Crée une transaction et met à jour le solde.
     */
    public function debitAccount(Request $request, Account $account)
    {
        if ($account->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Non autorisé'], Response::HTTP_FORBIDDEN);
        }

        $validated = $request->validate([
            'amount' => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:255',
        ]);

        $amount = (float) $validated['amount'];
        $description = $validated['description'] ?? 'Achat Bourse';

        if ((float) $account->balance < $amount) {
            return response()->json([
                'message' => 'Solde insuffisant',
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            DB::transaction(function () use ($account, $amount, $description) {
                $locked = Account::where('id', $account->id)->lockForUpdate()->firstOrFail();
                $locked->balance = (float) $locked->balance - $amount;
                $locked->save();

                Transaction::create([
                    'from_account_id' => $locked->id,
                    'to_account_id' => null,
                    'transaction_type' => 'bourse',
                    'amount' => $amount,
                    'description' => $description,
                    'status' => 'completed',
                    'reference_number' => 'BRS' . Str::upper(Str::random(12)),
                    'transaction_date' => now(),
                ]);
            });
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Erreur lors du débit du compte',
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }

        $account->refresh();
        return response()->json([
            'message' => 'Débit effectué',
            'balance' => (float) $account->balance,
        ]);
    }

    /**
     * Créditer un compte (ex. vente bourse / crypto). Ajoute au solde et crée une transaction.
     */
    public function creditAccount(Request $request, Account $account)
    {
        if ($account->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Non autorisé'], Response::HTTP_FORBIDDEN);
        }

        $validated = $request->validate([
            'amount' => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:255',
        ]);

        $amount = (float) $validated['amount'];
        $description = $validated['description'] ?? 'Vente Bourse';

        try {
            DB::transaction(function () use ($account, $amount, $description) {
                $locked = Account::where('id', $account->id)->lockForUpdate()->firstOrFail();
                $locked->balance = (float) $locked->balance + $amount;
                $locked->save();

                // Même compte en from/to + type bourse_credit pour éviter from_account_id NULL (compatible sans migration)
                Transaction::create([
                    'from_account_id' => $locked->id,
                    'to_account_id' => $locked->id,
                    'transaction_type' => 'bourse_credit',
                    'amount' => $amount,
                    'description' => $description,
                    'status' => 'completed',
                    'reference_number' => 'VNT' . Str::upper(Str::random(12)),
                    'transaction_date' => now(),
                ]);
            });
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Erreur lors du crédit du compte',
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }

        $account->refresh();
        return response()->json([
            'message' => 'Crédit effectué',
            'balance' => (float) $account->balance,
        ]);
    }

    private function generateIBAN($userId): string
    {
        $countryCode = 'FR';
        $bankCode = '20041';
        $accountNumber = str_pad($userId, 11, '0', STR_PAD_LEFT);
        return $countryCode . '14' . $bankCode . $accountNumber . random_int(10, 99);
    }
}
