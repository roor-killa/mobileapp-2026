import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma.service';
import { VaultService } from '../vault/vault.service';

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
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, name: true },
    });
    if (!user) throw new UnauthorizedException('Utilisateur introuvable');
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
   * Trouve ou crée un utilisateur à partir du JWT Supabase (première requête depuis l'app).
   * Crée les wallets ETH, SOL et ALGO (AlgoKit) si nouvel utilisateur.
   */
  async findOrCreateUserFromSupabase(
    supabaseUserId: string,
    email: string,
    name?: string,
  ) {
    let user = await this.prisma.user.findUnique({
      where: { supabaseId: supabaseUserId },
    });
    if (user) return user;

    const passwordHash = await bcrypt.hash('SUPABASE_AUTH_PLACEHOLDER', 10);
    user = await this.prisma.user.create({
      data: {
        email: email || `supabase-${supabaseUserId}@placeholder.local`,
        passwordHash,
        name: name ?? 'Utilisateur',
        supabaseId: supabaseUserId,
      },
    });

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
