<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class TransactionController extends Controller
{
    public function transfert(Request $request)
    {
        $sender = $request->user();
        $receiverId = $request->input('receiver_id');
        $amount = $request->input('amount');

        if (!$receiverId || !$amount || $amount <= 0) {
            return response()->json(['message' => 'Données invalides'], 400);
        }

        $receiver = User::find($receiverId);

        if (!$receiver) {
            return response()->json(['message' => 'Utilisateur introuvable'], 404);
        }

        if ($sender->wallet_balance < $amount) {
            return response()->json(['message' => 'Solde insuffisant'], 400);
        }

        // 🔥 mise à jour
        $sender->wallet_balance -= $amount;
        $receiver->wallet_balance += $amount;

        $senderSaved = $sender->save();
        $receiverSaved = $receiver->save(); 

        return response()->json([
            'message' => 'Transfert réussi',
            'sender_balance' => $sender->wallet_balance,
            'receiver_balance' => $receiver->wallet_balance,
            'debug_sender' => $senderSaved,
            'debug_receiver' => $receiverSaved,
        ]);
    }
}