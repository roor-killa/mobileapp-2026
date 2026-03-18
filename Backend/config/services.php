<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Services tiers
    |--------------------------------------------------------------------------
    */

    'stripe' => [
        'key'            => env('STRIPE_KEY'),
        'secret'         => env('STRIPE_SECRET'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
    ],

    'ollama' => [
        'host'  => env('OLLAMA_HOST', 'http://ollama:11434'),
        'model' => env('OLLAMA_MODEL', 'llama3.2'),
    ],

    'algorand' => [
        'mnemonic' => env('ALGORAND_MNEMONIC', 'GENERATE_ME'),
        'address'  => env('ALGORAND_ADDRESS', ''),
        'network'  => 'testnet',
    ],

];
