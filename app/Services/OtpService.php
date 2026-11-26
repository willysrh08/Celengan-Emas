<?php

namespace App\Services;

use App\Exceptions\OtpDeliveryFailedException;
use App\Exceptions\OtpResendThrottledException;
use App\Models\OtpCode;
use Illuminate\Support\Facades\Hash;
use InvalidArgumentException;
use Throwable;

class OtpService
{
    public const CODE_LENGTH = 6;

    public const EXPIRY_MINUTES = 5;

    public const RESEND_COOLDOWN_SECONDS = 60;

    public const MAX_ATTEMPTS = 5;

    public function __construct(
        private readonly EmailOtpSender $emailSender,
        private readonly WhatsAppOtpSender $whatsAppSender,
    ) {}

    /**
     * Generate, persist and deliver a fresh OTP for the given destination.
     *
     * @param  'wa'|'email'  $channel
     */
    public function send(string $target, string $channel): void
    {
        $latestCode = OtpCode::query()
            ->where('target', $target)
            ->where('channel', $channel)
            ->latest()
            ->first();

        if (
            $latestCode !== null
            && $latestCode->created_at->greaterThan(now()->subSeconds(self::RESEND_COOLDOWN_SECONDS))
        ) {
            throw new OtpResendThrottledException;
        }

        $code = str_pad(
            (string) random_int(0, 999999),
            self::CODE_LENGTH,
            '0',
            STR_PAD_LEFT,
        );

        OtpCode::query()
            ->where('target', $target)
            ->where('channel', $channel)
            ->whereNull('consumed_at')
            ->delete();

        $otpCode = OtpCode::create([
            'target' => $target,
            'channel' => $channel,
            'code_hash' => Hash::make($code),
            'expires_at' => now()->addMinutes(self::EXPIRY_MINUTES),
        ]);

        try {
            $this->senderFor($channel)->send($target, $code);
        } catch (Throwable $exception) {
            $otpCode->delete();

            throw new OtpDeliveryFailedException(previous: $exception);
        }
    }

    /**
     * Compare a submitted code with the latest active OTP and consume it on success.
     *
     * @param  'wa'|'email'  $channel
     */
    public function verify(string $target, string $channel, string $code): bool
    {
        $otpCode = OtpCode::query()
            ->where('target', $target)
            ->where('channel', $channel)
            ->whereNull('consumed_at')
            ->latest()
            ->first();

        if (
            $otpCode === null
            || $otpCode->expires_at->isPast()
            || $otpCode->attempts >= self::MAX_ATTEMPTS
        ) {
            return false;
        }

        if (! Hash::check($code, $otpCode->code_hash)) {
            $otpCode->increment('attempts');

            return false;
        }

        return OtpCode::query()
            ->where('id', $otpCode->id)
            ->whereNull('consumed_at')
            ->update(['consumed_at' => now()]) === 1;
    }

    /**
     * @param  'wa'|'email'  $channel
     */
    private function senderFor(string $channel): OtpSender
    {
        return match ($channel) {
            'email' => $this->emailSender,
            'wa' => $this->whatsAppSender,
            default => throw new InvalidArgumentException('Metode OTP tidak didukung.'),
        };
    }
}
