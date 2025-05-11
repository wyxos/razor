<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Application>
 */
class ApplicationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => $this->faker->unique()->word(),
            'domain' => $this->faker->unique()->domainName(),
            'server_id' => \App\Models\Server::factory(),
            'repository' => $this->faker->url(),
            'branch' => $this->faker->word(),
            'path' => $this->faker->word(),
            'public_path' => $this->faker->word(),
        ];
    }
}
