<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_user_with_hashed_password_and_returns_201(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Aqwila Pratama',
            'email' => 'aqwila@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.name', 'Aqwila Pratama')
            ->assertJsonPath('data.user.email', 'aqwila@example.com')
            ->assertJsonMissingPath('data.user.password');

        $user = User::where('email', 'aqwila@example.com')->firstOrFail();

        $this->assertModelExists($user);
        $this->assertSame(true, Hash::check('password123', $user->password));
    }

    public function test_register_returns_422_for_duplicate_email(): void
    {
        User::factory()->create(['email' => 'taken@example.com']);

        $response = $this->postJson('/api/register', [
            'name' => 'Aqwila Pratama',
            'email' => 'taken@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors('email')
            ->assertJsonPath('errors.email.0', 'Alamat email sudah terdaftar.');

        $this->assertSame(1, User::count());
    }

    public function test_register_returns_422_when_password_confirmation_mismatches(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Aqwila Pratama',
            'email' => 'aqwila@example.com',
            'password' => 'password123',
            'password_confirmation' => 'different-password',
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors('password')
            ->assertJsonPath('errors.password.0', 'Konfirmasi password tidak cocok.');

        $this->assertSame(0, User::count());
    }

    public function test_register_returns_422_for_empty_payload(): void
    {
        $response = $this->postJson('/api/register', []);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'email', 'password']);
    }

    public function test_login_issues_sanctum_token_and_returns_user(): void
    {
        $user = User::factory()->create([
            'email' => 'aqwila@example.com',
            'password' => 'secret123',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'aqwila@example.com',
            'password' => 'secret123',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $user->id)
            ->assertJsonPath('data.token_type', 'Bearer')
            ->assertJsonMissingPath('data.user.password');

        $this->assertIsString($response->json('data.token'));
        $this->assertSame(1, $user->tokens()->count());
    }

    #[DataProvider('invalidCredentials')]
    public function test_login_returns_422_for_invalid_credentials(string $email, string $password): void
    {
        $user = User::factory()->create([
            'email' => 'registered@example.com',
            'password' => 'secret123',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $email,
            'password' => $password,
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors('email')
            ->assertJsonPath('errors.email.0', 'Email atau password yang diberikan tidak benar.');

        $this->assertSame(0, $user->tokens()->count());
    }

    /**
     * @return array<string, array{string, string}>
     */
    public static function invalidCredentials(): array
    {
        return [
            'wrong password' => ['registered@example.com', 'wrong-password'],
            'unknown email' => ['unknown@example.com', 'secret123'],
        ];
    }

    public function test_login_returns_422_for_empty_payload(): void
    {
        $response = $this->postJson('/api/login', []);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['email', 'password']);
    }

    public function test_user_returns_authenticated_user_for_valid_token(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test-device')->plainTextToken;

        $response = $this->withToken($token)->getJson('/api/user');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $user->id)
            ->assertJsonPath('data.user.email', $user->email)
            ->assertJsonMissingPath('data.user.password');
    }

    public function test_user_returns_401_without_token(): void
    {
        $response = $this->getJson('/api/user');

        $response->assertUnauthorized()
            ->assertJsonPath('success', false);
    }

    public function test_user_returns_401_json_without_accept_header(): void
    {
        $response = $this->get('/api/user');

        $response->assertUnauthorized()
            ->assertJsonPath('success', false);
    }

    public function test_user_returns_401_for_revoked_token(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test-device')->plainTextToken;
        $user->tokens()->delete();

        $this->withToken($token)->getJson('/api/user')->assertUnauthorized();
    }

    public function test_logout_revokes_only_the_current_token(): void
    {
        $user = User::factory()->create();
        $currentToken = $user->createToken('current-device')->plainTextToken;
        $user->createToken('other-device')->plainTextToken;

        $response = $this->withToken($currentToken)->postJson('/api/logout');

        $response->assertOk()
            ->assertJsonPath('success', true);

        $this->assertSame(0, $user->tokens()->where('name', 'current-device')->count());
        $this->assertSame(1, $user->tokens()->where('name', 'other-device')->count());
    }

    public function test_logout_makes_the_token_unusable(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('current-device')->plainTextToken;

        $this->withToken($token)->postJson('/api/logout')->assertOk();

        // The auth guard caches the resolved user between simulated requests in one test.
        Auth::forgetGuards();

        $this->withToken($token)->getJson('/api/user')->assertUnauthorized();
    }

    public function test_logout_returns_401_without_token(): void
    {
        $response = $this->postJson('/api/logout');

        $response->assertUnauthorized()
            ->assertJsonPath('success', false);
    }
}
