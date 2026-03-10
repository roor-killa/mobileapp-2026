<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
 {
     Schema::table('users', function (Blueprint $table) {
         // On ajoute le solde BKN, par défaut à 0
         $table->decimal('solde_bkn', 16, 4)->default(0.0000);
     });
 }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            //
        });
    }
};
