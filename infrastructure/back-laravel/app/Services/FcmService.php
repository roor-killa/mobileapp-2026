<?php

namespace App\Services;

use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;

class FcmService
{
    public function __construct(private Messaging $messaging) {}

    public function sendToToken(string $token, string $title, string $body, array $data = []): void
    {
        try {
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(Notification::create($title, $body))
                ->withData(array_map('strval', $data));

            $this->messaging->send($message);
        } catch (\Throwable $e) {
            // Ne pas bloquer la transaction si la notification échoue
            Log::warning('FCM notification failed: ' . $e->getMessage());
        }
    }
}
