<?php

namespace App\Http\Controllers;

use App\Models\ExchangeRate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExchangeRateController extends Controller
{
    public function rates(): JsonResponse
    {
        $rates = ExchangeRate::all();
        return response()->json($rates);
    }

    public function convert(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'from_currency' => 'required|string|size:3',
            'to_currency' => 'required|string|size:3',
            'amount' => 'required|numeric|min:0.01',
        ]);

        $rate = ExchangeRate::where('from_currency', $validated['from_currency'])
            ->where('to_currency', $validated['to_currency'])
            ->first();

        if (! $rate) {
            return response()->json(['error' => 'Exchange rate not found'], 404);
        }

        $convertedAmount = $validated['amount'] * $rate->rate;
        $fee = $convertedAmount * ($rate->margin / 100);
        $finalAmount = $convertedAmount - $fee;

        return response()->json([
            'original_amount' => $validated['amount'],
            'from_currency' => $validated['from_currency'],
            'to_currency' => $validated['to_currency'],
            'rate' => $rate->rate,
            'converted_amount' => $convertedAmount,
            'margin' => $rate->margin,
            'fee' => $fee,
            'final_amount' => $finalAmount,
        ]);
    }
}
