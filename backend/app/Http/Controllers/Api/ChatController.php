<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Operation;

class ChatController extends Controller
{
    public function send(Request $request)
    {
        $message = strtolower($request->input('message'));

        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'reply' => "Vous devez être connecté pour utiliser l'assistant."
            ]);
        }

        $balance = $user->balance;

        $lastOperations = Operation::where('user_id', $user->id)
            ->latest()
            ->take(3)
            ->get();

        // =========================
        // Réponses intelligentes
        // =========================

        // 💰 Solde
        if (str_contains($message, 'solde')) {
            return response()->json([
                'reply' => "Votre solde actuel est de {$balance} €."
            ]);
        }

        // 📊 Historique
        if (str_contains($message, 'historique') || str_contains($message, 'opération')) {

            if ($lastOperations->isEmpty()) {
                return response()->json([
                    'reply' => "Vous n'avez aucune opération récente."
                ]);
            }

            $text = "Voici vos dernières opérations :\n";

            foreach ($lastOperations as $op) {
                $type = $op->type === 'deposit' ? 'Dépôt' : 'Retrait';
                $text .= "- {$type} de {$op->amount} €\n";
            }

            return response()->json([
                'reply' => $text
            ]);
        }

        // 💸 Déposer
        if (str_contains($message, 'déposer') || str_contains($message, 'depot')) {
            return response()->json([
                'reply' => "Pour déposer de l'argent, utilisez le bouton 'Déposer' sur l'écran principal."
            ]);
        }

        // 💸 Retirer
        if (str_contains($message, 'retirer')) {
            return response()->json([
                'reply' => "Pour retirer de l'argent, utilisez le bouton 'Retirer'."
            ]);
        }

        // 🔁 Virement
        if (str_contains($message, 'virement') || str_contains($message, 'envoyer')) {
            return response()->json([
                'reply' => "La fonctionnalité de virement entre utilisateurs arrive bientôt."
            ]);
        }

        // 👤 Profil
        if (str_contains($message, 'profil')) {
            return response()->json([
                'reply' => "Vous pouvez consulter votre profil dans l'onglet 'Mon profil'."
            ]);
        }

        // ❓ Réponse par défaut
        return response()->json([
            'reply' => "Je suis votre assistant MiniBank 🤖. Vous pouvez me demander votre solde, vos opérations ou comment utiliser l'application."
        ]);
    }
}