import { Module } from '@nestjs/common';
import { TransfersController } from './transfers.controller';
import { TransfersService } from './transfers.service';
import { VaultModule } from '../vault/vault.module';
import { PrismaService } from '../../common/prisma.service';

@Module({
  imports: [VaultModule],
  controllers: [TransfersController],
  providers: [TransfersService, PrismaService],
})
export class TransferModule {}
