<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pocket;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

class PocketController extends Controller
{
    // --- 1. LISTER LES POCKETS ---
    public function index(Request $request)
    {
        $user = $request->user();
        
        return response()->json([
            'success' => true,
            'solde_principal' => (float) $user->solde,
            'pockets' => $user->pockets // Laravel va chercher tous les pockets liés à ce user automatiquement
        ]);
    }

    // --- 2. CRÉER UN NOUVEAU POCKET ---
    public function store(Request $request)
    {
        $request->validate([
            'nom' => 'required|string|max:255',
            'icone' => 'nullable|string',
            'couleur' => 'nullable|string'
        ]);

        // On crée un pocket vide (solde à 0 par défaut)
        $pocket = $request->user()->pockets()->create([
            'nom' => $request->nom,
            'icone' => $request->icone ?? 'account_balance_wallet', // Icône Flutter par défaut
            'couleur' => $request->couleur ?? '#10B981', // Notre vert émeraude par défaut
            'solde' => 0.00
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pocket créé avec succès !',
            'pocket' => $pocket
        ]);
    }

    // --- 3. TRANSFÉRER DE L'ARGENT (Principal <-> Pocket) ---
    public function transfer(Request $request)
    {
        $request->validate([
            'pocket_id' => 'required|exists:pockets,id',
            'montant' => 'required|numeric|min:0.1',
            'direction' => 'required|in:to_pocket,to_main' // Pour savoir dans quel sens va l'argent
        ]);

        $user = $request->user();
        // On s'assure que le pocket appartient bien à l'utilisateur qui fait la demande !
        $pocket = Pocket::where('id', $request->pocket_id)->where('user_id', $user->id)->firstOrFail();
        $montant = $request->montant;

        // DB::beginTransaction() = "Si ça plante au milieu, on annule tout"
        try {
            DB::beginTransaction();

            if ($request->direction === 'to_pocket') {
                // Du Compte Principal VERS le Pocket
                if ($user->solde < $montant) throw new \Exception('Solde principal insuffisant.');
                
                $user->solde -= $montant;
                $pocket->solde += $montant;
                $desc = "Transfert vers le pocket " . $pocket->nom;
            } else {
                // Du Pocket VERS le Compte Principal (Retrait)
                if ($pocket->solde < $montant) throw new \Exception('Solde du pocket insuffisant.');
                
                $pocket->solde -= $montant;
                $user->solde += $montant;
                $desc = "Retrait depuis le pocket " . $pocket->nom;
            }

            $user->save();
            $pocket->save();

            // On crée le ticket de caisse dans l'historique
            Transaction::create([
                'user_id' => $user->id,
                'pocket_id' => $pocket->id,
                'type' => 'transfert_pocket',
                'montant' => $montant,
                'description' => $desc,
                'wallet_source' => $request->direction === 'to_pocket' ? 'principal' : 'pocket'
            ]);

            DB::commit(); // Tout s'est bien passé, on valide les calculs !

            return response()->json([
                'success' => true,
                'message' => $desc . ' effectué avec succès.',
                'solde_principal' => (float) $user->solde,
                'pocket' => $pocket
            ]);

        } catch (\Exception $e) {
            DB::rollBack(); // Erreur = on annule la transaction mathématique
            return response()->json(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}