<?php

namespace App\Http\Controllers;

use App\Models\Card;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $cards = $request->user()->cards()->with('bankAccount')->get();
        return response()->json($cards);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'bank_account_id' => 'required|exists:bank_accounts,id',
            'card_holder' => 'required|string',
            'card_type' => 'required|in:debit,credit,virtual',
            'card_brand' => 'required|in:visa,mastercard,amex',
            'daily_limit' => 'required|numeric|min:0',
            'monthly_limit' => 'required|numeric|min:0',
            'is_virtual' => 'boolean',
            'color' => 'sometimes|string',
        ]);

        $card = Card::create([
            'user_id' => $request->user()->id,
            'bank_account_id' => $validated['bank_account_id'],
            'card_number' => $this->generateCardNumber(),
            'card_holder' => $validated['card_holder'],
            'cvv' => str_pad(random_int(0, 999), 3, '0', STR_PAD_LEFT),
            'expiry_date' => now()->addYears(5),
            'card_type' => $validated['card_type'],
            'card_brand' => $validated['card_brand'],
            'daily_limit' => $validated['daily_limit'],
            'monthly_limit' => $validated['monthly_limit'],
            'is_virtual' => $validated['is_virtual'] ?? false,
            'is_primary' => false,
            'color' => $validated['color'] ?? '#FF5722',
            'activated_at' => now(),
        ]);

        return response()->json([
            'message' => 'Card created successfully',
            'card' => $card,
        ], 201);
    }

    public function show(Card $card): JsonResponse
    {
        $this->authorize('view', $card);
        return response()->json($card);
    }

    public function toggleBlock(Card $card): JsonResponse
    {
        $this->authorize('update', $card);
        
        $card->update([
            'card_status' => $card->card_status === 'active' ? 'blocked' : 'active'
        ]);

        return response()->json([
            'message' => 'Card status updated',
            'card' => $card,
        ]);
    }

    public function setPrimary(Card $card): JsonResponse
    {
        $this->authorize('update', $card);
        
        $card->user->cards()->update(['is_primary' => false]);
        $card->update(['is_primary' => true]);

        return response()->json([
            'message' => 'Primary card updated',
            'card' => $card,
        ]);
    }

    private function generateCardNumber(): string
    {
        return '4' . Str::random(15); // Visa format
    }
}
