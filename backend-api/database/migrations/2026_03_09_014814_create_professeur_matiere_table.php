<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Crée la table "professeur_matiere"
     * Fait le lien entre un professeur et ses matières (max 2)
     * On utilise unsignedBigInteger car la table professeurs
     * a été créée manuellement et non via une migration Laravel
     */
    public function up(): void
    {
        Schema::create('professeur_matiere', function (Blueprint $table) {
            $table->id();

            // Référence vers la table professeurs
            $table->unsignedBigInteger('professeur_id');
            $table->foreign('professeur_id')->references('id')->on('professeurs')->onDelete('cascade');

            // Référence vers la table matieres
            $table->unsignedBigInteger('matiere_id');
            $table->foreign('matiere_id')->references('id')->on('matieres')->onDelete('cascade');

    $table->timestamps();
        });
    }

    /**
     * Supprime la table si on annule la migration
     */
    public function down(): void
    {
        Schema::dropIfExists('professeur_matiere');
    }
};