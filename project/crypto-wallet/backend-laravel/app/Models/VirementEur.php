<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

/**
 * Virement EUR - mappe la table "VirementEur" (Prisma / PostgreSQL).
 */
class VirementEur extends Model
{
    protected $table = 'VirementEur';

    protected $keyType = 'string';

    public $incrementing = false;

    protected $fillable = ['id', 'fromUserId', 'toUserId', 'amount'];

    protected $casts = [
        'amount' => 'decimal:2',
        'createdAt' => 'datetime',
    ];

    public $timestamps = true;

    const CREATED_AT = 'createdAt';

    const UPDATED_AT = null;

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
        });
    }
}
