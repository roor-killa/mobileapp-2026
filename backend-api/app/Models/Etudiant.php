<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Etudiant extends Model
{
    protected $fillable = [
        'nom',
        'prenom',
        'email',
        'password',
        'classe_id',
    ];

    protected $hidden = [
        'password',
    ];

    // Un étudiant appartient à une classe
    public function classe()
    {
        return $this->belongsTo(Classe::class);
    }

    // Un étudiant a plusieurs notes
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