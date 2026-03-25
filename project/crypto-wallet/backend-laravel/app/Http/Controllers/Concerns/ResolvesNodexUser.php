<?php

namespace App\Http\Controllers\Concerns;

use App\Models\NodexUser;
use Illuminate\Http\Request;

/**
 * Même logique JWT → appwriteId → ligne User partout (carte, virements, wallets, chat).
 * Évite les 404 où un id ne correspond plus à la base (ex. Neon / Appwrite).
 */
trait ResolvesNodexUser
{
    protected function nodexUser(Request $request): ?NodexUser
    {
        $appwriteId = $this->appwriteIdFromJwt($request);
        if (!$appwriteId) {
            return null;
        }

        return NodexUser::where('appwriteId', $appwriteId)->first();
    }

    protected function nodexUserId(Request $request): ?string
    {
        return $this->nodexUser($request)?->id;
    }

    protected function appwriteIdFromJwt(Request $request): ?string
    {
        $auth = $request->header('Authorization');
        if (!$auth || !str_starts_with($auth, 'Bearer ')) {
            return null;
        }
        $token = substr($auth, 7);
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return null;
        }
        $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
        if (!is_array($payload)) {
            return null;
        }
        $appwriteId = $payload['userId'] ?? $payload['sub'] ?? $payload['$id'] ?? null;
        if (!$appwriteId && isset($payload['user']) && is_array($payload['user'])) {
            $u = $payload['user'];
            $appwriteId = $u['$id'] ?? $u['id'] ?? null;
        }

        return is_string($appwriteId) && $appwriteId !== '' ? $appwriteId : null;
    }
}
