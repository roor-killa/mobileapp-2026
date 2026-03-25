import { Injectable, OnModuleInit } from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../common/prisma.service';

function generateIban(userId: string): string {
  const hash = crypto.createHash('sha256').update(userId).digest('hex');
  const digits = hash
    .substring(0, 11)
    .split('')
    .map((c) => parseInt(c, 16) % 10)
    .join('');
  return `FR76 3000 6000 01${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 11)}`;
}

function generatePseudonym(name: string, userId: string): string {
  const clean = (name || '')
    .trim()
    .replace(/\s+/g, '')
    .replace(/[^a-zA-Z0-9]/g, '')
    .substring(0, 6);
  const suffix = userId.replace(/-/g, '').substring(0, 4);
  return (clean.length >= 2 ? clean : 'User') + suffix;
}

@Injectable()
export class VirementsBackfillService implements OnModuleInit {
  constructor(private prisma: PrismaService) {}

  async onModuleInit() {
    try {
      const users = await this.prisma.user.findMany({
        where: { OR: [{ iban: null }, { pseudonym: null }] },
      });
      for (const u of users) {
        const iban = generateIban(u.id);
        const pseudonym = generatePseudonym(u.name, u.id);
        await this.prisma.user.update({
          where: { id: u.id },
          data: { iban, pseudonym },
        });
      }
      if (users.length > 0) {
        console.log(`[Virements] ${users.length} utilisateur(s) mis à jour avec IBAN et pseudonyme`);
      }
    } catch (e) {
      console.warn('[Virements] Backfill IBAN/pseudonyme:', e);
    }
  }
}
