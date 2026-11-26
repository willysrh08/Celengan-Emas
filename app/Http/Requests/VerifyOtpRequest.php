<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;

class VerifyOtpRequest extends OtpRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            ...parent::rules(),
            'code' => ['required', 'string', 'regex:/^\d{6}$/'],
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
            ...parent::messages(),
            'code.required' => 'Kode OTP wajib diisi.',
            'code.regex' => 'Kode OTP harus 6 digit angka.',
        ];
    }
}
