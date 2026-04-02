<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Permet à ton API Laravel d'accepter des requêtes depuis ton application
    | Flutter Web (ou tout autre frontend).
    |
    */

    'paths' => ['api/*'], // toutes les routes API
    'allowed_methods' => ['*'], // toutes les méthodes : GET, POST, PUT, DELETE...
    'allowed_origins' => ['*'], // toutes les origines (Flutter Web tourne sur localhost:xxxx)
    'allowed_headers' => ['*'], // tous les headers autorisés
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,

];