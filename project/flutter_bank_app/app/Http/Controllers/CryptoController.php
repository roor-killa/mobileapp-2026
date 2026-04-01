<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BknPrice;
use App\Models\Transaction;

class CryptoController extends Controller
{
    // --- 1. RÉCUPÉRER LES INFOS DU MARCHÉ ---
    public function getMarketData(Request $request)
    {
        $user = $request->user();
        
        // 1. On récupère le prix actuel
        $dernierPrix = BknPrice::latest()->first();
        if (!$dernierPrix) {
            $dernierPrix = BknPrice::create(['prix' => 1.0000]);
        }

        // 2. CALCUL DE LA PERFORMANCE SUR 24H
        // On cherche le prix le plus proche d'il y a 24 heures
        $prixIlYa24h = BknPrice::where('created_at', '<=', now()->subDay())
            ->latest()
            ->first();

        // Si l'application est nouvelle et qu'on n'a pas encore 24h d'historique,
        // on prend le tout premier prix enregistré comme point de départ.
        if (!$prixIlYa24h) {
            $prixIlYa24h = BknPrice::oldest()->first();
        }

        $performance24h = 0;
        if ($prixIlYa24h && $prixIlYa24h->prix > 0) {
            $performance24h = (($dernierPrix->prix - $prixIlYa24h->prix) / $prixIlYa24h->prix) * 100;
        }

        // 3. GESTION DE L'HISTORIQUE POUR LE GRAPHIQUE (Ton code existant)
        $limite = $request->query('limit', 100);
        $historique = BknPrice::latest()
            ->take((int)$limite)
            ->get()
            ->reverse()
            ->values();

        return response()->json([
            'success' => true,
            'current_price' => (float) $dernierPrix->prix,
            'performance_24h' => (float) round($performance24h, 2), // On arrondit à 2 décimales
            'user_solde_eur' => (float) $user->solde,
            'user_solde_bkn' => (float) $user->solde_bkn,
            'price_history' => $historique
        ]);
    }

    // --- 2. ACHETER DU BKN (La demande fait monter le prix !) ---
    public function buyBkn(Request $request)
    {
        $request->validate(['quantite' => 'required|numeric|min:0.1']);
        $user = $request->user();
        $quantite = $request->quantite;

        $dernierPrix = BknPrice::latest()->first()->prix ?? 1.0000;
        $coutTotal = $quantite * $dernierPrix;

        // Vérification : A-t-il assez d'euros ?
        if ($user->solde < $coutTotal) {
            return response()->json(['success' => false, 'message' => 'Solde en euros insuffisant.']);
        }

        // 1. Transaction : On retire les euros, on ajoute les BKN
        $user->solde -= $coutTotal;
        $user->solde_bkn += $quantite;
        $user->save();

        // 2. On crée le reçu pour l'historique
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'achat_bkn',
            'montant' => $coutTotal,
            'description' => "Achat de $quantite BKN",
        ]);

        // === NOUVEAU : LA BOURSE À 0.1% ===
        // pow(1.001, quantite) veut dire "multiplie par 1.001 autant de fois qu'il y a de BKN achetés"
        $nouveauPrix = $dernierPrix * pow(1.001, $quantite);
        
        BknPrice::create(['prix' => $nouveauPrix]);

        return response()->json([
            'success' => true,
            'message' => "Vous avez acheté $quantite BKN avec succès !",
            'nouveau_solde_eur' => (float) $user->solde,
            'nouveau_solde_bkn' => (float) $user->solde_bkn,
            'nouveau_prix_bkn' => (float) $nouveauPrix
        ]);
    }

    // --- 3. VENDRE DU BKN (L'offre fait baisser le prix !) ---
    public function sellBkn(Request $request)
    {
        $request->validate(['quantite' => 'required|numeric|min:0.1']);
        $user = $request->user();
        $quantite = $request->quantite;

        // Vérification : A-t-il assez de BKN en stock ?
        if ($user->solde_bkn < $quantite) {
            return response()->json(['success' => false, 'message' => 'Fonds en BKN insuffisants.']);
        }

        $dernierPrix = BknPrice::latest()->first()->prix ?? 1.0000;
        $gainTotal = $quantite * $dernierPrix;

        // 1. Transaction : On retire les BKN, on ajoute les euros
        $user->solde_bkn -= $quantite;
        $user->solde += $gainTotal;
        $user->save();

        // 2. On crée le reçu
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'vente_bkn',
            'montant' => $gainTotal,
            'description' => "Vente de $quantite BKN",
        ]);

        // === NOUVEAU : LA BOURSE À -0.1% ===
        // pow(0.999, quantite) veut dire "baisse de 0.1% autant de fois qu'il y a de BKN vendus"
        $nouveauPrix = $dernierPrix * pow(0.999, $quantite);
        
        // Sécurité : On empêche le prix de descendre en dessous de 0.01 € (limite absolue)
        if ($nouveauPrix < 0.01) {
            $nouveauPrix = 0.01;
        }
        
        BknPrice::create(['prix' => $nouveauPrix]);

        return response()->json([
            'success' => true,
            'message' => "Vous avez vendu $quantite BKN pour " . number_format($gainTotal, 2) . " € !",
            'nouveau_solde_eur' => (float) $user->solde,
            'nouveau_solde_bkn' => (float) $user->solde_bkn,
            'nouveau_prix_bkn' => (float) $nouveauPrix
        ]);
    }
}