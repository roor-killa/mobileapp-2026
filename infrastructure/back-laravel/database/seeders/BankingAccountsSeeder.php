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
                'email' => 'jean.dupont@example.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Marie Martin',
                'email' => 'marie.martin@example.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Pierre Bernard',
                'email' => 'pierre.bernard@example.com',
                'password' => Hash::make('password123'),
            ],
            [
                'name' => 'Sophie Lefebvre',
                'email' => 'sophie.lefebvre@example.com',
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
    }

    private function generateIBAN($userId): string
    {
        $countryCode = 'FR';
        $bankCode = '20041';
        $accountNumber = str_pad($userId, 11, '0', STR_PAD_LEFT);
        
        return $countryCode . '14' . $bankCode . $accountNumber;
    }
}
