<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;



namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function transfert(Request $requete)
    {
        $requete->validate([
            'recepteur_id' => 'required|exists:users,id',
            'montant' => 'required|numeric|min:0.01',
        ]);

        // TEMPORAIRE pour test (sans JWT)
        $emetteur = User::find(1);

        $recepteur = User::find($requete->recepteur_id);
        $montant = $requete->montant;

        if ($emetteur->wallet_balance < $montant) {
            return response()->json([
                'success' => false,
                'message' => 'Solde insuffisant'
            ], 400);
        }

        DB::transaction(function() use ($emetteur, $recepteur, $montant) {
            $emetteur->wallet_balance -= $montant;
            $emetteur->save();

            $recepteur->wallet_balance += $montant;
            $recepteur->save();

            Transaction::create([
                'emetteur_id' => $emetteur->id,
                'recepteur_id' => $recepteur->id,
                'montant' => $montant,
                'statut' => 'effectue',
                'type' => 'fiat'
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Transfert effectué',
            'solde_emetteur' => $emetteur->wallet_balance
        ]);
    }
}