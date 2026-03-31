import { motion, AnimatePresence } from "motion/react";
import { X, Check } from "lucide-react";
import { useTheme, palettes } from "../contexts/ThemeContext";
import { toast } from "sonner";

interface AppearanceModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function AppearanceModal({ isOpen, onClose }: AppearanceModalProps) {
  const { currentPalette, setTheme } = useTheme();

  const handleSelectPalette = (paletteId: string) => {
    setTheme(paletteId);
    toast.success(`Theme changed to ${palettes[paletteId].name}`);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            className="fixed inset-x-4 top-20 bottom-20 md:inset-x-auto md:left-1/2 md:-translate-x-1/2 md:w-full md:max-w-2xl bg-gray-900/95 backdrop-blur-2xl border border-white/10 rounded-3xl shadow-2xl z-50 overflow-hidden flex flex-col"
          >
            {/* Header */}
            <div className="flex items-center justify-between p-6 border-b border-white/10">
              <div>
                <h2 className="text-2xl font-bold">Appearance</h2>
                <p className="text-sm text-gray-400 mt-1">Choose your color palette</p>
              </div>
              <button
                onClick={onClose}
                className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 transition-all flex items-center justify-center"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Palette Grid */}
            <div className="flex-1 overflow-y-auto p-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {Object.values(palettes).map((palette, index) => {
                  const isSelected = currentPalette === palette.id;

                  return (
                    <motion.button
                      key={palette.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.05 }}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      onClick={() => handleSelectPalette(palette.id)}
                      className={`relative rounded-2xl overflow-hidden transition-all ${
                        isSelected ? "ring-4 ring-white" : ""
                      }`}
                    >
                      {/* Preview Background */}
                      <div className={`bg-gradient-to-br ${palette.gradient} h-32 relative overflow-hidden`}>
                        {/* Animated Orbs */}
                        <div className="absolute inset-0">
                          <motion.div
                            animate={{
                              scale: [1, 1.2, 1],
                              opacity: [0.3, 0.5, 0.3],
                            }}
                            transition={{
                              duration: 4,
                              repeat: Infinity,
                              ease: "easeInOut",
                            }}
                            className="absolute top-4 left-4 w-16 h-16 bg-white/20 rounded-full blur-xl"
                          />
                          <motion.div
                            animate={{
                              scale: [1, 1.3, 1],
                              opacity: [0.2, 0.4, 0.2],
                            }}
                            transition={{
                              duration: 5,
                              repeat: Infinity,
                              ease: "easeInOut",
                              delay: 1,
                            }}
                            className="absolute bottom-4 right-4 w-20 h-20 bg-white/20 rounded-full blur-2xl"
                          />
                        </div>

                        {/* Mini Preview Elements */}
                        <div className="relative z-10 p-4 h-full flex flex-col justify-between">
                          <div className="flex gap-2">
                            <div className="w-12 h-12 rounded-xl bg-white/20 backdrop-blur-xl" />
                            <div className="flex-1 space-y-2">
                              <div className="h-2 w-16 bg-white/30 rounded-full" />
                              <div className="h-3 w-20 bg-white/40 rounded" />
                            </div>
                          </div>
                          <div className="flex gap-2">
                            <div className="flex-1 h-8 rounded-lg bg-white/20 backdrop-blur-xl" />
                            <div className="flex-1 h-8 rounded-lg bg-white/15 backdrop-blur-xl" />
                          </div>
                        </div>

                        {/* Selection Indicator */}
                        {isSelected && (
                          <motion.div
                            initial={{ scale: 0 }}
                            animate={{ scale: 1 }}
                            className="absolute top-2 right-2 w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-lg"
                          >
                            <Check className="w-5 h-5 text-green-600" />
                          </motion.div>
                        )}
                      </div>

                      {/* Info */}
                      <div className="bg-gray-800/90 p-3 border-t border-white/10">
                        <h3 className="font-semibold text-sm mb-1">{palette.name}</h3>
                        <div className="flex gap-1.5">
                          <div className={`w-6 h-6 rounded-full bg-gradient-to-r ${palette.primary}`} />
                          <div className={`w-6 h-6 rounded-full bg-gradient-to-r ${palette.secondary}`} />
                          <div className={`w-6 h-6 rounded-full bg-gradient-to-r ${palette.accent}`} />
                        </div>
                      </div>
                    </motion.button>
                  );
                })}
              </div>
            </div>

            {/* Footer */}
            <div className="p-6 border-t border-white/10 bg-gray-900/50">
              <button
                onClick={onClose}
                className="w-full py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 transition-all font-semibold"
              >
                Done
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
