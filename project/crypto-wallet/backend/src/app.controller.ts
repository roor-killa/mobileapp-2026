import { Controller, Get, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * Route racine de l'API - évite le 404 sur /
 * Si le navigateur demande du HTML, affiche une page avec lien vers l'app Flutter
 */
@Controller()
export class AppController {
  @Get()
  getRoot(@Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const accept = (req.headers.accept || '').toLowerCase();
    if (accept.includes('text/html')) {
      res.type('text/html').send(this.getHtmlPage());
      return;
    }
    return {
      message: 'Crypto Wallet API',
      version: '1.0',
      info: "Ceci est l'API backend. L'application NodEX (interface) est une app Flutter séparée.",
      app: {
        howToLaunch: 'Dans un terminal : cd project/crypto-wallet/flutter_app && flutter run -d chrome',
        url: 'http://localhost:8080 (ou le port affiché par Flutter)',
      },
      endpoints: {
        health: '/health',
        auth: '/auth (register, login, me)',
        wallets: '/wallets',
        prices: '/prices',
        transfers: '/transfers',
      },
    };
  }

  private getHtmlPage(): string {
    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>NodEX - Crypto Wallet</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 600px; margin: 80px auto; padding: 20px; }
    h1 { color: #333; }
    .box { background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; }
    code { background: #e0e0e0; padding: 2px 6px; border-radius: 4px; }
    a { color: #1976d2; }
  </style>
</head>
<body>
  <h1>NodEX — Portefeuille Crypto</h1>
  <p>Vous êtes sur l'<strong>API backend</strong> (port 3000). L'application (interface) est séparée.</p>
  <div class="box">
    <h2>Lancer l'application</h2>
    <p>Ouvrez un terminal et exécutez :</p>
    <p><code>cd project/crypto-wallet/flutter_app && flutter run -d chrome</code></p>
    <p>Ou double-cliquez sur <code>LANCER_APP.sh</code> dans le dossier crypto-wallet.</p>
    <p>L'app s'ouvrira dans Chrome sur <strong>http://localhost:8080</strong> (ou un port similaire).</p>
  </div>
  <p><a href="/">Voir la réponse JSON de l'API</a></p>
</body>
</html>`;
  }
}
