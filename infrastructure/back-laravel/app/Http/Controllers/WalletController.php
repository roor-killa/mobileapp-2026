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
            'balance'     => (float) $wallet->balance,
            'balance_bkn' => (float) $wallet->balance_bkn,
            'wallet_id'   => $wallet->id,
        ]);
    }

    // POST /api/wallet/transfer
    public function transfer(Request $request)
    {
        $request->validate([
            'recipient_email' => 'required|email|exists:users,email',
            'amount'          => 'required|numeric|min:0.01',
            'currency'        => 'sometimes|in:EUR,BKN',
        ]);

        $currency  = $request->input('currency', 'EUR');
        $sender    = $request->user();
        $recipient = User::where('email', $request->recipient_email)->firstOrFail();

        if ($sender->id === $recipient->id) {
            return response()->json(['message' => 'Vous ne pouvez pas vous transférer à vous-même.'], 422);
        }

        $amount       = round((float) $request->amount, 2);
        $senderWallet = $sender->wallet;
        $balanceField = $currency === 'BKN' ? 'balance_bkn' : 'balance';

        if ($senderWallet->$balanceField < $amount) {
            return response()->json(['message' => 'Solde insuffisant.'], 422);
        }

        DB::transaction(function () use ($senderWallet, $recipient, $amount, $currency, $balanceField) {
            $recipientWallet = $recipient->wallet;

            $senderWallet->decrement($balanceField, $amount);
            $recipientWallet->increment($balanceField, $amount);

            Transaction::create([
                'wallet_id'         => $senderWallet->id,
                'related_wallet_id' => $recipientWallet->id,
                'type'              => 'transfer_out',
                'amount'            => $amount,
                'currency'          => $currency,
                'status'            => 'completed',
            ]);

            Transaction::create([
                'wallet_id'         => $recipientWallet->id,
                'related_wallet_id' => $senderWallet->id,
                'type'              => 'transfer_in',
                'amount'            => $amount,
                'currency'          => $currency,
                'status'            => 'completed',
            ]);
        });

        $senderWallet->refresh();

        return response()->json([
            'success'           => true,
            'message'           => 'Transfert effectué avec succès.',
            'nouveau_solde'     => (float) $senderWallet->balance,
            'nouveau_solde_bkn' => (float) $senderWallet->balance_bkn,
            'currency'          => $currency,
        ]);
    }

    // GET /api/wallet/exchange-rate
    public function exchangeRate()
    {
        $rate = DB::table('exchange_rates')->where('key', 'EUR_TO_BKN')->value('value');

        return response()->json([
            'EUR_TO_BKN' => (float) ($rate ?? 10),
        ]);
    }

    // POST /api/wallet/convert
    public function convert(Request $request)
    {
        $request->validate([
            'from_currency' => 'required|in:EUR,BKN',
            'to_currency'   => 'required|in:EUR,BKN|different:from_currency',
            'amount'        => 'required|numeric|min:0.01',
        ]);

        $from   = $request->from_currency;
        $to     = $request->to_currency;
        $amount = round((float) $request->amount, 2);
        $wallet = $request->user()->wallet;

        $rate       = (float) (DB::table('exchange_rates')->where('key', 'EUR_TO_BKN')->value('value') ?? 10);
        $fromField  = $from === 'EUR' ? 'balance' : 'balance_bkn';
        $toField    = $to   === 'EUR' ? 'balance' : 'balance_bkn';
        $converted  = $from === 'EUR'
            ? round($amount * $rate, 2)
            : round($amount / $rate, 2);

        if ($wallet->$fromField < $amount) {
            return response()->json(['message' => 'Solde insuffisant.'], 422);
        }

        DB::transaction(function () use ($wallet, $amount, $converted, $fromField, $toField, $from) {
            $wallet->decrement($fromField, $amount);
            $wallet->increment($toField, $converted);

            Transaction::create([
                'wallet_id' => $wallet->id,
                'type'      => 'conversion',
                'amount'    => $amount,
                'currency'  => $from,
                'status'    => 'completed',
            ]);
        });

        $wallet->refresh();

        return response()->json([
            'success'           => true,
            'message'           => "Conversion : {$amount} {$from} → {$converted} {$to}.",
            'nouveau_solde'     => (float) $wallet->balance,
            'nouveau_solde_bkn' => (float) $wallet->balance_bkn,
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
                'currency'                 => 'EUR',
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
            ->get(['id', 'type', 'amount', 'currency', 'status', 'created_at', 'related_wallet_id']);

        return response()->json([
            'transactions' => $transactions->map(fn($t) => [
                'id'                => $t->id,
                'type'              => $t->type,
                'amount'            => $t->amount,
                'currency'          => $t->currency ?? 'EUR',
                'status'            => $t->status,
                'created_at'        => $t->created_at,
                'related_user_name' => $t->relatedWallet?->user?->name,
            ]),
        ]);
    }
}
