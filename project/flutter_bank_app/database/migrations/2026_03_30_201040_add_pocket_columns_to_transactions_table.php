<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->foreignId('pocket_id')
                  ->nullable()
                  ->after('user_id')
                  ->constrained()
                  ->onDelete('set null');
            $table->string('wallet_source')
                  ->nullable()
                  ->after('pocket_id')
                  ->default('principal');
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['pocket_id']);
            $table->dropColumn(['pocket_id', 'wallet_source']);
        });
    }
};