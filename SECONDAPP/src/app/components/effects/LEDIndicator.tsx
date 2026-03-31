import { motion } from "motion/react";

interface LEDIndicatorProps {
  color?: "green" | "blue" | "red" | "yellow" | "purple";
  size?: "sm" | "md" | "lg";
  pulsing?: boolean;
}

const colors = {
  green: { bg: "bg-emerald-500", shadow: "0 0 10px rgba(16, 185, 129, 0.8)" },
  blue: { bg: "bg-blue-500", shadow: "0 0 10px rgba(59, 130, 246, 0.8)" },
  red: { bg: "bg-red-500", shadow: "0 0 10px rgba(239, 68, 68, 0.8)" },
  yellow: { bg: "bg-yellow-500", shadow: "0 0 10px rgba(234, 179, 8, 0.8)" },
  purple: { bg: "bg-purple-500", shadow: "0 0 10px rgba(139, 92, 246, 0.8)" },
};

const sizes = {
  sm: "w-2 h-2",
  md: "w-3 h-3",
  lg: "w-4 h-4",
};

export default function LEDIndicator({ color = "green", size = "sm", pulsing = true }: LEDIndicatorProps) {
  return (
    <motion.div
      className={`${sizes[size]} ${colors[color].bg} rounded-full`}
      style={{
        boxShadow: colors[color].shadow,
      }}
      animate={
        pulsing
          ? {
              opacity: [0.5, 1, 0.5],
              scale: [1, 1.1, 1],
            }
          : undefined
      }
      transition={{
        duration: 1.5,
        repeat: Infinity,
        ease: "easeInOut",
      }}
    />
  );
}
