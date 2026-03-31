import { motion } from "motion/react";
import { Fingerprint, Smartphone, Shield, Lock, Key, Eye, CheckCircle, AlertTriangle, Clock } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import ChangePasswordModal from "./modals/ChangePasswordModal";

const securityFeatures = [
  {
    title: "Biometric Login",
    description: "Face ID & Fingerprint",
    enabled: true,
    icon: Fingerprint,
    color: "from-blue-500 to-cyan-500"
  },
  {
    title: "Two-Factor Authentication",
    description: "SMS & Authenticator App",
    enabled: true,
    icon: Smartphone,
    color: "from-purple-500 to-pink-500"
  },
  {
    title: "Transaction Alerts",
    description: "Instant notifications",
    enabled: true,
    icon: Shield,
    color: "from-emerald-500 to-teal-500"
  },
  {
    title: "Auto Lock",
    description: "Lock after 5 minutes",
    enabled: false,
    icon: Lock,
    color: "from-orange-500 to-red-500"
  },
];

const recentActivity = [
  { id: 1, action: "Login", device: "iPhone 14 Pro", location: "San Francisco, CA", time: "2 hours ago", status: "success" },
  { id: 2, action: "Password Changed", device: "MacBook Pro", location: "San Francisco, CA", time: "3 days ago", status: "success" },
  { id: 3, action: "Failed Login Attempt", device: "Unknown Device", location: "Unknown Location", time: "1 week ago", status: "warning" },
];

const trustedDevices = [
  { id: 1, name: "iPhone 14 Pro", lastActive: "Active now", icon: "📱" },
  { id: 2, name: "MacBook Pro", lastActive: "2 hours ago", icon: "💻" },
  { id: 3, name: "iPad Air", lastActive: "3 days ago", icon: "📱" },
];

export default function Security() {
  const [biometricEnabled, setBiometricEnabled] = useState(true);
  const [showChangePasswordModal, setShowChangePasswordModal] = useState(false);

  const handleRemoveDevice = (deviceName: string) => {
    toast.success(`${deviceName} removed from trusted devices`);
  };

  const handleToggleBiometric = () => {
    setBiometricEnabled(!biometricEnabled);
    if (!biometricEnabled) {
      toast.success("Biometric authentication enabled");
    } else {
      toast.warning("Biometric authentication disabled");
    }
  };

  const handleConfigureBiometric = () => {
    toast.info("Opening biometric configuration...");
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <h1 className="text-2xl font-bold">Security</h1>
        <p className="text-gray-400 mt-1">Protect your account</p>
      </motion.div>

      {/* Security Score */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="p-6 rounded-3xl bg-gradient-to-br from-blue-600/20 via-purple-600/20 to-pink-600/20 backdrop-blur-xl border border-white/10"
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-purple-500">
              <Fingerprint className="w-6 h-6" />
            </div>
            <div>
              <h3 className="font-semibold">Biometric Authentication</h3>
              <p className="text-sm text-gray-400">Face ID & Touch ID</p>
            </div>
          </div>
          <button
            onClick={handleToggleBiometric}
            className={`relative w-14 h-7 rounded-full transition-all cursor-pointer ${
              biometricEnabled
                ? "bg-gradient-to-r from-blue-500 to-purple-500"
                : "bg-white/10"
            }`}
          >
            <div
              className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${
                biometricEnabled ? "right-1" : "left-1"
              }`}
            ></div>
          </button>
        </div>
        {biometricEnabled && (
          <motion.button
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="w-full py-3 rounded-xl bg-white/10 border border-white/20 hover:bg-white/20 transition-all"
            onClick={handleConfigureBiometric}
          >
            Configure Biometric Settings
          </motion.button>
        )}
      </motion.div>

      {/* Security Features */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Security Features</h3>
        {securityFeatures.map((feature, idx) => {
          const Icon = feature.icon;
          return (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.4 + idx * 0.05 }}
              className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:bg-white/10 transition-all"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className={`p-3 rounded-xl bg-gradient-to-br ${feature.color}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="font-semibold">{feature.title}</h4>
                    <p className="text-sm text-gray-400">{feature.description}</p>
                  </div>
                </div>
                <div className={`px-3 py-1 rounded-full text-xs font-semibold ${
                  feature.enabled
                    ? "bg-emerald-500/20 text-emerald-400"
                    : "bg-gray-500/20 text-gray-400"
                }`}>
                  {feature.enabled ? "Enabled" : "Disabled"}
                </div>
              </div>
            </motion.div>
          );
        })}
      </motion.div>

      {/* Change Password */}
      <motion.button
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="w-full p-4 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 hover:shadow-blue-500/50 transition-all flex items-center justify-center gap-2"
        onClick={() => setShowChangePasswordModal(true)}
      >
        <Key className="w-5 h-5" />
        <span>Change Password</span>
      </motion.button>

      {/* Trusted Devices */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Trusted Devices</h3>
        {trustedDevices.map((device, idx) => (
          <motion.div
            key={device.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.8 + idx * 0.05 }}
            className="flex items-center gap-4 p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
          >
            <div className="text-3xl">{device.icon}</div>
            <div className="flex-1">
              <h4 className="font-semibold">{device.name}</h4>
              <p className="text-sm text-gray-400">{device.lastActive}</p>
            </div>
            <button className="text-sm text-red-400 hover:text-red-300" onClick={() => handleRemoveDevice(device.name)}>Remove</button>
          </motion.div>
        ))}
      </motion.div>

      {/* Recent Activity */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.9 }}
        className="space-y-3"
      >
        <h3 className="text-lg font-semibold">Recent Activity</h3>
        {recentActivity.map((activity, idx) => (
          <motion.div
            key={activity.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 1 + idx * 0.05 }}
            className="p-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10"
          >
            <div className="flex items-start gap-3">
              <div className={`p-2 rounded-lg ${
                activity.status === "success" ? "bg-emerald-500/20" : "bg-orange-500/20"
              }`}>
                {activity.status === "success" ? (
                  <CheckCircle className="w-5 h-5 text-emerald-400" />
                ) : (
                  <AlertTriangle className="w-5 h-5 text-orange-400" />
                )}
              </div>
              <div className="flex-1">
                <h4 className="font-semibold">{activity.action}</h4>
                <p className="text-sm text-gray-400">{activity.device} • {activity.location}</p>
                <div className="flex items-center gap-1 mt-1 text-xs text-gray-500">
                  <Clock className="w-3 h-3" />
                  <span>{activity.time}</span>
                </div>
              </div>
            </div>
          </motion.div>
        ))}
      </motion.div>

      {/* Change Password Modal */}
      <ChangePasswordModal 
        isOpen={showChangePasswordModal} 
        onClose={() => setShowChangePasswordModal(false)} 
      />
    </div>
  );
}