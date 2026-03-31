import { motion, AnimatePresence } from "motion/react";
import { X, ArrowRight } from "lucide-react";
import { useState } from "react";

interface SendMoneyModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const contacts = [
  { id: 1, name: "Sarah Chen", avatar: "SC", color: "from-pink-500 to-rose-500" },
  { id: 2, name: "Mike Johnson", avatar: "MJ", color: "from-blue-500 to-cyan-500" },
  { id: 3, name: "Emily Davis", avatar: "ED", color: "from-purple-500 to-pink-500" },
  { id: 4, name: "Tom Wilson", avatar: "TW", color: "from-emerald-500 to-teal-500" },
];

export default function SendMoneyModal({ isOpen, onClose }: SendMoneyModalProps) {
  const [amount, setAmount] = useState("");
  const [selectedContact, setSelectedContact] = useState<number | null>(null);
  const [sending, setSending] = useState(false);

  const handleSend = () => {
    setSending(true);
    setTimeout(() => {
      setSending(false);
      onClose();
      setAmount("");
      setSelectedContact(null);
    }, 1500);
  };

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
            className="fixed inset-x-4 top-20 max-w-md mx-auto bg-gray-900 rounded-3xl border border-white/10 z-50 max-h-[80vh] overflow-y-auto"
          >
            <div className="p-6 space-y-6">
              {/* Header */}
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold text-white">Send Money</h2>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-all"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              {/* Amount Input */}
              <div>
                <label className="text-sm text-gray-400 mb-2 block">Amount</label>
                <div className="flex items-center gap-2 p-4 rounded-2xl bg-white/5 border border-white/10">
                  <span className="text-2xl font-bold text-gray-400">$</span>
                  <input
                    type="text"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value.replace(/[^0-9.]/g, ""))}
                    placeholder="0.00"
                    className="flex-1 bg-transparent text-3xl font-bold outline-none text-white"
                  />
                </div>
              </div>

              {/* Select Contact */}
              <div>
                <label className="text-sm text-gray-400 mb-3 block">Send to</label>
                <div className="grid grid-cols-2 gap-3">
                  {contacts.map((contact) => (
                    <button
                      key={contact.id}
                      onClick={() => setSelectedContact(contact.id)}
                      className={`flex items-center gap-3 p-3 rounded-2xl transition-all ${
                        selectedContact === contact.id
                          ? "bg-white/20 border-2 border-blue-500"
                          : "bg-white/5 border border-white/10"
                      }`}
                    >
                      <div className={`w-10 h-10 rounded-full bg-gradient-to-br ${contact.color} flex items-center justify-center font-semibold text-sm`}>
                        {contact.avatar}
                      </div>
                      <span className="text-sm font-medium text-white">{contact.name}</span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Send Button */}
              <button
                onClick={handleSend}
                disabled={!amount || !selectedContact || sending}
                className="w-full py-4 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 hover:shadow-blue-500/50 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-white"
              >
                {sending ? (
                  <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Send ${amount || "0.00"}</span>
                    <ArrowRight className="w-5 h-5" />
                  </>
                )}
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
