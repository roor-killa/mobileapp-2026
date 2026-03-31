import { motion } from "motion/react";
import { TrendingUp, TrendingDown, Plus, DollarSign, Percent, PieChart, Search } from "lucide-react";
import { useState, useEffect } from "react";
import { toast } from "sonner";
import BuyStockModal from "./modals/BuyStockModal";
import RealTimeInvestmentChart from "./charts/RealTimeInvestmentChart";
import MiniSparkline from "./charts/MiniSparkline";
import LEDIndicator from "./effects/LEDIndicator";
import { AreaChart, Area, XAxis, YAxis, ResponsiveContainer, Tooltip } from "recharts";

const portfolioData = [
  { date: "Jan", value: 28000 },
  { date: "Feb", value: 32000 },
  { date: "Mar", value: 30500 },
  { date: "Apr", value: 35000 },
  { date: "May", value: 38500 },
  { date: "Jun", value: 42350 },
];

// Market prices (current prices)
const marketPrices: { [key: string]: number } = {
  "AAPL": 173.00,
  "TSLA": 265.00,
  "GOOGL": 165.00,
  "MSFT": 350.00,
  "NVDA": 892.50,
  "AMD": 178.30,
  "AMZN": 182.40,
};

interface Stock {
  symbol: string;
  name: string;
  shares: number;
  buyPrice: number;
  color: string;
}

const trendingStocks = [
  { symbol: "NVDA", name: "NVIDIA", price: "$892.50", change: "+8.3%", trend: "up" },
  { symbol: "AMD", name: "Advanced Micro Devices", price: "$178.30", change: "+4.5%", trend: "up" },
  { symbol: "AMZN", name: "Amazon", price: "$182.40", change: "+2.1%", trend: "up" },
];

const marketNews = [
  { id: 1, title: "Tech Stocks Rally on AI Boom", source: "Market Watch", time: "1h ago" },
  { id: 2, title: "Federal Reserve Holds Interest Rates", source: "Financial Times", time: "3h ago" },
  { id: 3, title: "Energy Sector Shows Strong Growth", source: "Bloomberg", time: "5h ago" },
];

export default function Investments() {
  const [stocks, setStocks] = useState<Stock[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [isBuyModalOpen, setIsBuyModalOpen] = useState(false);

  // Load stocks from localStorage on mount
  useEffect(() => {
    const savedStocks = localStorage.getItem("userStocks");
    if (savedStocks) {
      setStocks(JSON.parse(savedStocks));
    }
  }, []);

  // Save stocks to localStorage whenever they change
  useEffect(() => {
    if (stocks.length > 0) {
      localStorage.setItem("userStocks", JSON.stringify(stocks));
    }
  }, [stocks]);

  const handleBuyStock = (newStock: { symbol: string; name: string; shares: number; buyPrice: number; color: string }) => {
    setStocks(prev => {
      const existingStock = prev.find(s => s.symbol === newStock.symbol);
      if (existingStock) {
        // Update existing stock - average the buy price
        const totalShares = existingStock.shares + newStock.shares;
        const avgBuyPrice = ((existingStock.buyPrice * existingStock.shares) + (newStock.buyPrice * newStock.shares)) / totalShares;
        return prev.map(s => 
          s.symbol === newStock.symbol 
            ? { ...s, shares: totalShares, buyPrice: avgBuyPrice }
            : s
        );
      } else {
        // Add new stock
        return [...prev, newStock];
      }
    });
  };

  const calculateStockMetrics = (stock: Stock) => {
    const currentPrice = marketPrices[stock.symbol] || stock.buyPrice;
    const currentValue = currentPrice * stock.shares;
    const purchaseValue = stock.buyPrice * stock.shares;
    const gainLoss = currentValue - purchaseValue;
    const gainLossPercent = ((gainLoss / purchaseValue) * 100).toFixed(2);
    const trend = gainLoss >= 0 ? "up" : "down";

    return {
      currentPrice,
      currentValue,
      gainLoss,
      gainLossPercent,
      trend,
    };
  };

  const totalValue = stocks.reduce((sum, stock) => {
    const metrics = calculateStockMetrics(stock);
    return sum + metrics.currentValue;
  }, 0);

  const totalGainLoss = stocks.reduce((sum, stock) => {
    const metrics = calculateStockMetrics(stock);
    return sum + metrics.gainLoss;
  }, 0);

  const totalGainLossPercent = stocks.length > 0 
    ? ((totalGainLoss / stocks.reduce((sum, stock) => sum + (stock.buyPrice * stock.shares), 0)) * 100).toFixed(2)
    : "0.00";

  const handleSearch = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(event.target.value);
  };

  const handleAddInvestment = () => {
    setIsBuyModalOpen(true);
  };

  const handleManageStocks = () => {
    toast.info("Manage your stock portfolio");
  };

  const handleStockClick = (symbol: string, name: string) => {
    toast.info(`Viewing details for ${symbol} - ${name}`);
  };

  const handleTrendingStockClick = (symbol: string, name: string, price: string) => {
    toast.info(`${symbol}: ${price} • Tap to buy`, {
      duration: 3000,
    });
  };

  const handleNewsClick = (title: string) => {
    toast.info(`Reading: ${title}`);
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">Investments</h1>
        <p className="text-gray-400 mt-1">Build your wealth</p>
      </motion.div>

      {/* Portfolio Overview */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.1 }}
        className="p-6 rounded-3xl bg-gradient-to-br from-emerald-600/20 via-teal-600/20 to-cyan-600/20 backdrop-blur-xl border border-white/10"
      >
        <p className="text-sm text-gray-400 mb-2">Total Portfolio Value</p>
        <h2 className="text-4xl font-bold mb-4">${totalValue.toLocaleString()}</h2>
        <div className="flex items-center gap-2 text-emerald-400 mb-6">
          <TrendingUp className="w-4 h-4" />
          <span className="text-sm font-semibold">+$4,350.00 (12.4%) all time</span>
        </div>

        {/* Portfolio Chart */}
        <div className="h-40 -mx-2">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={portfolioData}>
              <defs>
                <linearGradient id="investmentsPortfolioGradient2024" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#10b981" stopOpacity={0.4} />
                  <stop offset="100%" stopColor="#10b981" stopOpacity={0} />
                </linearGradient>
              </defs>
              <XAxis 
                dataKey="date" 
                stroke="#6b7280" 
                style={{ fontSize: "12px" }}
                axisLine={false}
                tickLine={false}
                interval="preserveStartEnd"
              />
              <YAxis 
                stroke="#6b7280" 
                style={{ fontSize: "12px" }}
                axisLine={false}
                tickLine={false}
                width={60}
              />
              <Tooltip
                contentStyle={{ backgroundColor: "#1f2937", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "12px" }}
                labelStyle={{ color: "#fff" }}
              />
              <Area
                type="monotone"
                dataKey="value"
                stroke="#10b981"
                strokeWidth={3}
                fill="url(#investmentsPortfolioGradient2024)"
                isAnimationActive={false}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </motion.div>

      {/* Search */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="relative"
      >
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Search stocks, ETFs, funds..."
          className="w-full pl-12 pr-4 py-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 transition-all"
          value={searchTerm}
          onChange={handleSearch}
        />
      </motion.div>

      {/* Your Stocks */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Portfolio Analytics</h3>
        {stocks.length > 0 && (
          <div className="p-6 rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10">
            <RealTimeInvestmentChart 
              portfolioData={stocks.map(stock => ({
                name: stock.name,
                symbol: stock.symbol,
                shares: stock.shares,
                buyPrice: stock.buyPrice,
                currentPrice: marketPrices[stock.symbol] || stock.buyPrice,
                color: stock.color,
              }))}
            />
          </div>
        )}
      </motion.div>

      {/* Your Holdings */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="space-y-3"
      >
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-semibold">Your Holdings</h3>
          {stocks.length > 0 && (
            <button className="text-sm text-blue-400 hover:text-blue-300" onClick={handleManageStocks}>Manage</button>
          )}
        </div>
        {stocks.length === 0 ? (
          <div className="p-8 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 border-dashed text-center">
            <p className="text-gray-400">No stocks yet. Start building your portfolio!</p>
          </div>
        ) : (
          stocks.map((stock, idx) => {
            const metrics = calculateStockMetrics(stock);
            return (
              <motion.div
                key={stock.symbol}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.5 + idx * 0.05 }}
                className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all cursor-pointer scan-hover"
                onClick={() => handleStockClick(stock.symbol, stock.name)}
              >
                <div className="flex items-center gap-4">
                  <div 
                    className={`w-12 h-12 rounded-xl bg-gradient-to-br ${stock.color} flex items-center justify-center font-bold`}
                  >
                    {stock.symbol.substring(0, 2)}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="font-semibold">{stock.symbol}</h4>
                      <span className="text-xs text-gray-400">{stock.name}</span>
                      <LEDIndicator color={metrics.trend === "up" ? "green" : "red"} size="sm" />
                    </div>
                    <p className="text-sm text-gray-400">{stock.shares} shares • ${stock.buyPrice.toFixed(2)}/share</p>
                    {/* Mini sparkline */}
                    <div className="h-8 mt-2 -mb-2">
                      <MiniSparkline 
                        initialValue={metrics.currentPrice}
                        color={metrics.trend === "up" ? "#10b981" : "#ef4444"}
                        trend={metrics.trend}
                      />
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold">${metrics.currentValue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
                    <p className={`text-sm flex items-center gap-1 justify-end ${metrics.trend === "up" ? "text-emerald-400" : "text-red-400"}`}>
                      {metrics.trend === "up" ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                      {metrics.gainLossPercent}%
                    </p>
                  </div>
                </div>
              </motion.div>
            );
          })
        )}
      </motion.div>

      {/* Add Investment */}
      <motion.button
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="w-full p-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-500 font-semibold shadow-xl shadow-emerald-500/30 hover:shadow-emerald-500/50 transition-all flex items-center justify-center gap-2"
        onClick={handleAddInvestment}
      >
        <Plus className="w-5 h-5" />
        <span>Buy Stocks</span>
      </motion.button>

      {/* Trending Stocks */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Trending Today</h3>
        {trendingStocks.map((stock, idx) => (
          <motion.div
            key={stock.symbol}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.8 + idx * 0.05 }}
            className="flex items-center gap-4 p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all cursor-pointer"
            onClick={() => handleTrendingStockClick(stock.symbol, stock.name, stock.price)}
          >
            <TrendingUp className="w-5 h-5 text-emerald-400" />
            <div className="flex-1">
              <h4 className="font-semibold">{stock.symbol}</h4>
              <p className="text-xs text-gray-400">{stock.name}</p>
            </div>
            <div className="text-right">
              <p className="font-semibold">{stock.price}</p>
              <p className="text-sm text-emerald-400">{stock.change}</p>
            </div>
          </motion.div>
        ))}
      </motion.div>

      {/* Market News */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.9 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Market News</h3>
        {marketNews.map((news, idx) => (
          <motion.div
            key={news.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 1 + idx * 0.05 }}
            className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all cursor-pointer"
            onClick={() => handleNewsClick(news.title)}
          >
            <h4 className="font-medium mb-1">{news.title}</h4>
            <p className="text-xs text-gray-400">{news.source} • {news.time}</p>
          </motion.div>
        ))}
      </motion.div>

      {/* Buy Stock Modal */}
      <BuyStockModal isOpen={isBuyModalOpen} onClose={() => setIsBuyModalOpen(false)} onBuy={handleBuyStock} />
    </div>
  );
}