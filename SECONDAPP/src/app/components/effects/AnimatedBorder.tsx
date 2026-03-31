import { motion } from "motion/react";
import { ReactNode } from "react";

interface AnimatedBorderProps {
  children: ReactNode;
  className?: string;
  borderWidth?: number;
  speed?: number;
}

export default function AnimatedBorder({
  children,
  className = "",
  borderWidth = 2,
  speed = 3,
}: AnimatedBorderProps) {
  return (
    <div className={`relative ${className}`}>
      {/* Gradient border qui tourne */}
      <motion.div
        className="absolute inset-0 rounded-[inherit] p-[2px] pointer-events-none"
        style={{
          background: `linear-gradient(90deg, 
            #3b82f6 0%, 
            #8b5cf6 25%, 
            #ec4899 50%, 
            #f97316 75%, 
            #3b82f6 100%
          )`,
          WebkitMask: "linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)",
          WebkitMaskComposite: "xor",
          maskComposite: "exclude",
          padding: `${borderWidth}px`,
        }}
        animate={{
          backgroundPosition: ["0% 50%", "200% 50%"],
        }}
        transition={{
          duration: speed,
          repeat: Infinity,
          ease: "linear",
        }}
      />
      {children}
    </div>
  );
}
