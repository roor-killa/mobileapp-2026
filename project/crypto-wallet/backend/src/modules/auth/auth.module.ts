import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { SupabaseJwtStrategy } from './supabase-jwt.strategy';
import { PrismaService } from '../../common/prisma.service';
import { VaultModule } from '../vault/vault.module';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'dev-secret-key',
      signOptions: { expiresIn: '7d' },
    }),
    VaultModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, SupabaseJwtStrategy, PrismaService],
  exports: [AuthService],
})
export class AuthModule {}
