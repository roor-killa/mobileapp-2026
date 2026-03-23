<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class TransferNotification extends Mailable
{
    use Queueable, SerializesModels;

    public $amount;
    public $receiverName;

    public function __construct($amount, $receiverName)
    {
        $this->amount = $amount;
        $this->receiverName = $receiverName;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Confirmation de votre virement - FirstApp',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.transfer_confirmation',
        );
    }
}