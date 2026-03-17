<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\ResetPasswordMail;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rules\Password;

class PasswordResetController extends Controller
{
    /**
     * POST /api/v1/auth/forgot-password
     * Envoie un code de réinitialisation par email.
     *
     * Sécurité : retourne toujours 200 même si l'email n'existe pas
     * pour ne pas révéler si un compte est enregistré (user enumeration).
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
        ]);

        $user = User::where('email', $request->email)->first();

        if ($user) {
            // Générer un code à 8 chiffres (lisible sur mobile)
            $plainToken = str_pad(random_int(0, 99999999), 8, '0', STR_PAD_LEFT);

            // Supprimer l'ancien token s'il existe et stocker le nouveau haché
            DB::table('password_reset_tokens')->updateOrInsert(
                ['email' => $user->email],
                [
                    'token'      => Hash::make($plainToken),
                    'created_at' => now(),
                ]
            );

            // Envoyer l'email
            Mail::to($user->email)->send(new ResetPasswordMail(
                firstName: $user->first_name,
                token:     $plainToken,
            ));
        }

        // Toujours retourner 200 (anti-énumération)
        return response()->json([
            'message' => 'Si cet email est enregistré, vous recevrez un code de réinitialisation.',
        ]);
    }

    /**
     * POST /api/v1/auth/reset-password
     * Réinitialise le mot de passe avec le code reçu par email.
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email'                 => ['required', 'email'],
            'token'                 => ['required', 'string'],
            'password'              => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()],
        ]);

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        // Vérifier que le token existe
        if (!$record) {
            return response()->json([
                'message' => 'Code invalide ou expiré.',
            ], 422);
        }

        // Vérifier l'expiration (15 minutes)
        if (Carbon::parse($record->created_at)->addMinutes(15)->isPast()) {
            DB::table('password_reset_tokens')->where('email', $request->email)->delete();
            return response()->json([
                'message' => 'Ce code a expiré. Veuillez en demander un nouveau.',
            ], 422);
        }

        // Vérifier que le code correspond
        if (!Hash::check($request->token, $record->token)) {
            return response()->json([
                'message' => 'Code invalide ou expiré.',
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'Code invalide ou expiré.'], 422);
        }

        // Mettre à jour le mot de passe
        $user->update(['password' => Hash::make($request->password)]);

        // Supprimer le token (usage unique)
        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        // Révoquer tous les tokens Sanctum (sécurité)
        $user->tokens()->delete();

        return response()->json([
            'message' => 'Mot de passe réinitialisé avec succès. Veuillez vous reconnecter.',
        ]);
    }
}
