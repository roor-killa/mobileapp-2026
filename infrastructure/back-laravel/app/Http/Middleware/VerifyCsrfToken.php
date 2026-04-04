<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

class VerifyCsrfToken extends Middleware
{
    /**
     * URIs à exclure de la vérification CSRF.
     *
     * @var array<int, string>
     */
    protected $except = [
        'stripe/webhook', // ton webhook Stripe
    ];
}