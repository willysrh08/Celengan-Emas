<?php

namespace App\Exceptions;

use Exception;
use Throwable;

class OtpDeliveryFailedException extends Exception
{
    public function __construct(?Throwable $previous = null)
    {
        parent::__construct('Gagal mengirim kode OTP.', previous: $previous);
    }
}
