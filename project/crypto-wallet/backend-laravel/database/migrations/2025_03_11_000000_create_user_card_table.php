<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Table UserCard - compatible SQLite et PostgreSQL.
     */
    public function up(): void
    {
        if (Schema::hasTable('UserCard')) {
            return;
        }

        Schema::create('UserCard', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('userId')->unique();
            $table->string('cardNumber');
            $table->string('last4', 4);
            $table->unsignedTinyInteger('expiryMonth');
            $table->unsignedSmallInteger('expiryYear');
            $table->string('cvv', 4);
            $table->string('pin', 6);
            $table->timestamp('createdAt')->useCurrent();
        });

        Schema::table('UserCard', function (Blueprint $table) {
            $table->foreign('userId')->references('id')->on('User')->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('UserCard');
    }
};
