<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

//"INSCRIPTION"
Route::post('/register', [AuthController::class, 'register']);

//"LOGIN"
Route::post('/login', [AuthController::class, 'login']);

//pour voir ses propres infos (ton "DASHBOARD")
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');