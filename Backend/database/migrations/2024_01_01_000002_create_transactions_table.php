<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // Expéditeur (null si recharge externe Stripe)
            $table->foreignUuid('sender_id')->nullable()->constrained('users')->nullOnDelete();

            // Destinataire (null si retrait)
            $table->foreignUuid('receiver_id')->nullable()->constrained('users')->nullOnDelete();

            // Montant en centimes
            $table->bigInteger('amount')->unsigned();

            // Type de transaction
            $table->enum('type', [
                'transfer',  // Transfert entre utilisateurs
                'recharge',  // Recharge via Stripe
                'qr_receive', // Réception via QR Code
                'qr_send',    // Envoi via QR Code
            ]);

            // Statut
            $table->enum('status', ['pending', 'completed', 'failed', 'cancelled'])->default('pending');

            // Référence externe (ex: Stripe Payment Intent ID)
            $table->string('reference')->nullable()->unique();

            // Description / note optionnelle
            $table->string('note')->nullable();

            // Métadonnées (données brutes Stripe, etc.)
            $table->json('metadata')->nullable();

            // Soldes avant/après pour audit
            $table->bigInteger('sender_balance_before')->nullable();
            $table->bigInteger('sender_balance_after')->nullable();
            $table->bigInteger('receiver_balance_before')->nullable();
            $table->bigInteger('receiver_balance_after')->nullable();

            $table->timestamps();

            // Index pour les requêtes fréquentes
            $table->index(['sender_id', 'created_at']);
            $table->index(['receiver_id', 'created_at']);
            $table->index(['type', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
