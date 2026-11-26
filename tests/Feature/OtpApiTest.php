<?php

namespace Tests\Feature;

use App\Mail\OtpCodeMail;
use App\Models\OtpCode;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class OtpApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_send_otp_stores_hashed_code_and_sends_mail_for_email_target(): void
    {
        Mail::fake();

        $response = $this->postJson('/api/send-otp', [
            'target' => 'Aqwila@Example.com',
            'type' => 'email',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.target', 'aqwila@example.com')
            ->assertJsonPath('data.type', 'email')
            ->assertJsonPath('data.expires_in_seconds', 300);

        $otpCode = OtpCode::query()->where('target', 'aqwila@example.com')->firstOrFail();
        $sentCode = null;

        Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail) use (&$sentCode): bool {
            $sentCode = $mail->code;

            return $mail->hasTo('aqwila@example.com');
        });

        $this->assertIsString($sentCode);
        $this->assertMatchesRegularExpression('/^\d{6}$/', $sentCode);
        $this->assertSame(true, Hash::check($sentCode, $otpCode->code_hash));
        $this->assertSame('email', $otpCode->channel);
        $this->assertSame(0, $otpCode->attempts);
        $this->assertTrue($otpCode->expires_at->isAfter(now()->addMinutes(4)));
        $this->assertSame(1, OtpCode::count());
    }

    public function test_send_otp_normalizes_whatsapp_target_and_posts_to_fonnte(): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::response(['status' => true, 'detail' => 'success! message in queue']),
        ]);

        $response = $this->postJson('/api/send-otp', [
            'target' => '0812-3456-7890',
            'type' => 'wa',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.target', '6281234567890')
            ->assertJsonPath('data.type', 'wa');

        $this->assertDatabaseHas('otp_codes', [
            'target' => '6281234567890',
            'channel' => 'wa',
            'attempts' => 0,
        ]);

        Http::assertSent(function (HttpRequest $request): bool {
            return $request->url() === 'https://wa.example.test/send'
                && $request->isForm()
                && $request->hasHeader('Authorization', 'test-token')
                && $request['target'] === '6281234567890'
                && ! array_key_exists('to', $request->data())
                && ! array_key_exists('from', $request->data())
                && preg_match('/\b\d{6}\b/', (string) $request['message']) === 1;
        });
    }

    #[DataProvider('whatsappTargets')]
    public function test_send_otp_uses_one_canonical_target_for_storage_and_fonnte(string $input, string $expected): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::response(['status' => true]),
        ]);

        $response = $this->postJson('/api/send-otp', [
            'target' => $input,
            'type' => 'wa',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.target', $expected);

        $this->assertDatabaseHas('otp_codes', [
            'target' => $expected,
            'channel' => 'wa',
        ]);

        Http::assertSent(fn (HttpRequest $request): bool => $request['target'] === $expected);
    }

    /**
     * @return array<string, array{string, string}>
     */
    public static function whatsappTargets(): array
    {
        return [
            'plus prefix' => ['+62 812-3456-7890', '6281234567890'],
            'eight prefix' => ['81234567890', '6281234567890'],
        ];
    }

    public function test_send_otp_returns_502_when_whatsapp_gateway_is_unconfigured(): void
    {
        config()->set('services.whatsapp.endpoint', null);
        config()->set('services.whatsapp.token', null);

        Http::preventStrayRequests();

        $response = $this->postJson('/api/send-otp', [
            'target' => '6281234567890',
            'type' => 'wa',
        ]);

        $response->assertStatus(502)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Kode OTP gagal dikirim. Silakan coba lagi.');

        Http::assertNothingSent();
        $this->assertSame(0, OtpCode::count());
    }

    public function test_send_otp_returns_502_and_discards_code_when_whatsapp_gateway_fails(): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::response(['reason' => 'server down'], 500),
        ]);
        Log::spy();

        $response = $this->postJson('/api/send-otp', [
            'target' => '6281234567890',
            'type' => 'wa',
        ]);

        $response->assertStatus(502)
            ->assertExactJson([
                'success' => false,
                'message' => 'Kode OTP gagal dikirim. Silakan coba lagi.',
            ]);

        $this->assertSame(0, OtpCode::count());
        Http::assertSentCount(1);

        Log::shouldHaveReceived('error')->withArgs(function (string $message, array $context): bool {
            return str_contains($message, 'respons gagal')
                && ($context['http_status'] ?? null) === 500
                && ($context['reason'] ?? null) === 'server down';
        });
    }

    public function test_send_otp_returns_502_without_leaking_reason_when_fonnte_rejects(): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::response(['Status' => false, 'reason' => 'token invalid']),
        ]);
        Log::spy();

        $response = $this->postJson('/api/send-otp', [
            'target' => '6281234567890',
            'type' => 'wa',
        ]);

        $response->assertStatus(502)
            ->assertExactJson([
                'success' => false,
                'message' => 'Kode OTP gagal dikirim. Silakan coba lagi.',
            ]);

        $this->assertSame(0, OtpCode::count());
        Http::assertSentCount(1);

        Log::shouldHaveReceived('error')->withArgs(function (string $message, array $context): bool {
            return str_contains($message, 'menolak pengiriman')
                && ($context['reason'] ?? null) === 'token invalid'
                && ($context['target'] ?? null) === '6281234567890'
                && ! str_contains(json_encode($context), 'test-token');
        });
    }

    public function test_send_otp_returns_502_when_fonnte_reports_inactive_device(): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::response([
                'status' => true,
                'reason' => 'device not connected',
            ]),
        ]);
        Log::spy();

        $response = $this->postJson('/api/send-otp', [
            'target' => '081234567890',
            'type' => 'wa',
        ]);

        $response->assertStatus(502)
            ->assertExactJson([
                'success' => false,
                'message' => 'Kode OTP gagal dikirim. Silakan coba lagi.',
            ]);

        $this->assertSame(0, OtpCode::count());
        Http::assertSentCount(1);

        Log::shouldHaveReceived('error')->withArgs(function (string $message, array $context): bool {
            return str_contains($message, 'menolak pengiriman')
                && ($context['reason'] ?? null) === 'device not connected'
                && ($context['target'] ?? null) === '6281234567890';
        });
    }

    public function test_send_otp_returns_502_when_fonnte_returns_non_json_error(): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::response('Invalid token', 200, ['Content-Type' => 'text/plain']),
        ]);
        Log::spy();

        $response = $this->postJson('/api/send-otp', [
            'target' => '6281234567890',
            'type' => 'wa',
        ]);

        $response->assertStatus(502)
            ->assertExactJson([
                'success' => false,
                'message' => 'Kode OTP gagal dikirim. Silakan coba lagi.',
            ]);

        $this->assertSame(0, OtpCode::count());

        Log::shouldHaveReceived('error')->withArgs(function (string $message, array $context): bool {
            return str_contains($message, 'menolak pengiriman')
                && ($context['reason'] ?? null) === 'Invalid token';
        });
    }

    public function test_send_otp_returns_502_when_whatsapp_gateway_connection_fails(): void
    {
        config()->set('services.whatsapp.endpoint', 'https://wa.example.test/send');
        config()->set('services.whatsapp.token', 'test-token');

        Http::fake([
            'wa.example.test/*' => Http::failedConnection(),
        ]);

        $response = $this->postJson('/api/send-otp', [
            'target' => '6281234567890',
            'type' => 'wa',
        ]);

        $response->assertStatus(502)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Kode OTP gagal dikirim. Silakan coba lagi.');

        $this->assertSame(0, OtpCode::count());
        Http::assertSentCount(1);
    }

    public function test_send_otp_returns_502_when_email_mailer_is_log(): void
    {
        config()->set('mail.default', 'log');
        Mail::fake();

        $response = $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ]);

        $response->assertStatus(502)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Kode OTP gagal dikirim. Silakan coba lagi.');

        Mail::assertNothingSent();
        $this->assertSame(0, OtpCode::count());
    }

    public function test_send_otp_returns_422_for_invalid_email_target(): void
    {
        $response = $this->postJson('/api/send-otp', [
            'target' => 'bukan-email',
            'type' => 'email',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors('target')
            ->assertJsonPath('errors.target.0', 'Format alamat email tidak valid.');

        $this->assertSame(0, OtpCode::count());
    }

    public function test_send_otp_returns_422_for_invalid_whatsapp_target(): void
    {
        $response = $this->postJson('/api/send-otp', [
            'target' => '12345',
            'type' => 'wa',
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors('target')
            ->assertJsonPath('errors.target.0', 'Nomor WhatsApp tidak valid. Gunakan 10–15 digit angka.');

        $this->assertSame(0, OtpCode::count());
    }

    public function test_send_otp_returns_422_for_unsupported_type(): void
    {
        $response = $this->postJson('/api/send-otp', [
            'target' => '6281234567890',
            'type' => 'sms',
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors('type')
            ->assertJsonPath('errors.type.0', 'Metode OTP tidak didukung.');
    }

    public function test_send_otp_returns_422_for_empty_payload(): void
    {
        $this->postJson('/api/send-otp', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['target', 'type']);
    }

    public function test_send_otp_returns_429_when_resend_is_requested_within_cooldown(): void
    {
        Mail::fake();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $response = $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ]);

        $response->assertStatus(429)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Kode OTP baru dapat dikirim setelah 60 detik.');

        $this->assertSame(1, OtpCode::count());
        Mail::assertSentCount(1);
    }

    public function test_send_otp_replaces_previous_code_after_cooldown(): void
    {
        Mail::fake();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $firstId = OtpCode::query()->firstOrFail()->id;

        $this->travel(61)->seconds();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $this->assertSame(1, OtpCode::count());
        $this->assertNotSame($firstId, OtpCode::query()->firstOrFail()->id);
        Mail::assertSentCount(2);
    }

    public function test_verify_otp_accepts_valid_code_and_consumes_it(): void
    {
        Mail::fake();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $sentCode = null;
        Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail) use (&$sentCode): bool {
            $sentCode = $mail->code;

            return true;
        });
        $this->assertIsString($sentCode);

        $response = $this->postJson('/api/verify-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
            'code' => $sentCode,
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.verified', true)
            ->assertJsonPath('data.target', 'aqwila@example.com');

        $this->assertNotNull(OtpCode::query()->firstOrFail()->consumed_at);
    }

    public function test_verify_otp_returns_422_for_wrong_code_and_increments_attempts(): void
    {
        Mail::fake();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $sentCode = null;
        Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail) use (&$sentCode): bool {
            $sentCode = $mail->code;

            return true;
        });
        $this->assertIsString($sentCode);
        $wrongCode = $sentCode === '000000' ? '111111' : '000000';

        $response = $this->postJson('/api/verify-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
            'code' => $wrongCode,
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors('code')
            ->assertJsonPath('errors.code.0', 'Kode OTP tidak valid atau sudah kadaluarsa.');

        $this->assertSame(1, OtpCode::query()->firstOrFail()->attempts);
        $this->assertNull(OtpCode::query()->firstOrFail()->consumed_at);
    }

    public function test_verify_otp_returns_422_for_expired_code(): void
    {
        Mail::fake();
        $this->travelTo('2026-01-01 00:00:00');

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $sentCode = null;
        Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail) use (&$sentCode): bool {
            $sentCode = $mail->code;

            return true;
        });

        $this->travel(6)->minutes();

        $this->postJson('/api/verify-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
            'code' => $sentCode,
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('code');

        $this->assertNull(OtpCode::query()->firstOrFail()->consumed_at);
    }

    public function test_verify_otp_returns_422_for_already_consumed_code(): void
    {
        Mail::fake();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $sentCode = null;
        Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail) use (&$sentCode): bool {
            $sentCode = $mail->code;

            return true;
        });

        $payload = [
            'target' => 'aqwila@example.com',
            'type' => 'email',
            'code' => $sentCode,
        ];

        $this->postJson('/api/verify-otp', $payload)->assertOk();

        $this->postJson('/api/verify-otp', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors('code');
    }

    public function test_verify_otp_returns_422_after_too_many_wrong_attempts(): void
    {
        Mail::fake();

        $this->postJson('/api/send-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
        ])->assertOk();

        $sentCode = null;
        Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail) use (&$sentCode): bool {
            $sentCode = $mail->code;

            return true;
        });

        $this->assertIsString($sentCode);
        $wrongCode = $sentCode === '000000' ? '111111' : '000000';

        for ($attempt = 0; $attempt < 5; $attempt++) {
            $this->postJson('/api/verify-otp', [
                'target' => 'aqwila@example.com',
                'type' => 'email',
                'code' => $wrongCode,
            ])->assertUnprocessable();
        }

        $this->postJson('/api/verify-otp', [
            'target' => 'aqwila@example.com',
            'type' => 'email',
            'code' => $sentCode,
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('code');

        $this->assertSame(5, OtpCode::query()->firstOrFail()->attempts);
        $this->assertNull(OtpCode::query()->firstOrFail()->consumed_at);
    }

    public function test_verify_otp_returns_422_for_empty_payload(): void
    {
        $this->postJson('/api/verify-otp', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['target', 'type', 'code']);
    }
}
