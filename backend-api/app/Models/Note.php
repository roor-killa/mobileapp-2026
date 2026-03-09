<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// Modèle représentant les notes d'un étudiant pour une matière
// Un étudiant peut avoir jusqu'à 3 notes par matière
class Note extends Model
{
    // Colonnes autorisées à être remplies
    protected $fillable = [
        'etudiant_id', // L'étudiant concerné
        'matiere_id',  // La matière concernée
        'note1',       // Première note (nullable)
        'note2',       // Deuxième note (nullable)
        'note3',       // Troisième note (nullable)
    ];

    // Une note appartient à un étudiant
    public function etudiant()
    {
        return $this->belongsTo(Etudiant::class);
    }

    // Une note appartient à une matière
    public function matiere()
    {
        return $this->belongsTo(Matiere::class);
    }
}