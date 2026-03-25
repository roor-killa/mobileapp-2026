import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { WalletModule } from './modules/wallets/wallets.module';
import { PricesModule } from './modules/prices/prices.module';
import { TransferModule } from './modules/transfers/transfers.module';
import { VirementsModule } from './modules/virements/virements.module';
import { VaultModule } from './modules/vault/vault.module';
import { StripeModule } from './modules/stripe/stripe.module';
import { CardModule } from './modules/card/card.module';
import { PrismaService } from './common/prisma.service';

@Module({
  controllers: [AppController],
  imports: [
    ScheduleModule.forRoot(),
    HealthModule,
    AuthModule,
    WalletModule,
    PricesModule,
    TransferModule,
    VirementsModule,
    VaultModule,
    StripeModule,
    CardModule,
  ],
  providers: [PrismaService],
  exports: [PrismaService],
})
export class AppModule {}
