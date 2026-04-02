<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

class TransferController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:api');
    }

    public function transfer(Request $request)
    {
        $request->validate([
            'recepteur_id' => 'required|exists:users,id',
            'montant' => 'required|numeric|min:0.01',
        ]);

        $emetteur = Auth::user();
        $recepteur = User::find($request->recepteur_id);
        $montant = $request->montant;

        if ($emetteur->wallet_balance < $montant) {
            return response()->json([
                'success' => false,
                'message' => 'Solde insuffisant',
            ], 400);
        }

        DB::beginTransaction();

        try {
            $emetteur->wallet_balance -= $montant;
            $emetteur->save();

            $recepteur->wallet_balance += $montant;
            $recepteur->save();

            Transaction::create([
                'sender_id' => $emetteur->id,
                'receiver_id' => $recepteur->id,
                'amount' => $montant,
                'status' => 'completed',
                'type' => 'fiat',
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Transfert effectué avec succès',
                'solde_emetteur' => $emetteur->wallet_balance,
                'solde_recepteur' => $recepteur->wallet_balance,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du transfert : ' . $e->getMessage(),
            ], 500);
        }
    }
}