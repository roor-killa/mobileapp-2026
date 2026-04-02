<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Stripe\Stripe;
use Stripe\Checkout\Session as CheckoutSession;
use App\Models\User;

class StripeController extends Controller
{
    public function __construct()
    {
        Stripe::setApiKey(env('STRIPE_SECRET'));
    }

    public function createCheckoutSession(Request $request)
    {
        $user = $request->user();
        $amount = $request->input('montant');

        if (!$amount || $amount <= 0) {
            return response()->json(['error' => 'Montant invalide'], 400);
        }

        try {
            $amountInCents = intval(round($amount * 100));

            $session = CheckoutSession::create([
                'payment_method_types' => ['card'],
                'line_items' => [[
                    'price_data' => [
                        'currency' => 'eur',
                        'product_data' => ['name' => 'Rechargement wallet pour ' . $user->name],
                        'unit_amount' => $amountInCents,
                    ],
                    'quantity' => 1,
                ]],
                'mode' => 'payment',
                'success_url' => env('APP_URL') . '/success?session_id={CHECKOUT_SESSION_ID}',
                'cancel_url' => env('APP_URL') . '/cancel',
                'metadata' => ['user_id' => $user->id],
            ]);

            return response()->json(['id' => $session->id, 'url' => $session->url]);

        } catch (\Exception $e) {
            \Log::error('Stripe error: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    public function success(Request $request)
    {
        return response()->json([
            'message' => 'Paiement réussi !',
            'session_id' => $request->session_id,
        ]);
    }
}