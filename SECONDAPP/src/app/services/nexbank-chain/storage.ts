import type { NexbankChainState } from "./types";
import { initialChainState } from "./engine";

export const CHAIN_STATE_STORAGE_KEY = "secondapp-nexbank-chain-v1";
/** Émis après une mise à jour hors de l’écran Blockchain (ex. achat crypto) pour recharger le mempool. */
export const NEXBANK_CHAIN_UPDATE_EVENT = "secondapp-nexbank-chain-updated";

export const DEFAULT_DIFFICULTY = 2;

export function loadChainState(): NexbankChainState {
  try {
    const raw = localStorage.getItem(CHAIN_STATE_STORAGE_KEY);
    if (!raw) {
      return initialChainState(DEFAULT_DIFFICULTY);
    }
    const parsed = JSON.parse(raw) as NexbankChainState;
    if (!parsed?.blocks?.length || !Array.isArray(parsed.blocks)) {
      return initialChainState(DEFAULT_DIFFICULTY);
    }
    return {
      chainId: parsed.chainId ?? "nexbank-main-demo-v1",
      blocks: parsed.blocks,
      pendingTransactions: Array.isArray(parsed.pendingTransactions) ? parsed.pendingTransactions : [],
      difficulty: typeof parsed.difficulty === "number" ? parsed.difficulty : DEFAULT_DIFFICULTY,
    };
  } catch {
    return initialChainState(DEFAULT_DIFFICULTY);
  }
}

export function saveChainState(state: NexbankChainState): void {
  localStorage.setItem(CHAIN_STATE_STORAGE_KEY, JSON.stringify(state));
}

/** À appeler après `saveChainState` depuis un autre flux que l’UI Blockchain (même onglet). */
export function notifyNexbankChainUpdated(): void {
  if (typeof window === "undefined") return;
  window.dispatchEvent(new Event(NEXBANK_CHAIN_UPDATE_EVENT));
}

export function resetChainState(): NexbankChainState {
  const fresh = initialChainState(DEFAULT_DIFFICULTY);
  saveChainState(fresh);
  return fresh;
}
