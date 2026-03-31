import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "motion/react";
import { LineChart, Line, AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, ComposedChart } from "recharts";
import { TrendingUp, TrendingDown, Activity, Zap, Eye, BarChart3 } from "lucide-react";

interface CryptoChartProps {
  cryptoId: string;
  cryptoName: string;
  initialPrice: number;
  color: string;
}

interface DataPoint {
  time: string;
  price: number;
  volume: number;
  high: number;
  low: number;
  open: number;
  close: number;
  timestamp: number;
}

export default function RealTimeCryptoChart({ cryptoId, cryptoName, initialPrice, color }: CryptoChartProps) {
  const [data, setData] = useState<DataPoint[]>([]);
  const [timeframe, setTimeframe] = useState<"1H" | "24H" | "7D" | "1M">("24H");
  const [chartType, setChartType] = useState<"line" | "area" | "candle">("area");
  const [showVolume, setShowVolume] = useState(true);
  const [currentPrice, setCurrentPrice] = useState(initialPrice);
  const [priceChange, setPriceChange] = useState(0);
  const [lastUpdate, setLastUpdate] = useState(Date.now());
  const [isUpdating, setIsUpdating] = useState(false);
  const priceHistoryRef = useRef<number[]>([initialPrice]);

  // Get update interval based on timeframe
  const getUpdateInterval = (tf: "1H" | "24H" | "7D" | "1M") => {
    switch (tf) {
      case "1H": return 2000;
      case "24H": return 3000;
      case "7D": return 5000;
      case "1M": return 8000;
      default: return 3000;
    }
  };

  // Initialize data
  useEffect(() => {
    const points = timeframe === "1H" ? 30 : timeframe === "24H" ? 24 : timeframe === "7D" ? 7 : 4;
    
    const initialData: DataPoint[] = [];
    let currentValue = initialPrice;
    const now = Date.now();
    
    for (let i = 0; i < points; i++) {
      const volatility = initialPrice * 0.015;
      const change = (Math.random() - 0.5) * volatility;
      currentValue = Math.max(currentValue + change, initialPrice * 0.85);
      
      const volatilityRange = currentValue * 0.02;
      const high = currentValue + Math.random() * volatilityRange;
      const low = currentValue - Math.random() * volatilityRange;
      const open = i === 0 ? currentValue : initialData[i - 1].close;
      const close = currentValue;
      
      initialData.push({
        time: timeframe === "1H" 
          ? `${String(30 - points + i).padStart(2, '0')}min`
          : timeframe === "24H"
          ? `${String(i).padStart(2, '0')}h`
          : timeframe === "7D"
          ? `D${i + 1}`
          : `W${i + 1}`,
        price: currentValue,
        volume: Math.random() * 1000000 + 500000,
        high,
        low,
        open,
        close,
        timestamp: now + i * 1000,
      });
    }
    
    setData(initialData);
    setCurrentPrice(currentValue);
    const change = ((currentValue - initialPrice) / initialPrice) * 100;
    setPriceChange(change);
    priceHistoryRef.current = [currentValue];
  }, [timeframe, initialPrice]);

  // Real-time updates with dynamic interval
  useEffect(() => {
    const updateInterval = getUpdateInterval(timeframe);
    
    const interval = setInterval(() => {
      setIsUpdating(true);
      
      setData(prevData => {
        const newData = [...prevData];
        const lastPoint = newData[newData.length - 1];
        const volatility = initialPrice * 0.008;
        const change = (Math.random() - 0.5) * volatility;
        const newPrice = Math.max(lastPoint.price + change, initialPrice * 0.85);
        
        const volatilityRange = newPrice * 0.02;
        const high = Math.max(newPrice, lastPoint.high) + Math.random() * volatilityRange * 0.3;
        const low = Math.min(newPrice, lastPoint.low) - Math.random() * volatilityRange * 0.3;
        
        newData.shift();
        
        const timeLabel = timeframe === "1H"
          ? `${new Date().getMinutes()}min`
          : timeframe === "24H"
          ? `${new Date().getHours()}h`
          : timeframe === "7D"
          ? new Date().toLocaleDateString('en-US', { weekday: 'short' }).substring(0, 2)
          : `W${Math.floor(Date.now() / (7 * 24 * 60 * 60 * 1000)) % 4 + 1}`;
        
        newData.push({
          time: timeLabel,
          price: newPrice,
          volume: Math.random() * 1000000 + 500000,
          high,
          low,
          open: lastPoint.close,
          close: newPrice,
          timestamp: Date.now(),
        });
        
        setCurrentPrice(newPrice);
        const priceChangeCalc = ((newPrice - initialPrice) / initialPrice) * 100;
        setPriceChange(priceChangeCalc);
        setLastUpdate(Date.now());
        
        priceHistoryRef.current.push(newPrice);
        if (priceHistoryRef.current.length > 10) {
          priceHistoryRef.current.shift();
        }
        
        setTimeout(() => setIsUpdating(false), 300);
        
        return newData;
      });
    }, updateInterval);

    return () => clearInterval(interval);
  }, [initialPrice, timeframe]);

  const CustomTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="bg-gray-900/98 backdrop-blur-xl border border-white/30 rounded-2xl p-4 shadow-2xl"
          style={{
            boxShadow: `0 0 30px rgba(59, 130, 246, 0.3), 0 0 60px rgba(139, 92, 246, 0.2)`,
          }}
        >
          <div className="flex items-center gap-2 mb-3 pb-2 border-b border-white/10">
            <Zap className="w-4 h-4 text-yellow-400" />
            <p className="text-white font-bold">{data.time}</p>
          </div>
          <div className="space-y-2 text-sm">
            {chartType === "candle" ? (
              <>
                <div className="flex justify-between gap-6">
                  <span className="text-gray-400">Open</span>
                  <span className="text-emerald-400 font-semibold">${data.open.toFixed(2)}</span>
                </div>
                <div className="flex justify-between gap-6">
                  <span className="text-gray-400">High</span>
                  <span className="text-blue-400 font-semibold">${data.high.toFixed(2)}</span>
                </div>
                <div className="flex justify-between gap-6">
                  <span className="text-gray-400">Low</span>
                  <span className="text-red-400 font-semibold">${data.low.toFixed(2)}</span>
                </div>
                <div className="flex justify-between gap-6">
                  <span className="text-gray-400">Close</span>
                  <span className="text-purple-400 font-semibold">${data.close.toFixed(2)}</span>
                </div>
              </>
            ) : (
              <div className="flex justify-between gap-6">
                <span className="text-gray-400">Price</span>
                <span className="text-white font-bold text-lg">${data.price.toFixed(2)}</span>
              </div>
            )}
            {showVolume && (
              <div className="flex justify-between gap-6 pt-2 border-t border-white/10">
                <span className="text-gray-400">Volume</span>
                <span className="text-cyan-400 font-semibold">${(data.volume / 1000).toFixed(0)}K</span>
              </div>
            )}
          </div>
        </motion.div>
      );
    }
    return null;
  };

  const CandlestickBar = (props: any) => {
    const { x, y, width, height, payload } = props;
    const { open, close, high, low } = payload;
    
    if (!open || !close || !high || !low) return null;
    
    const isGreen = close >= open;
    const color = isGreen ? "#10b981" : "#ef4444";
    
    const maxPrice = high;
    const minPrice = low;
    const priceRange = maxPrice - minPrice;
    
    if (priceRange === 0) return null;
    
    const chartHeight = height;
    const yHigh = y - ((high - Math.max(open, close)) / priceRange) * chartHeight;
    const yLow = y + ((Math.min(open, close) - low) / priceRange) * chartHeight;
    const yOpen = y - ((open - minPrice) / priceRange) * chartHeight + chartHeight;
    const yClose = y - ((close - minPrice) / priceRange) * chartHeight + chartHeight;
    const bodyHeight = Math.abs(yClose - yOpen);
    
    return (
      <g>
        <line
          x1={x + width / 2}
          y1={yHigh}
          x2={x + width / 2}
          y2={yLow}
          stroke={color}
          strokeWidth={1.5}
          opacity={0.8}
        />
        <rect
          x={x + width * 0.2}
          y={Math.min(yOpen, yClose)}
          width={width * 0.6}
          height={Math.max(bodyHeight, 2)}
          fill={color}
          stroke={color}
          strokeWidth={1}
          opacity={0.9}
        />
      </g>
    );
  };

  const getPriceDirection = () => {
    if (priceHistoryRef.current.length < 2) return "neutral";
    const recent = priceHistoryRef.current.slice(-3);
    const trend = recent[recent.length - 1] - recent[0];
    return trend > 0 ? "up" : trend < 0 ? "down" : "neutral";
  };

  const priceDirection = getPriceDirection();

  return (
    <div className="space-y-5">
      {/* Header with current price */}
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2">
            <h3 className="text-xl font-bold text-white">{cryptoName}</h3>
            <div className={`px-2 py-1 rounded-lg text-xs font-semibold ${
              priceDirection === "up" ? "bg-emerald-500/20 text-emerald-400" :
              priceDirection === "down" ? "bg-red-500/20 text-red-400" :
              "bg-gray-500/20 text-gray-400"
            }`}>
              {cryptoId}
            </div>
          </div>
          <div className="flex items-baseline gap-4 flex-wrap">
            <motion.div
              key={currentPrice}
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
                    className="absolute -inset-2 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-xl blur-xl"
                  />
                )}
              </AnimatePresence>
              <span className={`relative text-4xl font-bold ${
                priceDirection === "up" ? "text-emerald-400" :
                priceDirection === "down" ? "text-red-400" :
                "text-white"
              }`}>
                ${currentPrice.toFixed(2)}
              </span>
            </motion.div>
            <div className={`flex items-center gap-2 px-3 py-2 rounded-xl ${
              priceChange >= 0 
                ? "bg-emerald-500/10 border border-emerald-500/30" 
                : "bg-red-500/10 border border-red-500/30"
            }`}>
              {priceChange >= 0 ? (
                <TrendingUp className="w-5 h-5 text-emerald-400" />
              ) : (
                <TrendingDown className="w-5 h-5 text-red-400" />
              )}
              <span className={`font-bold text-lg ${
                priceChange >= 0 ? "text-emerald-400" : "text-red-400"
              }`}>
                {priceChange >= 0 ? "+" : ""}{priceChange.toFixed(2)}%
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
          <span className="text-xs text-gray-500">
            Updates every {getUpdateInterval(timeframe) / 1000}s
          </span>
        </div>
      </div>

      {/* Controls */}
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div className="flex gap-2">
          {(["1H", "24H", "7D", "1M"] as const).map((tf) => (
            <button
              key={tf}
              onClick={() => setTimeframe(tf)}
              className={`relative px-4 py-2 rounded-xl text-sm font-bold transition-all overflow-hidden ${
                timeframe === tf
                  ? "text-white"
                  : "bg-white/5 text-gray-400 hover:bg-white/10 hover:text-white"
              }`}
            >
              {timeframe === tf && (
                <motion.div
                  layoutId="timeframe-bg"
                  className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500"
                  style={{ borderRadius: "0.75rem" }}
                  transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                />
              )}
              <span className="relative z-10">{tf}</span>
            </button>
          ))}
        </div>
        <div className="flex gap-2">
          {(["line", "area", "candle"] as const).map((type) => {
            const icons = {
              line: Activity,
              area: BarChart3,
              candle: Eye,
            };
            const Icon = icons[type];
            return (
              <button
                key={type}
                onClick={() => setChartType(type)}
                className={`relative flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all overflow-hidden capitalize ${
                  chartType === type
                    ? "text-white"
                    : "bg-white/5 text-gray-400 hover:bg-white/10 hover:text-white"
                }`}
              >
                {chartType === type && (
                  <motion.div
                    layoutId="charttype-bg"
                    className="absolute inset-0 bg-gradient-to-r from-purple-500 to-pink-500"
                    style={{ borderRadius: "0.75rem" }}
                    transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                  />
                )}
                <Icon className="w-4 h-4 relative z-10" />
                <span className="relative z-10">{type}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Chart */}
      <div className="relative">
        <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 via-purple-500/5 to-pink-500/5 rounded-3xl blur-3xl" />
        <div className="relative h-72 bg-gray-900/40 backdrop-blur-xl rounded-3xl border border-white/10 p-6 shadow-2xl">
          <ResponsiveContainer width="100%" height="100%">
            {chartType === "line" ? (
              <LineChart data={data}>
                <defs>
                  <linearGradient id={`line-glow-${cryptoId}`} x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor={color} stopOpacity={1} />
                    <stop offset="50%" stopColor="#8b5cf6" stopOpacity={1} />
                    <stop offset="100%" stopColor={color} stopOpacity={1} />
                  </linearGradient>
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
                  domain={['auto', 'auto']}
                />
                <Tooltip content={<CustomTooltip />} cursor={{ stroke: color, strokeWidth: 1, strokeDasharray: '5 5' }} />
                <Line 
                  type="monotone" 
                  dataKey="price" 
                  stroke={`url(#line-glow-${cryptoId})`}
                  strokeWidth={3}
                  dot={false}
                  isAnimationActive={false}
                />
              </LineChart>
            ) : chartType === "area" ? (
              <ComposedChart data={data}>
                <defs>
                  <linearGradient id={`gradient-${cryptoId}`} x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor={color} stopOpacity={0.4} />
                    <stop offset="50%" stopColor="#8b5cf6" stopOpacity={0.2} />
                    <stop offset="100%" stopColor={color} stopOpacity={0} />
                  </linearGradient>
                  <linearGradient id={`stroke-${cryptoId}`} x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor={color} />
                    <stop offset="50%" stopColor="#8b5cf6" />
                    <stop offset="100%" stopColor={color} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                <XAxis 
                  dataKey="time" 
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                />
                <YAxis 
                  yAxisId="left"
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                  domain={['auto', 'auto']}
                />
                {showVolume && (
                  <YAxis 
                    yAxisId="right"
                    orientation="right"
                    stroke="rgba(255,255,255,0.2)" 
                    tick={{ fill: 'rgba(255,255,255,0.4)', fontSize: 10 }}
                    axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                  />
                )}
                <Tooltip content={<CustomTooltip />} cursor={{ stroke: color, strokeWidth: 1, strokeDasharray: '5 5' }} />
                <Area 
                  yAxisId="left"
                  type="monotone" 
                  dataKey="price" 
                  stroke={`url(#stroke-${cryptoId})`}
                  strokeWidth={3}
                  fill={`url(#gradient-${cryptoId})`}
                  isAnimationActive={false}
                  key={`area-price-${cryptoId}`}
                />
                {showVolume && (
                  <Bar 
                    yAxisId="right"
                    dataKey="volume" 
                    fill="rgba(99, 102, 241, 0.2)"
                    radius={[4, 4, 0, 0]}
                    isAnimationActive={false}
                    key={`bar-volume-${cryptoId}`}
                  />
                )}
              </ComposedChart>
            ) : (
              <ComposedChart data={data}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                <XAxis 
                  dataKey="time" 
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                />
                <YAxis 
                  yAxisId="left"
                  stroke="rgba(255,255,255,0.3)" 
                  tick={{ fill: 'rgba(255,255,255,0.5)', fontSize: 11, fontWeight: 600 }}
                  axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                  domain={[(dataMin: number) => dataMin * 0.995, (dataMax: number) => dataMax * 1.005]}
                />
                {showVolume && (
                  <YAxis 
                    yAxisId="right"
                    orientation="right"
                    stroke="rgba(255,255,255,0.2)" 
                    tick={{ fill: 'rgba(255,255,255,0.4)', fontSize: 10 }}
                    axisLine={{ stroke: 'rgba(255,255,255,0.1)' }}
                  />
                )}
                <Tooltip content={<CustomTooltip />} cursor={{ stroke: color, strokeWidth: 1, strokeDasharray: '5 5' }} />
                <Bar 
                  yAxisId="left"
                  dataKey="close"
                  shape={<CandlestickBar />}
                  isAnimationActive={false}
                />
                {showVolume && (
                  <Bar 
                    yAxisId="right"
                    dataKey="volume" 
                    fill="rgba(99, 102, 241, 0.2)"
                    radius={[4, 4, 0, 0]}
                    isAnimationActive={false}
                  />
                )}
              </ComposedChart>
            )}
          </ResponsiveContainer>
        </div>
      </div>

      {/* Volume Toggle */}
      <div className="flex justify-end">
        <button
          onClick={() => setShowVolume(!showVolume)}
          className={`relative px-4 py-2 rounded-xl text-sm font-bold transition-all overflow-hidden ${
            showVolume
              ? "text-white"
              : "bg-white/5 text-gray-400 hover:bg-white/10"
          }`}
        >
          {showVolume && (
            <div className="absolute inset-0 bg-gradient-to-r from-cyan-500 to-blue-500 rounded-xl" />
          )}
          <span className="relative z-10">{showVolume ? "Hide" : "Show"} Volume</span>
        </button>
      </div>
    </div>
  );
}