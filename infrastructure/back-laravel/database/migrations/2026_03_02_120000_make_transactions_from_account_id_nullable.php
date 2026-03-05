<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['from_account_id']);
        });
        if ($driver === 'mysql') {
            DB::statement('ALTER TABLE transactions MODIFY from_account_id BIGINT UNSIGNED NULL');
        } else {
            Schema::table('transactions', function (Blueprint $table) {
                $table->unsignedBigInteger('from_account_id')->nullable()->change();
            });
        }
        Schema::table('transactions', function (Blueprint $table) {
            $table->foreign('from_account_id')->references('id')->on('accounts')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['from_account_id']);
        });
        if (Schema::getConnection()->getDriverName() === 'mysql') {
            DB::statement('ALTER TABLE transactions MODIFY from_account_id BIGINT UNSIGNED NOT NULL');
        } else {
            Schema::table('transactions', function (Blueprint $table) {
                $table->unsignedBigInteger('from_account_id')->nullable(false)->change();
            });
        }
        Schema::table('transactions', function (Blueprint $table) {
            $table->foreign('from_account_id')->references('id')->on('accounts')->cascadeOnDelete();
        });
    }
};
