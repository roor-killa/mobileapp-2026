<?php

namespace App\Http\Controllers;

use App\Models\Transfer;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class TransferController extends Controller
{
    /**
     * Récupère la liste de tous les utilisateurs (sauf l'utilisateur courant)
     * Utilisé pour afficher la liste des destinataires possibles
     */
    public function listUsers(Request $request)
    {
        // Pour la démo, on utilise l'ID 1 comme utilisateur courant
        $currentUserId = $request->query('current_user_id', 1);
        
        $users = User::where('id', '!=', $currentUserId)
            ->select('id', 'name', 'email', 'balance')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Récupère le solde de l'utilisateur courant
     */
    public function getBalance(Request $request)
    {
        $currentUserId = $request->query('user_id', 1);
        
        try {
            $user = User::findOrFail($currentUserId);
            return response()->json([
                'success' => true,
                'balance' => (float) $user->balance,
                'user_id' => $user->id,
                'name' => $user->name,
            ]);
        } catch (ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé',
            ], 404);
        }
    }

    /**
     * Effectue un transfert d'argent entre deux utilisateurs
     */
    public function transfer(Request $request)
    {
        // Valider les données reçues
        $validated = $request->validate([
            'from_user_id' => 'required|integer|exists:users,id',
            'to_user_id' => 'required|integer|exists:users,id|different:from_user_id',
            'amount' => 'required|numeric|min:0.01',
            'description' => 'nullable|string|max:255',
        ]);

        // Vérifier que l'utilisateur a assez de balance
        $fromUser = User::find($validated['from_user_id']);
        if ($fromUser->balance < $validated['amount']) {
            return response()->json([
                'success' => false,
                'message' => 'Solde insuffisant',
                'current_balance' => (float) $fromUser->balance,
                'required_amount' => $validated['amount'],
            ], 400);
        }

        // Débiter l'utilisateur qui envoie
        $fromUser->balance -= $validated['amount'];
        $fromUser->save();

        // Créditer l'utilisateur qui reçoit
        $toUser = User::find($validated['to_user_id']);
        $toUser->balance += $validated['amount'];
        $toUser->save();

        // Créer un enregistrement du transfert
        $transfer = Transfer::create([
            'from_user_id' => $validated['from_user_id'],
            'to_user_id' => $validated['to_user_id'],
            'amount' => $validated['amount'],
            'description' => $validated['description'] ?? null,
            'status' => 'completed',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Transfert effectué avec succès',
            'transfer' => $transfer,
            'from_user' => [
                'id' => $fromUser->id,
                'name' => $fromUser->name,
                'new_balance' => (float) $fromUser->balance,
            ],
            'to_user' => [
                'id' => $toUser->id,
                'name' => $toUser->name,
                'new_balance' => (float) $toUser->balance,
            ],
        ]);
    }

    /**
     * Récupère l'historique des transferts pour un utilisateur
     */
    public function getTransferHistory(Request $request)
    {
        $userId = $request->query('user_id', 1);

        $transfers = Transfer::where('from_user_id', $userId)
            ->orWhere('to_user_id', $userId)
            ->with(['fromUser:id,name', 'toUser:id,name'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $transfers,
        ]);
    }
}
