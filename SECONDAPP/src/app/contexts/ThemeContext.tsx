import { createContext, useContext, useState, ReactNode, useEffect } from "react";

export interface PaletteColors {
  id: string;
  name: string;
  gradient: string;
  primary: string;
  secondary: string;
  accent: string;
  cardBg: string;
  cardGlow: string;
}

export const palettes: Record<string, PaletteColors> = {
  sunset: {
    id: "sunset",
    name: "🌅 Sunset Blaze",
    gradient: "from-orange-400 via-pink-500 to-red-500",
    primary: "from-orange-400 to-pink-500",
    secondary: "from-pink-500 to-red-500",
    accent: "from-yellow-400 to-orange-500",
    cardBg: "from-orange-500/20 via-pink-500/20 to-red-500/20",
    cardGlow: "shadow-orange-500/20",
  },
  neon: {
    id: "neon",
    name: "⚡ Neon City",
    gradient: "from-cyan-400 via-fuchsia-500 to-yellow-400",
    primary: "from-cyan-400 to-blue-500",
    secondary: "from-fuchsia-500 to-pink-500",
    accent: "from-yellow-400 to-orange-400",
    cardBg: "from-cyan-500/20 via-fuchsia-500/20 to-blue-500/20",
    cardGlow: "shadow-cyan-500/20",
  },
  ocean: {
    id: "ocean",
    name: "🌊 Ocean Dream",
    gradient: "from-teal-400 via-cyan-500 to-blue-500",
    primary: "from-teal-400 to-cyan-500",
    secondary: "from-cyan-500 to-blue-500",
    accent: "from-emerald-400 to-teal-500",
    cardBg: "from-teal-500/20 via-cyan-500/20 to-blue-500/20",
    cardGlow: "shadow-teal-500/20",
  },
  royal: {
    id: "royal",
    name: "👑 Royal Purple",
    gradient: "from-indigo-500 via-purple-500 to-pink-500",
    primary: "from-indigo-500 to-purple-500",
    secondary: "from-purple-500 to-pink-500",
    accent: "from-violet-500 to-fuchsia-500",
    cardBg: "from-blue-600/20 via-purple-600/20 to-pink-600/20",
    cardGlow: "shadow-purple-500/20",
  },
  forest: {
    id: "forest",
    name: "🌲 Forest Glow",
    gradient: "from-green-400 via-emerald-500 to-teal-500",
    primary: "from-green-400 to-emerald-500",
    secondary: "from-emerald-500 to-teal-500",
    accent: "from-lime-400 to-green-500",
    cardBg: "from-green-500/20 via-emerald-500/20 to-teal-500/20",
    cardGlow: "shadow-emerald-500/20",
  },
  sunrise: {
    id: "sunrise",
    name: "🌄 Golden Sunrise",
    gradient: "from-yellow-300 via-amber-400 to-orange-500",
    primary: "from-yellow-300 to-amber-400",
    secondary: "from-amber-400 to-orange-500",
    accent: "from-yellow-400 to-yellow-500",
    cardBg: "from-yellow-400/20 via-amber-400/20 to-orange-500/20",
    cardGlow: "shadow-amber-500/20",
  },
  midnight: {
    id: "midnight",
    name: "🌙 Midnight Blue",
    gradient: "from-blue-600 via-indigo-600 to-purple-600",
    primary: "from-blue-600 to-indigo-600",
    secondary: "from-indigo-600 to-purple-600",
    accent: "from-cyan-500 to-blue-500",
    cardBg: "from-blue-700/20 via-indigo-700/20 to-purple-700/20",
    cardGlow: "shadow-blue-600/20",
  },
  candy: {
    id: "candy",
    name: "🍬 Candy Pop",
    gradient: "from-pink-300 via-purple-300 to-indigo-400",
    primary: "from-pink-300 to-purple-400",
    secondary: "from-purple-300 to-indigo-400",
    accent: "from-rose-300 to-pink-400",
    cardBg: "from-pink-400/20 via-purple-400/20 to-indigo-400/20",
    cardGlow: "shadow-pink-400/20",
  },
};

interface ThemeContextType {
  currentPalette: string;
  theme: PaletteColors;
  setTheme: (paletteId: string) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [currentPalette, setCurrentPalette] = useState<string>(() => {
    // Load from localStorage or default to 'royal'
    return localStorage.getItem("theme-palette") || "royal";
  });

  useEffect(() => {
    // Save to localStorage when theme changes
    localStorage.setItem("theme-palette", currentPalette);
  }, [currentPalette]);

  const setTheme = (paletteId: string) => {
    if (palettes[paletteId]) {
      setCurrentPalette(paletteId);
    }
  };

  const theme = palettes[currentPalette];

  return (
    <ThemeContext.Provider value={{ currentPalette, theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}
