<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChatController extends \App\Http\Controllers\Controller
{
    /**
     * Répond aux messages du chatbot (OpenAI si clé configurée, sinon réponses simulées).
     */
    public function chat(Request $request): JsonResponse
    {
        $request->validate([
            'message' => ['required', 'string', 'max:2000'],
        ]);

        $message = $request->input('message');
        $apiKey = config('services.openai.key');

        if (! empty($apiKey)) {
            try {
                $response = Http::withHeaders([
                    'Authorization' => 'Bearer '.$apiKey,
                    'Content-Type' => 'application/json',
                ])
                    ->timeout(30)
                    ->post('https://api.openai.com/v1/chat/completions', [
                        'model' => 'gpt-4o-mini',
                        'messages' => [
                            [
                                'role' => 'system',
                                'content' => 'Tu es l\'assistant virtuel de MyBank, une application bancaire. Tu réponds de façon courte, professionnelle et utile en français. Tu peux aider sur les comptes, virements, cartes, sécurité et l\'utilisation de l\'app.',
                            ],
                            [
                                'role' => 'user',
                                'content' => $message,
                            ],
                        ],
                        'max_tokens' => 500,
                    ]);

                if ($response->successful()) {
                    $body = $response->json();
                    $reply = $body['choices'][0]['message']['content'] ?? 'Désolé, je n\'ai pas pu générer de réponse.';

                    return response()->json(['reply' => trim($reply)]);
                }

                Log::warning('OpenAI API error', ['status' => $response->status(), 'body' => $response->body()]);
            } catch (\Throwable $e) {
                Log::error('OpenAI request failed', ['message' => $e->getMessage()]);
            }
        }

        return response()->json(['reply' => $this->mockReply($message)]);
    }

    private function mockReply(string $message): string
    {
        $lower = mb_strtolower($message);
        if (str_contains($lower, 'virement') || str_contains($lower, 'transfer')) {
            return 'Pour effectuer un virement, allez dans Accueil puis appuyez sur "Envoyer". Choisissez le compte à débiter, le bénéficiaire et le montant.';
        }
        if (str_contains($lower, 'compte') || str_contains($lower, 'solde')) {
            return 'Vos comptes et soldes sont visibles sur la page d\'accueil. Vous pouvez aussi ouvrir un nouveau compte via "Ouvrir un compte" depuis le menu.';
        }
        if (str_contains($lower, 'carte')) {
            return 'Les cartes liées à vos comptes sont accessibles via l\'onglet "Cartes" dans la barre de navigation.';
        }
        if (str_contains($lower, 'sécurité') || str_contains($lower, 'mot de passe')) {
            return 'Pour modifier votre mot de passe ou gérer la sécurité : Profil > Sécurité et confidentialité.';
        }
        if (str_contains($lower, 'bonjour') || str_contains($lower, 'salut') || str_contains($lower, 'hello')) {
            return 'Bonjour ! Comment puis-je vous aider avec votre compte MyBank ?';
        }
        if (str_contains($lower, 'merci')) {
            return 'Avec plaisir. N\'hésitez pas si vous avez d\'autres questions.';
        }

        return 'Je suis l\'assistant MyBank. Je peux vous aider sur les virements, comptes, cartes et paramètres de sécurité. Posez-moi une question précise.';
    }
}
