<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

// On étend Authenticatable au lieu de Model
// car ce modèle représente un utilisateur qui peut se connecter
class Professeur extends Authenticatable
{
    // Colonnes autorisées à être remplies via l'API
    protected $fillable = [
        'nom',
        'prenom',
        'email',
        'password',
    ];

    // Colonnes sensibles cachées
    // Ces champs ne seront JAMAIS retournés dans les réponses JSON
    protected $hidden = [
        'password',
    ];

    // Un professeur peut enseigner plusieurs matières (max 2)
    public function matieres()
    {
        return $this->belongsToMany(Matiere::class, 'professeur_matiere');
    }
}