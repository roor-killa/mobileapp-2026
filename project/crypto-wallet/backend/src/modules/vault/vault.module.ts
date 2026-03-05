import { Module } from '@nestjs/common';
import { VaultService } from './vault.service';
import { PrismaService } from '../../common/prisma.service';

@Module({
  providers: [VaultService, PrismaService],
  exports: [VaultService],
})
export class VaultModule {}
