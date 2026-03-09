<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('qr_tokens', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // Utilisateur qui génère le QR Code (le receveur)
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();

            // Montant que l'expéditeur devra payer (en centimes)
            $table->bigInteger('amount')->unsigned();

            // Token HMAC signé (payload chiffré)
            $table->string('token', 512)->unique();

            // Le QR code expire dans 10 secondes
            $table->timestamp('expires_at');

            // Vrai si déjà utilisé (consommé une seule fois)
            $table->boolean('is_used')->default(false);

            // Transaction liée une fois utilisé
            $table->foreignUuid('transaction_id')->nullable()->constrained('transactions')->nullOnDelete();

            $table->timestamps();

            // Index pour nettoyage des tokens expirés
            $table->index(['expires_at', 'is_used']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('qr_tokens');
    }
};
