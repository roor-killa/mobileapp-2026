<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Log;
use Stripe\Webhook;
use Illuminate\Http\Request;
use App\Models\User;
use Stripe\Stripe;
use Stripe\Checkout\Session;

class StripeController extends Controller
{
    public function __construct()
    {
        Stripe::setApiKey(env('STRIPE_SECRET')); // clé secrète Stripe
    }

    // Créer une session Stripe Checkout
    public function createCheckoutSession(Request $request)
    {
        $user = $request->user();
        $amount = $request->input('montant'); // montant en euros

        if (!$amount || $amount <= 0) {
            return response()->json(['success' => false, 'message' => 'Montant invalide'], 400);
        }

        try {
            $session = Session::create([
                'payment_method_types' => ['card'],
                'line_items' => [[
                    'price_data' => [
                        'currency' => 'eur',
                        'product_data' => [
                            'name' => 'Recharge Wallet',
                        ],
                        'unit_amount' => $amount * 100, // convertir euros → centimes
                    ],
                    'quantity' => 1,
                ]],
                'mode' => 'payment',
                'success_url' => env('APP_URL') . '/success?session_id={CHECKOUT_SESSION_ID}',
                'cancel_url' => env('APP_URL') . '/cancel',
                'metadata' => [
                    'user_id' => $user->id,
                ],
            ]);

            return response()->json(['success' => true, 'url' => $session->url]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // Page succès Stripe
    public function success(Request $request)
    {
        $sessionId = $request->query('session_id');

        if (!$sessionId) {
            return response('Session manquante', 400);
        }

        return response('Paiement réussi ✅');
    }
    public function webhook(Request $request)
{
    $endpoint_secret = env('STRIPE_WEBHOOK_SECRET');
    $payload = $request->getContent();
    $sig_header = $request->header('Stripe-Signature');

    try {
        $event = Webhook::constructEvent($payload, $sig_header, $endpoint_secret);
        Log::info('Stripe Webhook reçu', ['event' => $event->type]);
    } catch (\Exception $e) {
        Log::error('Erreur Webhook Stripe', ['message' => $e->getMessage()]);
        return response('Webhook error', 400);
    }

    // Paiement réussi via Stripe Checkout
    if ($event->type == 'checkout.session.completed') {
        $session = $event->data->object;
        $userId = $session->metadata->user_id ?? null;
        $amount = ($session->amount_total ?? 0) / 100;

        if ($userId) {
            $user = User::find($userId);
            if ($user) {
                $user->wallet_balance += $amount;
                $user->save();
            }
        }
    }

    return response('OK', 200);
}
}