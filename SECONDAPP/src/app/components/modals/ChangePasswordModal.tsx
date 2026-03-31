import { motion, AnimatePresence } from "motion/react";
import { X, Lock, Eye, EyeOff, CheckCircle2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

interface ChangePasswordModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ChangePasswordModal({ isOpen, onClose }: ChangePasswordModalProps) {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isChanging, setIsChanging] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Validation
    if (!currentPassword) {
      toast.error("Please enter your current password");
      return;
    }

    if (newPassword.length < 8) {
      toast.error("New password must be at least 8 characters");
      return;
    }

    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    }

    if (currentPassword === newPassword) {
      toast.error("New password must be different from current password");
      return;
    }

    setIsChanging(true);

    // Simulate API call
    setTimeout(() => {
      setIsChanging(false);
      setSuccess(true);
      toast.success("Password changed successfully!");

      setTimeout(() => {
        handleClose();
      }, 2000);
    }, 1500);
  };

  const handleClose = () => {
    setCurrentPassword("");
    setNewPassword("");
    setConfirmPassword("");
    setShowCurrentPassword(false);
    setShowNewPassword(false);
    setShowConfirmPassword(false);
    setSuccess(false);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-6">
        {/* Backdrop */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={handleClose}
          className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        />

        {/* Modal */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          className="relative w-full max-w-md bg-slate-900 rounded-3xl border border-white/10 shadow-2xl overflow-hidden"
        >
          {/* Success Screen */}
          {success ? (
            <div className="p-8 text-center">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", duration: 0.6 }}
                className="inline-flex p-6 rounded-full bg-gradient-to-br from-emerald-500/20 to-green-500/20 backdrop-blur-xl border border-emerald-500/20 mb-6"
              >
                <CheckCircle2 className="w-16 h-16 text-emerald-400" />
              </motion.div>
              <h2 className="text-2xl font-bold mb-2">Password Changed!</h2>
              <p className="text-gray-400">
                Your password has been updated successfully
              </p>
            </div>
          ) : (
            <>
              {/* Header */}
              <div className="flex items-center justify-between p-6 border-b border-white/10">
                <div className="flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-purple-500">
                    <Lock className="w-5 h-5" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold">Change Password</h2>
                    <p className="text-sm text-gray-400">Update your security credentials</p>
                  </div>
                </div>
                <button
                  onClick={handleClose}
                  className="p-2 rounded-xl bg-white/5 hover:bg-white/10 transition-all"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Form */}
              <form onSubmit={handleSubmit} className="p-6 space-y-4">
                {/* Current Password */}
                <div>
                  <label className="text-sm text-gray-400 mb-2 block">
                    Current Password
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                    <input
                      type={showCurrentPassword ? "text" : "password"}
                      value={currentPassword}
                      onChange={(e) => setCurrentPassword(e.target.value)}
                      placeholder="Enter current password"
                      className="w-full pl-10 pr-12 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors p-1"
                    >
                      {showCurrentPassword ? (
                        <EyeOff className="w-4 h-4" />
                      ) : (
                        <Eye className="w-4 h-4" />
                      )}
                    </button>
                  </div>
                </div>

                {/* New Password */}
                <div>
                  <label className="text-sm text-gray-400 mb-2 block">
                    New Password
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                    <input
                      type={showNewPassword ? "text" : "password"}
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="Enter new password"
                      minLength={8}
                      className="w-full pl-10 pr-12 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowNewPassword(!showNewPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors p-1"
                    >
                      {showNewPassword ? (
                        <EyeOff className="w-4 h-4" />
                      ) : (
                        <Eye className="w-4 h-4" />
                      )}
                    </button>
                  </div>
                  <p className="text-xs text-gray-500 mt-1">
                    Minimum 8 characters
                  </p>
                </div>

                {/* Confirm New Password */}
                <div>
                  <label className="text-sm text-gray-400 mb-2 block">
                    Confirm New Password
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                    <input
                      type={showConfirmPassword ? "text" : "password"}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      placeholder="Confirm new password"
                      minLength={8}
                      className="w-full pl-10 pr-12 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors p-1"
                    >
                      {showConfirmPassword ? (
                        <EyeOff className="w-4 h-4" />
                      ) : (
                        <Eye className="w-4 h-4" />
                      )}
                    </button>
                  </div>
                </div>

                {/* Password Match Indicator */}
                {newPassword && confirmPassword && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className={`text-sm px-3 py-2 rounded-lg ${
                      newPassword === confirmPassword
                        ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"
                        : "bg-red-500/10 text-red-400 border border-red-500/20"
                    }`}
                  >
                    {newPassword === confirmPassword
                      ? "✓ Passwords match"
                      : "✗ Passwords do not match"}
                  </motion.div>
                )}

                {/* Password Strength Indicator */}
                {newPassword && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-2"
                  >
                    <p className="text-xs text-gray-400">Password strength:</p>
                    <div className="flex gap-1">
                      <div
                        className={`h-1.5 flex-1 rounded-full transition-all ${
                          newPassword.length >= 8 ? "bg-emerald-500" : "bg-white/10"
                        }`}
                      />
                      <div
                        className={`h-1.5 flex-1 rounded-full transition-all ${
                          newPassword.length >= 10 && /[A-Z]/.test(newPassword)
                            ? "bg-emerald-500"
                            : "bg-white/10"
                        }`}
                      />
                      <div
                        className={`h-1.5 flex-1 rounded-full transition-all ${
                          newPassword.length >= 12 &&
                          /[A-Z]/.test(newPassword) &&
                          /[0-9]/.test(newPassword) &&
                          /[^A-Za-z0-9]/.test(newPassword)
                            ? "bg-emerald-500"
                            : "bg-white/10"
                        }`}
                      />
                    </div>
                    <p className="text-xs text-gray-500">
                      {newPassword.length >= 12 &&
                      /[A-Z]/.test(newPassword) &&
                      /[0-9]/.test(newPassword) &&
                      /[^A-Za-z0-9]/.test(newPassword)
                        ? "Strong password"
                        : newPassword.length >= 10 && /[A-Z]/.test(newPassword)
                        ? "Medium strength"
                        : "Weak password"}
                    </p>
                  </motion.div>
                )}

                {/* Security Tips */}
                <div className="p-4 rounded-xl bg-blue-500/10 border border-blue-500/20">
                  <p className="text-xs text-blue-400 mb-2 font-semibold">
                    💡 Password Tips:
                  </p>
                  <ul className="text-xs text-gray-400 space-y-1">
                    <li>• Use at least 8 characters</li>
                    <li>• Mix uppercase and lowercase letters</li>
                    <li>• Include numbers and special characters</li>
                    <li>• Avoid common words or personal info</li>
                  </ul>
                </div>

                {/* Buttons */}
                <div className="flex gap-3 pt-2">
                  <button
                    type="button"
                    onClick={handleClose}
                    className="flex-1 py-3 rounded-xl bg-white/5 border border-white/10 hover:bg-white/10 transition-all font-medium"
                  >
                    Cancel
                  </button>
                  <motion.button
                    whileTap={{ scale: 0.98 }}
                    type="submit"
                    disabled={isChanging}
                    className="flex-1 py-3 rounded-xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 hover:shadow-blue-500/50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isChanging ? "Changing..." : "Change Password"}
                  </motion.button>
                </div>
              </form>
            </>
          )}
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
