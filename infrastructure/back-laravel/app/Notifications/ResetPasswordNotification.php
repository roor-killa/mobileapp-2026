<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends Notification
{
    use Queueable;

    public function __construct(
        public string $token
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Réinitialisation de votre mot de passe - MyBank')
            ->line('Vous avez demandé une réinitialisation de mot de passe.')
            ->line('Utilisez le code suivant dans l\'application MyBank pour définir un nouveau mot de passe :')
            ->line('**' . $this->token . '**')
            ->line('Ce code expire dans 60 minutes.')
            ->line('Si vous n\'avez pas fait cette demande, ignorez cet email.');
    }
}
