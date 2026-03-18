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
        $janice = User::create([
            'first_name' => 'Janice',
            'last_name'  => 'Deslances',
            'email'      => 'janice.dlc@gmail.com',
            'phone'      => '0696781513',
            'password'   => 'Janice123',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 180000, // 1800,00 €
            'status'     => 'active',
        ]);

        $mathis = User::create([
            'first_name' => 'Mathis',
            'last_name'  => 'Eloidin--Michanol',
            'email'      => 'mathis.eld@gmail.com',
            'phone'      => '0696267656',
            'password'   => 'Mathis123',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 500000, // 500,00 €
            'status'     => 'active',
        ]);

        $mathyves = User::create([
            'first_name' => 'Mathyves',
            'last_name'  => 'Meranville',
            'email'      => 'mathyves.mrv@gmail.com',
            'phone'      => '0696066822',
            'password'   => 'Mathyves123',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 320000, // 3200,00 €
            'status'     => 'active',
        ]);

        $leina = User::create([
            'first_name' => 'Leina',
            'last_name'  => 'Musaraganyi',
            'email'      => 'leina.msrgn@gmail.com',
            'phone'      => '+33783695139',
            'password'   => 'Leina123',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 120000, // 1200,00 €
            'status'     => 'active',
        ]);

        $kylian = User::create([
            'first_name' => 'Kylian',
            'last_name'  => 'Eugene',
            'email'      => 'kylian.egn@gmail.com',
            'phone'      => '+33658445386',
            'password'   => 'Kylian123',
            'pin_hash'   => Hash::make('123456'),
            'balance'    => 180000, // 1800,00 €
            'status'     => 'active',
        ]);

        $this->command->info("Utilisateurs de test créés :");
        $this->command->info("  janice.dlc@gmail.com / Janice123 / PIN: 123456 (solde: 1800,00 €)");
        $this->command->info("  mathis.eld@gmail.com / Mathis123 / PIN: 123456 (solde: 5000,00 €)");
        $this->command->info("  mathyves.mrv@gmail.com / Mathyves123 / PIN: 123456 (solde: 3200,00 €)");
        $this->command->info("  leina.msrgn@gmail.com / Leina123 / PIN: 123456 (solde: 1200,00 €)");
        $this->command->info("  kylian.egn@gmail.com / Kylian123 / PIN: 123456 (solde: 1800,00 €)");

    }
}
