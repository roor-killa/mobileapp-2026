<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('etudiants', function (Blueprint $table) {
            // Ajoute la colonne classe_id après email
            // nullable() car les étudiants existants n'ont pas encore de classe
            $table->foreignId('classe_id')
                  ->nullable()
                  ->after('email')
                  ->constrained('classes')
                  ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('etudiants', function (Blueprint $table) {
            $table->dropForeign(['classe_id']);
            $table->dropColumn('classe_id');
        });
    }
};