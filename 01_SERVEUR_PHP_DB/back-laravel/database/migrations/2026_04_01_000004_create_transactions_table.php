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
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('from_account_id')->nullable()->constrained('bank_accounts');
            $table->foreignId('to_account_id')->nullable()->constrained('bank_accounts');
            $table->unsignedBigInteger('to_user_id')->nullable()->index();
            $table->enum('transaction_type', ['transfer', 'payment', 'deposit', 'withdrawal', 'card_purchase', 'currency_exchange', 'fee'])->default('transfer');
            $table->enum('status', ['pending', 'completed', 'failed', 'cancelled'])->default('pending');
            $table->decimal('amount', 15, 2);
            $table->string('currency', 3)->default('EUR');
            $table->string('description')->nullable();
            $table->string('reference')->unique();
            $table->string('recipient_name')->nullable();
            $table->string('recipient_iban')->nullable();
            $table->string('recipient_bank')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamp('executed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
