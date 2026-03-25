import * as dotenv from 'dotenv';
import { resolve } from 'path';

// Charge .env depuis le dossier backend (au cas où le cwd serait différent)
dotenv.config({ path: resolve(__dirname, '../.env') });

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: true, // Reflète l'origine de la requête (évite les blocages CORS)
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  await app.listen(3000);
  console.log('Serveur démarré sur http://localhost:3000');
}
bootstrap();
