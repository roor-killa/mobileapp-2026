<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Crée la table "notes"
     * Contient les notes des étudiants par matière (max 3 notes)
     */
    public function up(): void
    {
        Schema::create('notes', function (Blueprint $table) {
            $table->id();
            // Référence vers la table etudiants
            $table->foreignId('etudiant_id')->constrained('etudiants')->onDelete('cascade');
            // Référence vers la table matieres
            $table->foreignId('matiere_id')->constrained('matieres')->onDelete('cascade');
            // Les 3 notes possibles (nullable = pas obligatoire)
            $table->decimal('note1', 4, 2)->nullable(); // Ex: 15.50
            $table->decimal('note2', 4, 2)->nullable();
            $table->decimal('note3', 4, 2)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Supprime la table si on annule la migration
     */
    public function down(): void
    {
        Schema::dropIfExists('notes');
    }
};