import { Injectable, BadRequestException } from '@nestjs/common';
import { ethers } from 'ethers';
import { Keypair } from '@solana/web3.js';
import * as algosdk from 'algosdk';
import { PrismaService } from '../../common/prisma.service';

@Injectable()
export class VaultService {
  constructor(private prisma: PrismaService) {}

  /**
   * Génère une paire de clés pour la blockchain demandée.
   * La clé privée est coupée en 2 parts :
   * - keyShareServer : stockée en base (chiffrée côté serveur)
   * - keyShareClient : renvoyée à l'utilisateur (stockée sur l'app)
   * Les deux parts sont nécessaires pour signer une transaction.
   * Algorand : utilise AlgoKit / algosdk.
   */
  async generateKeyPair(
    chain: string,
  ): Promise<{ address: string; keyShareServer: string; keyShareClient: string }> {
    if (chain === 'ETH') {
      const wallet = ethers.Wallet.createRandom();
      const privateKey = wallet.privateKey.slice(2); // Retire le préfixe "0x"
      const mid = Math.floor(privateKey.length / 2);

      return {
        address: wallet.address,
        keyShareServer: privateKey.slice(0, mid),
        keyShareClient: privateKey.slice(mid),
      };
    }

    if (chain === 'SOL') {
      const keypair = Keypair.generate();
      const secretHex = Buffer.from(keypair.secretKey).toString('hex');
      const mid = Math.floor(secretHex.length / 2);

      return {
        address: keypair.publicKey.toBase58(),
        keyShareServer: secretHex.slice(0, mid),
        keyShareClient: secretHex.slice(mid),
      };
    }

    if (chain === 'ALGO') {
      const account = algosdk.generateAccount();
      const secretHex = Buffer.from(account.sk).toString('hex');
      const mid = Math.floor(secretHex.length / 2);
      return {
        address: String(account.addr),
        keyShareServer: secretHex.slice(0, mid),
        keyShareClient: secretHex.slice(mid),
      };
    }

    throw new BadRequestException(`Blockchain "${chain}" non supportée`);
  }

  /**
   * Reconstruit la clé privée à partir des 2 parts,
   * signe la transaction, puis efface la clé de la mémoire.
   */
  async signTransaction(
    walletId: string,
    txData: any,
    clientKeyShare: string,
  ): Promise<string> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { id: walletId },
    });
    if (!wallet) {
      throw new BadRequestException('Wallet introuvable');
    }

    // Reconstruit la clé privée complète
    const fullKey = wallet.keyShareServer + clientKeyShare;

    if (wallet.chain === 'ETH') {
      const provider = new ethers.JsonRpcProvider(process.env.ALCHEMY_ETH_URL);
      const signer = new ethers.Wallet('0x' + fullKey, provider);
      const tx = await signer.sendTransaction(txData);
      return tx.hash;
    }

    if (wallet.chain === 'SOL') {
      const { Connection, Transaction } = await import('@solana/web3.js');
      const secretKey = Uint8Array.from(Buffer.from(fullKey, 'hex'));
      const keypair = Keypair.fromSecretKey(secretKey);
      const connection = new Connection(
        process.env.SOLANA_RPC_URL || 'https://api.devnet.solana.com',
      );
      const transaction = Transaction.from(Buffer.from(txData, 'base64'));
      transaction.sign(keypair);
      const signature = await connection.sendRawTransaction(
        transaction.serialize(),
      );
      return signature;
    }

    if (wallet.chain === 'ALGO') {
      const sk = Uint8Array.from(Buffer.from(fullKey, 'hex'));
      const algodServer =
        process.env.ALGO_ALGOD_SERVER || 'https://testnet-api.algonode.cloud';
      const algodPort = process.env.ALGO_ALGOD_PORT || '443';
      const algodToken = process.env.ALGO_ALGOD_TOKEN || '';
      const client = new algosdk.Algodv2(
        algodToken,
        algodServer,
        algodPort,
      );
      const suggestedParams = await client.getTransactionParams().do();
      const { receiver, amountMicroAlgos } = JSON.parse(txData) as {
        receiver: string;
        amountMicroAlgos: number;
      };
      const ptxn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
        sender: wallet.address,
        receiver,
        amount: amountMicroAlgos,
        suggestedParams,
      });
      const signed = ptxn.signTxn(sk);
      const resp = await client.sendRawTransaction(signed).do();
      const txId = resp.txid;
      await algosdk.waitForConfirmation(client, txId, 4);
      return txId;
    }

    throw new BadRequestException(`Signature non supportée pour ${wallet.chain}`);
  }
}
