<?php

namespace App\Http\Controllers;

use App\Exceptions\OtpDeliveryFailedException;
use App\Exceptions\OtpResendThrottledException;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\SendOtpRequest;
use App\Http\Requests\VerifyOtpRequest;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    private const TOKEN_NAME = 'celengan-emas-mobile';

    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create($request->safe()->only(['name', 'email', 'password']));

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil dibuat.',
            'data' => [
                'user' => $this->userPayload($user),
            ],
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = $request->safe()->only(['email', 'password']);
        $user = User::where('email', $credentials['email'])->first();

        if ($user === null || ! Hash::check($credentials['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password yang diberikan tidak benar.'],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => [
                'user' => $this->userPayload($user),
                'token' => $user->createToken(self::TOKEN_NAME)->plainTextToken,
                'token_type' => 'Bearer',
            ],
        ]);
    }

    public function sendOtp(SendOtpRequest $request, OtpService $otpService): JsonResponse
    {
        $data = $request->safe()->only(['target', 'type']);

        try {
            $otpService->send($data['target'], $data['type']);
        } catch (OtpResendThrottledException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 429);
        } catch (OtpDeliveryFailedException $exception) {
            report($exception);

            return response()->json([
                'success' => false,
                'message' => 'Kode OTP gagal dikirim. Silakan coba lagi.',
            ], 502);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP dikirim ke '.$data['target'].'.',
            'data' => [
                'target' => $data['target'],
                'type' => $data['type'],
                'expires_in_seconds' => OtpService::EXPIRY_MINUTES * 60,
            ],
        ]);
    }

    public function verifyOtp(VerifyOtpRequest $request, OtpService $otpService): JsonResponse
    {
        $data = $request->safe()->only(['target', 'type', 'code']);

        if (! $otpService->verify($data['target'], $data['type'], $data['code'])) {
            throw ValidationException::withMessages([
                'code' => ['Kode OTP tidak valid atau sudah kadaluarsa.'],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP berhasil diverifikasi.',
            'data' => [
                'verified' => true,
                'target' => $data['target'],
                'type' => $data['type'],
            ],
        ]);
    }

    public function user(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        return response()->json([
            'success' => true,
            'message' => 'Data pengguna berhasil dimuat.',
            'data' => [
                'user' => $this->userPayload($user),
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }

    /**
     * @return array{id: int, name: string, email: string}
     */
    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
        ];
    }
}
