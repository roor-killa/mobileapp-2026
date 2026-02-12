<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('weather_data', function (Blueprint $table) {
            $table->id();
            $table->string('city');
            $table->string('country');
            $table->float('temperature');
            $table->string('description');
            $table->string('icon');
            $table->integer('humidity')->nullable();
            $table->float('wind_speed')->nullable();
            $table->integer('pressure')->nullable();
            $table->float('feels_like')->nullable();
            $table->timestamps();
            
            $table->index('city');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weather_data');
    }
};