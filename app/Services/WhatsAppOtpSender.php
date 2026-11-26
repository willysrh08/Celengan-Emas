<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class WhatsAppOtpSender implements OtpSender
{
    public function send(string $target, string $code): void
    {
        $endpoint = config('services.whatsapp.endpoint');
        $token = config('services.whatsapp.token');

        if (! is_string($endpoint) || filter_var($endpoint, FILTER_VALIDATE_URL) === false) {
            throw new RuntimeException('WHATSAPP_ENDPOINT belum dikonfigurasi dengan benar.');
        }

        if (! is_string($token) || $token === '') {
            throw new RuntimeException('WHATSAPP_TOKEN belum dikonfigurasi.');
        }

        $normalizedTarget = $this->normalizeTarget($target);
        $logContext = [
            'endpoint' => $endpoint,
            'target' => $normalizedTarget,
        ];

        try {
            $response = Http::asForm()
                ->withHeaders(['Authorization' => $token])
                ->connectTimeout((int) config('services.whatsapp.connect_timeout', 3))
                ->timeout((int) config('services.whatsapp.timeout', 10))
                ->post($endpoint, [
                    'target' => $normalizedTarget,
                    'message' => $this->message($code),
                ]);
        } catch (ConnectionException $exception) {
            Log::error('Gagal terhubung ke gateway WhatsApp.', $logContext + [
                'error' => $this->redact($exception->getMessage()),
            ]);

            throw new RuntimeException('Gagal terhubung ke gateway WhatsApp.', previous: $exception);
        }

        if (! $response->successful()) {
            $reason = $this->failureReason($response);

            Log::error('Gateway WhatsApp mengembalikan respons gagal.', $logContext + [
                'http_status' => $response->status(),
                'reason' => $reason,
            ]);

            throw new RuntimeException(sprintf(
                'Gateway WhatsApp mengembalikan HTTP %d%s.',
                $response->status(),
                $reason === null ? '' : ': '.$reason,
            ));
        }

        $reason = $this->rejectionReason($response);

        if ($reason !== null) {
            Log::error('Gateway WhatsApp menolak pengiriman OTP.', $logContext + [
                'reason' => $reason,
            ]);

            throw new RuntimeException('Gateway WhatsApp menolak pengiriman OTP: '.$reason);
        }
    }

    private function normalizeTarget(string $target): string
    {
        $digits = preg_replace('/\D+/', '', $target) ?? '';

        if (str_starts_with($digits, '0')) {
            return '62'.substr($digits, 1);
        }

        if (str_starts_with($digits, '8')) {
            return '62'.$digits;
        }

        return $digits;
    }

    private function message(string $code): string
    {
        return sprintf(
            'Kode verifikasi Celengan Emas Anda: %s. Berlaku %d menit. Jangan bagikan kode ini.',
            $code,
            OtpService::EXPIRY_MINUTES,
        );
    }

    private function rejectionReason(Response $response): ?string
    {
        $payload = $this->payload($response);
        $status = $payload['status'] ?? $payload['success'] ?? null;
        $isRejected = $status === false
            || (is_string($status) && in_array(mb_strtolower($status), ['error', 'failed', 'failure', 'false', 'gagal'], true));

        if (! $isRejected) {
            $reason = $this->reasonFrom($payload);

            if ($reason !== null && $this->isFailureReason($reason)) {
                return $reason;
            }

            $deviceStatus = $payload['device_status'] ?? null;

            if (is_string($deviceStatus) && in_array(mb_strtolower($deviceStatus), ['disconnect', 'disconnected', 'inactive', 'offline'], true)) {
                return $this->reasonFrom($payload) ?? 'Perangkat WhatsApp gateway tidak aktif.';
            }

            if ($payload === []) {
                return $this->reasonFromBody($response);
            }

            return null;
        }

        return $this->reasonFrom($payload) ?? $this->reasonFromBody($response) ?? 'Status pengiriman ditolak gateway.';
    }

    private function failureReason(Response $response): ?string
    {
        return $this->reasonFrom($this->payload($response)) ?? $this->reasonFromBody($response);
    }

    /**
     * Fonnte mixes `status` and `Status` in its responses, so keys are lowered first.
     *
     * @return array<string, mixed>
     */
    private function payload(Response $response): array
    {
        $payload = $response->json();

        return is_array($payload) ? array_change_key_case($payload, CASE_LOWER) : [];
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function reasonFrom(array $payload): ?string
    {
        foreach (['reason', 'message', 'detail', 'error'] as $key) {
            $value = $payload[$key] ?? null;

            if (is_string($value) && $value !== '') {
                return $this->redact($value);
            }
        }

        return null;
    }

    private function reasonFromBody(Response $response): ?string
    {
        $body = trim($response->body());

        if ($body === '' || mb_strlen($body) > 500) {
            return null;
        }

        return $this->redact($body);
    }

    private function isFailureReason(string $reason): bool
    {
        return preg_match(
            '/device\s+(?:not\s+(?:connected|active|ready)|disconnected|inactive|offline)|'
            .'(?:not|never)\s+connected|invalid\s+token|token\s+(?:invalid|expired)|'
            .'quota\s+(?:exceeded|habis)|insufficient\s+balance|gagal|failed/i',
            $reason,
        ) === 1;
    }

    /**
     * Keep credentials out of logs even if the gateway echoes them back.
     */
    private function redact(string $value): string
    {
        $token = config('services.whatsapp.token');

        if (! is_string($token) || $token === '') {
            return $value;
        }

        return str_replace($token, '[REDACTED]', $value);
    }
}
