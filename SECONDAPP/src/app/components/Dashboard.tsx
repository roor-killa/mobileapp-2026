import { motion } from "motion/react";
import { 
  Eye, EyeOff, Send, Download, TrendingUp, Wallet, 
  Zap, ArrowDownRight, ShoppingBag, Home as HomeIcon, Coffee 
} from "lucide-react";
import { useEffect, useState } from "react";
import { LineChart, Line, AreaChart, Area, XAxis, YAxis, ResponsiveContainer, Tooltip } from "recharts";
import SendMoneyModal from "./modals/SendMoneyModal";
import { useNavigate } from "react-router";
import { toast } from "sonner";
import HolographicCard from "./effects/HolographicCard";
import AnimatedBorder from "./effects/AnimatedBorder";
import LEDIndicator from "./effects/LEDIndicator";
import { useTheme } from "../contexts/ThemeContext";
import { getDashboardData, type DashboardInsight, type DashboardTransaction, type DashboardBalancePoint } from "../services/dashboardApi";

const iconMap = {
  zap: Zap,
  "arrow-down-right": ArrowDownRight,
  "shopping-bag": ShoppingBag,
  home: HomeIcon,
  coffee: Coffee,
};

export default function Dashboard() {
  const [showBalance, setShowBalance] = useState(true);
  const [isSendMoneyModalOpen, setIsSendMoneyModalOpen] = useState(false);
  const [balanceData, setBalanceData] = useState<DashboardBalancePoint[]>([]);
  const [transactions, setTransactions] = useState<DashboardTransaction[]>([]);
  const [insights, setInsights] = useState<DashboardInsight[]>([]);
  const [isDataAvailable, setIsDataAvailable] = useState(false);
  const navigate = useNavigate();
  const { theme } = useTheme();

  useEffect(() => {
    let isMounted = true;

    getDashboardData().then((data) => {
      if (!isMounted) return;

      if (!data) {
        setIsDataAvailable(false);
        setBalanceData([]);
        setTransactions([]);
        setInsights([]);
        return;
      }

      setIsDataAvailable(true);
      setBalanceData(data.balanceData);
      setTransactions(data.transactions);
      setInsights(data.insights);
    });

    return () => {
      isMounted = false;
    };
  }, []);

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold mb-1">Welcome back,</h1>
        <p className="text-gray-400">Alex Johnson</p>
      </motion.div>

      {/* Balance Card */}
      <HolographicCard>
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className={`relative overflow-hidden rounded-3xl bg-gradient-to-br ${theme.gradient} p-6 shadow-2xl`}
        >
          <div className="absolute inset-0 bg-gradient-to-br from-white/20 to-transparent"></div>
          <div className="relative z-10">
            <div className="flex justify-between items-start mb-4">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <p className="text-white/90 text-sm font-medium">Total Balance</p>
                  <LEDIndicator color="green" size="sm" />
                </div>
                <div className="flex items-center gap-3">
                  {showBalance ? (
                    <h2 className="text-4xl font-bold text-white drop-shadow-lg">$73,542.00</h2>
                  ) : (
                    <h2 className="text-4xl font-bold">••••••</h2>
                  )}
                  <button
                    onClick={() => setShowBalance(!showBalance)}
                    className="p-2 rounded-full bg-white/30 backdrop-blur-sm hover:bg-white/40 transition-all hover:scale-110"
                  >
                    {showBalance ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>
            </div>

            {/* Mini Chart */}
            <div className="h-20 -mx-6 -mb-6 mt-4">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={balanceData}>
                  <defs>
                    <linearGradient id="dashboardBalanceGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="rgba(255,255,255,0.6)" />
                      <stop offset="100%" stopColor="rgba(255,255,255,0)" />
                    </linearGradient>
                  </defs>
                  <Area
                    type="monotone"
                    dataKey="value"
                    stroke="rgba(255,255,255,0.9)"
                    strokeWidth={3}
                    fill="url(#dashboardBalanceGradient)"
                    isAnimationActive={false}
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>
        </motion.div>
      </HolographicCard>

      {!isDataAvailable && (
        <div className="p-4 rounded-2xl bg-amber-500/10 border border-amber-500/30 text-amber-200 text-sm">
          Donnees indisponibles : demarre Docker pour charger la base.
        </div>
      )}

      {/* Quick Actions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
        className="grid grid-cols-2 gap-4"
      >
        <motion.button
          whileHover={{ scale: 1.03, y: -2 }}
          whileTap={{ scale: 0.97 }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.3 }}
          onClick={() => setIsSendMoneyModalOpen(true)}
          className="flex items-center gap-4 p-5 rounded-2xl bg-gradient-to-r from-blue-500/20 to-cyan-500/20 backdrop-blur-xl border-2 border-blue-400/30 hover:border-blue-400/60 transition-all w-full group"
        >
          <div className="p-4 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 group-hover:scale-110 transition-transform">
            <Send className="w-6 h-6" />
          </div>
          <div className="text-left flex-1">
            <span className="block font-semibold text-base">Send Money</span>
            <span className="block text-xs text-gray-400 mt-0.5">Transfer to anyone</span>
          </div>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.03, y: -2 }}
          whileTap={{ scale: 0.97 }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.35 }}
          onClick={() => navigate("/transfers")}
          className="flex items-center gap-4 p-5 rounded-2xl bg-gradient-to-r from-emerald-500/20 to-teal-500/20 backdrop-blur-xl border-2 border-emerald-400/30 hover:border-emerald-400/60 transition-all w-full group"
        >
          <div className="p-4 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-500 group-hover:scale-110 transition-transform">
            <Download className="w-6 h-6" />
          </div>
          <div className="text-left flex-1">
            <span className="block font-semibold text-base">Receive</span>
            <span className="block text-xs text-gray-400 mt-0.5">Get paid easily</span>
          </div>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.03, y: -2 }}
          whileTap={{ scale: 0.97 }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.4 }}
          onClick={() => navigate("/investments")}
          className="flex items-center gap-4 p-5 rounded-2xl bg-gradient-to-r from-purple-500/20 to-pink-500/20 backdrop-blur-xl border-2 border-purple-400/30 hover:border-purple-400/60 transition-all w-full group"
        >
          <div className="p-4 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 group-hover:scale-110 transition-transform">
            <TrendingUp className="w-6 h-6" />
          </div>
          <div className="text-left flex-1">
            <span className="block font-semibold text-base">Invest</span>
            <span className="block text-xs text-gray-400 mt-0.5">Grow your wealth</span>
          </div>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.03, y: -2 }}
          whileTap={{ scale: 0.97 }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.45 }}
          onClick={() => navigate("/cards")}
          className="flex items-center gap-4 p-5 rounded-2xl bg-gradient-to-r from-orange-500/20 to-red-500/20 backdrop-blur-xl border-2 border-orange-400/30 hover:border-orange-400/60 transition-all w-full group"
        >
          <div className="p-4 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 group-hover:scale-110 transition-transform">
            <Wallet className="w-6 h-6" />
          </div>
          <div className="text-left flex-1">
            <span className="block font-semibold text-base">Pay Bills</span>
            <span className="block text-xs text-gray-400 mt-0.5">Quick payments</span>
          </div>
        </motion.button>
      </motion.div>

      {/* Smart Insights */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.4 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Smart Insights</h3>
        {insights.map((insight, idx) => (
          <motion.div
            key={insight.title}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.4, delay: 0.5 + idx * 0.1 }}
            className="p-4 rounded-2xl bg-white/20 backdrop-blur-xl border border-white/30 shadow-lg"
          >
            <div className="flex justify-between items-start mb-2">
              <h4 className="font-semibold">{insight.title}</h4>
              <span className={`text-lg font-bold ${
                insight.trend === "up" ? "text-emerald-300" : "text-orange-300"
              }`}>
                {insight.value}
              </span>
            </div>
            <p className="text-sm text-white/80">{insight.description}</p>
          </motion.div>
        ))}
        {insights.length === 0 && (
          <div className="p-4 rounded-2xl bg-white/10 border border-white/20 text-sm text-gray-300">
            Aucune donnee disponible.
          </div>
        )}
      </motion.div>

      {/* Recent Transactions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.6 }}
        className="space-y-3"
      >
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-semibold">Recent Transactions</h3>
          <button 
            className="text-sm text-cyan-300 hover:text-cyan-200 font-medium"
            onClick={() => {
              navigate("/analytics");
              toast.info("Viewing all transactions");
            }}
          >
            View All
          </button>
        </div>
        {transactions.map((transaction, idx) => {
          const Icon = iconMap[transaction.icon as keyof typeof iconMap] ?? Wallet;
          return (
            <motion.div
              key={transaction.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.4, delay: 0.7 + idx * 0.05 }}
              className="flex items-center gap-4 p-4 rounded-2xl bg-white/20 backdrop-blur-xl border border-white/30 hover:bg-white/30 transition-all scan-hover cursor-pointer shadow-lg"
            >
              <div className={`p-3 rounded-xl bg-gradient-to-br ${transaction.color} shadow-lg`}>
                <Icon className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <h4 className="font-semibold">{transaction.name}</h4>
                <p className="text-xs text-white/70">{transaction.category} • {transaction.time}</p>
              </div>
              <div className={`font-bold ${transaction.amount > 0 ? "text-emerald-300" : "text-white"}`}>
                {transaction.amount > 0 ? "+" : ""}${Math.abs(transaction.amount).toFixed(2)}
              </div>
            </motion.div>
          );
        })}
        {transactions.length === 0 && (
          <div className="p-4 rounded-2xl bg-white/10 border border-white/20 text-sm text-gray-300">
            Aucune transaction a afficher.
          </div>
        )}
      </motion.div>

      {/* Send Money Modal */}
      <SendMoneyModal
        isOpen={isSendMoneyModalOpen}
        onClose={() => setIsSendMoneyModalOpen(false)}
      />
    </div>
  );
}