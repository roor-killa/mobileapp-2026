<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Supprime l'ancienne colonne note de la table etudiants
    // Cette colonne est remplacée par la table notes (par matière)
    public function up(): void
    {
        Schema::table('etudiants', function (Blueprint $table) {
            $table->dropColumn('note');
        });
    }

    public function down(): void
    {
        Schema::table('etudiants', function (Blueprint $table) {
            $table->double('note')->default(0);
        });
    }
};
