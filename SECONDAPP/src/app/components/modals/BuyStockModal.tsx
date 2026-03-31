import { motion, AnimatePresence } from "motion/react";
import { X, ArrowRight, TrendingUp } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

interface BuyStockModalProps {
  isOpen: boolean;
  onClose: () => void;
  onBuy: (stock: { symbol: string; name: string; shares: number; buyPrice: number; color: string }) => void;
}

const popularStocks = [
  { symbol: "AAPL", name: "Apple Inc.", price: 173.00, color: "from-blue-500 to-cyan-500" },
  { symbol: "TSLA", name: "Tesla Inc.", price: 265.00, color: "from-red-500 to-orange-500" },
  { symbol: "GOOGL", name: "Alphabet Inc.", price: 165.00, color: "from-emerald-500 to-teal-500" },
  { symbol: "MSFT", name: "Microsoft Corp.", price: 350.00, color: "from-purple-500 to-pink-500" },
  { symbol: "NVDA", name: "NVIDIA Corp.", price: 892.50, color: "from-green-500 to-emerald-500" },
  { symbol: "AMD", name: "AMD", price: 178.30, color: "from-orange-500 to-red-500" },
  { symbol: "AMZN", name: "Amazon", price: 182.40, color: "from-yellow-500 to-orange-500" },
];

export default function BuyStockModal({ isOpen, onClose, onBuy }: BuyStockModalProps) {
  const [selectedStock, setSelectedStock] = useState<typeof popularStocks[0] | null>(null);
  const [shares, setShares] = useState("");
  const [pricePerShare, setPricePerShare] = useState("");
  const [buying, setBuying] = useState(false);

  const totalCost = selectedStock && shares && pricePerShare
    ? parseFloat(shares) * parseFloat(pricePerShare)
    : 0;

  const handleStockSelect = (stock: typeof popularStocks[0]) => {
    setSelectedStock(stock);
    setPricePerShare(stock.price.toString());
  };

  const handleBuy = () => {
    if (!selectedStock || !shares || !pricePerShare) return;

    setBuying(true);
    setTimeout(() => {
      onBuy({
        symbol: selectedStock.symbol,
        name: selectedStock.name,
        shares: parseFloat(shares),
        buyPrice: parseFloat(pricePerShare),
        color: selectedStock.color,
      });
      toast.success(`Successfully bought ${shares} shares of ${selectedStock.symbol} at $${pricePerShare} per share!`);
      setBuying(false);
      onClose();
      setSelectedStock(null);
      setShares("");
      setPricePerShare("");
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
                <h2 className="text-2xl font-bold text-white">Buy Stocks</h2>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-all"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              {/* Select Stock */}
              <div>
                <label className="text-sm text-gray-400 mb-3 block">Select Stock</label>
                <div className="space-y-2 max-h-64 overflow-y-auto pr-2">
                  {popularStocks.map((stock) => (
                    <button
                      key={stock.symbol}
                      onClick={() => handleStockSelect(stock)}
                      className={`w-full flex items-center gap-3 p-3 rounded-xl transition-all ${
                        selectedStock?.symbol === stock.symbol
                          ? "bg-white/20 border-2 border-emerald-500"
                          : "bg-white/5 border border-white/10 hover:bg-white/10"
                      }`}
                    >
                      <div className={`w-10 h-10 rounded-lg bg-gradient-to-br ${stock.color} flex items-center justify-center text-sm font-bold`}>
                        {stock.symbol.substring(0, 2)}
                      </div>
                      <div className="flex-1 text-left">
                        <h4 className="font-semibold text-white text-sm">{stock.symbol}</h4>
                        <p className="text-xs text-gray-400">{stock.name}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold text-white text-sm">${stock.price}</p>
                        <div className="flex items-center gap-1 text-xs text-emerald-400">
                          <TrendingUp className="w-3 h-3" />
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Number of Shares */}
              <div>
                <label className="text-sm text-gray-400 mb-2 block">Number of Shares</label>
                <div className="flex items-center gap-2 p-4 rounded-2xl bg-white/5 border border-white/10">
                  <input
                    type="text"
                    value={shares}
                    onChange={(e) => setShares(e.target.value.replace(/[^0-9]/g, ""))}
                    placeholder="0"
                    className="flex-1 bg-transparent text-2xl font-bold outline-none text-white"
                  />
                  <span className="text-sm text-gray-400">shares</span>
                </div>
              </div>

              {/* Price Per Share */}
              <div>
                <label className="text-sm text-gray-400 mb-2 block">Price Per Share (USD)</label>
                <div className="flex items-center gap-2 p-4 rounded-2xl bg-white/5 border border-white/10">
                  <span className="text-2xl font-bold text-gray-400">$</span>
                  <input
                    type="text"
                    value={pricePerShare}
                    onChange={(e) => setPricePerShare(e.target.value.replace(/[^0-9.]/g, ""))}
                    placeholder="0.00"
                    className="flex-1 bg-transparent text-2xl font-bold outline-none text-white"
                  />
                </div>
                {selectedStock && (
                  <p className="text-xs text-gray-400 mt-2">Current market price: ${selectedStock.price}</p>
                )}
              </div>

              {/* Total Cost */}
              {totalCost > 0 && (
                <div className="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/20">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Total Cost</span>
                    <span className="text-2xl font-bold text-emerald-400">
                      ${totalCost.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </span>
                  </div>
                </div>
              )}

              {/* Buy Button */}
              <button
                onClick={handleBuy}
                disabled={!selectedStock || !shares || !pricePerShare || buying}
                className="w-full py-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 font-semibold shadow-xl shadow-emerald-500/30 hover:shadow-emerald-500/50 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-white"
              >
                {buying ? (
                  <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Buy {selectedStock?.symbol || "Stock"}</span>
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