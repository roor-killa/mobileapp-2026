import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class VirementsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Récupère le solde EUR, l'IBAN et le pseudonyme de l'utilisateur.
   */
  async getMeInfo(userId: string): Promise<{
    balanceEur: number;
    iban: string | null;
    pseudonym: string | null;
  }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { balanceEur: true, iban: true, pseudonym: true },
    });
    if (!user) throw new NotFoundException('Utilisateur introuvable');
    return {
      balanceEur: Number(user.balanceEur),
      iban: user.iban,
      pseudonym: user.pseudonym,
    };
  }

  /**
   * Historique des virements (envoyés et reçus).
   */
  async getHistory(userId: string): Promise<
    Array<{ id: string; type: 'sent' | 'received'; amount: number; date: string; otherPseudonym?: string }>
  > {
    const sent = await this.prisma.virementEur.findMany({
      where: { fromUserId: userId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
    const received = await this.prisma.virementEur.findMany({
      where: { toUserId: userId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
    const fromIds = [...new Set(sent.map((s) => s.toUserId).concat(received.map((r) => r.fromUserId)))];
    const users = await this.prisma.user.findMany({
      where: { id: { in: fromIds } },
      select: { id: true, pseudonym: true },
    });
    const userMap = new Map(users.map((u) => [u.id, u.pseudonym ?? '']));
    const result: Array<{ id: string; type: 'sent' | 'received'; amount: number; date: string; otherPseudonym?: string }> = [];
    for (const s of sent) {
      result.push({
        id: s.id,
        type: 'sent',
        amount: Number(s.amount),
        date: s.createdAt.toISOString(),
        otherPseudonym: userMap.get(s.toUserId) ?? undefined,
      });
    }
    for (const r of received) {
      result.push({
        id: r.id,
        type: 'received',
        amount: Number(r.amount),
        date: r.createdAt.toISOString(),
        otherPseudonym: userMap.get(r.fromUserId) ?? undefined,
      });
    }
    result.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    return result.slice(0, 20);
  }

  /**
   * Récupère le solde EUR de l'utilisateur.
   */
  async getBalance(userId: string): Promise<{ balanceEur: number }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { balanceEur: true },
    });
    if (!user) throw new NotFoundException('Utilisateur introuvable');
    return {
      balanceEur: Number(user.balanceEur),
    };
  }

  /**
   * Envoie des EUR à un autre utilisateur NodEX (identifié par IBAN, pseudonyme ou email).
   */
  async sendToUser(
    fromUserId: string,
    toIdentifier: string,
    amount: number,
  ): Promise<{ success: true; newBalance: number; recipientCredited: boolean; recipientNewBalance: number }> {
    if (amount <= 0) {
      throw new BadRequestException('Le montant doit être positif');
    }

    const fromUser = await this.prisma.user.findUnique({
      where: { id: fromUserId },
    });
    if (!fromUser) throw new NotFoundException('Utilisateur introuvable');

    const fromBalance = Number(fromUser.balanceEur);
    if (fromBalance < amount) {
      throw new BadRequestException('Solde insuffisant');
    }

    // Normalisation : trim, suppression espaces (IBAN), toLowerCase pour email
    const ident = toIdentifier.trim();
    const normIban = ident.replace(/\s/g, '').toUpperCase(); // IBAN insensible à la casse
    const identLower = ident.toLowerCase();

    let toUser: { id: string; balanceEur: Decimal } | null = null;

    if (normIban.startsWith('FR') && normIban.length >= 14) {
      const all = await this.prisma.user.findMany({
        where: { iban: { not: null } },
      });
      toUser = all.find(
        (u) => u.iban && u.iban.replace(/\s/g, '').toUpperCase() === normIban,
      ) ?? null;
    }
    if (!toUser) {
      toUser = await this.prisma.user.findFirst({
        where: { pseudonym: { equals: ident, mode: 'insensitive' } },
      });
    }
    if (!toUser && ident.includes('@')) {
      toUser = await this.prisma.user.findUnique({
        where: { email: identLower },
      });
    }

    if (!toUser) {
      throw new NotFoundException(
        `Aucun compte NodEX trouvé pour "${ident}" (IBAN, pseudonyme ou email)`,
      );
    }
    if (toUser.id === fromUserId) {
      throw new BadRequestException(
        "Vous ne pouvez pas vous envoyer un virement à vous-même",
      );
    }

    // Diagnostic : vérifier que le bon compte est crédité
    const toBalanceBefore = Number(toUser.balanceEur);
    console.log(`[Virement] Crédit du compte ID: ${toUser.id} (ident: "${ident}")`);

    // Transaction atomique ACID : si une étape échoue, tout est annulé (rollback)
    const amountDec = new Decimal(amount);
    const fromBalanceDec = new Decimal(fromUser.balanceEur);

    await this.prisma.$transaction(async (tx) => {
      // 1. Débiter l'expéditeur (Decimal pour précision)
      await tx.user.update({
        where: { id: fromUserId },
        data: { balanceEur: fromBalanceDec.minus(amountDec) },
      });
      // 2. Créditer le destinataire (Decimal.plus() évite les erreurs d'arrondi)
      const toBalanceDec = toUser.balanceEur instanceof Decimal ? toUser.balanceEur : new Decimal(toUser.balanceEur);
      await tx.user.update({
        where: { id: toUser.id },
        data: { balanceEur: toBalanceDec.plus(amountDec) },
      });
      // 3. Enregistrer l'historique (traçabilité)
      await tx.virementEur.create({
        data: {
          fromUserId,
          toUserId: toUser.id,
          amount: new Decimal(amount),
        },
      });
    });

    // Vérification post-transaction : les deux comptes ont bien été mis à jour
    const [updatedFrom, updatedTo] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: fromUserId },
        select: { balanceEur: true },
      }),
      this.prisma.user.findUnique({
        where: { id: toUser.id },
        select: { balanceEur: true },
      }),
    ]);

    if (!updatedFrom || !updatedTo) {
      throw new BadRequestException('Erreur de vérification après virement');
    }

    const toBalanceAfter = Number(updatedTo.balanceEur);
    console.log(`[Virement] AVANT: ${toBalanceBefore} | APRES: ${toBalanceAfter}`);

    return {
      success: true,
      newBalance: Number(updatedFrom.balanceEur),
      recipientCredited: true,
      recipientNewBalance: toBalanceAfter, // Preuve que le compte B a bien reçu
    };
  }
}
