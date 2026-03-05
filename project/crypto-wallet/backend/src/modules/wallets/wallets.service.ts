import { Injectable } from '@nestjs/common';
import { ethers } from 'ethers';
import { Connection, PublicKey, LAMPORTS_PER_SOL } from '@solana/web3.js';
import * as algosdk from 'algosdk';
import { PrismaService } from '../../common/prisma.service';

const MICROALGOS_PER_ALGO = 1_000_000;

@Injectable()
export class WalletsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Récupère tous les wallets d'un utilisateur
   * et interroge la blockchain pour obtenir le solde de chacun.
   */
  async getWallets(userId: string) {
    const wallets = await this.prisma.wallet.findMany({
      where: { userId },
    });

    const walletsWithBalances = await Promise.all(
      wallets.map(async (wallet) => {
        const balance = await this.getBalance(wallet.chain, wallet.address);
        return {
          id: wallet.id,
          chain: wallet.chain,
          address: wallet.address,
          balance,
          createdAt: wallet.createdAt,
        };
      }),
    );

    return walletsWithBalances;
  }

  /**
   * Interroge le solde natif sur la blockchain correspondante.
   * En cas d'erreur réseau, retourne "0" plutôt que de planter.
   */
  private async getBalance(chain: string, address: string): Promise<string> {
    try {
      if (chain === 'ETH') {
        const provider = new ethers.JsonRpcProvider(
          process.env.ALCHEMY_ETH_URL,
        );
        const balance = await provider.getBalance(address);
        return ethers.formatEther(balance);
      }

      if (chain === 'SOL') {
        const connection = new Connection(
          process.env.SOLANA_RPC_URL || 'https://api.devnet.solana.com',
        );
        const pubkey = new PublicKey(address);
        const balance = await connection.getBalance(pubkey);
        return (balance / LAMPORTS_PER_SOL).toString();
      }

      if (chain === 'ALGO') {
        const algodServer =
          process.env.ALGO_ALGOD_SERVER || 'https://testnet-api.algonode.cloud';
        const algodPort = process.env.ALGO_ALGOD_PORT || '443';
        const algodToken = process.env.ALGO_ALGOD_TOKEN || '';
        const client = new algosdk.Algodv2(
          algodToken,
          algodServer,
          algodPort,
        );
        const info = await client.accountInformation(address).do();
        const microAlgos = Number(info.amount ?? 0);
        return (microAlgos / MICROALGOS_PER_ALGO).toString();
      }

      return '0';
    } catch {
      return '0';
    }
  }

  async getTransactions(walletId: string) {
    return this.prisma.transaction.findMany({
      where: { walletId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
