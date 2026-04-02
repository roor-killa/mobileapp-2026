<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bank_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('account_number')->unique();
            $table->string('iban')->nullable()->unique();
            $table->string('bic')->nullable();
            $table->string('account_name');
            $table->string('currency', 3)->default('EUR');
            $table->decimal('balance', 15, 2)->default(0);
            $table->enum('account_type', ['checking', 'savings', 'investment'])->default('checking');
            $table->enum('status', ['active', 'inactive', 'frozen'])->default('active');
            $table->timestamp('opened_at')->nullable();
            $table->timestamp('closed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bank_accounts');
    }
};
