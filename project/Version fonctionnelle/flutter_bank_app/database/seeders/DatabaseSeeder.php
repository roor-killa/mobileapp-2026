<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. On te crée un compte "Boss" avec un solde énorme pour faire tes tests !
        User::create([
            'name' => 'Boss',
            'prenom' => 'Admin',
            'email' => 'boss@mail.com', // Ton email de connexion
            'telephone' => '0600000000',
            'password' => Hash::make('password'), // Le mot de passe sera "password"
            'solde' => 5000.00, // Boom, 5000 € !
        ]);

        // 2. On crée 5 "faux" amis grâce à une petite boucle
        for ($i = 1; $i <= 5; $i++) {
            User::create([
                'name' => 'Testeur',
                'prenom' => 'Ami ' . $i,
                'email' => 'ami' . $i . '@mail.com', // Leurs emails : ami1@mail.com, ami2@mail.com...
                'telephone' => '070000000' . $i,
                'password' => Hash::make('password'), // Même mot de passe pour tous
                'solde' => 100.00, // On leur donne 100 € chacun
            ]);
        }
    }
}