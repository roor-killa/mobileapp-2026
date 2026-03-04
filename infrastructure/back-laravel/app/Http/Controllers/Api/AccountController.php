<?php

namespace App\Http\Controllers\Api;

use App\Models\Account;
use Illuminate\Http\Request;

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

    private function generateIBAN($userId): string
    {
        $countryCode = 'FR';
        $bankCode = '20041';
        $accountNumber = str_pad($userId, 11, '0', STR_PAD_LEFT);
        return $countryCode . '14' . $bankCode . $accountNumber . random_int(10, 99);
    }
}
