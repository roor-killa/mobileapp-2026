<?php

namespace App\Http\Controllers\Api;

use App\Models\Account;
use App\Models\PaymentRequest;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PaymentRequestController extends \App\Http\Controllers\Controller
{
    /**
     * Créer une demande d'argent (l'utilisateur connecté demande à "to_user_id")
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'to_user_id' => 'required|integer|exists:users,id',
            'amount' => 'required|numeric|min:0.01',
            'message' => 'nullable|string|max:500',
        ]);

        $fromUserId = $request->user()->id;
        $toUserId = (int) $validated['to_user_id'];

        if ($fromUserId === $toUserId) {
            return response()->json(['message' => 'Vous ne pouvez pas vous envoyer une demande à vous-même.'], 422);
        }

        $pr = PaymentRequest::create([
            'from_user_id' => $fromUserId,
            'to_user_id' => $toUserId,
            'amount' => $validated['amount'],
            'currency' => 'EUR',
            'message' => $validated['message'] ?? null,
            'status' => 'pending',
        ]);

        $pr->load('fromUser:id,first_name,last_name,name');

        return response()->json([
            'message' => 'Demande envoyée. L\'utilisateur recevra une notification.',
            'payment_request' => [
                'id' => $pr->id,
                'from_user_id' => $pr->from_user_id,
                'to_user_id' => $pr->to_user_id,
                'amount' => (float) $pr->amount,
                'currency' => $pr->currency,
                'message' => $pr->message,
                'status' => $pr->status,
                'from_user_name' => $pr->fromUser->full_name ?? $pr->fromUser->name ?? 'Utilisateur',
                'created_at' => $pr->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Liste des demandes reçues (pour l'utilisateur connecté = to_user_id)
     */
    public function index(Request $request)
    {
        $list = PaymentRequest::query()
            ->where('to_user_id', $request->user()->id)
            ->with('fromUser:id,first_name,last_name,name')
            ->orderByDesc('created_at')
            ->limit(50)
            ->get();

        $items = $list->map(function (PaymentRequest $pr) {
            return [
                'id' => $pr->id,
                'from_user_id' => $pr->from_user_id,
                'from_user_name' => $pr->fromUser->full_name ?? $pr->fromUser->name ?? 'Utilisateur',
                'amount' => (float) $pr->amount,
                'currency' => $pr->currency,
                'message' => $pr->message,
                'status' => $pr->status,
                'created_at' => $pr->created_at->toIso8601String(),
            ];
        });

        return response()->json(['payment_requests' => $items]);
    }

    /**
     * Accepter une demande d'argent : effectue le virement du compte du destinataire vers un compte du demandeur.
     */
    public function accept(Request $request, PaymentRequest $paymentRequest)
    {
        if ($paymentRequest->to_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Non autorisé.'], Response::HTTP_FORBIDDEN);
        }

        if ($paymentRequest->status !== 'pending') {
            return response()->json(['message' => 'Cette demande a déjà été traitée.'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $validated = $request->validate([
            'from_account_id' => 'required|integer|exists:accounts,id',
        ]);

        $fromAccount = Account::findOrFail($validated['from_account_id']);
        if ($fromAccount->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Compte non autorisé.'], Response::HTTP_FORBIDDEN);
        }

        $toAccount = $paymentRequest->fromUser->accounts()->where('is_active', true)->first();
        if (! $toAccount) {
            return response()->json(['message' => 'Le demandeur n\'a plus de compte actif.'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $amount = (float) $paymentRequest->amount;
        if ((float) $fromAccount->balance < $amount) {
            return response()->json(['message' => 'Solde insuffisant sur le compte choisi.'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $toAccountId = $toAccount->id;
        try {
            DB::transaction(function () use ($validated, $toAccountId, $amount, $paymentRequest) {
                $fromAccount = Account::where('id', $validated['from_account_id'])->lockForUpdate()->firstOrFail();
                $toAccount = Account::where('id', $toAccountId)->lockForUpdate()->firstOrFail();

                $fromAccount->balance = (float) $fromAccount->balance - $amount;
                $fromAccount->save();

                $toAccount->balance = (float) $toAccount->balance + $amount;
                $toAccount->save();

                Transaction::create([
                    'from_account_id' => $fromAccount->id,
                    'to_account_id' => $toAccount->id,
                    'transaction_type' => 'transfer',
                    'amount' => $amount,
                    'description' => 'Demande d\'argent acceptée',
                    'status' => 'completed',
                    'reference_number' => 'TRF' . Str::upper(Str::random(12)),
                    'transaction_date' => now(),
                ]);

                $paymentRequest->update(['status' => 'accepted']);
            });
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Erreur lors du virement: ' . $e->getMessage(),
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }

        return response()->json([
            'message' => 'Virement effectué. La demande a été acceptée.',
        ]);
    }

    /**
     * Refuser une demande d'argent.
     */
    public function decline(Request $request, PaymentRequest $paymentRequest)
    {
        if ($paymentRequest->to_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Non autorisé.'], Response::HTTP_FORBIDDEN);
        }

        if ($paymentRequest->status !== 'pending') {
            return response()->json(['message' => 'Cette demande a déjà été traitée.'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $paymentRequest->update(['status' => 'declined']);

        return response()->json([
            'message' => 'Demande refusée.',
        ]);
    }
}
