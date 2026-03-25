<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Utilisateur NodEX - mappe la table "User" créée par Prisma.
 */
class NodexUser extends Model
{
    protected $table = 'User';

    /** Obligatoire pour PostgreSQL + UUID : sinon Laravel caste l’id en entier (virements / carte cassés). */
    protected $keyType = 'string';

    public $incrementing = false;

    protected $fillable = ['id', 'email', 'passwordHash', 'name', 'pseudonym', 'iban', 'appwriteId', 'balanceEur'];

    protected $casts = [
        'balanceEur' => 'decimal:2',
    ];

    public $timestamps = true;
    const CREATED_AT = 'createdAt';
    const UPDATED_AT = 'updatedAt';

    /** IBAN de démo déterministe (même logique que le middleware EnsureNodexUser). */
    public static function syntheticIbanForAppwriteId(string $appwriteId): string
    {
        $hash = hash('sha256', $appwriteId.'iban');
        $digits = preg_replace('/\D/', '', $hash);
        if (strlen($digits) < 11) {
            $digits = str_pad($digits, 11, '0');
        }

        return 'FR76 3000 6000 01'.substr($digits, 0, 11).'00';
    }

    public static function syntheticPseudonymForAppwriteId(string $appwriteId): string
    {
        return 'nodex_'.substr(md5($appwriteId), 0, 12);
    }

    /**
     * Complète IBAN / pseudonyme si la ligne User existait sans (anciennes données ou import).
     */
    public function ensureSyntheticBankingFilled(): void
    {
        $dirty = false;
        if (! $this->iban || trim((string) $this->iban) === '') {
            $this->iban = self::syntheticIbanForAppwriteId($this->appwriteId);
            $dirty = true;
        }
        if (! $this->pseudonym || trim((string) $this->pseudonym) === '') {
            $this->pseudonym = self::syntheticPseudonymForAppwriteId($this->appwriteId);
            $dirty = true;
        }
        if ($dirty) {
            $this->save();
        }
    }
}
