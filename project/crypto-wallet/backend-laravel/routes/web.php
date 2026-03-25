<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect('/app/'));

// Flutter SPA : servir index.html pour toutes les routes /app/* (login, dashboard, etc.)
Route::get('/app/{path?}', function (?string $path = null) {
    $indexPath = public_path('app/index.html');
    if (file_exists($indexPath)) {
        return response()->file($indexPath, ['Content-Type' => 'text/html']);
    }
    abort(404);
})->where('path', '.*');
