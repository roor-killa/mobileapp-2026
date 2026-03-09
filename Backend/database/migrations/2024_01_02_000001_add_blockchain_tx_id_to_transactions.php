<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            // TX ID Algorand (ex: ABCDEF123456...)
            $table->string('blockchain_tx_id')->nullable()->after('metadata');
            // URL directe vers l'explorateur Algorand
            $table->string('blockchain_explorer_url')->nullable()->after('blockchain_tx_id');
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropColumn(['blockchain_tx_id', 'blockchain_explorer_url']);
        });
    }
};
