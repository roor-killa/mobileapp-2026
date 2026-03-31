import { motion, AnimatePresence } from "motion/react";
import { X, ArrowRight } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

interface BuyCryptoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onBuy: (crypto: { symbol: string; name: string; amount: number; buyPrice: number; color: string; icon: string }) => void;
}

const cryptos = [
  { symbol: "BTC", name: "Bitcoin", icon: "₿", color: "from-orange-500 to-yellow-500", price: 62000 },
  { symbol: "ETH", name: "Ethereum", icon: "Ξ", color: "from-purple-500 to-indigo-500", price: 2510 },
  { symbol: "SOL", name: "Solana", icon: "◎", color: "from-cyan-500 to-blue-500", price: 71.50 },
  { symbol: "USDT", name: "Tether", icon: "₮", color: "from-emerald-500 to-teal-500", price: 1.00 },
  { symbol: "BNB", name: "Binance Coin", icon: "Ⓑ", color: "from-yellow-500 to-orange-500", price: 310 },
  { symbol: "ADA", name: "Cardano", icon: "₳", color: "from-blue-500 to-cyan-500", price: 0.45 },
];

export default function BuyCryptoModal({ isOpen, onClose, onBuy }: BuyCryptoModalProps) {
  const [amount, setAmount] = useState("");
  const [selectedCrypto, setSelectedCrypto] = useState<typeof cryptos[0] | null>(null);
  const [buying, setBuying] = useState(false);

  const totalCost = selectedCrypto && amount ? parseFloat(amount) : 0;
  const cryptoAmount = selectedCrypto && amount ? parseFloat(amount) / selectedCrypto.price : 0;

  const handleBuy = () => {
    if (!selectedCrypto || !amount) return;

    setBuying(true);
    setTimeout(() => {
      onBuy({
        symbol: selectedCrypto.symbol,
        name: selectedCrypto.name,
        amount: cryptoAmount,
        buyPrice: selectedCrypto.price,
        color: selectedCrypto.color,
        icon: selectedCrypto.icon,
      });
      toast.success(`Successfully bought ${cryptoAmount.toFixed(6)} ${selectedCrypto.symbol} for $${amount}!`);
      setBuying(false);
      onClose();
      setAmount("");
      setSelectedCrypto(null);
    }, 1500);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed inset-x-4 top-20 max-w-md mx-auto bg-gray-900 rounded-3xl border border-white/10 z-50 max-h-[80vh] overflow-y-auto"
          >
            <div className="p-6 space-y-6">
              {/* Header */}
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold text-white">Buy Crypto</h2>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-all"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              {/* Select Crypto */}
              <div>
                <label className="text-sm text-gray-400 mb-3 block">Select Cryptocurrency</label>
                <div className="space-y-3">
                  {cryptos.map((crypto) => (
                    <button
                      key={crypto.symbol}
                      onClick={() => setSelectedCrypto(crypto)}
                      className={`w-full flex items-center gap-4 p-4 rounded-2xl transition-all ${
                        selectedCrypto === crypto
                          ? "bg-white/20 border-2 border-blue-500"
                          : "bg-white/5 border border-white/10 hover:bg-white/10"
                      }`}
                    >
                      <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${crypto.color} flex items-center justify-center text-2xl font-bold`}>
                        {crypto.icon}
                      </div>
                      <div className="flex-1 text-left">
                        <h4 className="font-semibold text-white">{crypto.name}</h4>
                        <p className="text-sm text-gray-400">{crypto.symbol}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold text-white">${crypto.price.toLocaleString()}</p>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Amount Input */}
              <div>
                <label className="text-sm text-gray-400 mb-2 block">Amount (USD)</label>
                <div className="flex items-center gap-2 p-4 rounded-2xl bg-white/5 border border-white/10">
                  <span className="text-2xl font-bold text-gray-400">$</span>
                  <input
                    type="text"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value.replace(/[^0-9.]/g, ""))}
                    placeholder="0.00"
                    className="flex-1 bg-transparent text-3xl font-bold outline-none text-white"
                  />
                </div>
              </div>

              {/* Buy Button */}
              <button
                onClick={handleBuy}
                disabled={!amount || !selectedCrypto || buying}
                className="w-full py-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 font-semibold shadow-xl shadow-emerald-500/30 hover:shadow-emerald-500/50 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-white"
              >
                {buying ? (
                  <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Buy {selectedCrypto ? selectedCrypto.name : "Crypto"}</span>
                    <ArrowRight className="w-5 h-5" />
                  </>
                )}
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}