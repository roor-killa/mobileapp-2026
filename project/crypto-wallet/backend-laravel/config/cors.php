<?php

return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['http://localhost', 'http://127.0.0.1', 'http://localhost:8080', 'http://localhost:3000', 'http://localhost:5000'],
    'allowed_origins_patterns' => ['#^https?://localhost(:\d+)?$#', '#^https?://127\.0\.0\.1(:\d+)?$#'],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
