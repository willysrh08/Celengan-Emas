<?php

namespace Database\Factories;

use App\Models\OtpCode;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends Factory<OtpCode>
 */
class OtpCodeFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'target' => fake()->unique()->safeEmail(),
            'channel' => 'email',
            'code_hash' => Hash::make('123456'),
            'expires_at' => now()->addMinutes(5),
        ];
    }

    /**
     * @return Factory<OtpCode>
     */
    public function whatsapp(): Factory
    {
        return $this->state(fn (array $attributes): array => [
            'target' => '62'.fake()->numerify('##########'),
            'channel' => 'wa',
        ]);
    }

    /**
     * @return Factory<OtpCode>
     */
    public function expired(): Factory
    {
        return $this->state(fn (array $attributes): array => [
            'expires_at' => now()->subMinute(),
        ]);
    }
}
