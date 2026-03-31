<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pocket extends Model
{
    use HasFactory;

    // On autorise Laravel à remplir ces champs automatiquement
    protected $fillable = [
        'user_id',
        'nom',
        'icone',
        'couleur',
        'solde'
    ];

    // RELATION : Un pocket appartient à UN utilisateur
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // RELATION : Un pocket peut avoir PLUSIEURS transactions
    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}