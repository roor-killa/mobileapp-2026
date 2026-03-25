<?php

namespace App\Http\Middleware;

use App\Models\NodexUser;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

/**
 * Crée automatiquement un NodexUser si l'utilisateur est authentifié via Appwrite
 * mais n'existe pas encore en base.
 * Email unique : {appwriteId}@nodex-local.invalid (plus de conflit "user@nodex.local").
 */
class EnsureNodexUser
{
    public function handle(Request $request, Closure $next): Response
    {
        $auth = $request->header('Authorization');
        if (!$auth || !str_starts_with($auth, 'Bearer ')) {
            return $next($request);
        }

        $token = substr($auth, 7);
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return $next($request);
        }

        $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
        if (!is_array($payload)) {
            return $next($request);
        }

        // Même extraction que ResolvesNodexUser (évite « Undefined array key user » sur le JWT Appwrite).
        $appwriteId = $payload['userId'] ?? $payload['sub'] ?? $payload['$id'] ?? null;
        if (!$appwriteId && isset($payload['user']) && is_array($payload['user'])) {
            $u = $payload['user'];
            $appwriteId = $u['$id'] ?? $u['id'] ?? null;
        }
        if (!$appwriteId || !is_string($appwriteId)) {
            return $next($request);
        }

        if (NodexUser::where('appwriteId', $appwriteId)->exists()) {
            return $next($request);
        }

        $iban = NodexUser::syntheticIbanForAppwriteId($appwriteId);
        $pseudo = NodexUser::syntheticPseudonymForAppwriteId($appwriteId);

        NodexUser::firstOrCreate(
            ['appwriteId' => $appwriteId],
            [
                'id' => (string) Str::uuid(),
                'email' => $appwriteId.'@nodex-local.invalid',
                'name' => 'Utilisateur',
                'pseudonym' => $pseudo,
                'iban' => $iban,
                'passwordHash' => '',
                'balanceEur' => 2000,
            ]
        );

        return $next($request);
    }
}
