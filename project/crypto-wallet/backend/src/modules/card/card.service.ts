import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../common/prisma.service';

/** Calcule le chiffre de contrôle Luhn pour un numéro de carte valide */
function luhnCheckDigit(partial: string): number {
  const digits = partial.split('').map(Number);
  let sum = 0;
  for (let i = digits.length - 1; i >= 0; i--) {
    let d = digits[i];
    if ((digits.length - i) % 2 === 0) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  return (10 - (sum % 10)) % 10;
}

/** Génère un numéro de carte Visa (4xxx) valide Luhn, déterministe à partir de userId */
function generateCardNumber(userId: string): string {
  const hash = crypto.createHash('sha256').update(userId).digest('hex');
  const digits = hash
    .split('')
    .map((c) => parseInt(c, 16) % 10)
    .join('')
    .substring(0, 15);
  const prefix = '4' + digits; // Visa commence par 4
  const check = luhnCheckDigit(prefix);
  return prefix + check;
}

/** Génère un CVC à 3 chiffres (100-999) déterministe */
function generateCvv(userId: string): string {
  const hash = crypto.createHash('sha256').update(userId + 'cvv').digest('hex');
  const n = parseInt(hash.substring(0, 3), 16) % 900 + 100;
  return n.toString();
}

/** Génère un PIN à 4 chiffres (1000-9999) déterministe */
function generatePin(userId: string): string {
  const hash = crypto.createHash('sha256').update(userId + 'pin').digest('hex');
  const n = parseInt(hash.substring(0, 4), 16) % 9000 + 1000;
  return n.toString();
}

/** Génère mois/année d'expiration (2 à 5 ans) déterministe */
function generateExpiry(userId: string): { month: number; year: number } {
  const hash = crypto.createHash('sha256').update(userId + 'exp').digest('hex');
  const month = (parseInt(hash.substring(0, 2), 16) % 12) + 1;
  const yearOffset = (parseInt(hash.substring(2, 4), 16) % 4) + 2; // 2 à 5 ans
  const year = new Date().getFullYear() % 100 + yearOffset;
  return { month, year };
}

@Injectable()
export class CardService {
  constructor(private prisma: PrismaService) {}

  async getOrCreateCard(userId: string) {
    let card = await this.prisma.userCard.findUnique({
      where: { userId },
    });

    if (!card) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
      });
      if (!user) return null;

      const cardNumber = generateCardNumber(userId);
      const last4 = cardNumber.slice(-4);
      const { month, year } = generateExpiry(userId);
      const cvv = generateCvv(userId);
      const pin = generatePin(userId);

      card = await this.prisma.userCard.create({
        data: {
          userId,
          cardNumber,
          last4,
          expiryMonth: month,
          expiryYear: year,
          cvv,
          pin,
        },
      });
    }

    return {
      cardNumber: card.cardNumber.replace(/(.{4})/g, '$1 ').trim(),
      last4: card.last4,
      expiryMonth: card.expiryMonth.toString().padStart(2, '0'),
      expiryYear: card.expiryYear.toString().padStart(2, '0'),
      expiry: `${card.expiryMonth.toString().padStart(2, '0')}/${card.expiryYear.toString().padStart(2, '0')}`,
      cvv: card.cvv,
      pin: card.pin,
      holderName: (await this.prisma.user.findUnique({ where: { id: userId } }))?.name?.toUpperCase() ?? 'TITULAIRE',
    };
  }
}
