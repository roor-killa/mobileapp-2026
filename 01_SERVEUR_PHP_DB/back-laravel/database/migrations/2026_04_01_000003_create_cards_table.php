<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('bank_account_id')->constrained('bank_accounts')->onDelete('cascade');
            $table->string('card_number')->unique();
            $table->string('card_holder');
            $table->string('cvv')->encrypted();
            $table->date('expiry_date');
            $table->enum('card_type', ['debit', 'credit', 'virtual'])->default('debit');
            $table->enum('card_status', ['active', 'blocked', 'expired', 'cancelled'])->default('active');
            $table->enum('card_brand', ['visa', 'mastercard', 'amex'])->default('visa');
            $table->decimal('daily_limit', 15, 2)->default(1000);
            $table->decimal('monthly_limit', 15, 2)->default(10000);
            $table->decimal('spent_today', 15, 2)->default(0);
            $table->decimal('spent_month', 15, 2)->default(0);
            $table->boolean('is_virtual')->default(false);
            $table->boolean('is_primary')->default(false);
            $table->string('color')->default('#FF5722');
            $table->timestamp('activated_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cards');
    }
};
