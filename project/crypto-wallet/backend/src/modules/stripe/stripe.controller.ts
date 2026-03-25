import { Body, Controller, Post, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { StripeService } from './stripe.service';
import { PrismaService } from '../../common/prisma.service';
import { Decimal } from '@prisma/client/runtime/library';

class CreateIntentDto {
  amountEur!: number;
  walletId!: string;
  symbol!: string;
}

class ConfirmDto {
  paymentIntentId!: string;
}

@Controller('payments')
@UseGuards(AuthGuard('appwrite-jwt'))
export class StripeController {
  constructor(
    private readonly stripe: StripeService,
    private readonly prisma: PrismaService,
  ) {}

  @Post('create-intent')
  async createIntent(
    @Request() req: { user: { userId: string } },
    @Body() dto: CreateIntentDto,
  ) {
    if (!this.stripe.isConfigured) {
      return { error: 'Stripe non configuré. Ajoutez STRIPE_SECRET_KEY dans .env' };
    }
    const amount = Number(dto.amountEur);
    if (amount < 0.5 || amount > 10000) {
      return { error: 'Montant invalide (0.50 - 10000 €)' };
    }
    const wallet = await this.prisma.wallet.findFirst({
      where: { id: dto.walletId, userId: req.user.userId },
    });
    if (!wallet) {
      return { error: 'Portefeuille introuvable' };
    }
    const result = await this.stripe.createPaymentIntent(amount * 1.015, {
      userId: req.user.userId,
      walletId: dto.walletId,
      symbol: dto.symbol,
    });
    if (!result) return { error: 'Impossible de créer le paiement' };
    return { clientSecret: result.clientSecret, paymentIntentId: result.paymentIntentId };
  }

  @Post('confirm')
  async confirm(
    @Request() req: { user: { userId: string } },
    @Body() dto: ConfirmDto,
  ) {
    if (!this.stripe.isConfigured) {
      return { error: 'Stripe non configuré' };
    }
    const verified = await this.stripe.verifyPaymentSucceeded(dto.paymentIntentId);
    if (!verified || verified.userId !== req.user.userId) {
      return { error: 'Paiement invalide ou non confirmé' };
    }
    const wallet = await this.prisma.wallet.findFirst({
      where: { id: verified.walletId, userId: req.user.userId },
    });
    if (!wallet) return { error: 'Portefeuille introuvable' };
    const amountEur = verified.amountEur;
    const fee = amountEur * 0.015;
    const netEur = amountEur - fee;
    const priceCache = await this.prisma.priceCache.findUnique({
      where: { symbol: verified.symbol },
    });
    const priceEur = priceCache ? Number(priceCache.priceEur) : 1;
    const cryptoAmount = netEur / priceEur;
    await this.prisma.transaction.create({
      data: {
        walletId: verified.walletId,
        chain: wallet.chain,
        type: 'receive',
        amount: new Decimal(cryptoAmount),
        tokenSymbol: verified.symbol,
        toAddress: wallet.address,
        fromAddress: 'stripe',
        status: 'confirmed',
      },
    });
    return { success: true, cryptoAmount, symbol: verified.symbol };
  }
}
