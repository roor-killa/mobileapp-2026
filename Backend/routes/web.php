<?php

use Illuminate\Support\Facades\Route;

// Route de santé pour vérifier que l'app tourne
Route::get('/', function () {
    return response()->json([
        'app'     => 'MoneyTransferApp API',
        'version' => '1.0.0',
        'status'  => 'running',
    ]);
});
