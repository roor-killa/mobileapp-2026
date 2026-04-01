import type { NexbankBlock, NexbankChainState, NexbankTransaction } from "./types";

const CHAIN_ID = "nexbank-main-demo-v1";

export async function sha256Hex(message: string): Promise<string> {
  const data = new TextEncoder().encode(message);
  const buf = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function blockHeaderPayload(
  index: number,
  timestamp: number,
  previousHash: string,
  nonce: number,
  difficulty: number,
  transactions: NexbankTransaction[],
): string {
  const txs = JSON.stringify(
    transactions.map((t) => ({
      id: t.id,
      type: t.type,
      from: t.from,
      to: t.to,
      amount: t.amount,
      asset: t.asset ?? "",
      memo: t.memo ?? "",
      timestamp: t.timestamp,
    })),
  );
  return `${index}|${timestamp}|${previousHash}|${nonce}|${difficulty}|${txs}`;
}

export async function hashBlock(
  index: number,
  timestamp: number,
  previousHash: string,
  nonce: number,
  difficulty: number,
  transactions: NexbankTransaction[],
): Promise<string> {
  return sha256Hex(blockHeaderPayload(index, timestamp, previousHash, nonce, difficulty, transactions));
}

/** Proof-of-work : le hash doit commencer par `difficulty` zéros hex (ex. 2 → "00..."). */
export async function mineBlock(
  index: number,
  timestamp: number,
  previousHash: string,
  difficulty: number,
  transactions: NexbankTransaction[],
  maxNonce = 5_000_000,
): Promise<{ nonce: number; hash: string }> {
  let nonce = 0;
  const prefix = "0".repeat(difficulty);
  while (nonce < maxNonce) {
    const hash = await hashBlock(index, timestamp, previousHash, nonce, difficulty, transactions);
    if (hash.startsWith(prefix)) {
      return { nonce, hash };
    }
    nonce += 1;
  }
  throw new Error("Mining timeout — diminue la difficulté ou réessaie.");
}

export function createGenesisBlock(): NexbankBlock {
  const timestamp = Date.now();
  const transactions: NexbankTransaction[] = [
    {
      id: "genesis-0",
      type: "mint",
      from: "NexBank",
      to: "Réseau",
      amount: "0",
      memo: "Bloc genèse — NexBank Chain (démonstration)",
      timestamp,
    },
  ];
  // Genesis : nonce fixe pour temps de chargement instantané (difficulté 0)
  const index = 0;
  const previousHash = "0".repeat(64);
  const nonce = 0;
  const payload = blockHeaderPayload(index, timestamp, previousHash, nonce, 0, transactions);
  // sync hash for genesis without await in sync constructor — use a placeholder then we need async init
  // Simpler: genesis with difficulty 0, hash computed synchronously via a sync fallback
  const hash = simpleSyncHash(payload);

  return {
    index,
    timestamp,
    previousHash,
    nonce,
    difficulty: 0,
    transactions,
    hash,
  };
}

/** Hash déterministe synchrone uniquement pour le bloc genèse (évite async au premier paint). */
function simpleSyncHash(str: string): string {
  let h = 5381;
  for (let i = 0; i < str.length; i++) {
    h = (h << 5) + h + str.charCodeAt(i);
    h = h >>> 0;
  }
  const hex = h.toString(16).padStart(8, "0");
  return (hex + hex + hex + hex + hex + hex + hex + hex).slice(0, 64);
}

export function initialChainState(difficulty: number): NexbankChainState {
  return {
    chainId: CHAIN_ID,
    blocks: [createGenesisBlock()],
    pendingTransactions: [],
    difficulty,
  };
}

export async function appendMinedBlock(
  state: NexbankChainState,
  transactions: NexbankTransaction[],
): Promise<NexbankChainState> {
  const previous = state.blocks[state.blocks.length - 1];
  const index = previous.index + 1;
  const timestamp = Date.now();
  const { nonce, hash } = await mineBlock(
    index,
    timestamp,
    previous.hash,
    state.difficulty,
    transactions,
  );

  const newBlock: NexbankBlock = {
    index,
    timestamp,
    previousHash: previous.hash,
    nonce,
    difficulty: state.difficulty,
    transactions,
    hash,
  };

  return {
    ...state,
    blocks: [...state.blocks, newBlock],
    pendingTransactions: [],
  };
}

export async function validateChain(state: NexbankChainState): Promise<{ valid: boolean; reason?: string }> {
  if (state.blocks.length === 0) {
    return { valid: false, reason: "Chaîne vide" };
  }

  const genesis = state.blocks[0];
  if (genesis.index !== 0 || genesis.previousHash !== "0".repeat(64)) {
    return { valid: false, reason: "Bloc genèse invalide" };
  }
  const genesisPayload = blockHeaderPayload(
    genesis.index,
    genesis.timestamp,
    genesis.previousHash,
    genesis.nonce,
    genesis.difficulty,
    genesis.transactions,
  );
  if (simpleSyncHash(genesisPayload) !== genesis.hash) {
    return { valid: false, reason: "Hash du bloc genèse invalide" };
  }

  for (let i = 1; i < state.blocks.length; i++) {
    const block = state.blocks[i];
    const prev = state.blocks[i - 1];
    if (block.previousHash !== prev.hash) {
      return { valid: false, reason: `Lien cassé au bloc #${block.index}` };
    }
    const expected = await hashBlock(
      block.index,
      block.timestamp,
      block.previousHash,
      block.nonce,
      block.difficulty,
      block.transactions,
    );
    if (expected !== block.hash) {
      return { valid: false, reason: `Hash incohérent au bloc #${block.index}` };
    }
    const prefix = "0".repeat(block.difficulty);
    if (block.difficulty > 0 && !block.hash.startsWith(prefix)) {
      return { valid: false, reason: `Preuve de travail invalide au bloc #${block.index}` };
    }
  }

  return { valid: true };
}

export function enqueueTransaction(
  state: NexbankChainState,
  tx: Omit<NexbankTransaction, "id" | "timestamp"> & { id?: string },
): NexbankChainState {
  const full: NexbankTransaction = {
    id: tx.id ?? `tx-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
    type: tx.type,
    from: tx.from,
    to: tx.to,
    amount: tx.amount,
    asset: tx.asset,
    memo: tx.memo,
    timestamp: Date.now(),
  };
  return {
    ...state,
    pendingTransactions: [...state.pendingTransactions, full],
  };
}
