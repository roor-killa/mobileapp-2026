<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ChatbotController;
use App\Http\Controllers\WeatherController;

Route::post('/chatbot', [ChatbotController::class, 'chat']);
Route::post('/weather/fetch', [WeatherController::class, 'fetchAndStore']);
Route::post('/weather/get', [WeatherController::class, 'getWeather']);

Route::get('/test', function () {
    return response()->json([
        'message' => 'API Laravel fonctionne !',
        'version' => '12.50.0'
    ]);
});