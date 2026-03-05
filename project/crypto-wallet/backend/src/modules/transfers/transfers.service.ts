import {
  Injectable,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { ethers } from 'ethers';
import { PrismaService } from '../../common/prisma.service';
import { VaultService } from '../vault/vault.service';

@Injectable()
export class TransfersService {
  constructor(
    private prisma: PrismaService,
    private vaultService: VaultService,
  ) {}

  async executeTransfer(
    userId: string,
    fromWalletId: string,
    toAddress: string,
    amount: string,
    tokenSymbol: string,
    clientKeyShare: string,
  ) {
    const wallet = await this.prisma.wallet.findUnique({
      where: { id: fromWalletId },
    });

    if (!wallet) {
      throw new BadRequestException('Wallet introuvable');
    }
    if (wallet.userId !== userId) {
      throw new ForbiddenException('Ce wallet ne vous appartient pas');
    }

    const transaction = await this.prisma.transaction.create({
      data: {
        walletId: wallet.id,
        chain: wallet.chain,
        type: 'send',
        amount: parseFloat(amount),
        tokenSymbol,
        toAddress,
        fromAddress: wallet.address,
        status: 'pending',
      },
    });

    try {
      let txHash: string;

      if (wallet.chain === 'ETH') {
        const txData = {
          to: toAddress,
          value: ethers.parseEther(amount),
        };
        txHash = await this.vaultService.signTransaction(
          wallet.id,
          txData,
          clientKeyShare,
        );
      } else if (wallet.chain === 'SOL') {
        txHash = await this.vaultService.signTransaction(
          wallet.id,
          amount,
          clientKeyShare,
        );
      } else if (wallet.chain === 'ALGO') {
        const amountMicroAlgos = Math.floor(parseFloat(amount) * 1_000_000);
        const txData = JSON.stringify({
          receiver: toAddress,
          amountMicroAlgos,
        });
        txHash = await this.vaultService.signTransaction(
          wallet.id,
          txData,
          clientKeyShare,
        );
      } else {
        throw new BadRequestException(`Chain ${wallet.chain} non supportée`);
      }

      await this.prisma.transaction.update({
        where: { id: transaction.id },
        data: { txHash, status: 'confirmed' },
      });

      return { txHash, status: 'confirmed' };
    } catch (error) {
      await this.prisma.transaction.update({
        where: { id: transaction.id },
        data: { status: 'failed' },
      });

      throw new BadRequestException(
        `Échec du transfert : ${error.message || error}`,
      );
    }
  }
}
