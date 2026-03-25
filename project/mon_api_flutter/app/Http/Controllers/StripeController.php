<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use Illuminate\Support\Facades\Auth;
use Stripe\Webhook;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Support\Facades\Log;

class StripeController extends Controller
{
    public function createPaymentIntent(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        Stripe::setApiKey(env('STRIPE_SECRET'));

        try {
            $intent = PaymentIntent::create([
                'amount' => $request->amount * 100,
                'currency' => 'eur',
                'payment_method_types' => ['card'],
                'metadata' => [
                    'user_id' => Auth::id(),
                ],
            ]);

            return response()->json([
                'clientSecret' => $intent->client_secret,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function handleWebhook(Request $request)
    {
        $payload = $request->getContent();
        $sig_header = $request->header('Stripe-Signature');
        $endpoint_secret = env('STRIPE_WEBHOOK_SECRET');

        try {
            $event = Webhook::constructEvent($payload, $sig_header, $endpoint_secret);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Invalid payload'], 400);
        }

        if ($event->type === 'payment_intent.succeeded') {
            $paymentIntent = $event->data->object;
            $userId = $paymentIntent->metadata->user_id;
            $amount = $paymentIntent->amount / 100;

            // Vérification anti-doublon : On vérifie si cette référence Stripe existe déjà
            $exists = Transaction::where('reference', $paymentIntent->id)->exists();

            if (!$exists) {
                $user = User::find($userId);
                if ($user) {
                    // 1. Créditer le solde
                    $user->increment('balance', $amount);

                    // 2. Créer l'historique
                    Transaction::create([
                        'user_id' => $user->id,
                        'amount' => $amount,
                        'type' => 'recharge',
                        'status' => 'success',
                        'description' => 'Recharge via Stripe',
                        'reference' => $paymentIntent->id,
                    ]);
                    
                    Log::info("Paiement réussi pour l'utilisateur ID: $userId");
                }
            }
        }

        return response()->json(['status' => 'success']);
    }
}