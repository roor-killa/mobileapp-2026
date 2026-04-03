<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Beneficiary;

class BeneficiaryPolicy
{
    public function update(User $user, Beneficiary $beneficiary): bool
    {
        return $user->id === $beneficiary->user_id;
    }

    public function delete(User $user, Beneficiary $beneficiary): bool
    {
        return $user->id === $beneficiary->user_id;
    }
}
