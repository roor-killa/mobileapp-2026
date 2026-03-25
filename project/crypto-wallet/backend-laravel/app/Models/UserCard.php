<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

/**
 * Carte virtuelle NodEX - mappe la table "UserCard" (même schéma que Prisma).
 */
class UserCard extends Model
{
    protected $table = 'UserCard';

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = ['userId', 'cardNumber', 'last4', 'expiryMonth', 'expiryYear', 'cvv', 'pin'];

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

    public function user()
    {
        return $this->belongsTo(NodexUser::class, 'userId', 'id');
    }
}
