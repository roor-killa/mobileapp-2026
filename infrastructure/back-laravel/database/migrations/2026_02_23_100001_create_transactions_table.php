<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained()->onDelete('cascade');
            $table->foreignId('related_wallet_id')->nullable()->constrained('wallets')->onDelete('set null');
            $table->enum('type', ['topup', 'transfer_out', 'transfer_in']);
            $table->decimal('amount', 10, 2);
            $table->string('stripe_payment_intent_id')->nullable();
            $table->string('status')->default('completed');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
