<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Crée la table "matieres"
     * Contient la liste de toutes les matières disponibles
     */
    public function up(): void
    {
        Schema::create('matieres', function (Blueprint $table) {
            $table->id();                          // Identifiant unique
            $table->string('nom');                 // Nom de la matière (ex: Maths)
            $table->timestamps();                  // created_at et updated_at
        });
    }

    /**
     * Supprime la table si on annule la migration
     */
    public function down(): void
    {
        Schema::dropIfExists('matieres');
    }
};