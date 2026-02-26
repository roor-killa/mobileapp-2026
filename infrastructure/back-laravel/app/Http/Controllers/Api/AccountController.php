<?php

namespace App\Http\Controllers\Api;

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
    public function getAccount(Request $request, $accountId)
    {
        $account = $request->user()->accounts()->find($accountId);

        if (!$account) {
            return response()->json([
                'message' => 'Compte non trouvé',
            ], 404);
        }

        return response()->json([
            'account' => $account,
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

    private function generateIBAN($userId): string
    {
        $countryCode = 'FR';
        $bankCode = '20041';
        $accountNumber = str_pad($userId, 11, '0', STR_PAD_LEFT);
        return $countryCode . '14' . $bankCode . $accountNumber . random_int(10, 99);
    }
}
