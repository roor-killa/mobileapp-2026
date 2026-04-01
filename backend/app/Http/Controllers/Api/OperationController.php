<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Operation;
use App\Models\User;

class OperationController extends Controller
{
    public function deposit(Request $request)
    {
        $user = Auth::user();

        $amount = $request->input('amount');

        $user->balance += $amount;
        $user->save();

        $operation = Operation::create([
            'user_id' => $user->id,
            'type' => 'deposit',
            'amount' => $amount,
            'description' => $request->input('description'),
        ]);

        return response()->json([
            'message' => 'Dépôt effectué',
            'balance' => $user->balance,
            'operation' => $operation
        ]);
    }

    public function withdraw(Request $request)
    {
        $user = Auth::user();

        $amount = $request->input('amount');

        if ($amount > $user->balance) {
            return response()->json([
                'message' => 'Solde insuffisant'
            ], 400);
        }

        $user->balance -= $amount;
        $user->save();

        $operation = Operation::create([
            'user_id' => $user->id,
            'type' => 'withdraw',
            'amount' => $amount,
            'description' => $request->input('description'),
        ]);

        return response()->json([
            'message' => 'Retrait effectué',
            'balance' => $user->balance,
            'operation' => $operation
        ]);
    }

    public function history()
    {
        $user = Auth::user();

        return Operation::where('user_id', $user->id)
            ->latest()
            ->get();
    }

    // 🔥 NOUVELLE MÉTHODE
    public function transfer(Request $request)
    {
        $sender = Auth::user();

        $receiverEmail = $request->input('email');
        $amount = $request->input('amount');

        if ($amount <= 0) {
            return response()->json([
                'message' => 'Montant invalide'
            ], 400);
        }

        if ($amount > $sender->balance) {
            return response()->json([
                'message' => 'Solde insuffisant'
            ], 400);
        }

        $receiver = User::where('email', $receiverEmail)->first();

        if (!$receiver) {
            return response()->json([
                'message' => 'Utilisateur introuvable'
            ], 404);
        }

        if ($receiver->id === $sender->id) {
            return response()->json([
                'message' => 'Impossible de s’envoyer de l’argent à soi-même'
            ], 400);
        }

        // Débit expéditeur
        $sender->balance -= $amount;
        $sender->save();

        // Crédit destinataire
        $receiver->balance += $amount;
        $receiver->save();

        // Historique sender
        Operation::create([
            'user_id' => $sender->id,
            'type' => 'transfer_sent',
            'amount' => $amount,
            'description' => 'Envoi à ' . $receiver->email,
        ]);

        // Historique receiver
        Operation::create([
            'user_id' => $receiver->id,
            'type' => 'transfer_received',
            'amount' => $amount,
            'description' => 'Reçu de ' . $sender->email,
        ]);

        return response()->json([
            'message' => 'Virement effectué avec succès',
            'balance' => $sender->balance
        ]);
    }
}