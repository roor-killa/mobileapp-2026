import { motion } from "motion/react";
import { ReactNode } from "react";

interface PulsingGlowProps {
  children: ReactNode;
  className?: string;
  color?: "blue" | "purple" | "pink" | "emerald";
}

const colors = {
  blue: {
    shadow: "rgba(59, 130, 246, 0.6)",
    gradient: "from-blue-500/20 to-cyan-500/20",
  },
  purple: {
    shadow: "rgba(139, 92, 246, 0.6)",
    gradient: "from-purple-500/20 to-pink-500/20",
  },
  pink: {
    shadow: "rgba(236, 72, 153, 0.6)",
    gradient: "from-pink-500/20 to-rose-500/20",
  },
  emerald: {
    shadow: "rgba(16, 185, 129, 0.6)",
    gradient: "from-emerald-500/20 to-teal-500/20",
  },
};

export default function PulsingGlow({ children, className = "", color = "blue" }: PulsingGlowProps) {
  return (
    <div className={`relative ${className}`}>
      {/* Pulsating glow effect */}
      <motion.div
        className="absolute inset-0 rounded-[inherit] blur-xl"
        style={{
          background: `radial-gradient(circle, ${colors[color].shadow} 0%, transparent 70%)`,
        }}
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.3, 0.6, 0.3],
        }}
        transition={{
          duration: 2,
          repeat: Infinity,
          ease: "easeInOut",
        }}
      />
      {children}
    </div>
  );
}
