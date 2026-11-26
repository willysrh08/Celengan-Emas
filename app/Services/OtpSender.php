<?php

namespace App\Services;

interface OtpSender
{
    public function send(string $target, string $code): void;
}
