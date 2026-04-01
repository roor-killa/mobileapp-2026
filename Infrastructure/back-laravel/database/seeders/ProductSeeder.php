<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        Product::insert([
            ['product_name' => 'Ti punch', 'product_price' => 5.50, 'created_at' => now(), 'updated_at' => now()],
            ['product_name' => 'Rhum arrangé', 'product_price' => 8.00, 'created_at' => now(), 'updated_at' => now()],
            ['product_name' => 'Jus de goyave', 'product_price' => 3.50, 'created_at' => now(), 'updated_at' => now()],
            ['product_name' => 'Accras de morue', 'product_price' => 6.00, 'created_at' => now(), 'updated_at' => now()],
            ['product_name' => 'Bokits poulet', 'product_price' => 7.50, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}
