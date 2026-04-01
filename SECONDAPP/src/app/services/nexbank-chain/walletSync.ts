import { enqueueTransaction } from "./engine";
import { loadChainState, notifyNexbankChainUpdated, saveChainState } from "./storage";

/** Enfile une transaction liée à un achat crypto (visible dans la file d’attente avant minage). */
export function queueCryptoPurchase(symbol: string, name: string, amount: number): void {
  const st = loadChainState();
  const next = enqueueTransaction(st, {
    type: "wallet",
    from: "NexBank Exchange",
    to: `Wallet • ${name}`,
    amount: String(amount),
    asset: symbol,
    memo: `Achat spot ${symbol}`,
  });
  saveChainState(next);
  notifyNexbankChainUpdated();
}
