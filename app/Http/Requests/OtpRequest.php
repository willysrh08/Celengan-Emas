<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

abstract class OtpRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'target' => ['required', 'string', 'max:255'],
            'type' => ['required', Rule::in(['wa', 'email'])],
        ];
    }

    /**
     * Get the error messages for the defined validation rules.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'target.required' => 'Tujuan OTP wajib diisi.',
            'type.required' => 'Metode OTP wajib diisi.',
            'type.in' => 'Metode OTP tidak didukung.',
        ];
    }

    /**
     * Normalize the destination so sending and verification use one canonical value.
     */
    protected function prepareForValidation(): void
    {
        $target = $this->input('target');

        if (! is_string($target)) {
            return;
        }

        $target = trim($target);

        if ($this->input('type') === 'wa') {
            $digits = preg_replace('/\D+/', '', $target) ?? '';

            if (str_starts_with($digits, '0')) {
                $digits = '62'.substr($digits, 1);
            } elseif (str_starts_with($digits, '8')) {
                $digits = '62'.$digits;
            }

            $this->merge(['target' => $digits]);

            return;
        }

        $this->merge(['target' => mb_strtolower($target)]);
    }

    /**
     * Validate the destination against the selected channel.
     *
     * @return array<int, \Closure>
     */
    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if ($validator->errors()->isNotEmpty()) {
                    return;
                }

                $target = (string) $this->input('target');

                if ($this->input('type') === 'email' && filter_var($target, FILTER_VALIDATE_EMAIL) === false) {
                    $validator->errors()->add('target', 'Format alamat email tidak valid.');
                }

                if ($this->input('type') === 'wa' && preg_match('/^\d{10,15}$/', $target) !== 1) {
                    $validator->errors()->add('target', 'Nomor WhatsApp tidak valid. Gunakan 10–15 digit angka.');
                }
            },
        ];
    }
}
