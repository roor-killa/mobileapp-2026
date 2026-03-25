<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Autorise les requêtes cross-origin depuis localhost (Flutter web).
 * Répond avec l'origine réelle pour que le navigateur envoie les headers (Authorization).
 */
class CorsAllowLocalhost
{
    public function handle(Request $request, Closure $next): Response
    {
        $origin = $request->header('Origin');
        $allowed = $origin && (
            str_starts_with($origin, 'http://localhost') ||
            str_starts_with($origin, 'http://127.0.0.1') ||
            str_starts_with($origin, 'https://localhost') ||
            str_starts_with($origin, 'https://127.0.0.1')
        );

        if ($allowed && $request->isMethod('OPTIONS')) {
            return response('', 204)
                ->header('Access-Control-Allow-Origin', $origin)
                ->header('Access-Control-Allow-Credentials', 'true')
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
        }

        $response = $next($request);

        if ($allowed) {
            $response->headers->set('Access-Control-Allow-Origin', $origin);
            $response->headers->set('Access-Control-Allow-Credentials', 'true');
        }

        return $response;
    }
}
