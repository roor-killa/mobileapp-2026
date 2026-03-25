import { Injectable } from '@nestjs/common';
import Stripe from 'stripe';

/**
 * Service Stripe pour les paiements par carte.
 * Crée des PaymentIntents et confirme les paiements.
 * Configurez STRIPE_SECRET_KEY dans .env
 */
@Injectable()
export class StripeService {
  private stripe: Stripe | null = null;

  constructor() {
    const secretKey = process.env.STRIPE_SECRET_KEY;
    if (secretKey) {
      this.stripe = new Stripe(secretKey);
    }
  }

  get isConfigured(): boolean {
    return this.stripe !== null;
  }

  /**
   * Crée un PaymentIntent pour un achat crypto.
   * @param amountEur Montant en euros
   * @param metadata userId, walletId, symbol pour le crédit après paiement
   */
  async createPaymentIntent(
    amountEur: number,
    metadata: { userId: string; walletId: string; symbol: string },
  ): Promise<{ clientSecret: string; paymentIntentId: string } | null> {
    if (!this.stripe) return null;
    const amountCents = Math.round(amountEur * 100);
    if (amountCents < 50) return null; // Stripe minimum ~0.50€
    const pi = await this.stripe.paymentIntents.create({
      amount: amountCents,
      currency: 'eur',
      metadata,
      automatic_payment_methods: { enabled: true },
    });
    return {
      clientSecret: pi.client_secret!,
      paymentIntentId: pi.id,
    };
  }

  /**
   * Vérifie qu'un paiement a réussi et retourne les métadonnées.
   */
  async verifyPaymentSucceeded(paymentIntentId: string): Promise<{
    userId: string;
    walletId: string;
    symbol: string;
    amountEur: number;
  } | null> {
    if (!this.stripe) return null;
    const pi = await this.stripe.paymentIntents.retrieve(paymentIntentId);
    if (pi.status !== 'succeeded') return null;
    const amountEur = (pi.amount_received || 0) / 100;
    return {
      userId: pi.metadata.userId,
      walletId: pi.metadata.walletId,
      symbol: pi.metadata.symbol,
      amountEur,
    };
  }
}
