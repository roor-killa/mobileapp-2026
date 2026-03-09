<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QrToken extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'user_id',
        'amount',
        'token',
        'expires_at',
        'is_used',
        'transaction_id',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'integer',
            'expires_at' => 'datetime',
            'is_used' => 'boolean',
        ];
    }

    // ─── Relations ─────────────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    // ─── Helpers ───────────────────────────────────────────────────────────────

    public function isExpired(): bool
    {
        return $this->expires_at->isPast();
    }

    public function isValid(): bool
    {
        return !$this->is_used && !$this->isExpired();
    }

    // ─── Scopes ────────────────────────────────────────────────────────────────

    public function scopeValid($query)
    {
        return $query->where('is_used', false)
                     ->where('expires_at', '>', now());
    }
}
