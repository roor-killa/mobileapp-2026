<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// Modèle représentant un étudiant dans la base de données
// Laravel fait automatiquement le lien avec la table "etudiants"
class Etudiant extends Model
{
    // Colonnes autorisées à être remplies via l'API
    protected $fillable = [
        'nom',
        'prenom',
        'email',
        'password',
    ];

    // Cache le password dans toutes les réponses JSON (sécurité)
    protected $hidden = [
        'password',
    ];

    // Un étudiant a plusieurs notes (une par matière)
    public function notes()
    {
        return $this->hasMany(Note::class);
    }

    // Un étudiant a des notes dans plusieurs matières
    public function matieres()
    {
        return $this->belongsToMany(Matiere::class, 'notes')
                    ->withPivot('note1', 'note2', 'note3');
    }
}