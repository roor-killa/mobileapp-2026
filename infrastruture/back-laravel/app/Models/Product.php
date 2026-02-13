<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory; // <--- Ligne 1
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory; // <--- Ligne 2 (C'est celle qui manquait)

    // On autorise le remplissage de ces champs
    protected $fillable = ['name', 'description', 'price', 'in_stock'];
}
