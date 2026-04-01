<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CryptoAsset;
use App\Models\Operation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CryptoController extends Controller
{
    private array $prices = [
        'BTC' => 60000,
        'ETH' => 3000,
        'SOL' => 150,
    ];

    public function index()
    {
        $user = Auth::user();

        return response()->json(
            $user->cryptoAssets()->get()
        );
    }

    public function buy(Request $request)
    {
        $user = Auth::user();

        $symbol = strtoupper($request->input('symbol'));
        $amountEuros = $request->input('amount');

        if (!isset($this->prices[$symbol])) {
            return response()->json([
                'message' => 'Crypto non prise en charge'
            ], 400);
        }

        if ($amountEuros <= 0) {
            return response()->json([
                'message' => 'Montant invalide'
            ], 400);
        }

        if ($amountEuros > $user->balance) {
            return response()->json([
                'message' => 'Solde insuffisant'
            ], 400);
        }

        $price = $this->prices[$symbol];
        $quantityBought = $amountEuros / $price;

        $asset = CryptoAsset::firstOrCreate(
            [
                'user_id' => $user->id,
                'symbol' => $symbol,
            ],
            [
                'quantity' => 0,
                'average_buy_price' => 0,
            ]
        );

        $oldTotalValue = $asset->quantity * $asset->average_buy_price;
        $newTotalValue = $oldTotalValue + $amountEuros;
        $newQuantity = $asset->quantity + $quantityBought;
        $newAverage = $newQuantity > 0 ? $newTotalValue / $newQuantity : 0;

        $asset->quantity = $newQuantity;
        $asset->average_buy_price = $newAverage;
        $asset->save();

        $user->balance -= $amountEuros;
        $user->save();

        Operation::create([
            'user_id' => $user->id,
            'type' => 'crypto_buy',
            'amount' => $amountEuros,
            'description' => 'Achat de ' . $symbol,
        ]);

        return response()->json([
            'message' => 'Achat crypto effectué avec succès',
            'balance' => $user->balance,
            'asset' => $asset,
            'current_price' => $price,
        ]);
    }

    public function sell(Request $request)
    {
        $user = Auth::user();

        $symbol = strtoupper($request->input('symbol'));
        $quantityToSell = $request->input('quantity');

        if (!isset($this->prices[$symbol])) {
            return response()->json([
                'message' => 'Crypto non prise en charge'
            ], 400);
        }

        if ($quantityToSell <= 0) {
            return response()->json([
                'message' => 'Quantité invalide'
            ], 400);
        }

        $asset = CryptoAsset::where('user_id', $user->id)
            ->where('symbol', $symbol)
            ->first();

        if (!$asset || $asset->quantity < $quantityToSell) {
            return response()->json([
                'message' => 'Quantité insuffisante'
            ], 400);
        }

        $price = $this->prices[$symbol];
        $eurosReceived = $quantityToSell * $price;

        $asset->quantity -= $quantityToSell;

        if ($asset->quantity <= 0) {
            $asset->delete();
        } else {
            $asset->save();
        }

        $user->balance += $eurosReceived;
        $user->save();

        Operation::create([
            'user_id' => $user->id,
            'type' => 'crypto_sell',
            'amount' => $eurosReceived,
            'description' => 'Vente de ' . $symbol,
        ]);

        return response()->json([
            'message' => 'Vente crypto effectuée avec succès',
            'balance' => $user->balance,
            'received' => $eurosReceived,
            'current_price' => $price,
        ]);
    }
}
