import { motion } from "motion/react";
import { User, Mail, Phone, MapPin, Bell, Globe, Moon, Palette, LogOut, ChevronRight, Settings, CreditCard, Shield, HelpCircle } from "lucide-react";
import { useNavigate } from "react-router";
import { useState } from "react";
import { toast } from "sonner";
import { useTheme } from "../contexts/ThemeContext";
import { useAuth } from "../contexts/AuthContext";
import AppearanceModal from "./AppearanceModal";

const profileInfo = {
  name: "Alex Johnson",
  email: "alex.johnson@email.com",
  phone: "+1 (555) 123-4567",
  address: "San Francisco, CA",
  avatar: "AJ",
  memberSince: "January 2022",
};

const menuSections = [
  {
    title: "Account",
    items: [
      { icon: User, label: "Personal Information", color: "from-blue-500 to-cyan-500" },
      { icon: CreditCard, label: "Payment Methods", color: "from-purple-500 to-pink-500" },
      { icon: Shield, label: "Security & Privacy", color: "from-emerald-500 to-teal-500" },
    ]
  },
  {
    title: "Preferences",
    items: [
      { icon: Bell, label: "Notifications", color: "from-orange-500 to-red-500", badge: "3" },
      { icon: Globe, label: "Language", color: "from-cyan-500 to-blue-500", value: "English" },
      { icon: Palette, label: "Appearance", color: "from-pink-500 to-rose-500", value: "Dark" },
    ]
  },
  {
    title: "Support",
    items: [
      { icon: HelpCircle, label: "Help Center", color: "from-teal-500 to-emerald-500" },
      { icon: Settings, label: "Settings", color: "from-indigo-500 to-purple-500" },
    ]
  }
];

const stats = [
  { label: "Transactions", value: "2,847", color: "from-blue-500 to-cyan-500" },
  { label: "Total Spent", value: "$124.5K", color: "from-purple-500 to-pink-500" },
  { label: "Savings", value: "$32.8K", color: "from-emerald-500 to-teal-500" },
];

export default function Profile() {
  const navigate = useNavigate();
  const { logout } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [isAppearanceModalOpen, setIsAppearanceModalOpen] = useState(false);
  const { theme } = useTheme();

  const handleEditProfile = () => {
    setIsEditing(true);
    toast.success("Edit mode activated!");
  };

  const handleSaveProfile = () => {
    setIsEditing(false);
    toast.success("Profile updated successfully!");
  };

  const handleMenuItemClick = (label: string) => {
    if (label === "Security & Privacy") {
      navigate("/security");
    } else if (label === "Payment Methods") {
      navigate("/cards");
    } else if (label === "Personal Information") {
      toast.info("Opening personal information...");
    } else if (label === "Notifications") {
      toast.info("Opening notification settings...");
    } else if (label === "Language") {
      toast.info("Language: English (US) • Tap to change");
    } else if (label === "Appearance") {
      setIsAppearanceModalOpen(true);
    } else if (label === "Help Center") {
      toast.info("Opening help center...");
    } else if (label === "Settings") {
      toast.info("Opening advanced settings...");
    }
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">Profile</h1>
        <p className="text-gray-400 mt-1">Manage your account</p>
      </motion.div>

      {/* Profile Card */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.1 }}
        className={`p-6 rounded-3xl bg-gradient-to-br ${theme.cardBg} backdrop-blur-xl border border-white/10`}
      >
        <div className="flex items-start gap-4 mb-6">
          <div className={`w-20 h-20 rounded-2xl bg-gradient-to-br ${theme.gradient} flex items-center justify-center text-2xl font-bold`}>
            {profileInfo.avatar}
          </div>
          <div className="flex-1">
            <h2 className="text-xl font-bold mb-1">{profileInfo.name}</h2>
            <p className="text-sm text-gray-400 mb-3">Member since {profileInfo.memberSince}</p>
            <button className="px-4 py-2 rounded-xl bg-white/10 border border-white/20 hover:bg-white/20 transition-all text-sm font-medium" onClick={handleEditProfile}>
              Edit Profile
            </button>
          </div>
        </div>

        {/* Contact Info */}
        <div className="space-y-3">
          <div className="flex items-center gap-3 p-3 rounded-xl bg-white/5">
            <Mail className="w-4 h-4 text-gray-400" />
            <span className="text-sm">{profileInfo.email}</span>
          </div>
          <div className="flex items-center gap-3 p-3 rounded-xl bg-white/5">
            <Phone className="w-4 h-4 text-gray-400" />
            <span className="text-sm">{profileInfo.phone}</span>
          </div>
          <div className="flex items-center gap-3 p-3 rounded-xl bg-white/5">
            <MapPin className="w-4 h-4 text-gray-400" />
            <span className="text-sm">{profileInfo.address}</span>
          </div>
        </div>
      </motion.div>

      {/* Stats */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="grid grid-cols-3 gap-3"
      >
        {stats.map((stat, idx) => (
          <motion.div
            key={stat.label}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 + idx * 0.05 }}
            className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 text-center"
          >
            <div className={`inline-flex p-2 rounded-lg bg-gradient-to-br ${stat.color} mb-2`}>
              <User className="w-4 h-4" />
            </div>
            <p className="text-lg font-bold">{stat.value}</p>
            <p className="text-xs text-gray-400">{stat.label}</p>
          </motion.div>
        ))}
      </motion.div>

      {/* Menu Sections */}
      {menuSections.map((section, sectionIdx) => (
        <motion.div
          key={section.title}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 + sectionIdx * 0.1 }}
          className="space-y-3"
        >
          <h3 className="text-sm font-semibold text-gray-400 uppercase tracking-wider px-2">
            {section.title}
          </h3>
          {section.items.map((item, idx) => {
            const Icon = item.icon;
            return (
              <motion.button
                key={item.label}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.5 + sectionIdx * 0.1 + idx * 0.05 }}
                whileHover={{ scale: 1.01 }}
                whileTap={{ scale: 0.99 }}
                className="w-full flex items-center gap-4 p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all"
                onClick={() => handleMenuItemClick(item.label)}
              >
                <div className={`p-3 rounded-xl bg-gradient-to-br ${item.color}`}>
                  <Icon className="w-5 h-5" />
                </div>
                <span className="flex-1 text-left font-medium">{item.label}</span>
                {item.badge && (
                  <span className="px-2 py-1 rounded-full bg-red-500 text-xs font-semibold">
                    {item.badge}
                  </span>
                )}
                {item.value && (
                  <span className="text-sm text-gray-400">{item.value}</span>
                )}
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </motion.button>
            );
          })}
        </motion.div>
      ))}

      {/* Logout */}
      <motion.button
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="w-full p-4 rounded-2xl bg-red-500/20 border border-red-500/50 hover:bg-red-500/30 transition-all flex items-center justify-center gap-2 font-semibold text-red-400"
        onClick={() => {
          logout();
          navigate("/login", { replace: true });
          toast.message("Vous êtes déconnecté.");
        }}
      >
        <LogOut className="w-5 h-5" />
        <span>Logout</span>
      </motion.button>

      {/* App Version */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.9 }}
        className="text-center text-sm text-gray-500 pb-4"
      >
        NexBank v2.4.1
      </motion.div>

      {/* Appearance Modal */}
      <AppearanceModal
        isOpen={isAppearanceModalOpen}
        onClose={() => setIsAppearanceModalOpen(false)}
      />
    </div>
  );
}