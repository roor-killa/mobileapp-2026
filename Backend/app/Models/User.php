<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, HasUuids, Notifiable;

    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'phone',
        'password',
        'pin_hash',
        'avatar_url',
        'status',
    ];

    protected $hidden = [
        'password',
        'pin_hash',
        'remember_token',
    ];

    protected $attributes = [
        'balance' => 0,
        'status'  => 'active',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'balance' => 'integer',
        ];
    }

    // ─── Accesseurs ────────────────────────────────────────────────────────────

    /**
     * Solde formaté en euros (balance stockée en centimes)
     */
    public function getBalanceInEurosAttribute(): string
    {
        return number_format($this->balance / 100, 2, ',', ' ') . ' €';
    }

    /**
     * Nom complet
     */
    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }

    // ─── Relations ─────────────────────────────────────────────────────────────

    public function sentTransactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'sender_id');
    }

    public function receivedTransactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'receiver_id');
    }

    public function qrTokens(): HasMany
    {
        return $this->hasMany(QrToken::class);
    }

    // ─── Méthodes métier ───────────────────────────────────────────────────────

    /**
     * Vérifie si l'utilisateur a assez de solde
     */
    public function hasSufficientBalance(int $amountInCents): bool
    {
        return $this->balance >= $amountInCents;
    }

    /**
     * Vérifie le PIN de l'utilisateur
     */
    public function verifyPin(string $pin): bool
    {
        return password_verify($pin, $this->pin_hash);
    }
}
