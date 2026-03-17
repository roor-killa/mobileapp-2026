<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transfer extends Model
{
    use HasFactory;

    /**
     * Les attributs qui peuvent être assignés en masse.
     */
    protected $fillable = [
        'sender_id',
        'receiver_id',
        'amount',
    ];

    /**
     * Relation vers l'utilisateur qui ENVOIE l'argent.
     */
    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Relation vers l'utilisateur qui REÇOIT l'argent.
     */
    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    /**
     * Casts pour transformer les types de données automatiquement.
     */
    protected $casts = [
        'amount' => 'double',
        'created_at' => 'datetime',
    ];
}