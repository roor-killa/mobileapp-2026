import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-custom';
import { Request } from 'express';
import { Client, Account } from 'node-appwrite';
import { AuthService } from './auth.service';

/**
 * Valide le JWT Appwrite en appelant account.get() avec le token.
 * À la première requête, crée l'utilisateur en base + wallets ETH/SOL/ALGO.
 * Mets APPWRITE_ENDPOINT et APPWRITE_PROJECT_ID dans .env
 */
@Injectable()
export class AppwriteJwtStrategy extends PassportStrategy(
  Strategy,
  'appwrite-jwt',
) {
  private readonly endpoint: string;
  private readonly projectId: string;

  constructor(private authService: AuthService) {
    super();
    this.endpoint = process.env.APPWRITE_ENDPOINT || 'https://cloud.appwrite.io/v1';
    this.projectId = process.env.APPWRITE_PROJECT_ID || '';
    if (!this.projectId) {
      throw new Error(
        'APPWRITE_PROJECT_ID manquant dans .env (Appwrite Console → Settings)',
      );
    }
  }

  async validate(req: Request): Promise<{ userId: string }> {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token manquant');
    }
    const token = authHeader.slice(7);

    try {
      const client = new Client()
        .setEndpoint(this.endpoint)
        .setProject(this.projectId)
        .setJWT(token);

      const account = new Account(client);
      const user = await account.get();

      const appwriteId = user.$id;
      const email = user.email ?? '';
      const name = user.name ?? undefined;

      const dbUser = await this.authService.findOrCreateUserFromAppwrite(
        appwriteId,
        email,
        name,
      );
      return { userId: dbUser.id };
    } catch {
      throw new UnauthorizedException('Token Appwrite invalide ou expiré');
    }
  }
}
