<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Stripe\StripeClient;

class WalletController extends Controller
{
    // GET /api/wallet
    public function show(Request $request)
    {
        $wallet = $request->user()->wallet;

        return response()->json([
            'balance'   => (float) $wallet->balance,
            'wallet_id' => $wallet->id,
        ]);
    }

    // POST /api/wallet/transfer
    public function transfer(Request $request)
    {
        $request->validate([
            'recipient_email' => 'required|email|exists:users,email',
            'amount'          => 'required|numeric|min:0.01',
        ]);

        $sender    = $request->user();
        $recipient = User::where('email', $request->recipient_email)->firstOrFail();

        if ($sender->id === $recipient->id) {
            return response()->json(['message' => 'Vous ne pouvez pas vous transférer à vous-même.'], 422);
        }

        $amount       = round((float) $request->amount, 2);
        $senderWallet = $sender->wallet;

        if ($senderWallet->balance < $amount) {
            return response()->json(['message' => 'Solde insuffisant.'], 422);
        }

        DB::transaction(function () use ($senderWallet, $recipient, $amount) {
            $recipientWallet = $recipient->wallet;

            $senderWallet->decrement('balance', $amount);
            $recipientWallet->increment('balance', $amount);

            Transaction::create([
                'wallet_id'         => $senderWallet->id,
                'related_wallet_id' => $recipientWallet->id,
                'type'              => 'transfer_out',
                'amount'            => $amount,
                'status'            => 'completed',
            ]);

            Transaction::create([
                'wallet_id'         => $recipientWallet->id,
                'related_wallet_id' => $senderWallet->id,
                'type'              => 'transfer_in',
                'amount'            => $amount,
                'status'            => 'completed',
            ]);
        });

        $senderWallet->refresh();

        return response()->json([
            'success'       => true,
            'message'       => 'Transfert effectué avec succès.',
            'nouveau_solde' => (float) $senderWallet->balance,
        ]);
    }

    // POST /api/wallet/topup/create-intent
    public function createPaymentIntent(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $amountCents = (int) round($request->amount * 100);

        $stripe = new StripeClient(config('services.stripe.secret'));

        $intent = $stripe->paymentIntents->create([
            'amount'   => $amountCents,
            'currency' => 'eur',
            'metadata' => ['user_id' => $request->user()->id],
            'automatic_payment_methods' => ['enabled' => true],
        ]);

        return response()->json([
            'client_secret' => $intent->client_secret,
        ]);
    }

    // POST /api/wallet/topup/confirm
    public function confirmTopUp(Request $request)
    {
        $request->validate([
            'payment_intent_id' => 'required|string',
            'amount'            => 'required|numeric|min:1',
        ]);

        $stripe = new StripeClient(config('services.stripe.secret'));
        $intent = $stripe->paymentIntents->retrieve($request->payment_intent_id);

        if (!in_array($intent->status, ['succeeded', 'processing'])) {
            return response()->json([
                'message' => 'Paiement non confirmé par Stripe (statut : ' . $intent->status . ').',
            ], 422);
        }

        if ((int) $intent->metadata->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Accès non autorisé.'], 403);
        }

        $amount = round((float) $request->amount, 2);
        $wallet = $request->user()->wallet;

        DB::transaction(function () use ($wallet, $amount, $request) {
            $wallet->increment('balance', $amount);

            Transaction::create([
                'wallet_id'                => $wallet->id,
                'type'                     => 'topup',
                'amount'                   => $amount,
                'stripe_payment_intent_id' => $request->payment_intent_id,
                'status'                   => 'completed',
            ]);
        });

        $wallet->refresh();

        return response()->json([
            'success'       => true,
            'message'       => 'Rechargement effectué avec succès.',
            'nouveau_solde' => (float) $wallet->balance,
        ]);
    }

    // GET /api/wallet/transactions
    public function transactions(Request $request)
    {
        $transactions = $request->user()->wallet
            ->transactions()
            ->with('relatedWallet.user')
            ->latest()
            ->take(20)
            ->get(['id', 'type', 'amount', 'status', 'created_at', 'related_wallet_id']);

        return response()->json([
            'transactions' => $transactions->map(fn($t) => [
                'id'                => $t->id,
                'type'              => $t->type,
                'amount'            => $t->amount,
                'status'            => $t->status,
                'created_at'        => $t->created_at,
                'related_user_name' => $t->relatedWallet?->user?->name,
            ]),
        ]);
    }
}
