import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "motion/react";
import { LineChart, Line, AreaChart, Area, PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar } from "recharts";
import { TrendingUp, TrendingDown, Activity, PieChart as PieIcon, BarChart3, Radar as RadarIcon, Sparkles, Target } from "lucide-react";

interface InvestmentChartProps {
  portfolioData: Array<{
    name: string;
    symbol: string;
    shares: number;
    buyPrice: number;
    currentPrice: number;
    color: string;
  }>;
}

export default function RealTimeInvestmentChart({ portfolioData }: InvestmentChartProps) {
  const [timeSeriesData, setTimeSeriesData] = useState<any[]>([]);
  const [chartType, setChartType] = useState<"timeline" | "allocation" | "performance" | "radar">("timeline");
  const [totalValue, setTotalValue] = useState(0);
  const [totalChange, setTotalChange] = useState(0);
  const [isUpdating, setIsUpdating] = useState(false);
  const chartId = useRef(`chart-${Math.random().toString(36).substr(2, 9)}`).current;

  // Initialize timeline data
  useEffect(() => {
    if (portfolioData.length === 0) return;
    
    const points = 30;
    const initialData = [];
    const now = Date.now();
    
    for (let i = 0; i < points; i++) {
      const dataPoint: any = {
        time: `${points - i}m`,
        total: 0,
        timestamp: now + i * 1000,
      };
      
      portfolioData.forEach(stock => {
        const baseValue = stock.shares * stock.currentPrice;
        const volatility = baseValue * 0.01;
        const value = baseValue + (Math.random() - 0.5) * volatility;
        dataPoint[stock.symbol] = value;
        dataPoint.total += value;
      });
      
      initialData.push(dataPoint);
    }
    
    setTimeSeriesData(initialData);
    
    const currentTotal = initialData[initialData.length - 1].total;
    const invested = portfolioData.reduce((sum, stock) => sum + (stock.shares * stock.buyPrice), 0);
    setTotalValue(currentTotal);
    setTotalChange(((currentTotal - invested) / invested) * 100);
  }, [portfolioData]);

  // Real-time updates
  useEffect(() => {
    if (portfolioData.length === 0) return;
    
    const interval = setInterval(() => {
      setIsUpdating(true);
      
      setTimeSeriesData(prevData => {
        const newData = [...prevData];
        const dataPoint: any = {
          time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
          total: 0,
          timestamp: Date.now(),
        };
        
        portfolioData.forEach(stock => {
          const lastValue = newData[newData.length - 1][stock.symbol];
          const volatility = lastValue * 0.005;
          const change = (Math.random() - 0.5) * volatility;
          const newValue = Math.max(lastValue + change, stock.shares * stock.currentPrice * 0.9);
          dataPoint[stock.symbol] = newValue;
          dataPoint.total += newValue;
        });
        
        newData.shift();
        newData.push(dataPoint);
        
        const invested = portfolioData.reduce((sum, stock) => sum + (stock.shares * stock.buyPrice), 0);
        setTotalValue(dataPoint.total);
        setTotalChange(((dataPoint.total - invested) / invested) * 100);
        
        setTimeout(() => setIsUpdating(false), 300);
        
        return newData;
      });
    }, 4000);

    return () => clearInterval(interval);
  }, [portfolioData]);

  const allocationData = portfolioData.map(stock => ({
    name: stock.name,
    symbol: stock.symbol,
    value: stock.shares * stock.currentPrice,
    color: stock.color,
  }));

  const performanceData = portfolioData.map(stock => {
    const current = stock.shares * stock.currentPrice;
    const invested = stock.shares * stock.buyPrice;
    const change = ((current - invested) / invested) * 100;
    return {
      name: stock.symbol,
      performance: change,
      color: stock.color,
    };
  });

  const totalInvested = portfolioData.reduce((sum, s) => sum + (s.shares * s.buyPrice), 0);
  const diversificationScore = Math.min(100, portfolioData.length * 20);
  const avgPerformance = performanceData.reduce((sum, p) => sum + p.performance, 0) / performanceData.length;
  
  const radarData = [
    {
      metric: 'Returns',
      value: Math.max(0, Math.min(100, 50 + avgPerformance)),
    },
    {
      metric: 'Volatility',
      value: Math.min(100, Math.abs(totalChange) * 5),
    },
    {
      metric: 'Diversification',
      value: diversificationScore,
    },
    {
      metric: 'Risk',
      value: Math.min(100, 50 + Math.random() * 20),
    },
    {
      metric: 'Liquidity',
      value: 80,
    },
  ];

  const CustomTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      return (
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-gray-900/98 backdrop-blur-xl border border-white/30 rounded-2xl p-4 shadow-2xl"
          style={{
            boxShadow: `0 0 30px rgba(16, 185, 129, 0.3), 0 0 60px rgba(59, 130, 246, 0.2)`,
          }}
        >
          <div className="flex items-center gap-2 mb-3 pb-2 border-b border-white/10">
            <Target className="w-4 h-4 text-emerald-400" />
            <p className="text-white font-bold">{payload[0].payload.time}</p>
          </div>
          <div className="space-y-2 text-sm">
            {payload.map((entry: any, index: number) => (
              <div key={index} className="flex justify-between gap-6">
                <span style={{ color: entry.color }} className="font-semibold">
                  {entry.name}
                </span>
                <span className="text-white font-bold">
                  ${entry.value?.toFixed(2) || 0}
                </span>
              </div>
            ))}
          </div>
        </motion.div>
      );
    }
    return null;
  };

  const renderCustomLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent, name }: any) => {
    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    const x = cx + radius * Math.cos(-midAngle * Math.PI / 180);
    const y = cy + radius * Math.sin(-midAngle * Math.PI / 180);

    if (percent < 0.05) return null;

    return (
      <text 
        x={x} 
        y={y} 
        fill="white" 
        textAnchor={x > cx ? 'start' : 'end'} 
        dominantBaseline="central"
        className="text-xs font-bold"
      >
        {`${(percent * 100).toFixed(0)}%`}
      </text>
    );
  };

  if (portfolioData.length === 0) {
    return (
      <div className="flex items-center justify-center h-96 text-gray-400">
        <div className="text-center">
          <Sparkles className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p>No portfolio data available</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2">
            <h3 className="text-xl font-bold text-white">Portfolio Performance</h3>
            <div className={`px-2 py-1 rounded-lg text-xs font-semibold ${
              totalChange >= 0 ? "bg-emerald-500/20 text-emerald-400" : "bg-red-500/20 text-red-400"
            }`}>
              {portfolioData.length} Holdings
            </div>
          </div>
          <div className="flex items-baseline gap-4 flex-wrap">
            <motion.div
              key={totalValue}
              initial={{ scale: 1.1 }}
              animate={{ scale: 1 }}
              className="relative"
            >
              <AnimatePresence mode="wait">
                {isUpdating && (
                  <motion.div
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0 }}
                    className="absolute -inset-2 bg-gradient-to-r from-emerald-500/20 to-blue-500/20 rounded-xl blur-xl"
                  />
                )}
              </AnimatePresence>
              <span className={`relative text-4xl font-bold ${
                totalChange >= 0 ? "text-emerald-400" : "text-red-400"
              }`}>
                ${totalValue.toFixed(2)}
              </span>
            </motion.div>
            <div className={`flex items-center gap-2 px-3 py-2 rounded-xl ${
              totalChange >= 0 
                ? "bg-emerald-500/10 border border-emerald-500/30" 
                : "bg-red-500/10 border border-red-500/30"
            }`}>
              {totalChange >= 0 ? (
                <TrendingUp className="w-5 h-5 text-emerald-400" />
              ) : (
                <TrendingDown className="w-5 h-5 text-red-400" />
              )}
              <span className={`font-bold text-lg ${
                totalChange >= 0 ? "text-emerald-400" : "text-red-400"
              }`}>
                {totalChange >= 0 ? "+" : ""}{totalChange.toFixed(2)}%
              </span>
            </div>
          </div>
        </div>
        <div className="flex flex-col items-end gap-2">
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/20 border border-emerald-500/50">
            <motion.div
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ repeat: Infinity, duration: 2 }}
            >
              <Activity className="w-4 h-4 text-emerald-400" />
            </motion.div>
            <span className="text-xs font-semibold text-emerald-400">LIVE</span>
          </div>
          <span className="text-xs text-gray-500">Updates every 4s</span>
        </div>
      </div>

      {/* Chart Type Selector */}
      <div className="flex gap-2 flex-wrap">
        {[
          { key: "timeline", icon: BarChart3, label: "Timeline", color: "from-blue-500 to-cyan-500" },
          { key: "allocation", icon: PieIcon, label: "Allocation", color: "from-purple-500 to-pink-500" },
          { key: "performance", icon: TrendingUp, label: "Performance", color: "from-emerald-500 to-green-500" },
          { key: "radar", icon: RadarIcon, label: "Analysis", color: "from-pink-500 to-rose-500" },
        ].map(({ key, icon: Icon, label, color }) => (
          <button
            key={key}
            onClick={() => setChartType(key as any)}
            className={`relative flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all overflow-hidden ${
              chartType === key
                ? "text-white"
                : "bg-white/5 text-gray-400 hover:bg-white/10 hover:text-white"
            }`}
          >
            {chartType === key && (
              <motion.div
                layoutId="portfolio-chart-bg"
                className={`absolute inset-0 bg-gradient-to-r ${color}`}
                style={{ borderRadius: "0.75rem" }}
                transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
              />
            )}
            <Icon className="w-4 h-4 relative z-10" />
            <span className="relative z-10">{label}</span>
          </button>
        ))}
      </div>

      {/* Chart */}
      <div className="relative">
        <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 via-blue-500/5 to-purple-500/5 rounded-3xl blur-3xl" />
        <div className="relative h-96 bg-gray-900/40 backdrop-blur-xl rounded-3xl border border-white/10 p-6 shadow-2xl">
          <ResponsiveContainer width="100%" height="100%">
            {chartType === "timeline" ? (
              <AreaChart data={timeSeriesData}>
                <defs>
                  {portfolioData.map((stock) => (
                    <linearGradient key={stock.symbol} id={`gradient-${stock.symbol}`} x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor={stock.color} stopOpacity={0.4} />
                      <stop offset="100%" stopColor={stock.color} stopOpacity={0.05} />
                    </linearGradient>
                  ))}
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                <XAxis 
                  dataKey="time" 
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                />
                <YAxis 
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                />
                <Tooltip content={<CustomTooltip />} cursor={{ stroke: '#10b981', strokeWidth: 1, strokeDasharray: '5 5' }} />
                <Legend 
                  wrapperStyle={{ color: 'rgba(255,255,255,0.7)', fontSize: '12px', fontWeight: 600 }}
                  iconType="circle"
                />
                {portfolioData.map((stock) => (
                  <Area
                    key={stock.symbol}
                    type="monotone"
                    dataKey={stock.symbol}
                    stroke={stock.color}
                    fill={`url(#gradient-${stock.symbol})`}
                    strokeWidth={2}
                    isAnimationActive={false}
                    stackId="1"
                  />
                ))}
              </AreaChart>
            ) : chartType === "allocation" ? (
              <PieChart>
                <Pie
                  data={allocationData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={renderCustomLabel}
                  outerRadius={140}
                  innerRadius={60}
                  fill="#8884d8"
                  dataKey="value"
                  isAnimationActive={true}
                  animationDuration={1000}
                  animationBegin={0}
                >
                  {allocationData.map((entry, index) => (
                    <Cell 
                      key={`cell-${index}`} 
                      fill={entry.color}
                      stroke="rgba(255,255,255,0.1)"
                      strokeWidth={2}
                    />
                  ))}
                </Pie>
                <Tooltip 
                  content={({ active, payload }: any) => {
                    if (active && payload && payload.length) {
                      const percent = (payload[0].value / totalValue) * 100;
                      return (
                        <motion.div
                          initial={{ opacity: 0, scale: 0.9 }}
                          animate={{ opacity: 1, scale: 1 }}
                          className="bg-gray-900/98 backdrop-blur-xl border border-white/30 rounded-2xl p-4 shadow-2xl"
                        >
                          <p className="text-white font-bold mb-2">{payload[0].payload.symbol}</p>
                          <div className="space-y-1 text-sm">
                            <p className="text-gray-400">Value: <span className="text-emerald-400 font-semibold">${payload[0].value.toFixed(2)}</span></p>
                            <p className="text-gray-400">Share: <span className="text-purple-400 font-semibold">{percent.toFixed(1)}%</span></p>
                          </div>
                        </motion.div>
                      );
                    }
                    return null;
                  }}
                />
                <Legend 
                  verticalAlign="bottom" 
                  height={50}
                  wrapperStyle={{ color: 'rgba(255,255,255,0.7)', fontSize: '12px', fontWeight: 600 }}
                  formatter={(value, entry: any) => entry.payload.symbol}
                />
              </PieChart>
            ) : chartType === "performance" ? (
              <BarChart data={performanceData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                <XAxis 
                  dataKey="name" 
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                />
                <YAxis 
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                  label={{ value: 'Return %', angle: -90, position: 'insideLeft', fill: 'rgba(255,255,255,0.5)', fontWeight: 600 }}
                />
                <Tooltip 
                  content={({ active, payload }: any) => {
                    if (active && payload && payload.length) {
                      return (
                        <motion.div
                          initial={{ opacity: 0, scale: 0.9 }}
                          animate={{ opacity: 1, scale: 1 }}
                          className="bg-gray-900/98 backdrop-blur-xl border border-white/30 rounded-2xl p-4 shadow-2xl"
                        >
                          <p className="text-white font-bold mb-2">{payload[0].payload.name}</p>
                          <p className={`text-lg font-bold ${payload[0].value >= 0 ? "text-emerald-400" : "text-red-400"}`}>
                            {payload[0].value >= 0 ? "+" : ""}{payload[0].value.toFixed(2)}%
                          </p>
                        </motion.div>
                      );
                    }
                    return null;
                  }}
                  cursor={{ fill: 'rgba(255,255,255,0.05)' }}
                />
                <Bar dataKey="performance" radius={[8, 8, 0, 0]} isAnimationActive={true}>
                  {performanceData.map((entry, index) => (
                    <Cell 
                      key={`cell-${index}`} 
                      fill={entry.performance >= 0 ? "#10b981" : "#ef4444"}
                      opacity={0.9}
                    />
                  ))}
                </Bar>
              </BarChart>
            ) : (
              <RadarChart cx="50%" cy="50%" outerRadius="75%" data={radarData}>
                <PolarGrid stroke="rgba(255,255,255,0.1)" />
                <PolarAngleAxis 
                  dataKey="metric" 
                  tick={{ fill: 'rgba(255,255,255,0.7)', fontSize: 13, fontWeight: 600 }}
                />
                <PolarRadiusAxis 
                  angle={90} 
                  domain={[0, 100]} 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.2)' }}
                />
                <Radar 
                  name="Portfolio Metrics" 
                  dataKey="value" 
                  stroke="#8b5cf6" 
                  fill="#8b5cf6" 
                  fillOpacity={0.6}
                  strokeWidth={2}
                  isAnimationActive={true}
                />
                <Tooltip 
                  content={({ active, payload }: any) => {
                    if (active && payload && payload.length) {
                      return (
                        <motion.div
                          initial={{ opacity: 0, scale: 0.9 }}
                          animate={{ opacity: 1, scale: 1 }}
                          className="bg-gray-900/98 backdrop-blur-xl border border-white/30 rounded-2xl p-4 shadow-2xl"
                        >
                          <p className="text-white font-bold mb-2">{payload[0].payload.metric}</p>
                          <div className="flex items-center gap-2">
                            <div className="flex-1 h-2 bg-gray-700 rounded-full overflow-hidden">
                              <div 
                                className="h-full bg-gradient-to-r from-purple-500 to-pink-500 rounded-full"
                                style={{ width: `${payload[0].value}%` }}
                              />
                            </div>
                            <span className="text-purple-400 font-bold">{payload[0].value.toFixed(0)}</span>
                          </div>
                        </motion.div>
                      );
                    }
                    return null;
                  }}
                />
              </RadarChart>
            )}
          </ResponsiveContainer>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-3 gap-3">
        <motion.div 
          whileHover={{ scale: 1.02 }}
          className="bg-gradient-to-br from-blue-500/10 to-cyan-500/10 backdrop-blur-xl rounded-2xl border border-blue-500/30 p-4"
        >
          <p className="text-xs text-gray-400 mb-2 font-semibold">Total Invested</p>
          <p className="text-xl font-bold text-white">
            ${totalInvested.toFixed(2)}
          </p>
        </motion.div>
        <motion.div 
          whileHover={{ scale: 1.02 }}
          className={`bg-gradient-to-br backdrop-blur-xl rounded-2xl border p-4 ${
            totalChange >= 0 
              ? "from-emerald-500/10 to-green-500/10 border-emerald-500/30"
              : "from-red-500/10 to-rose-500/10 border-red-500/30"
          }`}
        >
          <p className="text-xs text-gray-400 mb-2 font-semibold">Total Gain/Loss</p>
          <p className={`text-xl font-bold ${totalChange >= 0 ? "text-emerald-400" : "text-red-400"}`}>
            {totalChange >= 0 ? "+" : ""}${(totalValue - totalInvested).toFixed(2)}
          </p>
        </motion.div>
        <motion.div 
          whileHover={{ scale: 1.02 }}
          className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 backdrop-blur-xl rounded-2xl border border-purple-500/30 p-4"
        >
          <p className="text-xs text-gray-400 mb-2 font-semibold">Holdings</p>
          <p className="text-xl font-bold text-white">{portfolioData.length} stocks</p>
        </motion.div>
      </div>
    </div>
  );
}