<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// Modèle représentant une matière (ex: Maths, Français...)
class Matiere extends Model
{
    // Colonnes autorisées à être remplies
    protected $fillable = ['nom'];

    // Une matière peut être enseignée par plusieurs professeurs
    public function professeurs()
    {
        return $this->belongsToMany(Professeur::class, 'professeur_matiere');
    }

    // Une matière a plusieurs notes d'étudiants
    public function notes()
    {
        return $this->hasMany(Note::class);
    }
}