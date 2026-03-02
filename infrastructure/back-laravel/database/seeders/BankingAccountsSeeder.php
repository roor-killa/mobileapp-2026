<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Account;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class BankingAccountsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create test users
        $users = [
            [
                'name' => 'Jean Dupont',
                'first_name' => 'Jean',
                'last_name' => 'Dupont',
                'email' => 'jean.dupont@example.com',
                'phone' => '0612345678',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Marie Martin',
                'first_name' => 'Marie',
                'last_name' => 'Martin',
                'email' => 'marie.martin@example.com',
                'phone' => '0698765432',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Pierre Bernard',
                'first_name' => 'Pierre',
                'last_name' => 'Bernard',
                'email' => 'pierre.bernard@example.com',
                'phone' => '0601020304',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Sophie Lefebvre',
                'first_name' => 'Sophie',
                'last_name' => 'Lefebvre',
                'email' => 'sophie.lefebvre@example.com',
                'phone' => '0605060708',
                'password' => Hash::make('password123'),
            ],
        ];

        foreach ($users as $key => $userData) {
            $user = User::create($userData);

            // Créer un compte chèques principal
            $user->accounts()->create([
                'account_number' => 'ACC' . str_pad($user->id, 10, '0', STR_PAD_LEFT),
                'account_type' => 'Compte Chèques',
                'balance' => 1000 + ($key * 500),
                'currency' => 'EUR',
                'iban' => $this->generateIBAN($user->id),
                'is_active' => true,
            ]);

            // Créer un compte d'épargne
            $user->accounts()->create([
                'account_number' => 'SAV' . str_pad($user->id, 10, '0', STR_PAD_LEFT),
                'account_type' => 'Compte d\'Épargne',
                'balance' => 5000 + ($key * 1000),
                'currency' => 'EUR',
                'iban' => $this->generateIBAN($user->id + 1000),
                'is_active' => true,
            ]);
        }

        // Créer quelques transactions réalistes entre utilisateurs (pour que l'app ait du contenu dès le 1er lancement)
        $jean = User::where('email', 'jean.dupont@example.com')->first();
        $marie = User::where('email', 'marie.martin@example.com')->first();

        if ($jean && $marie) {
            $from = $jean->accounts()->where('account_type', 'Compte Chèques')->first();
            $to = $marie->accounts()->where('account_type', 'Compte Chèques')->first();

            if ($from && $to) {
                $this->seedTransfer($from, $to, 75.50, 'Remboursement restaurant');
                $this->seedTransfer($to, $from, 25.00, 'Participation covoiturage');
            }
        }
    }

    private function generateIBAN($userId): string
    {
        $countryCode = 'FR';
        $bankCode = '20041';
        $accountNumber = str_pad($userId, 11, '0', STR_PAD_LEFT);
        
        return $countryCode . '14' . $bankCode . $accountNumber;
    }

    private function seedTransfer(Account $from, Account $to, float $amount, string $description): void
    {
        if ($amount <= 0) {
            return;
        }

        $fromBalance = (float) $from->balance;
        $toBalance = (float) $to->balance;

        if ($fromBalance < $amount) {
            return;
        }

        $from->balance = $fromBalance - $amount;
        $from->save();

        $to->balance = $toBalance + $amount;
        $to->save();

        \App\Models\Transaction::create([
            'from_account_id' => $from->id,
            'to_account_id' => $to->id,
            'transaction_type' => 'transfer',
            'amount' => $amount,
            'description' => $description,
            'status' => 'completed',
            'reference_number' => 'TRF' . strtoupper(\Illuminate\Support\Str::random(12)),
            'transaction_date' => now(),
        ]);
    }
}
