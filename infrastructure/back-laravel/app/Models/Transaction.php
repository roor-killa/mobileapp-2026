<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'emetteur_id',
        'recepteur_id',
        'montant',
        'statut',
        'type'
    ];

    public function emetteur() {
        return $this->belongsTo(User::class, 'emetteur_id');
    }

    public function recepteur() {
        return $this->belongsTo(User::class, 'recepteur_id');
    }
}