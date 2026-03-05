import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthService } from './auth.service';

/**
 * Valide le JWT émis par Supabase Auth (app mobile).
 * À la première requête, crée l'utilisateur en base + wallets ETH/SOL.
 * Mets SUPABASE_JWT_SECRET dans .env (Supabase Dashboard → Settings → API → JWT Secret).
 */
@Injectable()
export class SupabaseJwtStrategy extends PassportStrategy(
  Strategy,
  'supabase-jwt',
) {
  constructor(private authService: AuthService) {
    const secret = process.env.SUPABASE_JWT_SECRET;
    if (!secret) {
      throw new Error(
        'SUPABASE_JWT_SECRET manquant dans .env (Supabase → Settings → API → JWT Secret)',
      );
    }
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: secret,
    });
  }

  async validate(payload: {
    sub: string;
    email?: string;
    user_metadata?: { full_name?: string; name?: string };
  }) {
    const email = payload.email ?? '';
    const name =
      payload.user_metadata?.full_name ??
      payload.user_metadata?.name ??
      undefined;
    const user = await this.authService.findOrCreateUserFromSupabase(
      payload.sub,
      email,
      name,
    );
    return { userId: user.id };
  }
}
