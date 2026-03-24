<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exchange_rates', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->decimal('value', 10, 4);
            $table->timestamps();
        });

        // Taux initial : 1 EUR = 10 BKN
        DB::table('exchange_rates')->insert([
            'key'        => 'EUR_TO_BKN',
            'value'      => 10.0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('exchange_rates');
    }
};
