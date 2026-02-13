<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('password');

        User::create(['name' => 'Moi Admin', 'username' => 'admin', 'email' => 'admin@bkn.app', 'password' => $password, 'balance' => 1500]);
        User::create(['name' => 'Alice', 'username' => 'alice', 'email' => 'alice@bkn.app', 'password' => $password, 'balance' => 50]);
        User::create(['name' => 'Bob', 'username' => 'bob', 'email' => 'bob@bkn.app', 'password' => $password, 'balance' => 0]);
        User::create(['name' => 'Charlie', 'username' => 'charlie', 'email' => 'charlie@bkn.app', 'password' => $password, 'balance' => 300]);
    }
}
