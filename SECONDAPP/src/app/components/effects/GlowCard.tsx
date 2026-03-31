import { motion } from "motion/react";
import { ReactNode } from "react";

interface GlowCardProps {
  children: ReactNode;
  className?: string;
  glowColor?: "blue" | "purple" | "pink" | "emerald" | "orange" | "cyan";
  intensity?: "low" | "medium" | "high";
  animated?: boolean;
}

const glowColors = {
  blue: "rgba(59, 130, 246, 0.5)",
  purple: "rgba(139, 92, 246, 0.5)",
  pink: "rgba(236, 72, 153, 0.5)",
  emerald: "rgba(16, 185, 129, 0.5)",
  orange: "rgba(249, 115, 22, 0.5)",
  cyan: "rgba(6, 182, 212, 0.5)",
};

const intensityValues = {
  low: "0 0 10px",
  medium: "0 0 20px",
  high: "0 0 30px",
};

export default function GlowCard({
  children,
  className = "",
  glowColor = "blue",
  intensity = "medium",
  animated = true,
}: GlowCardProps) {
  const boxShadow = `${intensityValues[intensity]} ${glowColors[glowColor]}`;

  return (
    <motion.div
      className={`relative ${className}`}
      style={{
        boxShadow: animated ? undefined : boxShadow,
      }}
      whileHover={
        animated
          ? {
              boxShadow: `${intensityValues[intensity]} ${glowColors[glowColor]}, ${intensityValues.high} ${glowColors[glowColor]}`,
            }
          : undefined
      }
      transition={{ duration: 0.3 }}
    >
      {animated && (
        <motion.div
          className="absolute inset-0 rounded-[inherit] pointer-events-none"
          style={{
            boxShadow: boxShadow,
          }}
          animate={{
            opacity: [0.5, 1, 0.5],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
      )}
      {children}
    </motion.div>
  );
}
