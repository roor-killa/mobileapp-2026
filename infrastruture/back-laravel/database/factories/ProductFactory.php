<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Product>
 */
class ProductFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->words(3, true),           // Ex: "Super Smart Phone"
            'description' => fake()->sentence(),        // Ex: "This is a great product."
            'price' => fake()->randomFloat(2, 10, 500), // Ex: 199.99
            'in_stock' => fake()->boolean(),            // Ex: true
        ];
    }
}
