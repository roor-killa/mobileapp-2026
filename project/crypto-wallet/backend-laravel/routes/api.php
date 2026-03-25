<?php

use App\Http\Controllers\CardController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\VirementController;
use App\Http\Controllers\WalletController;
use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => response()->json(['ok' => true, 'time' => now()->toIso8601String()]));

// Debug : vérifier que le JWT est bien reçu (à supprimer en prod)
Route::get('/debug/auth', function (\Illuminate\Http\Request $request) {
    $auth = $request->header('Authorization');
    $hasAuth = $auth && str_starts_with($auth, 'Bearer ');
    $payload = null;
    if ($hasAuth) {
        $token = substr($auth, 7);
        $parts = explode('.', $token);
        if (count($parts) === 3) {
            $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
        }
    }
    return response()->json([
        'hasAuth' => $hasAuth,
        'payloadKeys' => $payload ? array_keys($payload) : [],
        'userId' => $payload['userId'] ?? $payload['sub'] ?? null,
    ]);
});

Route::get('/card', [CardController::class, 'index']);
Route::get('/wallets', [WalletController::class, 'index']);
Route::post('/chat/groq', [ChatController::class, 'completions']);

// Même structure que NestJS : /virements/... (Flutter appelle baseUrl + /virements/...)
Route::prefix('virements')->group(function () {
    Route::get('balance', [VirementController::class, 'balance']);
    Route::get('me', [VirementController::class, 'me']);
    Route::get('history', [VirementController::class, 'history']);
    Route::post('send', [VirementController::class, 'send']);
});
