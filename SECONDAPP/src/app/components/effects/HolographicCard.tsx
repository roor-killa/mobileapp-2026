import { motion } from "motion/react";
import { ReactNode, useState } from "react";

interface HolographicCardProps {
  children: ReactNode;
  className?: string;
}

export default function HolographicCard({ children, className = "" }: HolographicCardProps) {
  const [mousePosition, setMousePosition] = useState({ x: 0.5, y: 0.5 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;
    setMousePosition({ x, y });
  };

  const handleMouseLeave = () => {
    setMousePosition({ x: 0.5, y: 0.5 });
  };

  return (
    <motion.div
      className={`relative ${className}`}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        transformStyle: "preserve-3d",
      }}
      animate={{
        rotateX: (mousePosition.y - 0.5) * 10,
        rotateY: (mousePosition.x - 0.5) * -10,
      }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    >
      {/* Reflet holographique */}
      <motion.div
        className="absolute inset-0 rounded-[inherit] pointer-events-none opacity-0 hover:opacity-100 transition-opacity duration-300"
        style={{
          background: `radial-gradient(
            circle at ${mousePosition.x * 100}% ${mousePosition.y * 100}%,
            rgba(59, 130, 246, 0.3) 0%,
            rgba(139, 92, 246, 0.2) 25%,
            rgba(236, 72, 153, 0.2) 50%,
            transparent 70%
          )`,
          mixBlendMode: "overlay",
        }}
      />
      
      {/* Effet irisé */}
      <div
        className="absolute inset-0 rounded-[inherit] pointer-events-none opacity-30"
        style={{
          background: `linear-gradient(
            ${mousePosition.x * 360}deg,
            rgba(59, 130, 246, 0.1) 0%,
            rgba(139, 92, 246, 0.1) 33%,
            rgba(236, 72, 153, 0.1) 66%,
            rgba(59, 130, 246, 0.1) 100%
          )`,
        }}
      />

      {children}
    </motion.div>
  );
}
