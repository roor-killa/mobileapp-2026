<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TransferTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh --seed');
    }

    public function test_jean_can_transfer_to_marie_and_both_see_transaction(): void
    {
        $base = '/api';

        // Login Jean
        $loginJean = $this->postJson("$base/auth/login", [
            'email' => 'jean.dupont@example.com',
            'password' => 'password123',
        ])->assertOk()->json();

        $jeanToken = $loginJean['token'];

        // Récupérer un compte chèque de Jean
        $jeanAccounts = $this
            ->withHeader('Authorization', 'Bearer '.$jeanToken)
            ->getJson("$base/accounts")
            ->assertOk()
            ->json('accounts');

        $fromAccountId = collect($jeanAccounts)
            ->firstWhere('account_type', 'Compte Chèques')['id'];

        // Récupérer un compte bénéficiaire appartenant à Marie
        $beneficiaries = $this
            ->withHeader('Authorization', 'Bearer '.$jeanToken)
            ->getJson("$base/beneficiaries")
            ->assertOk()
            ->json('beneficiaries');

        $toAccountId = collect($beneficiaries)
            ->firstWhere('owner.name', 'Marie Martin')['id'];

        // Effectuer un virement
        $transfer = $this
            ->withHeader('Authorization', 'Bearer '.$jeanToken)
            ->postJson("$base/transactions/transfer", [
                'from_account_id' => $fromAccountId,
                'to_account_id' => $toAccountId,
                'amount' => 10.00,
                'description' => 'Test virement PHPUnit',
            ])
            ->assertCreated()
            ->json('transaction');

        $reference = $transfer['reference_number'];

        // Login Marie
        $loginMarie = $this->postJson("$base/auth/login", [
            'email' => 'marie.martin@example.com',
            'password' => 'password123',
        ])->assertOk()->json();

        $marieToken = $loginMarie['token'];

        // Vérifier que la transaction apparaît dans l'historique de Marie
        $marieTx = $this
            ->withHeader('Authorization', 'Bearer '.$marieToken)
            ->getJson("$base/transactions")
            ->assertOk()
            ->json('transactions');

        $found = collect($marieTx)->firstWhere('reference_number', $reference);
        $this->assertNotNull($found, 'La transaction doit être visible dans le compte de Marie');
    }
}

