<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    /**
     * PUT /api/profile
     * Mettre à jour les informations du profil
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'first_name' => ['sometimes', 'string', 'max:100'],
            'last_name'  => ['sometimes', 'string', 'max:100'],
            'email'      => ['sometimes', 'email', 'unique:users,email,' . $user->id],
            'phone'      => ['sometimes', 'nullable', 'string', 'unique:users,phone,' . $user->id],
            'avatar_url' => ['sometimes', 'nullable', 'url'],
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'Profil mis à jour avec succès.',
            'user'    => [
                'id'         => $user->id,
                'first_name' => $user->first_name,
                'last_name'  => $user->last_name,
                'full_name'  => $user->full_name,
                'email'      => $user->email,
                'phone'      => $user->phone,
                'avatar_url' => $user->avatar_url,
                'balance'    => $user->balance,
                'balance_formatted' => $user->balance_in_euros,
            ],
        ]);
    }

    /**
     * PUT /api/profile/password
     * Changer le mot de passe
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => ['required', 'string'],
            'password'         => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()],
        ]);

        $user = $request->user();

        if (!Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'message' => 'Le mot de passe actuel est incorrect.',
            ], 403);
        }

        $user->update([
            'password' => Hash::make($validated['password']),
        ]);

        // Révoquer tous les tokens pour forcer une reconnexion
        $user->tokens()->delete();

        return response()->json([
            'message' => 'Mot de passe modifié. Veuillez vous reconnecter.',
        ]);
    }

    /**
     * PUT /api/profile/pin
     * Changer le PIN de confirmation des transferts
     */
    public function changePin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_pin' => ['required', 'digits:6'],
            'new_pin'     => ['required', 'digits:6', 'confirmed'],
        ]);

        $user = $request->user();

        if (!$user->verifyPin($validated['current_pin'])) {
            return response()->json([
                'message' => 'Le PIN actuel est incorrect.',
            ], 403);
        }

        $user->update([
            'pin_hash' => Hash::make($validated['new_pin']),
        ]);

        return response()->json([
            'message' => 'PIN modifié avec succès.',
        ]);
    }
}
