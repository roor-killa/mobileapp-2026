<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    // On autorise le remplissage de ces colonnes
    protected $fillable = ['user_id', 'type', 'montant', 'description'];
}