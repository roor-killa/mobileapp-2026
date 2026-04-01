/**
 * Blockchain pédagogique propre à SECONDAPP — « NexBank Chain ».
 * Chaîne privée simulée (pas de réseau public), stockée en localStorage.
 */

export type NexbankTxType = "transfer" | "mint" | "swap" | "wallet";

export type NexbankTransaction = {
  id: string;
  type: NexbankTxType;
  from: string;
  to: string;
  amount: string;
  asset?: string;
  memo?: string;
  timestamp: number;
};

export type NexbankBlock = {
  index: number;
  timestamp: number;
  previousHash: string;
  nonce: number;
  difficulty: number;
  transactions: NexbankTransaction[];
  hash: string;
};

export type NexbankChainState = {
  chainId: string;
  blocks: NexbankBlock[];
  pendingTransactions: NexbankTransaction[];
  difficulty: number;
};
