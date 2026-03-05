import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import axios from 'axios';
import { PrismaService } from '../../common/prisma.service';

const COINGECKO_MAP: Record<string, string> = {
  bitcoin: 'BTC',
  ethereum: 'ETH',
  solana: 'SOL',
  algorand: 'ALGO',
  'usd-coin': 'USDC',
};

@Injectable()
export class PricesService {
  private readonly logger = new Logger(PricesService.name);

  constructor(private prisma: PrismaService) {}

  // Cron job toutes les 60 secondes : récupère les prix depuis CoinGecko
  @Cron('*/60 * * * * *')
  async fetchPrices() {
    try {
      const url =
        process.env.COINGECKO_API_URL ||
        'https://api.coingecko.com/api/v3/simple/price';

      const { data } = await axios.get(url, {
        params: {
          ids: 'bitcoin,ethereum,solana,algorand,usd-coin',
          vs_currencies: 'eur',
        },
      });

      for (const [coingeckoId, symbol] of Object.entries(COINGECKO_MAP)) {
        const priceEur = data[coingeckoId]?.eur;
        if (priceEur === undefined) continue;

        await this.prisma.priceCache.upsert({
          where: { symbol },
          update: { priceEur },
          create: { symbol, priceEur },
        });
      }

      this.logger.log('Prix mis à jour depuis CoinGecko');
    } catch (error) {
      this.logger.error('Erreur lors de la récupération des prix', error);
    }
  }

  async getPrices() {
    return this.prisma.priceCache.findMany();
  }
}
