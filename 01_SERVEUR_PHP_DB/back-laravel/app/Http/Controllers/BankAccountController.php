<?php

namespace App\Http\Controllers;

use App\Models\BankAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BankAccountController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $accounts = $request->user()->bankAccounts()->with(['cards', 'transactions'])->get();
        return response()->json($accounts);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'account_name' => 'required|string',
            'currency' => 'required|string|size:3',
            'account_type' => 'required|in:checking,savings,investment',
        ]);

        $account = BankAccount::create([
            'user_id' => $request->user()->id,
            'account_number' => 'ACC' . Str::random(12),
            'account_name' => $validated['account_name'],
            'currency' => $validated['currency'],
            'account_type' => $validated['account_type'],
            'opened_at' => now(),
        ]);

        return response()->json([
            'message' => 'Bank account created successfully',
            'account' => $account,
        ], 201);
    }

    public function show(BankAccount $bankAccount): JsonResponse
    {
        $this->authorize('view', $bankAccount);
        return response()->json($bankAccount->load(['cards', 'transactions']));
    }

    public function update(Request $request, BankAccount $bankAccount): JsonResponse
    {
        $this->authorize('update', $bankAccount);

        $bankAccount->update(
            $request->validate([
                'account_name' => 'sometimes|string',
                'status' => 'sometimes|in:active,inactive,frozen',
            ])
        );

        return response()->json([
            'message' => 'Bank account updated successfully',
            'account' => $bankAccount,
        ]);
    }

    public function destroy(BankAccount $bankAccount): JsonResponse
    {
        $this->authorize('delete', $bankAccount);
        $bankAccount->update(['status' => 'inactive', 'closed_at' => now()]);

        return response()->json(['message' => 'Bank account closed successfully']);
    }
}
