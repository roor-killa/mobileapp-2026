<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ─── Utilisateurs de test ─────────────────────────────────────────────
        $alice = User::create([
            'first_name' => 'Alice',
            'last_name'  => 'Martin',
            'email'      => 'alice@test.com',
            'phone'      => '+33600000001',
            'password'   => 'password',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 100000, // 1000,00 €
            'status'     => 'active',
        ]);

        $bob = User::create([
            'first_name' => 'Bob',
            'last_name'  => 'Dupont',
            'email'      => 'bob@test.com',
            'phone'      => '+33600000002',
            'password'   => 'password',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 50000, // 500,00 €
            'status'     => 'active',
        ]);

        $this->command->info("Utilisateurs de test créés :");
        $this->command->info("  alice@test.com / password / PIN: 123456 (solde: 1000,00 €)");
        $this->command->info("  bob@test.com   / password / PIN: 123456 (solde: 500,00 €)");
    }
}
