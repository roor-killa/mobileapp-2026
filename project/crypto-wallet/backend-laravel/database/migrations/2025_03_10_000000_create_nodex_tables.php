<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tables NodEX (User, VirementEur) - compatible SQLite et PostgreSQL.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('User')) {
            return;
        }

        Schema::create('User', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('email')->unique();
            $table->string('passwordHash')->nullable();
            $table->string('name')->nullable();
            $table->string('pseudonym')->nullable()->unique();
            $table->string('iban')->nullable()->unique();
            $table->string('appwriteId')->nullable()->unique();
            $table->decimal('balanceEur', 15, 2)->default(2000);
            $table->timestamps();
        });

        if (!Schema::hasTable('VirementEur')) {
            Schema::create('VirementEur', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('fromUserId');
                $table->uuid('toUserId');
                $table->decimal('amount', 15, 2);
                $table->timestamp('createdAt')->useCurrent();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('VirementEur');
        Schema::dropIfExists('User');
    }
};
