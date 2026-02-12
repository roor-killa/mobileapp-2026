<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WeatherData extends Model
{
    protected $table = 'weather_data';
    
    protected $fillable = [
        'city',
        'country',
        'temperature',
        'description',
        'icon',
        'humidity',
        'wind_speed',
        'pressure',
        'feels_like',
    ];

    protected $casts = [
        'temperature' => 'float',
        'wind_speed' => 'float',
        'feels_like' => 'float',
    ];
}