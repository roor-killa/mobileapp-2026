<?php

namespace App\Http\Controllers;

use App\Models\Wallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $wallets = $request->user()->wallets()->get();
        return response()->json($wallets);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'currency' => 'required|string|size:3|unique:wallets,currency,null,null,user_id,' . $request->user()->id,
        ]);

        $wallet = Wallet::create([
            'user_id' => $request->user()->id,
            'currency' => $validated['currency'],
            'balance' => 0,
        ]);

        return response()->json([
            'message' => 'Wallet created successfully',
            'wallet' => $wallet,
        ], 201);
    }
}
