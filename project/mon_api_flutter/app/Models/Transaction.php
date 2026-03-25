<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'user_id',
        'amount',
        'type',
        'status',
        'description',
        'reference'
    ];

    // Optionnel : Relation vers l'utilisateur
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}