import { motion } from "motion/react";
import { Send, Download, QrCode, Users, ArrowRight, Zap } from "lucide-react";
import { useState } from "react";
import SendMoneyModal from "./modals/SendMoneyModal";
import QRPaymentModal from "./modals/QRPaymentModal";
import { toast } from "sonner";

const recentContacts = [
  { id: 1, name: "Sarah Chen", avatar: "SC", color: "from-pink-500 to-rose-500" },
  { id: 2, name: "Mike Johnson", avatar: "MJ", color: "from-blue-500 to-cyan-500" },
  { id: 3, name: "Emily Davis", avatar: "ED", color: "from-purple-500 to-pink-500" },
  { id: 4, name: "Tom Wilson", avatar: "TW", color: "from-emerald-500 to-teal-500" },
  { id: 5, name: "Lisa Anderson", avatar: "LA", color: "from-orange-500 to-yellow-500" },
];

export default function Transfers() {
  const [amount, setAmount] = useState("");
  const [selectedContact, setSelectedContact] = useState<number | null>(null);
  const [sendMoneyModalOpen, setSendMoneyModalOpen] = useState(false);
  const [qrPaymentModalOpen, setQRPaymentModalOpen] = useState(false);

  const handleRequest = () => {
    toast.info("Request payment from a contact");
  };

  const handleSplitBill = () => {
    toast.info("Split bill with friends");
  };

  const handleSendMoney = () => {
    if (!amount) {
      toast.error("Please enter an amount");
      return;
    }
    if (!selectedContact) {
      toast.error("Please select a contact");
      return;
    }
    const contact = recentContacts.find(c => c.id === selectedContact);
    toast.success(`Sending $${amount} to ${contact?.name}`);
    setAmount("");
    setSelectedContact(null);
  };

  const handleViewAllContacts = () => {
    toast.info("View all contacts");
  };

  const handlePaymentMethodClick = (methodName: string) => {
    toast.info(`Selected payment method: ${methodName}`);
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">Transfers & Payments</h1>
        <p className="text-gray-400 mt-1">Send money instantly</p>
      </motion.div>

      {/* Transfer Options */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="grid grid-cols-2 gap-4"
      >
        {[
          { icon: Send, label: "Send Money", color: "from-blue-500 to-cyan-500", description: "Instant transfer" },
          { icon: Download, label: "Request", color: "from-emerald-500 to-teal-500", description: "Request payment" },
          { icon: QrCode, label: "QR Payment", color: "from-purple-500 to-pink-500", description: "Scan to pay" },
          { icon: Users, label: "Split Bill", color: "from-orange-500 to-red-500", description: "Share expenses" },
        ].map((option, idx) => (
          <motion.button
            key={option.label}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2 + idx * 0.05 }}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="p-5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all text-left"
            onClick={() => {
              if (option.label === "Send Money") {
                setSendMoneyModalOpen(true);
              } else if (option.label === "QR Payment") {
                setQRPaymentModalOpen(true);
              } else if (option.label === "Request") {
                handleRequest();
              } else if (option.label === "Split Bill") {
                handleSplitBill();
              }
            }}
          >
            <div className={`inline-flex p-3 rounded-xl bg-gradient-to-br ${option.color} mb-3`}>
              <option.icon className="w-6 h-6" />
            </div>
            <h3 className="font-semibold mb-1">{option.label}</h3>
            <p className="text-xs text-gray-400">{option.description}</p>
          </motion.button>
        ))}
      </motion.div>

      {/* Instant Transfer Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="p-6 rounded-3xl bg-gradient-to-br from-blue-600/20 via-purple-600/20 to-pink-600/20 backdrop-blur-xl border border-white/10"
      >
        <div className="flex items-center gap-2 mb-4">
          <Zap className="w-5 h-5 text-yellow-400" />
          <h3 className="font-semibold">Instant Transfer</h3>
        </div>

        {/* Amount Input */}
        <div className="mb-6">
          <label className="text-sm text-gray-400 mb-2 block">Amount</label>
          <div className="flex items-center gap-2 p-4 rounded-2xl bg-white/5 border border-white/10">
            <span className="text-2xl font-bold text-gray-400">$</span>
            <input
              type="text"
              value={amount}
              onChange={(e) => setAmount(e.target.value.replace(/[^0-9.]/g, ""))}
              placeholder="0.00"
              className="flex-1 bg-transparent text-3xl font-bold outline-none"
            />
          </div>
        </div>

        {/* Recent Contacts */}
        <div className="mb-6">
          <label className="text-sm text-gray-400 mb-3 block">Send to</label>
          <div className="flex gap-3 overflow-x-auto pb-2">
            {recentContacts.map((contact) => (
              <motion.button
                key={contact.id}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedContact(contact.id)}
                className={`flex-shrink-0 flex flex-col items-center gap-2 p-3 rounded-2xl backdrop-blur-xl transition-all cursor-pointer ${
                  selectedContact === contact.id
                    ? "bg-blue-500/30 border border-blue-500/50"
                    : "bg-white/5 border border-white/10"
                }`}
              >
                <div className={`w-12 h-12 rounded-full bg-gradient-to-br ${contact.color} flex items-center justify-center font-semibold`}>
                  {contact.avatar}
                </div>
                <span className="text-xs text-center whitespace-nowrap">{contact.name.split(" ")[0]}</span>
              </motion.button>
            ))}
            <button className="flex-shrink-0 flex flex-col items-center gap-2 p-3 rounded-2xl bg-white/5 border border-white/10" onClick={handleViewAllContacts}>
              <div className="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center">
                <Users className="w-6 h-6" />
              </div>
              <span className="text-xs">All</span>
            </button>
          </div>
        </div>

        {/* Send Button */}
        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          className="w-full py-4 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 hover:shadow-blue-500/50 transition-all flex items-center justify-center gap-2"
          onClick={handleSendMoney}
        >
          <span>Send Money</span>
          <ArrowRight className="w-5 h-5" />
        </motion.button>
      </motion.div>

      {/* Payment Methods */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Payment Methods</h3>
        {[
          { name: "Visa •••• 4242", type: "Credit Card", icon: "💳", balance: "$12,450" },
          { name: "Main Account", type: "Checking", icon: "🏦", balance: "$73,542" },
          { name: "Crypto Wallet", type: "Bitcoin", icon: "₿", balance: "0.234 BTC" },
        ].map((method, idx) => (
          <motion.div
            key={method.name}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5 + idx * 0.05 }}
            className="flex items-center gap-4 p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all cursor-pointer"
            onClick={() => handlePaymentMethodClick(method.name)}
          >
            <div className="text-3xl">{method.icon}</div>
            <div className="flex-1">
              <h4 className="font-medium">{method.name}</h4>
              <p className="text-xs text-gray-400">{method.type}</p>
            </div>
            <div className="text-right">
              <p className="font-semibold">{method.balance}</p>
            </div>
          </motion.div>
        ))}
      </motion.div>

      {/* Modals */}
      <SendMoneyModal
        isOpen={sendMoneyModalOpen}
        onClose={() => setSendMoneyModalOpen(false)}
      />
      <QRPaymentModal
        isOpen={qrPaymentModalOpen}
        onClose={() => setQRPaymentModalOpen(false)}
      />
    </div>
  );
}