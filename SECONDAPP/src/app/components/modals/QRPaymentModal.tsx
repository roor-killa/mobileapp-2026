import { motion, AnimatePresence } from "motion/react";
import { X, QrCode, Camera } from "lucide-react";

interface QRPaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function QRPaymentModal({ isOpen, onClose }: QRPaymentModalProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed inset-x-4 top-20 max-w-md mx-auto bg-gray-900 rounded-3xl border border-white/10 z-50"
          >
            <div className="p-6 space-y-6">
              {/* Header */}
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold text-white">QR Payment</h2>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-all"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              {/* QR Code Display */}
              <div className="p-8 rounded-2xl bg-white flex items-center justify-center">
                <div className="w-48 h-48 bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 rounded-2xl flex items-center justify-center">
                  <QrCode className="w-32 h-32 text-white" />
                </div>
              </div>

              <p className="text-center text-gray-400 text-sm">
                Scan this QR code to receive payment
              </p>

              {/* Scan Button */}
              <button
                onClick={onClose}
                className="w-full py-4 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 font-semibold shadow-xl shadow-purple-500/30 hover:shadow-purple-500/50 transition-all flex items-center justify-center gap-2 text-white"
              >
                <Camera className="w-5 h-5" />
                <span>Scan QR Code</span>
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
