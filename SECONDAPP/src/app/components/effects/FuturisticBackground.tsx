import { motion } from "motion/react";
import { useEffect, useState } from "react";

// Particules flottantes
const FloatingParticles = () => {
  const [particles, setParticles] = useState<Array<{ id: number; x: number; y: number; delay: number; duration: number }>>([]);

  useEffect(() => {
    const newParticles = Array.from({ length: 30 }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      delay: Math.random() * 5,
      duration: 10 + Math.random() * 20,
    }));
    setParticles(newParticles);
  }, []);

  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
      {particles.map((particle) => (
        <motion.div
          key={particle.id}
          className="absolute w-1 h-1 bg-blue-400/30 rounded-full blur-[1px]"
          style={{
            left: `${particle.x}%`,
            top: `${particle.y}%`,
          }}
          animate={{
            y: [0, -100, 0],
            opacity: [0, 1, 0],
            scale: [0, 1.5, 0],
          }}
          transition={{
            duration: particle.duration,
            repeat: Infinity,
            delay: particle.delay,
            ease: "linear",
          }}
        />
      ))}
    </div>
  );
};

// Grille cyberpunk animée
const CyberpunkGrid = () => {
  return (
    <div className="fixed inset-0 pointer-events-none z-0 opacity-20">
      <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <motion.path
              d="M 40 0 L 0 0 0 40"
              fill="none"
              stroke="url(#gridGradient)"
              strokeWidth="0.5"
              initial={{ pathLength: 0, opacity: 0 }}
              animate={{ pathLength: 1, opacity: 1 }}
              transition={{ duration: 2, ease: "easeInOut" }}
            />
          </pattern>
          <linearGradient id="gridGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.3" />
            <stop offset="50%" stopColor="#8b5cf6" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#ec4899" stopOpacity="0.3" />
          </linearGradient>
          <radialGradient id="gridFade" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="white" stopOpacity="0.8" />
            <stop offset="100%" stopColor="white" stopOpacity="0" />
          </radialGradient>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" mask="url(#gridMask)" />
        <motion.g
          animate={{
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{
            duration: 3,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        >
          <line x1="0" y1="20%" x2="100%" y2="20%" stroke="#3b82f6" strokeWidth="1" opacity="0.3" />
          <line x1="0" y1="40%" x2="100%" y2="40%" stroke="#8b5cf6" strokeWidth="1" opacity="0.3" />
          <line x1="0" y1="60%" x2="100%" y2="60%" stroke="#ec4899" strokeWidth="1" opacity="0.3" />
          <line x1="0" y1="80%" x2="100%" y2="80%" stroke="#3b82f6" strokeWidth="1" opacity="0.3" />
        </motion.g>
      </svg>
    </div>
  );
};

// Scan lines
const ScanLines = () => {
  return (
    <>
      <motion.div
        className="fixed inset-0 pointer-events-none z-[1]"
        style={{
          backgroundImage: `repeating-linear-gradient(
            0deg,
            rgba(0, 0, 0, 0.03) 0px,
            transparent 1px,
            transparent 2px,
            rgba(0, 0, 0, 0.03) 3px
          )`,
        }}
      />
      <motion.div
        className="fixed inset-0 pointer-events-none z-[1] opacity-30"
        animate={{
          backgroundPosition: ["0% 0%", "0% 100%"],
        }}
        transition={{
          duration: 8,
          repeat: Infinity,
          ease: "linear",
        }}
        style={{
          backgroundImage: `linear-gradient(
            180deg,
            transparent 0%,
            rgba(59, 130, 246, 0.1) 50%,
            transparent 100%
          )`,
          backgroundSize: "100% 200px",
        }}
      />
    </>
  );
};

// Gradient orbs flottants
const GradientOrbs = () => {
  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
      <motion.div
        className="absolute w-96 h-96 rounded-full blur-[120px] opacity-20"
        style={{
          background: "radial-gradient(circle, rgba(59,130,246,0.4) 0%, transparent 70%)",
        }}
        animate={{
          x: ["-10%", "110%"],
          y: ["0%", "50%", "0%"],
        }}
        transition={{
          duration: 25,
          repeat: Infinity,
          ease: "linear",
        }}
      />
      <motion.div
        className="absolute w-96 h-96 rounded-full blur-[120px] opacity-20"
        style={{
          background: "radial-gradient(circle, rgba(139,92,246,0.4) 0%, transparent 70%)",
          right: 0,
        }}
        animate={{
          x: ["10%", "-110%"],
          y: ["50%", "0%", "50%"],
        }}
        transition={{
          duration: 30,
          repeat: Infinity,
          ease: "linear",
        }}
      />
      <motion.div
        className="absolute w-96 h-96 rounded-full blur-[120px] opacity-20 bottom-0"
        style={{
          background: "radial-gradient(circle, rgba(236,72,153,0.3) 0%, transparent 70%)",
        }}
        animate={{
          x: ["100%", "-20%", "100%"],
          y: ["-20%", "0%", "-20%"],
        }}
        transition={{
          duration: 35,
          repeat: Infinity,
          ease: "linear",
        }}
      />
    </div>
  );
};

export default function FuturisticBackground() {
  return (
    <>
      <GradientOrbs />
      <CyberpunkGrid />
      <FloatingParticles />
      <ScanLines />
    </>
  );
}
