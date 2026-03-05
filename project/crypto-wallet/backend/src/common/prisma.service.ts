import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    console.log('Connexion à la base de données...');
    await this.$connect();
    console.log('Base de données connectée.');
  }
}
