<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie', '*'], // On autorise tout ce qui est API

    'allowed_methods' => ['*'], // GET, POST, PUT, DELETE... tout est permis

    'allowed_origins' => ['http://localhost:3000', 'http://localhost:3001'],
    //                          // ⚠️ ATTENTION : Cela autorise TOUT LE MONDE.
                                // Pour la prod, mettez plutôt : ['http://localhost:3000']

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'], // On accepte tous les headers (Content-Type, Authorization...)

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false, // Mettre à 'true' seulement si vous utilisez des cookies/sessions

];
