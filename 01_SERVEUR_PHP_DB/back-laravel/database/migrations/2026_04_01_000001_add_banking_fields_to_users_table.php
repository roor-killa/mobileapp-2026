<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable()->unique();
            $table->date('date_of_birth')->nullable();
            $table->string('nationality')->nullable();
            $table->string('address')->nullable();
            $table->string('city')->nullable();
            $table->string('country')->nullable();
            $table->string('postal_code')->nullable();
            $table->enum('kyc_status', ['pending', 'verified', 'rejected'])->default('pending');
            $table->decimal('account_balance', 15, 2)->default(0);
            $table->decimal('daily_limit', 15, 2)->default(5000);
            $table->decimal('monthly_limit', 15, 2)->default(50000);
            $table->enum('account_status', ['active', 'suspended', 'blocked'])->default('active');
            $table->timestamp('last_login')->nullable();
            $table->string('preferred_currency', 3)->default('EUR');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'phone', 'date_of_birth', 'nationality', 'address', 'city', 'country', 
                'postal_code', 'kyc_status', 'account_balance', 'daily_limit', 'monthly_limit',
                'account_status', 'last_login', 'preferred_currency'
            ]);
        });
    }
};
