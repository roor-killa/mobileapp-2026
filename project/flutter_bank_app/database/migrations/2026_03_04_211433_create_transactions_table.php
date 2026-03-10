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
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            // L'ID de l'utilisateur à qui appartient la transaction
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); 
            
            // Le type: 'rechargement', 'envoi', 'reception'
            $table->string('type'); 
            
            // Le montant de la transaction
            $table->decimal('montant', 10, 2); 
            
            // Un petit texte (ex: "Rechargement par carte" ou "Envoyé à test@mail.com")
            $table->string('description'); 
            
            $table->timestamps(); // Ajoute automatiquement 'created_at' (la date) et 'updated_at'
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
