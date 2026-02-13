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
        $table->foreignId('sender_id')->constrained('users');   // Qui envoie
        $table->foreignId('receiver_id')->constrained('users'); // Qui reçoit
        $table->integer('amount'); // Combien
        $table->timestamps(); // Date (created_at)
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
