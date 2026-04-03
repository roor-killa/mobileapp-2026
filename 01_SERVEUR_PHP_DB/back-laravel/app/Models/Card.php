<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Card extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'bank_account_id',
        'card_number',
        'card_holder',
        'cvv',
        'expiry_date',
        'card_type',
        'card_status',
        'card_brand',
        'daily_limit',
        'monthly_limit',
        'spent_today',
        'spent_month',
        'is_virtual',
        'is_primary',
        'color',
        'activated_at',
    ];

    protected $hidden = ['cvv', 'card_number'];

    protected $casts = [
        'expiry_date' => 'date',
        'daily_limit' => 'decimal:2',
        'monthly_limit' => 'decimal:2',
        'spent_today' => 'decimal:2',
        'spent_month' => 'decimal:2',
        'is_virtual' => 'boolean',
        'is_primary' => 'boolean',
        'activated_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function bankAccount(): BelongsTo
    {
        return $this->belongsTo(BankAccount::class);
    }

    public function getMaskedCardAttribute(): string
    {
        return 'XXXX XXXX XXXX ' . substr($this->card_number, -4);
    }
}
