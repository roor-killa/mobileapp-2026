<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. L'utilisateur principal (VOUS)
        User::factory()->create([
            'username' => 'admin_moi', // <--- AJOUTÉ
            'name' => 'Moi (Admin)',
            'email' => 'moi@bkn.com',
            'password' => bcrypt('password'),
            'balance' => 1500,
        ]);

        // 2. Les amis
        User::factory()->create([
            'username' => 'alice_w', // <--- AJOUTÉ
            'name' => 'Alice',
            'email' => 'alice@bkn.com',
            'balance' => 50,
        ]);

        User::factory()->create([
            'username' => 'bob_le_bricoleur', // <--- AJOUTÉ
            'name' => 'Bob',
            'email' => 'bob@bkn.com',
            'balance' => 0,
        ]);

        User::factory()->create([
            'username' => 'charlie_chaplin', // <--- AJOUTÉ
            'name' => 'Charlie',
            'email' => 'charlie@bkn.com',
            'balance' => 300,
        ]);
    }
}
