<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Classe extends Model
{
    protected $fillable = ['nom'];

    // Une classe a plusieurs étudiants
    public function etudiants()
    {
        return $this->hasMany(Etudiant::class);
    }
}