<?php

namespace App\Services;

use App\Mail\OtpCodeMail;
use Illuminate\Support\Facades\Mail;
use RuntimeException;

class EmailOtpSender implements OtpSender
{
    public function send(string $target, string $code): void
    {
        if (config('mail.default') === 'log') {
            throw new RuntimeException('Mailer log tidak dapat digunakan untuk mengirim OTP email.');
        }

        Mail::to($target)->send(new OtpCodeMail($code));
    }
}
