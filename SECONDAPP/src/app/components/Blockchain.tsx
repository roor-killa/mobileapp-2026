import { motion } from "motion/react";
import {
  Blocks,
  Link2,
  ShieldCheck,
  AlertTriangle,
  Hammer,
  Plus,
  Trash2,
  RefreshCw,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import {
  type NexbankChainState,
  type NexbankTransaction,
  appendMinedBlock,
  enqueueTransaction,
  validateChain,
  loadChainState,
  saveChainState,
  resetChainState,
  CHAIN_STATE_STORAGE_KEY,
  NEXBANK_CHAIN_UPDATE_EVENT,
} from "../services/nexbank-chain";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Badge } from "./ui/badge";
import { useTheme } from "../contexts/ThemeContext";

function shortHash(h: string, n = 10) {
  if (h.length <= 2 * n) return h;
  return `${h.slice(0, n)}…${h.slice(-n)}`;
}

export default function Blockchain() {
  const { theme } = useTheme();
  const [state, setState] = useState<NexbankChainState>(() => loadChainState());
  const [valid, setValid] = useState<boolean | null>(null);
  const [mining, setMining] = useState(false);
  const [expanded, setExpanded] = useState<number | null>(null);

  const [form, setForm] = useState({
    type: "transfer" as NexbankTransaction["type"],
    from: "Moi",
    to: "",
    amount: "",
    asset: "EUR",
    memo: "",
  });

  useEffect(() => {
    saveChainState(state);
  }, [state]);

  useEffect(() => {
    const reloadFromStorage = () => {
      setState(loadChainState());
      setValid(null);
    };
    window.addEventListener(NEXBANK_CHAIN_UPDATE_EVENT, reloadFromStorage);
    const onStorage = (e: StorageEvent) => {
      if (e.key === CHAIN_STATE_STORAGE_KEY || e.key === null) reloadFromStorage();
    };
    window.addEventListener("storage", onStorage);
    return () => {
      window.removeEventListener(NEXBANK_CHAIN_UPDATE_EVENT, reloadFromStorage);
      window.removeEventListener("storage", onStorage);
    };
  }, []);

  const runValidation = useCallback(async () => {
    const r = await validateChain(state);
    setValid(r.valid);
    if (r.valid) {
      toast.success("Chaîne intègre ✓");
    } else {
      toast.error(r.reason ?? "Chaîne invalide");
    }
  }, [state]);

  const addPending = () => {
    if (!form.to.trim() || !form.amount.trim()) {
      toast.error("Renseigne au moins le destinataire et le montant.");
      return;
    }
    setState((s) =>
      enqueueTransaction(s, {
        type: form.type,
        from: form.from.trim() || "Inconnu",
        to: form.to.trim(),
        amount: form.amount.trim(),
        asset: form.asset.trim() || undefined,
        memo: form.memo.trim() || undefined,
      }),
    );
    toast.success("Transaction ajoutée à la file d’attente");
    setForm((f) => ({ ...f, to: "", amount: "", memo: "" }));
  };

  const mine = async () => {
    if (state.pendingTransactions.length === 0) {
      toast.error("Aucune transaction en attente — ajoute-en une d’abord.");
      return;
    }
    setMining(true);
    try {
      const txs = [...state.pendingTransactions];
      const next = await appendMinedBlock(state, txs);
      setState(next);
      setValid(null);
      toast.success(`Bloc #${next.blocks.length - 1} miné et ajouté à NexBank Chain`);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Échec du minage");
    } finally {
      setMining(false);
    }
  };

  const hardReset = () => {
    if (!confirm("Réinitialiser toute la NexBank Chain ? Les blocs seront perdus (sauf export manuel).")) {
      return;
    }
    setState(resetChainState());
    setValid(null);
    toast.message("Chaîne réinitialisée.");
  };

  const latest = state.blocks[state.blocks.length - 1];

  return (
    <div className="p-6 space-y-6 pb-28">
      <motion.div initial={{ opacity: 0, y: -12 }} animate={{ opacity: 1, y: 0 }} className="pt-16">
        <div className="flex items-start gap-3">
          <div className={`p-3 rounded-2xl bg-gradient-to-br ${theme.gradient} shadow-lg`}>
            <Blocks className="w-7 h-7 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold">NexBank Chain</h1>
            <p className="text-gray-400 text-sm mt-0.5">
              Blockchain de démonstration interne à l’app — SHA-256 + preuve de travail légère
            </p>
          </div>
        </div>
      </motion.div>

      <div className="rounded-2xl border border-white/15 bg-white/10 backdrop-blur-md p-4 space-y-3 text-sm">
        <div className="flex flex-wrap gap-2 items-center">
          <Badge variant="outline" className="border-cyan-400/50 text-cyan-200">
            Chaîne : {state.chainId}
          </Badge>
          <Badge variant="secondary">
            Difficulté PoW : {state.difficulty} ({state.difficulty} zéro{state.difficulty > 1 ? "s" : ""} hex en tête du hash)
          </Badge>
        </div>
        <p className="text-white/70">
          Les données sont enregistrées dans ton navigateur (<code className="text-xs bg-black/30 px-1 rounded">localStorage</code>).
          Ce n’est pas une blockchain publique : aucun réseau pair-à-pair, pas de crypto-monnaie réelle.
        </p>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div className="rounded-2xl bg-white/5 border border-white/10 p-4">
          <p className="text-xs text-white/50">Hauteur</p>
          <p className="text-2xl font-bold">{state.blocks.length}</p>
          <p className="text-[11px] text-white/40 mt-1">blocs minés</p>
        </div>
        <div className="rounded-2xl bg-white/5 border border-white/10 p-4">
          <p className="text-xs text-white/50">File d’attente</p>
          <p className="text-2xl font-bold">{state.pendingTransactions.length}</p>
          <p className="text-[11px] text-white/40 mt-1">transactions</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-2">
        <Button
          type="button"
          variant="secondary"
          className="bg-emerald-600/80 text-white hover:bg-emerald-500"
          onClick={runValidation}
        >
          <ShieldCheck className="w-4 h-4" />
          Vérifier la chaîne
        </Button>
        {valid === false && (
          <span className="flex items-center gap-1 text-amber-300 text-xs">
            <AlertTriangle className="w-4 h-4" />
            Dernière vérif : invalide
          </span>
        )}
        <Button type="button" variant="outline" className="border-white/30 text-white" onClick={hardReset}>
          <Trash2 className="w-4 h-4" />
          Réinitialiser
        </Button>
      </div>

      {latest && (
        <div className="rounded-2xl border border-purple-400/30 bg-purple-950/30 p-4 space-y-2 text-xs">
          <p className="text-white/60 flex items-center gap-2">
            <Link2 className="w-4 h-4" /> Dernier bloc #{latest.index}
          </p>
          <p className="font-mono text-[11px] break-all text-white/90">{latest.hash}</p>
        </div>
      )}

      <div className="space-y-3">
        <h2 className="text-lg font-semibold flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Nouvelle transaction (mempool)
        </h2>
        <div className="rounded-2xl border border-white/10 bg-white/5 p-4 space-y-3">
          <div className="grid grid-cols-2 gap-2">
            <div>
              <label className="text-[11px] text-white/50">Type</label>
              <select
                className="w-full mt-1 h-9 rounded-md border border-white/20 bg-zinc-900/80 text-sm text-white px-2"
                value={form.type}
                onChange={(e) =>
                  setForm((f) => ({ ...f, type: e.target.value as NexbankTransaction["type"] }))
                }
              >
                <option value="transfer">Transfert</option>
                <option value="swap">Échange</option>
                <option value="mint">Émission (démo)</option>
                <option value="wallet">Portefeuille</option>
              </select>
            </div>
            <div>
              <label className="text-[11px] text-white/50">Actif</label>
              <Input
                className="mt-1 bg-zinc-900/80 border-white/20 text-white"
                value={form.asset}
                onChange={(e) => setForm((f) => ({ ...f, asset: e.target.value }))}
                placeholder="EUR, BTC…"
              />
            </div>
          </div>
          <div>
            <label className="text-[11px] text-white/50">De</label>
            <Input
              className="mt-1 bg-zinc-900/80 border-white/20 text-white"
              value={form.from}
              onChange={(e) => setForm((f) => ({ ...f, from: e.target.value }))}
            />
          </div>
          <div>
            <label className="text-[11px] text-white/50">Vers</label>
            <Input
              className="mt-1 bg-zinc-900/80 border-white/20 text-white"
              value={form.to}
              onChange={(e) => setForm((f) => ({ ...f, to: e.target.value }))}
              placeholder="Bénéficiaire ou compte"
            />
          </div>
          <div>
            <label className="text-[11px] text-white/50">Montant</label>
            <Input
              className="mt-1 bg-zinc-900/80 border-white/20 text-white"
              value={form.amount}
              onChange={(e) => setForm((f) => ({ ...f, amount: e.target.value }))}
              placeholder="ex. 100.50"
            />
          </div>
          <div>
            <label className="text-[11px] text-white/50">Mémo</label>
            <Input
              className="mt-1 bg-zinc-900/80 border-white/20 text-white"
              value={form.memo}
              onChange={(e) => setForm((f) => ({ ...f, memo: e.target.value }))}
            />
          </div>
          <Button type="button" onClick={addPending} className="w-full bg-white text-purple-800 hover:bg-white/90">
            Ajouter à la file
          </Button>
        </div>
      </div>

      <Button
        type="button"
        disabled={mining || state.pendingTransactions.length === 0}
        className="w-full h-14 rounded-2xl text-base font-semibold bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-400 hover:to-orange-500 text-white shadow-lg disabled:opacity-40"
        onClick={mine}
      >
        {mining ? (
          <>
            <RefreshCw className="w-5 h-5 animate-spin" />
            Minage en cours…
          </>
        ) : (
          <>
            <Hammer className="w-5 h-5" />
            Miner un bloc (inclut {state.pendingTransactions.length} tx)
          </>
        )}
      </Button>

      {state.pendingTransactions.length > 0 && (
        <div className="rounded-2xl border border-amber-500/30 bg-amber-950/20 p-4">
          <p className="text-sm font-medium text-amber-200 mb-2">En attente de minage</p>
          <ul className="space-y-2 text-xs text-white/80">
            {state.pendingTransactions.map((tx) => (
              <li key={tx.id} className="font-mono border-b border-white/10 pb-2">
                {tx.type} · {tx.from} → {tx.to} · {tx.amount} {tx.asset ?? ""}
                {tx.memo ? ` — ${tx.memo}` : ""}
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="space-y-2">
        <h2 className="text-lg font-semibold">Blocs</h2>
        {[...state.blocks].reverse().map((block) => (
          <motion.div
            key={block.index}
            layout
            className="rounded-2xl border border-white/10 bg-black/20 overflow-hidden"
          >
            <button
              type="button"
              className="w-full flex items-center justify-between p-4 text-left hover:bg-white/5"
              onClick={() => setExpanded((e) => (e === block.index ? null : block.index))}
            >
              <div>
                <p className="font-semibold">
                  Bloc #{block.index}{" "}
                  {block.index === 0 && (
                    <Badge variant="secondary" className="text-[10px]">
                      Genèse
                    </Badge>
                  )}
                </p>
                <p className="text-[11px] font-mono text-white/50 mt-1">{shortHash(block.hash)}</p>
              </div>
              {expanded === block.index ? <ChevronUp className="w-5 h-5" /> : <ChevronDown className="w-5 h-5" />}
            </button>
            {expanded === block.index && (
              <div className="px-4 pb-4 pt-0 space-y-2 text-xs border-t border-white/10">
                <p>
                  <span className="text-white/50">Hash précédent :</span>{" "}
                  <span className="font-mono break-all">{shortHash(block.previousHash, 12)}</span>
                </p>
                <p>
                  <span className="text-white/50">Nonce :</span> {block.nonce} ·{" "}
                  <span className="text-white/50">Tx :</span> {block.transactions.length}
                </p>
                <p className="font-mono break-all text-[10px] text-white/70">{block.hash}</p>
                <ul className="mt-2 space-y-1 text-[11px]">
                  {block.transactions.map((tx) => (
                    <li key={tx.id}>
                      {tx.type} {tx.from} → {tx.to} : {tx.amount} {tx.asset ?? ""}
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </motion.div>
        ))}
      </div>
    </div>
  );
}
