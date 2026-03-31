import { motion } from "motion/react";
import { CreditCard, Eye, EyeOff, Lock, Unlock, Plus, X, Zap } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import HolographicCard from "./effects/HolographicCard";
import AnimatedBorder from "./effects/AnimatedBorder";
import LEDIndicator from "./effects/LEDIndicator";

const cards = [
  {
    id: 1,
    type: "Virtual Card",
    number: "4532 •••• •••• 8923",
    holder: "Alex Johnson",
    expiry: "12/26",
    cvv: "***",
    balance: "$12,450.00",
    limit: "$15,000.00",
    color: "from-blue-600 via-purple-600 to-pink-600",
    status: "active"
  },
  {
    id: 2,
    type: "Physical Card",
    number: "5234 •••• •••• 1234",
    holder: "Alex Johnson",
    expiry: "09/27",
    cvv: "***",
    balance: "$8,234.50",
    limit: "$10,000.00",
    color: "from-emerald-600 via-teal-600 to-cyan-600",
    status: "active"
  },
];

const recentCardTransactions = [
  { id: 1, merchant: "Apple Store", amount: "$1,299.00", date: "Today, 2:30 PM", category: "Shopping" },
  { id: 2, merchant: "Uber", amount: "$24.50", date: "Today, 10:15 AM", category: "Transportation" },
  { id: 3, merchant: "Whole Foods", amount: "$142.80", date: "Yesterday, 6:45 PM", category: "Groceries" },
];

export default function Cards() {
  const [selectedCard, setSelectedCard] = useState(0);
  const [showDetails, setShowDetails] = useState(false);
  const [cardLocked, setCardLocked] = useState(false);

  const currentCard = cards[selectedCard];

  const handleLockToggle = () => {
    setCardLocked(!cardLocked);
    if (!cardLocked) {
      toast.warning("Card locked for security");
    } else {
      toast.success("Card unlocked successfully");
    }
  };

  const handleShowDetails = () => {
    setShowDetails(!showDetails);
    if (!showDetails) {
      toast.info("Showing full card details");
    }
  };

  const handleAdjustLimit = () => {
    toast.info("Adjust spending limit");
  };

  const handleRequestNewCard = () => {
    toast.success("New card request submitted!");
  };

  const handleViewAllTransactions = () => {
    toast.info("View all card transactions");
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">My Cards</h1>
        <p className="text-gray-400 mt-1">Manage your cards</p>
      </motion.div>

      {/* Card Display */}
      <div className="space-y-4">
        {cards.map((card, idx) => (
          <HolographicCard key={card.id} className="rounded-3xl">
            <AnimatedBorder className="rounded-3xl" borderWidth={2} speed={4}>
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ 
                  opacity: selectedCard === idx ? 1 : 0.6,
                  scale: selectedCard === idx ? 1 : 0.95,
                  y: selectedCard === idx ? 0 : 10
                }}
                transition={{ delay: 0.1 + idx * 0.05 }}
                onClick={() => setSelectedCard(idx)}
                className="relative overflow-hidden rounded-3xl p-6 cursor-pointer transition-all"
                style={{
                  background: `linear-gradient(135deg, var(--tw-gradient-stops))`,
                }}
              >
                <div className={`absolute inset-0 bg-gradient-to-br ${card.color}`}></div>
                <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-transparent"></div>
                
                <div className="relative z-10 space-y-8">
                  {/* Card Header */}
                  <div className="flex justify-between items-start">
                    <div>
                      <p className="text-white/80 text-xs mb-1">{card.type}</p>
                      <p className="text-white text-sm font-semibold">{card.balance}</p>
                    </div>
                    <div className="flex gap-2 items-center">
                      <Zap className="w-5 h-5 text-white/80" />
                      {card.status === "active" && (
                        <LEDIndicator color="green" size="sm" />
                      )}
                    </div>
                  </div>

                  {/* Card Number */}
                  <div>
                    <p className="text-white text-xl font-semibold tracking-wider text-glow">
                      {card.number}
                    </p>
                  </div>

                  {/* Card Footer */}
                  <div className="flex justify-between items-end">
                    <div>
                      <p className="text-white/60 text-xs mb-1">Card Holder</p>
                      <p className="text-white text-sm font-semibold">{card.holder}</p>
                    </div>
                    <div>
                      <p className="text-white/60 text-xs mb-1">Expires</p>
                      <p className="text-white text-sm font-semibold">{card.expiry}</p>
                    </div>
                    <div>
                      <p className="text-white/60 text-xs mb-1">CVV</p>
                      <p className="text-white text-sm font-semibold">{card.cvv}</p>
                    </div>
                  </div>
                </div>

                {/* Card Chip */}
                <div className="absolute top-20 left-6 w-12 h-10 bg-gradient-to-br from-yellow-400 to-yellow-600 rounded-lg opacity-80"></div>
              </motion.div>
            </AnimatedBorder>
          </HolographicCard>
        ))}
      </div>

      {/* Card Actions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="grid grid-cols-2 gap-4"
      >
        <motion.button
          whileHover={{ scale: 1.03, y: -2 }}
          whileTap={{ scale: 0.98 }}
          onClick={handleLockToggle}
          className={`p-5 rounded-2xl backdrop-blur-xl border-2 transition-all ${
            cardLocked
              ? "bg-red-500/20 border-red-500/50 hover:border-red-500/70"
              : "bg-white/5 border-white/20 hover:border-white/40"
          }`}
        >
          <div className="flex items-center justify-center gap-3">
            <div className={`p-2 rounded-lg ${cardLocked ? "bg-red-500/30" : "bg-blue-500/20"}`}>
              {cardLocked ? <Lock className="w-5 h-5 text-red-400" /> : <Unlock className="w-5 h-5 text-blue-400" />}
            </div>
            <div className="text-left">
              <span className="block font-semibold text-sm">{cardLocked ? "Unlock Card" : "Lock Card"}</span>
              <span className="block text-xs text-gray-400 mt-0.5">{cardLocked ? "Restore access" : "Secure card"}</span>
            </div>
          </div>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.03, y: -2 }}
          whileTap={{ scale: 0.98 }}
          onClick={handleShowDetails}
          className="p-5 rounded-2xl bg-white/5 backdrop-blur-xl border-2 border-white/20 hover:border-white/40 transition-all"
        >
          <div className="flex items-center justify-center gap-3">
            <div className="p-2 rounded-lg bg-purple-500/20">
              {showDetails ? <EyeOff className="w-5 h-5 text-purple-400" /> : <Eye className="w-5 h-5 text-purple-400" />}
            </div>
            <div className="text-left">
              <span className="block font-semibold text-sm">{showDetails ? "Hide Details" : "Show Details"}</span>
              <span className="block text-xs text-gray-400 mt-0.5">Card information</span>
            </div>
          </div>
        </motion.button>
      </motion.div>

      {/* Card Details */}
      {showDetails && (
        <motion.div
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: "auto" }}
          exit={{ opacity: 0, height: 0 }}
          className="p-5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 space-y-4"
        >
          <div className="flex justify-between">
            <span className="text-gray-400">Full Card Number</span>
            <span className="font-semibold">4532 1234 5678 8923</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">CVV</span>
            <span className="font-semibold">582</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Spending Limit</span>
            <span className="font-semibold">{currentCard.limit}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Available</span>
            <span className="font-semibold text-emerald-400">
              ${(parseFloat(currentCard.limit.replace(/[$,]/g, "")) - parseFloat(currentCard.balance.replace(/[$,]/g, ""))).toLocaleString()}
            </span>
          </div>
        </motion.div>
      )}

      {/* Spending Limit */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="p-5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
      >
        <div className="flex justify-between items-center mb-3">
          <h3 className="font-semibold">Spending Limit</h3>
          <button className="text-sm text-blue-400 hover:text-blue-300" onClick={handleAdjustLimit}>Adjust</button>
        </div>
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span className="text-gray-400">Used</span>
            <span className="font-semibold">{currentCard.balance} / {currentCard.limit}</span>
          </div>
          <div className="h-2 bg-white/10 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"
              style={{
                width: `${(parseFloat(currentCard.balance.replace(/[$,]/g, "")) / parseFloat(currentCard.limit.replace(/[$,]/g, ""))) * 100}%`
              }}
            ></div>
          </div>
        </div>
      </motion.div>

      {/* Recent Transactions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="space-y-3"
      >
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-semibold">Recent Transactions</h3>
          <button className="text-sm text-blue-400 hover:text-blue-300" onClick={handleViewAllTransactions}>View All</button>
        </div>
        {recentCardTransactions.map((transaction, idx) => (
          <motion.div
            key={transaction.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.6 + idx * 0.05 }}
            className="flex items-center justify-between p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
          >
            <div className="flex-1">
              <h4 className="font-medium">{transaction.merchant}</h4>
              <p className="text-xs text-gray-400">{transaction.date} • {transaction.category}</p>
            </div>
            <div className="font-semibold">${transaction.amount}</div>
          </motion.div>
        ))}
      </motion.div>

      {/* Add New Card */}
      <motion.button
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="w-full p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 border-dashed hover:bg-white/10 transition-all flex items-center justify-center gap-2"
        onClick={handleRequestNewCard}
      >
        <Plus className="w-5 h-5" />
        <span>Request New Card</span>
      </motion.button>
    </div>
  );
}