<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'amount',
        'type',
        'status',
        'reference',
        'note',
        'metadata',
        'sender_balance_before',
        'sender_balance_after',
        'receiver_balance_before',
        'receiver_balance_after',
        'blockchain_tx_id',
        'blockchain_explorer_url',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'integer',
            'metadata' => 'array',
            'sender_balance_before' => 'integer',
            'sender_balance_after' => 'integer',
            'receiver_balance_before' => 'integer',
            'receiver_balance_after' => 'integer',
        ];
    }

    // ─── Relations ─────────────────────────────────────────────────────────────

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    // ─── Accesseurs ────────────────────────────────────────────────────────────

    public function getAmountInEurosAttribute(): string
    {
        return number_format($this->amount / 100, 2, ',', ' ') . ' €';
    }

    public function getIsDebitAttribute(): bool
    {
        return in_array($this->type, ['transfer', 'qr_send']);
    }

    public function getIsCompletedAttribute(): bool
    {
        return $this->status === 'completed';
    }
}
