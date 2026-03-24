<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    // ---> C'EST CETTE LIGNE QU'IL FAUT AJOUTER <---
    protected $fillable = [
        'sender_id', 
        'recipient_id', 
        'montant', 
        'type', 
        'description', 
        'user_id' // Garde user_id s'il est utilisé par tes anciennes transactions
    ];
}