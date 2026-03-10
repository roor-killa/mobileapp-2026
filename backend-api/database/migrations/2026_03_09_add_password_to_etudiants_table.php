<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Ajoute le champ password à la table etudiants
    // pour permettre aux étudiants de se connecter
    public function up(): void
    {
        Schema::table('etudiants', function (Blueprint $table) {
            // nullable() car les étudiants existants n'ont pas encore de password
            $table->string('password')->nullable()->after('email');
        });
    }

    // Supprime le champ password si on annule la migration
    public function down(): void
    {
        Schema::table('etudiants', function (Blueprint $table) {
            $table->dropColumn('password');
        });
    }
};