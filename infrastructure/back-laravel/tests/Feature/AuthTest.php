<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh --seed');
    }

    public function test_login_with_seeded_user_succeeds(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'jean.dupont@example.com',
            'password' => 'password123',
        ]);

        $response
            ->assertOk()
            ->assertJsonStructure([
                'message',
                'user' => ['id', 'email'],
                'token',
            ]);
    }

    public function test_cannot_login_with_wrong_password(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'jean.dupont@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(422);
    }

    public function test_logout_revokes_token(): void
    {
        $user = User::where('email', 'jean.dupont@example.com')->firstOrFail();
        $token = $user->createToken('test')->plainTextToken;

        $response = $this
            ->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/auth/logout');

        $response->assertOk();
    }
}

