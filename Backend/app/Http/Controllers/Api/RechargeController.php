<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Stripe\Exception\ApiErrorException;
use Stripe\PaymentIntent;
use Stripe\Stripe;
use Stripe\Webhook;

class RechargeController extends Controller
{
    public function __construct()
    {
        Stripe::setApiKey(config('services.stripe.secret'));
    }

    /**
     * POST /api/recharge/create-intent
     * Crée un PaymentIntent Stripe et retourne le client_secret à Flutter
     */
    public function createPaymentIntent(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => ['required', 'integer', 'min:100', 'max:1000000'], // entre 1€ et 10 000€
        ]);

        try {
            $paymentIntent = PaymentIntent::create([
                'amount'   => $validated['amount'],
                'currency' => 'eur',
                'metadata' => [
                    'user_id'    => $request->user()->id,
                    'user_email' => $request->user()->email,
                ],
                'automatic_payment_methods' => [
                    'enabled' => true,
                ],
            ]);

            return response()->json([
                'client_secret' => $paymentIntent->client_secret,
                'payment_intent_id' => $paymentIntent->id,
                'amount' => $validated['amount'],
                'amount_formatted' => number_format($validated['amount'] / 100, 2, ',', ' ') . ' €',
            ]);

        } catch (ApiErrorException $e) {
            Log::error('Stripe PaymentIntent error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Erreur lors de la création du paiement.',
            ], 500);
        }
    }

    /**
     * POST /api/recharge/webhook
     * Webhook Stripe : crédite le compte quand le paiement est confirmé
     * IMPORTANT : route sans middleware auth (vérification via signature Stripe)
     */
    public function webhook(Request $request): JsonResponse
    {
        $payload   = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $secret    = config('services.stripe.webhook_secret');

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $secret);
        } catch (\Exception $e) {
            Log::warning('Stripe webhook signature invalide: ' . $e->getMessage());
            return response()->json(['message' => 'Invalid signature.'], 400);
        }

        // Traitement uniquement des paiements réussis
        if ($event->type === 'payment_intent.succeeded') {
            $paymentIntent = $event->data->object;
            $userId        = $paymentIntent->metadata->user_id ?? null;
            $amount        = $paymentIntent->amount;
            $reference     = $paymentIntent->id;

            if (!$userId) {
                return response()->json(['message' => 'Missing user_id in metadata.'], 400);
            }

            // Éviter le double traitement (idempotence)
            if (Transaction::where('reference', $reference)->exists()) {
                return response()->json(['message' => 'Already processed.'], 200);
            }

            DB::transaction(function () use ($userId, $amount, $reference, $paymentIntent) {
                $user = \App\Models\User::findOrFail($userId);
                $balanceBefore = $user->balance;
                $user->increment('balance', $amount);

                Transaction::create([
                    'receiver_id'             => $user->id,
                    'amount'                  => $amount,
                    'type'                    => 'recharge',
                    'status'                  => 'completed',
                    'reference'               => $reference,
                    'metadata'                => [
                        'stripe_payment_intent' => $paymentIntent->id,
                        'payment_method'        => $paymentIntent->payment_method,
                    ],
                    'receiver_balance_before' => $balanceBefore,
                    'receiver_balance_after'  => $user->fresh()->balance,
                ]);
            });

            Log::info("Recharge réussie: user={$userId}, amount={$amount}, ref={$reference}");
        }

        return response()->json(['message' => 'Webhook traité.']);
    }
}
