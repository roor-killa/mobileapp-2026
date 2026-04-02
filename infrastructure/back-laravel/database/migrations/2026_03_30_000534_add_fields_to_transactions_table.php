<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::table('transactions', function (Blueprint $table) {
        $table->unsignedBigInteger('emetteur_id');
        $table->unsignedBigInteger('recepteur_id');
        $table->double('montant');
        $table->string('statut');
        $table->string('type');
    });
}

public function down()
{
    Schema::table('transactions', function (Blueprint $table) {
        $table->dropColumn([
            'emetteur_id',
            'recepteur_id',
            'montant',
            'statut',
            'type'
        ]);
    });
}
};
