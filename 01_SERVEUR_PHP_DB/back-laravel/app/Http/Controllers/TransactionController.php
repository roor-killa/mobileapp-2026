<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\BankAccount;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $transactions = $request->user()
            ->transactions()
            ->with(['fromAccount', 'toAccount', 'toUser'])
            ->latest()
            ->paginate(20);

        return response()->json($transactions);
    }

    public function transfer(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'from_account_id' => 'required|exists:bank_accounts,id',
            'to_iban' => 'required|string',
            'recipient_name' => 'required|string',
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'required|string|size:3',
            'description' => 'sometimes|string',
        ]);

        $fromAccount = BankAccount::find($validated['from_account_id']);
        $this->authorize('view', $fromAccount);

        if ($fromAccount->balance < $validated['amount']) {
            return response()->json(['error' => 'Insufficient funds'], 400);
        }

        $transaction = Transaction::create([
            'user_id' => $request->user()->id,
            'from_account_id' => $validated['from_account_id'],
            'transaction_type' => 'transfer',
            'status' => 'pending',
            'amount' => $validated['amount'],
            'currency' => $validated['currency'],
            'description' => $validated['description'] ?? 'Transfer',
            'reference' => 'TRF' . Str::random(12),
            'recipient_name' => $validated['recipient_name'],
            'recipient_iban' => $validated['to_iban'],
            'executed_at' => now(),
        ]);

        // Update balances
        $fromAccount->update(['balance' => $fromAccount->balance - $validated['amount']]);
        $transaction->update(['status' => 'completed']);

        // Create notification
        Notification::create([
            'user_id' => $request->user()->id,
            'title' => 'Transfer Sent',
            'message' => "Transfer of {$validated['amount']} {$validated['currency']} to {$validated['recipient_name']}",
            'type' => 'transaction',
            'transaction_id' => $transaction->id,
            'icon' => 'send',
            'color' => '#4CAF50',
        ]);

        return response()->json([
            'message' => 'Transfer completed successfully',
            'transaction' => $transaction,
        ], 201);
    }

    public function cardPayment(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'card_id' => 'required|exists:cards,id',
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'required|string|size:3',
            'merchant' => 'required|string',
            'description' => 'sometimes|string',
        ]);

        $card = $request->user()->cards()->findOrFail($validated['card_id']);
        $fromAccount = $card->bankAccount;

        // Check limits
        if ($card->spent_today + $validated['amount'] > $card->daily_limit) {
            return response()->json(['error' => 'Daily limit exceeded'], 400);
        }

        if ($fromAccount->balance < $validated['amount']) {
            return response()->json(['error' => 'Insufficient funds'], 400);
        }

        $transaction = Transaction::create([
            'user_id' => $request->user()->id,
            'from_account_id' => $fromAccount->id,
            'transaction_type' => 'card_purchase',
            'status' => 'completed',
            'amount' => $validated['amount'],
            'currency' => $validated['currency'],
            'description' => $validated['merchant'],
            'reference' => 'CARD' . Str::random(12),
            'executed_at' => now(),
        ]);

        // Update card and account
        $card->update([
            'spent_today' => $card->spent_today + $validated['amount'],
            'spent_month' => $card->spent_month + $validated['amount'],
        ]);
        $fromAccount->update(['balance' => $fromAccount->balance - $validated['amount']]);

        return response()->json([
            'message' => 'Payment processed successfully',
            'transaction' => $transaction,
        ], 201);
    }

    public function show(Transaction $transaction): JsonResponse
    {
        $this->authorize('view', $transaction);
        return response()->json($transaction->load(['fromAccount', 'toAccount', 'toUser']));
    }
}
