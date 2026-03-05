import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { WalletModule } from './modules/wallets/wallets.module';
import { PricesModule } from './modules/prices/prices.module';
import { TransferModule } from './modules/transfers/transfers.module';
import { VaultModule } from './modules/vault/vault.module';
import { PrismaService } from './common/prisma.service';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    HealthModule,
    AuthModule,
    WalletModule,
    PricesModule,
    TransferModule,
    VaultModule,
  ],
  providers: [PrismaService],
  exports: [PrismaService],
})
export class AppModule {}
