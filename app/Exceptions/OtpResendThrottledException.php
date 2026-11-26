<?php

namespace App\Exceptions;

use Exception;

class OtpResendThrottledException extends Exception
{
    public function __construct()
    {
        parent::__construct('Kode OTP baru dapat dikirim setelah 60 detik.');
    }
}
