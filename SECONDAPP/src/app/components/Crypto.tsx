import { motion } from "motion/react";
import { TrendingUp, TrendingDown, ArrowUpRight, ArrowDownRight, Plus, Repeat, Activity } from "lucide-react";
import { useState, useEffect } from "react";
import BuyCryptoModal from "./modals/BuyCryptoModal";
import { toast } from "sonner";
import LEDIndicator from "./effects/LEDIndicator";
import RealTimeCryptoChart from "./charts/RealTimeCryptoChart";
import MiniSparkline from "./charts/MiniSparkline";
import { useTheme } from "../contexts/ThemeContext";

// Market prices (current prices)
const marketPrices: { [key: string]: number } = {
  "BTC": 62000,
  "ETH": 2510,
  "SOL": 71.50,
  "USDT": 1.00,
  "BNB": 310,
  "ADA": 0.45,
};

interface CryptoAsset {
  symbol: string;
  name: string;
  amount: number;
  buyPrice: number;
  color: string;
  icon: string;
}

const recentTransactions = [
  { id: 1, type: "Buy", crypto: "BTC", amount: "0.0234 BTC", value: "$1,450.00", time: "2h ago", icon: ArrowDownRight, color: "text-emerald-400" },
  { id: 2, type: "Sell", crypto: "ETH", amount: "0.5 ETH", value: "$1,250.00", time: "1d ago", icon: ArrowUpRight, color: "text-blue-400" },
  { id: 3, type: "Buy", crypto: "SOL", amount: "10 SOL", value: "$715.00", time: "2d ago", icon: ArrowDownRight, color: "text-emerald-400" },
];

export default function Crypto() {
  const [cryptoAssets, setCryptoAssets] = useState<CryptoAsset[]>([]);
  const [isBuyModalOpen, setIsBuyModalOpen] = useState(false);

  // Load crypto assets from localStorage on mount
  useEffect(() => {
    const savedCryptos = localStorage.getItem("userCryptos");
    if (savedCryptos) {
      setCryptoAssets(JSON.parse(savedCryptos));
    }
  }, []);

  // Save crypto assets to localStorage whenever they change
  useEffect(() => {
    if (cryptoAssets.length > 0) {
      localStorage.setItem("userCryptos", JSON.stringify(cryptoAssets));
    }
  }, [cryptoAssets]);

  const handleBuyCrypto = (newCrypto: { symbol: string; name: string; amount: number; buyPrice: number; color: string; icon: string }) => {
    setCryptoAssets(prev => {
      const existingCrypto = prev.find(c => c.symbol === newCrypto.symbol);
      if (existingCrypto) {
        // Update existing crypto - average the buy price
        const totalAmount = existingCrypto.amount + newCrypto.amount;
        const avgBuyPrice = ((existingCrypto.buyPrice * existingCrypto.amount) + (newCrypto.buyPrice * newCrypto.amount)) / totalAmount;
        return prev.map(c =>
          c.symbol === newCrypto.symbol
            ? { ...c, amount: totalAmount, buyPrice: avgBuyPrice }
            : c
        );
      } else {
        // Add new crypto
        return [...prev, newCrypto];
      }
    });
  };

  const calculateCryptoMetrics = (crypto: CryptoAsset) => {
    const currentPrice = marketPrices[crypto.symbol] || crypto.buyPrice;
    const currentValue = currentPrice * crypto.amount;
    const purchaseValue = crypto.buyPrice * crypto.amount;
    const gainLoss = currentValue - purchaseValue;
    const gainLossPercent = ((gainLoss / purchaseValue) * 100).toFixed(2);
    const trend = gainLoss >= 0 ? "up" : gainLoss < 0 ? "down" : "neutral";

    return {
      currentPrice,
      currentValue,
      gainLoss,
      gainLossPercent,
      trend,
    };
  };

  const totalValue = cryptoAssets.reduce((sum, asset) => {
    const metrics = calculateCryptoMetrics(asset);
    return sum + metrics.currentValue;
  }, 0);

  const totalGainLoss = cryptoAssets.reduce((sum, asset) => {
    const metrics = calculateCryptoMetrics(asset);
    return sum + metrics.gainLoss;
  }, 0);

  const totalGainLossPercent = cryptoAssets.length > 0
    ? ((totalGainLoss / cryptoAssets.reduce((sum, asset) => sum + (asset.buyPrice * asset.amount), 0)) * 100).toFixed(2)
    : "0.00";

  const handleSwap = () => {
    toast.info("Opening crypto swap...");
  };

  const handleViewAllTransactions = () => {
    toast.info("View all crypto transactions");
  };

  const handleAssetClick = (name: string, symbol: string) => {
    toast.info(`Viewing ${name} (${symbol}) details`);
  };

  const { theme } = useTheme();

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">Crypto Wallet</h1>
        <p className="text-gray-400 mt-1">Manage your digital assets</p>
      </motion.div>

      {/* Total Portfolio Value */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.1 }}
        className="p-6 rounded-3xl bg-gradient-to-br from-purple-400 via-pink-400 to-orange-400 backdrop-blur-xl border border-white/30 shadow-2xl"
      >
        <div className="flex items-center gap-2 mb-2">
          <p className="text-sm text-white/90 font-medium">Total Portfolio Value</p>
          <LEDIndicator color="purple" size="sm" />
        </div>
        <h2 className="text-4xl font-bold mb-1 text-white drop-shadow-lg">${totalValue.toLocaleString()}</h2>
        <div className="flex items-center gap-2 text-white">
          <TrendingUp className="w-4 h-4" />
          <span className="text-sm font-semibold">+$2,345.80 (7.8%) today</span>
        </div>
      </motion.div>

      {/* Quick Actions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="grid grid-cols-3 gap-3"
      >
        <motion.button
          whileHover={{ scale: 1.05, y: -2 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => setIsBuyModalOpen(true)}
          className="flex flex-col items-center gap-3 p-5 rounded-2xl bg-gradient-to-br from-emerald-500/20 to-teal-500/20 backdrop-blur-xl border-2 border-emerald-400/30 hover:border-emerald-400/60 transition-all group"
        >
          <div className="p-3 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-500 group-hover:scale-110 transition-transform">
            <Plus className="w-6 h-6" />
          </div>
          <div className="text-center">
            <span className="block font-semibold text-sm">Buy Crypto</span>
            <span className="block text-xs text-gray-400 mt-0.5">Add to wallet</span>
          </div>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.05, y: -2 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => toast.info("Swap crypto feature")}
          className="flex flex-col items-center gap-3 p-5 rounded-2xl bg-gradient-to-br from-blue-500/20 to-purple-500/20 backdrop-blur-xl border-2 border-blue-400/30 hover:border-blue-400/60 transition-all group"
        >
          <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-purple-500 group-hover:scale-110 transition-transform">
            <Repeat className="w-6 h-6" />
          </div>
          <div className="text-center">
            <span className="block font-semibold text-sm">Swap</span>
            <span className="block text-xs text-gray-400 mt-0.5">Exchange coins</span>
          </div>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.05, y: -2 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => toast.info("Market activity")}
          className="flex flex-col items-center gap-3 p-5 rounded-2xl bg-gradient-to-br from-orange-500/20 to-pink-500/20 backdrop-blur-xl border-2 border-orange-400/30 hover:border-orange-400/60 transition-all group"
        >
          <div className="p-3 rounded-xl bg-gradient-to-br from-orange-500 to-pink-500 group-hover:scale-110 transition-transform">
            <Activity className="w-6 h-6" />
          </div>
          <div className="text-center">
            <span className="block font-semibold text-sm">Activity</span>
            <span className="block text-xs text-gray-400 mt-0.5">View history</span>
          </div>
        </motion.button>
      </motion.div>

      {/* Crypto Assets */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Market Overview</h3>
        <div className="p-6 rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10">
          <RealTimeCryptoChart 
            cryptoId="BTC"
            cryptoName="Bitcoin"
            initialPrice={62000}
            color="#f7931a"
          />
        </div>
      </motion.div>

      {/* Your Assets */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Your Assets</h3>
        {cryptoAssets.length === 0 ? (
          <div className="p-8 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 border-dashed text-center">
            <p className="text-gray-400">No crypto yet. Start investing in digital assets!</p>
          </div>
        ) : (
          cryptoAssets.map((asset, idx) => {
            const metrics = calculateCryptoMetrics(asset);
            return (
              <motion.div
                key={asset.symbol}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.6 + idx * 0.05 }}
                className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all cursor-pointer scan-hover"
                onClick={() => handleAssetClick(asset.name, asset.symbol)}
              >
                <div className="flex items-center gap-4">
                  <div 
                    className={`w-12 h-12 rounded-xl bg-gradient-to-br ${asset.color} flex items-center justify-center text-2xl font-bold`}
                  >
                    {asset.icon}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="font-semibold">{asset.name}</h4>
                      <span className="text-xs text-gray-400">{asset.symbol}</span>
                      <LEDIndicator color={metrics.trend === "up" ? "green" : "red"} size="sm" />
                    </div>
                    <p className="text-sm text-gray-400">{asset.amount.toFixed(6)} {asset.symbol}</p>
                    {/* Mini sparkline */}
                    <div className="h-8 mt-2 -mb-2">
                      <MiniSparkline 
                        initialValue={metrics.currentPrice}
                        color={metrics.trend === "up" ? "#10b981" : "#ef4444"}
                        trend={metrics.trend as "up" | "down"}
                      />
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold">${metrics.currentValue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
                    <p className={`text-sm flex items-center gap-1 justify-end ${
                      metrics.trend === "up" ? "text-emerald-400" : 
                      metrics.trend === "down" ? "text-red-400" : 
                      "text-gray-400"
                    }`}>
                      {metrics.trend === "up" && <TrendingUp className="w-3 h-3" />}
                      {metrics.trend === "down" && <TrendingDown className="w-3 h-3" />}
                      {metrics.gainLossPercent}%
                    </p>
                  </div>
                </div>
              </motion.div>
            );
          })
        )}
      </motion.div>

      {/* Add New Asset */}
      <motion.button
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7 }}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="w-full p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 border-dashed hover:bg-white/10 transition-all flex items-center justify-center gap-2"
        onClick={() => setIsBuyModalOpen(true)}
      >
        <Plus className="w-5 h-5" />
        <span>Add New Asset</span>
      </motion.button>

      {/* Recent Transactions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        className="space-y-3"
      >
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-semibold">Recent Transactions</h3>
          <button className="text-sm text-blue-400 hover:text-blue-300" onClick={handleViewAllTransactions}>View All</button>
        </div>
        {recentTransactions.map((tx, idx) => {
          const Icon = tx.icon;
          return (
            <motion.div
              key={tx.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.9 + idx * 0.05 }}
              className="flex items-center gap-4 p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
            >
              <div className={`p-2 rounded-lg ${tx.color}`}>
                <Icon className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <h4 className="font-medium">{tx.type} {tx.crypto}</h4>
                <p className="text-xs text-gray-400">{tx.amount} • {tx.time}</p>
              </div>
              <div className="text-right">
                <p className="font-semibold">{tx.value}</p>
              </div>
            </motion.div>
          );
        })}
      </motion.div>

      {/* Buy Crypto Modal */}
      <BuyCryptoModal
        isOpen={isBuyModalOpen}
        onClose={() => setIsBuyModalOpen(false)}
        onBuy={handleBuyCrypto}
      />
    </div>
  );
}