<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Pocket;

class ChatController extends Controller
{
    public function askGemini(Request $request)
    {
        try {
            $request->validate(['message' => 'required|string']);
            $user = $request->user();
            
            // Sécurité : Vérifier si l'utilisateur est bien reconnu (problème de route auth:sanctum)
            if (!$user) {
                return response()->json(['success' => false, 'message' => "L'utilisateur n'est pas reconnu. La route API est-elle bien dans le groupe auth:sanctum ?"], 200);
            }

            $messageUser = $request->message;

            // 1. Vérification de la clé API
            $apiKey = env('GEMINI_API_KEY');
            if (empty($apiKey)) {
                return response()->json(['success' => false, 'message' => "La clé API Gemini est introuvable ou vide dans le fichier .env !"], 200);
            }

            // 2. Récupérer les sous-comptes
            $pockets = Pocket::where('user_id', $user->id)->get();
            $pocketsText = "";
            if ($pockets->isEmpty()) {
                $pocketsText = "Aucun sous-compte.";
            } else {
                foreach($pockets as $p) {
                    $pocketsText .= "- {$p->nom} : {$p->solde} €\n";
                }
            }

            // 3. CONSTRUIRE LE PROMPT SYSTÈME
            $systemPrompt = "Tu es Agent-BKN Wallet, l'assistant financier intelligent et exclusif de l'application BKN Wallet.
            Tu dois répondre de manière concise, professionnelle et chaleureuse en français. Ne fais pas de réponses trop longues, le texte s'affiche sur un écran de téléphone.
            
            Voici les informations strictes et en temps réel de l'utilisateur avec qui tu parles :
            - Prénom : {$user->prenom}
            - Solde principal : {$user->solde} €
            - Portefeuille Crypto : {$user->solde_bkn} BKN
            - Sous-comptes (Pockets) actuels :
            {$pocketsText}

            RÈGLES STRICTES : 
            1. Tu ne dois parler QUE de ses finances, de l'application BKN, ou de concepts financiers/cryptos. 
            2. Si on te pose une question hors sujet, refuse poliment. 
            3. Ne donne pas de conseils d'investissement risqués.";

            // 4. APPEL À L'API GEMINI (Le vrai modèle de 2026 !)
            $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={$apiKey}";

            // On fusionne secrètement tes règles et la question de l'utilisateur
            $promptFinal = $systemPrompt . "\n\n--- QUESTION DE L'UTILISATEUR --- \n" . $messageUser;

            $response = Http::post($url, [
                'contents' => [
                    [
                        'role' => 'user',
                        'parts' => [
                            ['text' => $promptFinal]
                        ]
                    ]
                ]
            ]);

            // 5. GESTION DE LA RÉPONSE DE GOOGLE
            if ($response->successful()) {
                $botReply = $response->json('candidates.0.content.parts.0.text');
                return response()->json(['success' => true, 'reply' => $botReply], 200);
            } else {
                // Si Google refuse la requête (clé invalide, erreur de syntaxe, etc.)
                $googleError = $response->json('error.message') ?? 'Erreur inconnue de Google';
                return response()->json(['success' => false, 'message' => "Refus de Google : " . $googleError], 200);
            }

        } catch (\Exception $e) {
            // Si Laravel crash (problème de base de données, syntaxe PHP, cURL, etc.)
            return response()->json([
                'success' => false,
                'message' => "Crash interne Laravel : " . $e->getMessage() . " à la ligne " . $e->getLine()
            ], 200);
        }
    }
}