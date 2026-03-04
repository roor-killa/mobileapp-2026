<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Etudiant extends Model {
    
    // Les champs que l'on autorise à remplir depuis l'API
    // Sans ça, Laravel bloque l'insertion pour des raisons de sécurité
    protected $fillable = ['nom', 'prenom', 'email', 'note'];
}