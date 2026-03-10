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
     Schema::create('bkn_prices', function (Blueprint $table) {
         $table->id();
         $table->decimal('prix', 10, 4); // Le prix en euros (ex: 1.0520 €)
         $table->timestamps(); // Enregistre la date exacte du changement de prix
     });
 }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bkn_prices');
    }
};
