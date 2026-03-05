import { Module } from '@nestjs/common';
import { WalletsController } from './wallets.controller';
import { WalletsService } from './wallets.service';
import { PrismaService } from '../../common/prisma.service';

@Module({
  controllers: [WalletsController],
  providers: [WalletsService, PrismaService],
  exports: [WalletsService],
})
export class WalletModule {}
