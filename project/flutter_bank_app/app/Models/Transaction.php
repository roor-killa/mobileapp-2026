<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    // On autorise Laravel à remplir TOUS ces champs (Anciens + Transferts + Pockets)
    protected $fillable = [
        'user_id',       // Gardé pour tes anciennes transactions (achats BKN, etc.)
        'sender_id',     // Pour les virements entre utilisateurs
        'recipient_id',  // Pour les virements entre utilisateurs
        'montant', 
        'type', 
        'description',
        
        // --- LES 2 NOUVEAUX CHAMPS POUR LES POCKETS ---
        'pocket_id',
        'wallet_source'
    ];

    // RELATION : L'utilisateur propriétaire de la transaction
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // RELATION : Le pocket lié à cette transaction (s'il y en a un)
    public function pocket()
    {
        return $this->belongsTo(Pocket::class);
    }
}