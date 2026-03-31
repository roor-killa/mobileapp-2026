import { motion } from "motion/react";
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Tooltip, Legend } from "recharts";
import { TrendingUp, TrendingDown, DollarSign, ShoppingBag, Home, Car, Coffee, Zap, Smartphone } from "lucide-react";

const spendingCategories = [
  { name: "Shopping", value: 1840, percent: 28, color: "#3b82f6", icon: ShoppingBag },
  { name: "Housing", value: 1500, percent: 23, color: "#a855f7", icon: Home },
  { name: "Transport", value: 980, percent: 15, color: "#10b981", icon: Car },
  { name: "Food & Drink", value: 850, percent: 13, color: "#f59e0b", icon: Coffee },
  { name: "Utilities", value: 720, percent: 11, color: "#ef4444", icon: Zap },
  { name: "Entertainment", value: 650, percent: 10, color: "#ec4899", icon: Smartphone },
];

const monthlySpending = [
  { month: "Jan", spending: 5200, income: 6800 },
  { month: "Feb", spending: 5800, income: 6800 },
  { month: "Mar", spending: 5400, income: 6800 },
  { month: "Apr", spending: 6200, income: 6800 },
  { month: "May", spending: 5900, income: 7200 },
  { month: "Jun", spending: 6540, income: 7500 },
];

const insights = [
  {
    title: "Top Spending Category",
    value: "Shopping",
    amount: "$1,840",
    change: "+12%",
    trend: "up",
    color: "from-blue-500 to-cyan-500"
  },
  {
    title: "Average Daily Spend",
    value: "$218",
    amount: "vs $245 last month",
    change: "-11%",
    trend: "down",
    color: "from-emerald-500 to-teal-500"
  },
  {
    title: "Savings Rate",
    value: "18.4%",
    amount: "$1,380 saved",
    change: "+5%",
    trend: "up",
    color: "from-purple-500 to-pink-500"
  },
];

export default function Analytics() {
  const totalSpending = spendingCategories.reduce((sum, cat) => sum + cat.value, 0);

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">Analytics</h1>
        <p className="text-gray-400 mt-1">Track your spending</p>
      </motion.div>

      {/* Quick Stats */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="grid grid-cols-3 gap-3"
      >
        {insights.map((insight, idx) => (
          <motion.div
            key={insight.title}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2 + idx * 0.05 }}
            className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
          >
            <div className={`inline-flex p-2 rounded-lg bg-gradient-to-br ${insight.color} mb-2`}>
              <DollarSign className="w-4 h-4" />
            </div>
            <p className="text-xs text-gray-400 mb-1">{insight.title}</p>
            <p className="text-lg font-bold">{insight.value}</p>
            <p className={`text-xs mt-1 ${insight.trend === "up" ? "text-emerald-400" : "text-blue-400"}`}>
              {insight.change}
            </p>
          </motion.div>
        ))}
      </motion.div>

      {/* Monthly Overview */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="p-6 rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10"
      >
        <h3 className="text-lg font-semibold mb-4">Monthly Overview</h3>
        <div className="h-56">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={monthlySpending}>
              <XAxis dataKey="month" stroke="#6b7280" style={{ fontSize: "12px" }} />
              <YAxis stroke="#6b7280" style={{ fontSize: "12px" }} />
              <Tooltip
                contentStyle={{
                  backgroundColor: "#1f2937",
                  border: "1px solid rgba(255,255,255,0.1)",
                  borderRadius: "12px"
                }}
                labelStyle={{ color: "#fff" }}
              />
              <Legend wrapperStyle={{ fontSize: "12px" }} />
              <Bar dataKey="spending" fill="#ef4444" radius={[8, 8, 0, 0]} isAnimationActive={false} />
              <Bar dataKey="income" fill="#10b981" radius={[8, 8, 0, 0]} isAnimationActive={false} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </motion.div>

      {/* Spending Categories - Pie Chart */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="p-6 rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10"
      >
        <h3 className="text-lg font-semibold mb-4">Spending by Category</h3>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={spendingCategories}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={90}
                paddingAngle={5}
                dataKey="value"
              >
                {spendingCategories.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{
                  backgroundColor: "#1f2937",
                  border: "1px solid rgba(255,255,255,0.1)",
                  borderRadius: "12px"
                }}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </motion.div>

      {/* Category Breakdown */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Category Breakdown</h3>
        {spendingCategories.map((category, idx) => {
          const Icon = category.icon;
          return (
            <motion.div
              key={category.name}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.6 + idx * 0.05 }}
              className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
            >
              <div className="flex items-center gap-4 mb-3">
                <div
                  className="p-3 rounded-xl"
                  style={{ backgroundColor: category.color }}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <h4 className="font-semibold">{category.name}</h4>
                  <p className="text-sm text-gray-400">{category.percent}% of spending</p>
                </div>
                <div className="text-right">
                  <p className="font-semibold">${category.value.toLocaleString()}</p>
                </div>
              </div>
              <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                <div
                  className="h-full rounded-full transition-all"
                  style={{
                    width: `${category.percent}%`,
                    backgroundColor: category.color
                  }}
                ></div>
              </div>
            </motion.div>
          );
        })}
      </motion.div>

      {/* AI Insights */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        className="p-6 rounded-3xl bg-gradient-to-br from-purple-600/20 via-pink-600/20 to-orange-600/20 backdrop-blur-xl border border-white/10"
      >
        <div className="flex items-start gap-3">
          <div className="p-3 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500">
            <Smartphone className="w-5 h-5" />
          </div>
          <div className="flex-1">
            <h3 className="font-semibold mb-2">AI Financial Insight</h3>
            <p className="text-sm text-gray-300 mb-3">
              Based on your spending patterns, you could save an additional $420/month by reducing shopping expenses by 15% and switching to a lower-cost transportation option.
            </p>
            <button className="text-sm text-blue-400 hover:text-blue-300 font-medium">
              View Detailed Recommendations →
            </button>
          </div>
        </div>
      </motion.div>

      {/* Summary */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.9 }}
        className="p-5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 space-y-3"
      >
        <div className="flex justify-between">
          <span className="text-gray-400">Total Spending (June)</span>
          <span className="font-semibold text-red-400">${totalSpending.toLocaleString()}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-400">Total Income</span>
          <span className="font-semibold text-emerald-400">$7,500</span>
        </div>
        <div className="h-px bg-white/10"></div>
        <div className="flex justify-between">
          <span className="text-gray-400">Net Savings</span>
          <span className="font-bold text-emerald-400">
            ${(7500 - totalSpending).toLocaleString()}
          </span>
        </div>
      </motion.div>
    </div>
  );
}