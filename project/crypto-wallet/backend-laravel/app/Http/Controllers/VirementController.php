<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\ResolvesNodexUser;
use App\Models\NodexUser;
use App\Models\VirementEur;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * API virements NodEX - compatible avec Flutter (même format que NestJS).
 */
class VirementController extends Controller
{
    use ResolvesNodexUser;

    /**
     * GET /api/virements/balance
     */
    public function balance(Request $request): JsonResponse
    {
        $user = $this->nodexUser($request);
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        return response()->json(['balanceEur' => (float) $user->balanceEur]);
    }

    /**
     * GET /api/virements/me
     */
    public function me(Request $request): JsonResponse
    {
        $user = $this->nodexUser($request);
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        $user->ensureSyntheticBankingFilled();
        $user->refresh();

        return response()->json([
            'balanceEur' => (float) $user->balanceEur,
            'iban' => $user->iban,
            'pseudonym' => $user->pseudonym,
            // Pour afficher un RIB (titulaire du compte)
            'holderName' => $user->name,
        ]);
    }

    /**
     * GET /api/virements/history
     */
    public function history(Request $request): JsonResponse
    {
        $user = $this->nodexUser($request);
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        $userId = $user->id;
        $sent = VirementEur::where('fromUserId', $userId)->orderByDesc('createdAt')->limit(20)->get();
        $received = VirementEur::where('toUserId', $userId)->orderByDesc('createdAt')->limit(20)->get();

        $fromIds = collect($sent->pluck('toUserId'))->concat($received->pluck('fromUserId'))->unique()->values();
        $users = NodexUser::whereIn('id', $fromIds)->get()->keyBy('id');

        $result = [];
        foreach ($sent as $s) {
            $result[] = [
                'id' => $s->id,
                'type' => 'sent',
                'amount' => (float) $s->amount,
                'date' => $s->createdAt?->toIso8601String(),
                'otherPseudonym' => $users->get($s->toUserId)?->pseudonym ?? '',
            ];
        }
        foreach ($received as $r) {
            $result[] = [
                'id' => $r->id,
                'type' => 'received',
                'amount' => (float) $r->amount,
                'date' => $r->createdAt?->toIso8601String(),
                'otherPseudonym' => $users->get($r->fromUserId)?->pseudonym ?? '',
            ];
        }

        usort($result, fn ($a, $b) => strcmp($b['date'] ?? '', $a['date'] ?? ''));

        return response()->json(array_slice($result, 0, 20));
    }

    /**
     * POST /api/virements/send
     */
    public function send(Request $request): JsonResponse
    {
        $fromUser = $this->nodexUser($request);
        if (!$fromUser) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        $userId = $fromUser->id;

        $toIdentifier = trim((string) ($request->input('toIdentifier') ?? $request->input('toEmail') ?? ''));
        $amount = (float) ($request->input('amount') ?? 0);

        if (!$toIdentifier) {
            return response()->json(['message' => "Indiquez l'IBAN, le pseudonyme ou l'email du destinataire"], 400);
        }
        if ($amount <= 0) {
            return response()->json(['message' => 'Le montant doit être positif'], 400);
        }

        $fromBalance = (float) $fromUser->balanceEur;
        if ($fromBalance < $amount) {
            return response()->json(['message' => 'Solde insuffisant'], 400);
        }

        $ident = trim($toIdentifier);
        $normIban = strtoupper(str_replace(' ', '', $ident));
        $identLower = strtolower($ident);

        $toUser = null;

        if (str_starts_with($normIban, 'FR') && strlen($normIban) >= 14) {
            $all = NodexUser::whereNotNull('iban')->get();
            foreach ($all as $u) {
                if ($u->iban && strtoupper(str_replace(' ', '', $u->iban)) === $normIban) {
                    $toUser = $u;
                    break;
                }
            }
        }
        if (!$toUser) {
            // Comparaison insensible à la casse (avant : LOWER(col) = saisie sans lower → échec)
            $toUser = NodexUser::whereRaw('LOWER(pseudonym) = ?', [$identLower])->first();
        }
        if (!$toUser && str_contains($ident, '@')) {
            $toUser = NodexUser::where('email', $identLower)->first();
        }

        if (!$toUser) {
            return response()->json(['message' => "Aucun compte NodEX trouvé pour \"$ident\""], 404);
        }
        if ($toUser->id === $userId) {
            return response()->json(['message' => 'Vous ne pouvez pas vous envoyer un virement à vous-même'], 400);
        }

        $toBalanceBefore = (float) $toUser->balanceEur;

        try {
            DB::transaction(function () use ($userId, $toUser, $amount, $fromBalance, $toBalanceBefore) {
                NodexUser::where('id', $userId)->update(['balanceEur' => $fromBalance - $amount]);
                NodexUser::where('id', $toUser->id)->update(['balanceEur' => $toBalanceBefore + $amount]);
                VirementEur::create([
                    'fromUserId' => (string) $userId,
                    'toUserId' => (string) $toUser->id,
                    'amount' => $amount,
                ]);
            });
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Erreur lors du virement: ' . $e->getMessage()], 500);
        }

        $updatedFrom = NodexUser::find($userId);
        $updatedTo = NodexUser::find($toUser->id);

        return response()->json([
            'success' => true,
            'newBalance' => (float) $updatedFrom->balanceEur,
            'recipientCredited' => true,
            'recipientNewBalance' => (float) $updatedTo->balanceEur,
        ]);
    }

}
