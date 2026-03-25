import { Module } from '@nestjs/common';
import { VirementsController } from './virements.controller';
import { VirementsService } from './virements.service';
import { VirementsBackfillService } from './virements-backfill.service';
import { PrismaService } from '../../common/prisma.service';

@Module({
  controllers: [VirementsController],
  providers: [VirementsService, VirementsBackfillService, PrismaService],
})
export class VirementsModule {}
