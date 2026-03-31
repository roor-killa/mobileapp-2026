import { useEffect, useState } from "react";
import { LineChart, Line, ResponsiveContainer } from "recharts";
import { motion } from "motion/react";

interface SparklineProps {
  initialValue: number;
  color: string;
  trend: "up" | "down";
}

export default function MiniSparkline({ initialValue, color, trend }: SparklineProps) {
  const [data, setData] = useState<{ value: number; timestamp: number }[]>([]);
  const [currentValue, setCurrentValue] = useState(initialValue);

  useEffect(() => {
    // Generate initial sparkline data
    const points = 20;
    const newData = [];
    let currentVal = initialValue;
    const trendMultiplier = trend === "up" ? 1.2 : 0.8;
    const now = Date.now();

    for (let i = 0; i < points; i++) {
      const change = (Math.random() - 0.4) * initialValue * 0.015 * trendMultiplier;
      currentVal = Math.max(currentVal + change, initialValue * 0.85);
      newData.push({ value: currentVal, timestamp: now + i * 1000 });
    }

    setData(newData);
    setCurrentValue(newData[newData.length - 1].value);
  }, [initialValue, trend]);

  useEffect(() => {
    const interval = setInterval(() => {
      setData(prevData => {
        const newData = [...prevData];
        const lastValue = newData[newData.length - 1].value;
        const trendMultiplier = trend === "up" ? 1.2 : 0.8;
        const change = (Math.random() - 0.4) * initialValue * 0.015 * trendMultiplier;
        const newValue = Math.max(lastValue + change, initialValue * 0.85);

        newData.shift();
        newData.push({ value: newValue, timestamp: Date.now() });

        setCurrentValue(newValue);

        return newData;
      });
    }, 2000);

    return () => clearInterval(interval);
  }, [initialValue, trend]);

  // Calculate gradient based on trend
  const gradientId = `sparkline-gradient-${Math.random().toString(36).substr(2, 9)}`;
  const gradientColor = trend === "up" ? "#10b981" : "#ef4444";

  return (
    <div className="relative w-full h-full">
      {/* Glow effect */}
      <motion.div
        animate={{
          opacity: [0.3, 0.6, 0.3],
        }}
        transition={{
          duration: 2,
          repeat: Infinity,
          ease: "easeInOut",
        }}
        className="absolute inset-0 blur-sm"
        style={{
          background: `linear-gradient(to right, transparent, ${gradientColor}20, transparent)`,
        }}
      />
      
      {/* Chart */}
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data}>
          <defs>
            <linearGradient id={gradientId} x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stopColor={gradientColor} stopOpacity={0.3} />
              <stop offset="50%" stopColor={gradientColor} stopOpacity={1} />
              <stop offset="100%" stopColor={gradientColor} stopOpacity={0.3} />
            </linearGradient>
          </defs>
          <Line 
            type="monotone" 
            dataKey="value" 
            stroke={`url(#${gradientId})`}
            strokeWidth={2}
            dot={false}
            isAnimationActive={false}
          />
        </LineChart>
      </ResponsiveContainer>
      
      {/* Current value indicator (optional small dot at the end) */}
      <motion.div
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.7, 1, 0.7],
        }}
        transition={{
          duration: 1.5,
          repeat: Infinity,
          ease: "easeInOut",
        }}
        className="absolute right-1 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full"
        style={{ backgroundColor: gradientColor, boxShadow: `0 0 8px ${gradientColor}` }}
      />
    </div>
  );
}
