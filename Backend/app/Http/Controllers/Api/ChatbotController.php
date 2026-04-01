<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    /**
     * POST /api/chatbot/message
     * Envoyer un message au chatbot Ollama
     */
    public function message(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message' => ['required', 'string', 'max:1000'],
        ]);

        $user = $request->user();

        // Contexte financier de l'utilisateur injecté dans le prompt système
        $systemPrompt = $this->buildSystemPrompt($user);

        // Vérifier si le message est une demande de transfert
        $transferIntent = $this->detectTransferIntent($validated['message']);

        try {
            $response = Http::timeout(30)->post(config('services.ollama.host') . '/api/chat', [
                'model'  => config('services.ollama.model', 'llama3.2'),
                'stream' => false,
                'messages' => [
                    [
                        'role'    => 'system',
                        'content' => $systemPrompt,
                    ],
                    [
                        'role'    => 'user',
                        'content' => $validated['message'],
                    ],
                ],
            ]);

            if (!$response->successful()) {
                throw new \Exception('Ollama unavailable: ' . $response->status());
            }

            $botMessage = $response->json('message.content') ?? 'Je n\'ai pas pu traiter votre demande.';

            return response()->json([
                'response'       => $botMessage,
                'transfer_intent' => $transferIntent,
            ]);

        } catch (\Exception $e) {
            Log::error('Chatbot Ollama error: ' . $e->getMessage());
            return response()->json([
                'response' => 'Le chatbot est temporairement indisponible. Veuillez réessayer.',
                'error'    => true,
            ], 503);
        }
    }

    // ─── Helpers ───────────────────────────────────────────────────────────────

    /**
     * Construit le prompt système avec le contexte du compte utilisateur
     */
    private function buildSystemPrompt(User $user): string
    {
        // Dernières 5 transactions
        $recentTx = Transaction::with(['sender', 'receiver'])
            ->where(function ($q) use ($user) {
                $q->where('sender_id', $user->id)
                  ->orWhere('receiver_id', $user->id);
            })
            ->latest()
            ->take(5)
            ->get()
            ->map(function ($tx) use ($user) {
                $direction = $tx->sender_id === $user->id ? 'Envoyé' : 'Reçu';
                $counterpart = $tx->sender_id === $user->id
                    ? ($tx->receiver->full_name ?? 'Inconnu')
                    : ($tx->sender->full_name ?? 'Recharge');
                return "- {$direction} {$tx->amount_in_euros} à/de {$counterpart} le {$tx->created_at->format('d/m/Y')}";
            })
            ->join("\n");

        return <<<PROMPT
Tu es un assistant financier personnel pour l'application Payflow.
Tu réponds UNIQUEMENT en français, de manière concise et professionnelle.

=== INFORMATIONS DU COMPTE ===
Utilisateur : {$user->full_name}
Email       : {$user->email}
Solde actuel : {$user->balance_in_euros}

=== DERNIÈRES TRANSACTIONS ===
{$recentTx}

=== TES CAPACITÉS ===
- Informer l'utilisateur sur son solde
- Expliquer ses transactions
- Guider pour effectuer un transfert (mais ne JAMAIS exécuter un transfert toi-même directement)
- Conseiller sur la gestion de son argent

=== RÈGLES IMPORTANTES ===
- Ne demande JAMAIS le mot de passe ou le PIN
- Si l'utilisateur veut faire un transfert, donne-lui les informations nécessaires et laisse l'app gérer
- En cas de doute, redirige vers le support
PROMPT;
    }

    /**
     * Détecte si le message contient une intention de transfert
     */
    private function detectTransferIntent(string $message): ?array
    {
        $message = strtolower($message);

        // Patterns : "envoyer 50€ à alice@test.com" ou "transfert de 20 euros à Bob"
        $patterns = [
            '/envo(?:yer?|i)\s+(\d+(?:[.,]\d{1,2})?)\s*(?:€|euros?|eur)\s+[àa]\s+([^\s]+@[^\s]+)/ui',
            '/transfer(?:t|er)\s+(?:de\s+)?(\d+(?:[.,]\d{1,2})?)\s*(?:€|euros?|eur)\s+[àa]\s+([^\s]+@[^\s]+)/ui',
        ];

        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $message, $matches)) {
                $amount = (float) str_replace(',', '.', $matches[1]);
                return [
                    'detected'       => true,
                    'amount_euros'   => $amount,
                    'amount_cents'   => (int) round($amount * 100),
                    'receiver_email' => $matches[2],
                ];
            }
        }

        return null;
    }
}
