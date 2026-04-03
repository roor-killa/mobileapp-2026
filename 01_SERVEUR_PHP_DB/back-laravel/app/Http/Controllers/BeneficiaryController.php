<?php

namespace App\Http\Controllers;

use App\Models\Beneficiary;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BeneficiaryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $beneficiaries = $request->user()->beneficiaries()->get();
        return response()->json($beneficiaries);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'email' => 'sometimes|email',
            'phone' => 'sometimes|string',
            'iban' => 'required|string|unique:beneficiaries',
            'bic' => 'sometimes|string',
            'bank_name' => 'sometimes|string',
            'country' => 'sometimes|string',
            'account_type' => 'sometimes|string',
            'is_favorite' => 'boolean',
        ]);

        $beneficiary = Beneficiary::create([
            'user_id' => $request->user()->id,
            ...$validated,
        ]);

        return response()->json([
            'message' => 'Beneficiary added successfully',
            'beneficiary' => $beneficiary,
        ], 201);
    }

    public function update(Request $request, Beneficiary $beneficiary): JsonResponse
    {
        $this->authorize('update', $beneficiary);

        $beneficiary->update(
            $request->validate([
                'name' => 'sometimes|string',
                'email' => 'sometimes|email',
                'phone' => 'sometimes|string',
                'is_favorite' => 'sometimes|boolean',
                'status' => 'sometimes|in:active,inactive,blocked',
            ])
        );

        return response()->json([
            'message' => 'Beneficiary updated successfully',
            'beneficiary' => $beneficiary,
        ]);
    }

    public function destroy(Beneficiary $beneficiary): JsonResponse
    {
        $this->authorize('delete', $beneficiary);
        $beneficiary->delete();

        return response()->json(['message' => 'Beneficiary deleted successfully']);
    }
}
