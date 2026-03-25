import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { PrismaService } from '../../common/prisma.service';
import { VaultService } from '../vault/vault.service';

/** Génère un IBAN unique à partir de l'id utilisateur */
function generateIban(userId: string): string {
  const hash = crypto.createHash('sha256').update(userId).digest('hex');
  const digits = hash
    .substring(0, 11)
    .split('')
    .map((c) => parseInt(c, 16) % 10)
    .join('');
  return `FR76 3000 6000 01${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 11)}`;
}

/** Génère un pseudonyme unique (nom + fin de l'id pour unicité) */
function generatePseudonym(name: string, userId: string): string {
  const clean = name
    .trim()
    .replace(/\s+/g, '')
    .replace(/[^a-zA-Z0-9]/g, '')
    .substring(0, 6);
  const suffix = userId.replace(/-/g, '').substring(0, 4);
  return (clean.length >= 2 ? clean : 'User') + suffix;
}

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private vaultService: VaultService,
  ) {}

  async register(email: string, password: string, name: string) {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new ConflictException('Cet email est déjà utilisé');
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await this.prisma.user.create({
      data: { email, passwordHash, name },
    });

    // Génère automatiquement les wallets ETH, SOL et ALGO à l'inscription
    const clientKeyShares: Record<string, string> = {};

    for (const chain of ['ETH', 'SOL', 'ALGO']) {
      const keyPair = await this.vaultService.generateKeyPair(chain);

      await this.prisma.wallet.create({
        data: {
          userId: user.id,
          chain,
          address: keyPair.address,
          keyShareServer: keyPair.keyShareServer,
        },
      });

      // La part client est renvoyée une seule fois (à stocker côté app)
      clientKeyShares[chain] = keyPair.keyShareClient;
    }

    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      token,
      user: { id: user.id, email: user.email, name: user.name },
      clientKeyShares,
    };
  }

  async getMe(userId: string) {
    let user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, name: true, iban: true, pseudonym: true },
    });
    if (!user) throw new UnauthorizedException('Utilisateur introuvable');
    // Backfill IBAN/pseudonym pour les utilisateurs existants
    if (!user.iban || !user.pseudonym) {
      const full = await this.prisma.user.findUniqueOrThrow({
        where: { id: userId },
      });
      const iban = full.iban ?? generateIban(userId);
      const pseudonym = full.pseudonym ?? generatePseudonym(full.name, userId);
      await this.prisma.user.update({
        where: { id: userId },
        data: { iban, pseudonym },
      });
      user = { ...user, iban, pseudonym };
    }
    return { user };
  }

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      token,
      user: { id: user.id, email: user.email, name: user.name },
    };
  }

  /**
   * Trouve ou crée un utilisateur à partir du JWT Appwrite (première requête depuis l'app).
   * Crée les wallets ETH, SOL et ALGO (AlgoKit) si nouvel utilisateur.
   */
  async findOrCreateUserFromAppwrite(
    appwriteUserId: string,
    email: string,
    name?: string,
  ) {
    let user = await this.prisma.user.findUnique({
      where: { appwriteId: appwriteUserId },
    });
    if (user) {
      // Backfill IBAN/pseudonym pour les utilisateurs existants (créés avant l'ajout de ces champs)
      if (!user.iban || !user.pseudonym) {
        const iban = generateIban(user.id);
        const pseudonym = generatePseudonym(user.name, user.id);
        await this.prisma.user.update({
          where: { id: user.id },
          data: { iban, pseudonym },
        });
        user = await this.prisma.user.findUniqueOrThrow({
          where: { id: user.id },
        });
      }
      return user;
    }

    const passwordHash = await bcrypt.hash('APPWRITE_AUTH_PLACEHOLDER', 10);
    const userName = name ?? 'Utilisateur';
    const tempId = crypto.randomUUID();
    const iban = generateIban(tempId);
    const pseudonym = generatePseudonym(userName, tempId);
    user = await this.prisma.user.create({
      data: {
        email: email || `appwrite-${appwriteUserId}@placeholder.local`,
        passwordHash,
        name: userName,
        appwriteId: appwriteUserId,
        iban,
        pseudonym,
      },
    });
    // Mise à jour avec l'IBAN basé sur le vrai id
    const realIban = generateIban(user.id);
    const realPseudonym = generatePseudonym(userName, user.id);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { iban: realIban, pseudonym: realPseudonym },
    });
    user = await this.prisma.user.findUniqueOrThrow({ where: { id: user.id } });

    for (const chain of ['ETH', 'SOL', 'ALGO']) {
      const keyPair = await this.vaultService.generateKeyPair(chain);
      await this.prisma.wallet.create({
        data: {
          userId: user.id,
          chain,
          address: keyPair.address,
          keyShareServer: keyPair.keyShareServer,
        },
      });
    }

    return user;
  }
}
