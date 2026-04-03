<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExchangeRate extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'from_currency',
        'to_currency',
        'rate',
        'margin',
        'updated_at',
    ];

    protected $casts = [
        'rate' => 'decimal:8',
        'margin' => 'decimal:2',
        'updated_at' => 'datetime',
    ];
}
