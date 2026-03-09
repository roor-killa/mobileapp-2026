<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

// Modèle représentant un administrateur
class Admin extends Authenticatable
{
    // Colonnes autorisées à être remplies
    protected $fillable = [
        'nom',
        'prenom',
        'email',
        'password',
    ];

    // Champs cachés dans les réponses JSON
    protected $hidden = [
        'password',
    ];
}