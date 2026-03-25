<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\ResolvesNodexUser;
use App\Models\NodexUser;
use App\Models\VirementEur;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

/**
 * Proxy Groq : le navigateur ne peut pas appeler api.groq.com directement (CORS).
 * La clé reste sur le serveur (GROQ_API_KEY dans .env).
 * À chaque requête, on enrichit le message « system » avec le solde EUR, les crypto
 * et les derniers virements de l’utilisateur connecté (JWT), pour que l’IA ne devine pas.
 */
class ChatController extends Controller
{
    use ResolvesNodexUser;

    /** Même liste que WalletController (cache nodex_crypto_{userId}). */
    private const CRYPTO_SYMBOLS = ['ETH', 'BTC', 'SOL', 'ALGO'];

    public function completions(Request $request): JsonResponse
    {
        $user = $this->nodexUser($request);
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        // trim + relecture .env si le cache de config est vide (souvent après oubli de config:clear)
        $key = trim((string) (config('services.groq.key') ?: env('GROQ_API_KEY', '')));
        if ($key === '') {
            return response()->json([
                'message' => 'Chat non configuré : ajoutez GROQ_API_KEY dans le fichier .env du backend Laravel.',
            ], 503);
        }

        $model = $request->input('model', config('services.groq.model', 'llama-3.1-8b-instant'));
        $messages = $request->input('messages', []);
        if (!is_array($messages)) {
            $messages = [];
        }

        $messages = $this->injectLiveAccountContext($messages, $user);

        $response = Http::withHeaders([
            'Authorization' => 'Bearer '.$key,
            'Content-Type' => 'application/json',
        ])
            ->timeout(50)
            ->post('https://api.groq.com/openai/v1/chat/completions', [
                'model' => $model,
                'messages' => $messages,
                'temperature' => (float) $request->input('temperature', 0.7),
                'max_tokens' => (int) $request->input('max_tokens', 1024),
            ]);

        if (!$response->successful()) {
            $body = $response->body();
            $short = strlen($body) > 200 ? substr($body, 0, 200).'…' : $body;

            return response()->json([
                'message' => 'Erreur Groq ('.$response->status().') : '.$short,
            ], 502);
        }

        return response()->json($response->json());
    }

    /**
     * Ajoute (ou fusionne) un bloc de faits sur le compte dans le premier message system.
     */
    private function injectLiveAccountContext(array $messages, NodexUser $user): array
    {
        $facts = $this->buildAccountFactsBlock($user);
        $suffix = "\n\n--- Données réelles du compte connecté (obligatoire pour solde / virements / crypto) ---\n"
            ."Règles : pour tout ce qui concerne l’argent de CET utilisateur, utilise UNIQUEMENT les chiffres ci-dessous. "
            ."Ne jamais inventer de solde, d’IBAN ni de montant. Si une info manque, dis qu’elle n’est pas disponible.\n\n"
            .$facts;

        $merged = [];
        $systemDone = false;
        foreach ($messages as $m) {
            if (!is_array($m)) {
                continue;
            }
            $role = $m['role'] ?? '';
            if (!$systemDone && $role === 'system') {
                $prev = $m['content'] ?? '';
                $prev = is_string($prev) ? $prev : json_encode($prev);
                $merged[] = [
                    'role' => 'system',
                    'content' => $prev.$suffix,
                ];
                $systemDone = true;
            } else {
                $merged[] = $m;
            }
        }

        if (!$systemDone) {
            array_unshift($merged, [
                'role' => 'system',
                'content' => "Tu es l'assistant NodEX.\n".$suffix,
            ]);
        }

        return $merged;
    }

    private function buildAccountFactsBlock(NodexUser $user): string
    {
        $uid = $user->id;
        $balances = $this->getCryptoBalances($uid);

        $eur = number_format((float) $user->balanceEur, 2, ',', ' ');
        $name = $user->name !== null && trim((string) $user->name) !== '' ? trim((string) $user->name) : '(non renseigné)';
        $pseudo = $user->pseudonym !== null && trim((string) $user->pseudonym) !== '' ? trim((string) $user->pseudonym) : '(aucun)';
        $iban = $user->iban !== null && trim((string) $user->iban) !== '' ? trim((string) $user->iban) : '(non chargé)';

        $lines = [];
        $lines[] = 'Horodatage serveur : '.now()->toIso8601String();
        $lines[] = 'Solde compte euro (virements internes NodEX) : '.$eur.' EUR';
        $lines[] = 'Nom affiché : '.$name;
        $lines[] = 'Pseudonyme pour les virements : '.$pseudo;
        $lines[] = 'IBAN de réception des virements entrants : '.$iban;
        $lines[] = 'Carte virtuelle : gérée dans l’app (ne jamais inventer de numéro de carte).';
        $lines[] = 'Cryptomonnaies (quantités en unités natives ; pas le cours € en direct ici) :';
        foreach (self::CRYPTO_SYMBOLS as $sym) {
            $b = isset($balances[$sym]) ? (float) $balances[$sym] : 0.0;
            $lines[] = '  - '.$sym.' : '.$this->formatCryptoAmount($b);
        }
        $lines[] = 'Pour la valeur totale en euros avec cours du marché, indique que c’est sur l’écran d’accueil / Wallets de l’app.';

        $v = VirementEur::where(function ($q) use ($uid) {
            $q->where('fromUserId', $uid)->orWhere('toUserId', $uid);
        })
            ->orderByDesc('createdAt')
            ->limit(8)
            ->get();

        if ($v->isEmpty()) {
            $lines[] = 'Historique virements : aucun pour le moment.';
        } else {
            $lines[] = 'Derniers virements (EUR) :';
            $otherIds = $v->map(function ($row) use ($uid) {
                return $row->fromUserId === $uid ? $row->toUserId : $row->fromUserId;
            })->unique()->filter()->values();
            $others = NodexUser::whereIn('id', $otherIds)->get()->keyBy('id');

            foreach ($v as $row) {
                $out = $row->fromUserId === $uid;
                $oid = $out ? $row->toUserId : $row->fromUserId;
                $op = $others->get($oid);
                $opPseudo = $op && $op->pseudonym ? '@'.$op->pseudonym : '(utilisateur)';
                $amt = number_format((float) $row->amount, 2, ',', ' ');
                $d = $row->createdAt instanceof \DateTimeInterface
                    ? $row->createdAt->format('Y-m-d H:i')
                    : (string) $row->createdAt;
                $lines[] = $out
                    ? "  - {$d} : envoyé {$amt} EUR vers {$opPseudo}"
                    : "  - {$d} : reçu {$amt} EUR de {$opPseudo}";
            }
        }

        return implode("\n", $lines);
    }

    /** Même logique que WalletController::getCryptoBalances. */
    private function getCryptoBalances(string $userId): array
    {
        $key = "nodex_crypto_{$userId}";
        $stored = cache()->get($key);
        if (is_array($stored)) {
            return $stored;
        }

        return ['ETH' => 0, 'BTC' => 0, 'SOL' => 0, 'ALGO' => 0];
    }

    private function formatCryptoAmount(float $v): string
    {
        if (abs($v) < 1e-12) {
            return '0';
        }
        $s = rtrim(rtrim(sprintf('%.8f', $v), '0'), '.');

        return $s === '' ? '0' : $s;
    }
}
