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
            $table->foreignId('from_account_id')->constrained('accounts')->cascadeOnDelete();
            $table->foreignId('to_account_id')->nullable()->constrained('accounts')->cascadeOnDelete();
            $table->string('transaction_type'); // transfer, deposit, withdrawal
            $table->decimal('amount', 15, 2);
            $table->string('description')->nullable();
            $table->string('status')->default('completed'); // pending, completed, failed
            $table->string('reference_number')->unique();
            $table->timestamp('transaction_date');
            $table->timestamps();
            
            $table->index('from_account_id');
            $table->index('to_account_id');
            $table->index('transaction_date');
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
