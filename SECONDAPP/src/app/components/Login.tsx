import { motion } from "motion/react";
import { Fingerprint, Eye, EyeOff, Lock, Shield, Scan, Key, Mail, ArrowLeft, CheckCircle2 } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router";
import { useTheme } from "../contexts/ThemeContext";

type AuthMode = "biometric" | "email" | "key";

export default function Login() {
  const [authMode, setAuthMode] = useState<AuthMode>("biometric");
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [keyCode, setKeyCode] = useState("");
  const [authenticating, setAuthenticating] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [resetEmail, setResetEmail] = useState("");
  const [resetSent, setResetSent] = useState(false);
  const [faceScanning, setFaceScanning] = useState(false);
  const navigate = useNavigate();
  const { theme } = useTheme();

  // Handle biometric login (Face ID / Touch ID)
  const handleBiometricLogin = () => {
    setAuthenticating(true);
    setTimeout(() => {
      navigate("/");
    }, 1500);
  };

  // Handle facial recognition
  const handleFaceRecognition = () => {
    setFaceScanning(true);
    setTimeout(() => {
      setAuthenticating(true);
      setTimeout(() => {
        navigate("/");
      }, 1000);
    }, 2000);
  };

  // Handle email/password login
  const handleEmailLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setAuthenticating(true);
    setTimeout(() => {
      navigate("/");
    }, 1000);
  };

  // Handle key access login
  const handleKeyLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setAuthenticating(true);
    setTimeout(() => {
      navigate("/");
    }, 1000);
  };

  // Handle forgot password
  const handleForgotPassword = (e: React.FormEvent) => {
    e.preventDefault();
    setTimeout(() => {
      setResetSent(true);
    }, 1000);
  };

  // Forgot Password Screen
  if (showForgotPassword) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 text-white flex flex-col">
        {/* Header */}
        <div className="p-6 flex items-center">
          <button
            onClick={() => {
              setShowForgotPassword(false);
              setResetSent(false);
              setResetEmail("");
            }}
            className="p-3 rounded-2xl bg-white/20 hover:bg-white/30 transition-all active:scale-95 shadow-lg"
          >
            <ArrowLeft className="w-6 h-6" />
          </button>
        </div>

        <div className="flex-1 flex items-center justify-center px-6 pb-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="w-full max-w-sm"
          >
            {!resetSent ? (
              <>
                {/* Icon */}
                <div className="text-center mb-8">
                  <div className="inline-flex p-6 rounded-3xl bg-gradient-to-br from-blue-500/20 to-purple-500/20 backdrop-blur-xl border border-white/10 mb-6">
                    <Lock className="w-12 h-12 text-blue-400" />
                  </div>
                  <h1 className="text-3xl font-bold mb-3">Mot de passe oublié ?</h1>
                  <p className="text-gray-400">
                    Pas de souci ! Entrez votre email et nous vous enverrons un lien de réinitialisation
                  </p>
                </div>

                {/* Reset Form */}
                <form onSubmit={handleForgotPassword} className="space-y-6">
                  <div>
                    <label className="text-sm text-gray-400 mb-3 block">Adresse email</label>
                    <div className="relative">
                      <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
                      <input
                        type="email"
                        value={resetEmail}
                        onChange={(e) => setResetEmail(e.target.value)}
                        placeholder="alex.martin@email.com"
                        className="w-full pl-12 pr-4 py-5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-base"
                        required
                      />
                    </div>
                  </div>

                  <motion.button
                    whileTap={{ scale: 0.98 }}
                    type="submit"
                    className="w-full py-5 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 transition-all active:scale-95"
                  >
                    Envoyer le lien
                  </motion.button>
                </form>
              </>
            ) : (
              <>
                {/* Success State */}
                <div className="text-center">
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: "spring", duration: 0.6 }}
                    className="inline-flex p-6 rounded-full bg-gradient-to-br from-emerald-500/20 to-green-500/20 backdrop-blur-xl border border-emerald-500/20 mb-8"
                  >
                    <CheckCircle2 className="w-20 h-20 text-emerald-400" />
                  </motion.div>
                  <h1 className="text-3xl font-bold mb-4">Email envoyé !</h1>
                  <p className="text-gray-400 mb-10 leading-relaxed">
                    Vérifiez votre boîte mail.<br />Un lien de réinitialisation a été envoyé à<br />
                    <span className="text-blue-400 font-medium">{resetEmail}</span>
                  </p>
                  <motion.button
                    whileTap={{ scale: 0.98 }}
                    onClick={() => {
                      setShowForgotPassword(false);
                      setResetSent(false);
                      setResetEmail("");
                    }}
                    className="w-full py-5 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 transition-all active:scale-95"
                  >
                    Retour à la connexion
                  </motion.button>
                </div>
              </>
            )}
          </motion.div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 text-white flex flex-col relative overflow-hidden">
      {/* Animated Background Orbs */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 -left-20 w-72 h-72 bg-cyan-400/30 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-40 -right-20 w-80 h-80 bg-yellow-400/20 rounded-full blur-3xl animate-pulse" style={{ animationDelay: "1.5s" }}></div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-pink-400/20 rounded-full blur-3xl animate-pulse" style={{ animationDelay: "3s" }}></div>
      </div>

      {/* Header */}
      <div className="relative z-10 pt-6 pb-4 px-6">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
        >
          <div className="inline-flex p-3 rounded-2xl bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 shadow-2xl shadow-purple-500/40 mb-3 relative overflow-hidden">
            <Lock className="w-8 h-8 relative z-10" />
            <motion.div
              className="absolute inset-0 bg-white/20"
              animate={{
                opacity: [0.2, 0.4, 0.2],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            />
          </div>
          <h1 className="text-3xl font-bold mb-1 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
            NexBank
          </h1>
          <p className="text-gray-400 text-xs">Votre banque du futur</p>
        </motion.div>
      </div>

      {/* Content */}
      <div className="flex-1 relative z-10 px-6 pb-4 overflow-y-auto">
        <div className="max-w-sm mx-auto space-y-3">
          {/* Auth Mode Tabs */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.1 }}
            className="p-1 rounded-2xl bg-slate-900/60 backdrop-blur-xl border border-white/10"
          >
            <div className="grid grid-cols-3 gap-1">
              <button
                onClick={() => setAuthMode("biometric")}
                className={`py-3 px-2 rounded-xl transition-all ${ 
                  authMode === "biometric"
                    ? "bg-gradient-to-r from-blue-500 to-purple-500"
                    : "bg-transparent active:bg-white/5"
                }`}
              >
                <Fingerprint className="w-6 h-6" />
              </button>
              <button
                onClick={() => setAuthMode("key")}
                className={`py-3 px-2 rounded-xl transition-all ${
                  authMode === "key"
                    ? "bg-gradient-to-r from-blue-500 to-purple-500"
                    : "bg-transparent active:bg-white/5"
                }`}
              >
                <Key className="w-6 h-6" />
              </button>
              <button
                onClick={() => setAuthMode("email")}
                className={`py-3 px-2 rounded-xl transition-all ${
                  authMode === "email"
                    ? "bg-gradient-to-r from-blue-500 to-purple-500"
                    : "bg-transparent active:bg-white/5"
                }`}
              >
                <Mail className="w-4 h-4 mx-auto mb-1" />
                <span className="text-[10px] font-medium">Email</span>
              </button>
            </div>
          </motion.div>

          {/* Biometric Authentication */}
          {authMode === "biometric" && (
            <motion.div
              key="biometric"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="space-y-3"
            >
              {/* Face ID */}
              <div className="p-5 rounded-2xl bg-gradient-to-br from-blue-500/10 via-purple-500/10 to-pink-500/10 backdrop-blur-xl border border-white/10">
                <h2 className="text-sm font-semibold mb-4 text-center">Face ID</h2>
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  onClick={handleFaceRecognition}
                  disabled={authenticating || faceScanning}
                  className="relative mx-auto w-24 h-24 rounded-full bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 shadow-2xl shadow-purple-500/50 flex items-center justify-center mb-3 disabled:opacity-50 overflow-hidden active:scale-95 transition-transform"
                >
                  {faceScanning ? (
                    <>
                      <Scan className="w-12 h-12 animate-pulse relative z-10" />
                      <motion.div
                        className="absolute inset-0 border-4 border-white/40 rounded-full"
                        animate={{
                          scale: [1, 1.3, 1],
                          opacity: [0.6, 0, 0.6],
                        }}
                        transition={{
                          duration: 1.5,
                          repeat: Infinity,
                          ease: "easeInOut",
                        }}
                      />
                    </>
                  ) : authenticating ? (
                    <div className="w-12 h-12 border-4 border-white/30 border-t-white rounded-full animate-spin"></div>
                  ) : (
                    <Scan className="w-12 h-12 relative z-10" />
                  )}
                  <motion.div
                    className="absolute inset-0 bg-white/10"
                    animate={{
                      opacity: [0.1, 0.2, 0.1],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                    }}
                  />
                </motion.button>
                <p className="text-center text-xs text-gray-400 mb-2">
                  {faceScanning ? "Scan en cours..." : "Toucher pour scanner"}
                </p>
                <div className="flex items-center justify-center gap-2 text-[10px] text-gray-500">
                  <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></div>
                  <span>Caméra prête</span>
                </div>
              </div>

              {/* Touch ID */}
              <div className="p-5 rounded-2xl bg-gradient-to-br from-emerald-500/10 via-blue-500/10 to-purple-500/10 backdrop-blur-xl border border-white/10">
                <h2 className="text-sm font-semibold mb-4 text-center">Touch ID</h2>
                <motion.button
                  whileTap={{ scale: 0.95 }}
                  onClick={handleBiometricLogin}
                  disabled={authenticating || faceScanning}
                  className="relative mx-auto w-20 h-20 rounded-full bg-gradient-to-br from-emerald-500 to-blue-500 shadow-2xl shadow-emerald-500/50 flex items-center justify-center mb-2 disabled:opacity-50 active:scale-95 transition-transform"
                >
                  {authenticating ? (
                    <div className="w-10 h-10 border-4 border-white/30 border-t-white rounded-full animate-spin"></div>
                  ) : (
                    <Fingerprint className="w-10 h-10 relative z-10" />
                  )}
                  <motion.div
                    className="absolute inset-0 rounded-full bg-white/20"
                    animate={{
                      scale: [1, 1.4, 1],
                      opacity: [0.5, 0, 0.5],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut",
                    }}
                  />
                </motion.button>
                <p className="text-center text-xs text-gray-400">Toucher pour authentifier</p>
              </div>
            </motion.div>
          )}

          {/* Key Access */}
          {authMode === "key" && (
            <motion.form
              key="key"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              onSubmit={handleKeyLogin}
              className="p-6 rounded-2xl bg-gradient-to-br from-slate-900/80 via-blue-900/30 to-slate-900/80 backdrop-blur-xl border border-white/10"
            >
              <div className="text-center mb-5">
                <div className="inline-flex p-4 rounded-2xl bg-gradient-to-br from-amber-500/20 to-orange-500/20 mb-4">
                  <Key className="w-8 h-8 text-amber-400" />
                </div>
                <h2 className="text-xl font-bold mb-1">Clé d'accès</h2>
                <p className="text-gray-400 text-xs">Code sécurisé unique</p>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-xs text-gray-400 mb-2 block">Votre code</label>
                  <input
                    type="password"
                    value={keyCode}
                    onChange={(e) => setKeyCode(e.target.value)}
                    placeholder="• • • • • • • •"
                    maxLength={12}
                    className="w-full px-4 py-4 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-amber-500/50 focus:bg-white/10 transition-all text-center text-2xl tracking-[0.5em] font-light"
                    required
                  />
                  <p className="text-[10px] text-gray-500 mt-2 text-center">8 à 12 caractères</p>
                </div>

                <motion.button
                  whileTap={{ scale: 0.98 }}
                  type="submit"
                  disabled={authenticating}
                  className="w-full py-4 rounded-2xl bg-gradient-to-r from-amber-500 to-orange-500 font-semibold shadow-xl shadow-amber-500/30 transition-all disabled:opacity-50 active:scale-95"
                >
                  {authenticating ? "Vérification..." : "Connexion"}
                </motion.button>
              </div>
            </motion.form>
          )}

          {/* Email/Password */}
          {authMode === "email" && (
            <motion.form
              key="email"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              onSubmit={handleEmailLogin}
              className="p-6 rounded-2xl bg-gradient-to-br from-slate-900/80 via-blue-900/30 to-slate-900/80 backdrop-blur-xl border border-white/10"
            >
              <div className="text-center mb-5">
                <div className="inline-flex p-4 rounded-2xl bg-gradient-to-br from-blue-500/20 to-purple-500/20 mb-4">
                  <Mail className="w-8 h-8 text-blue-400" />
                </div>
                <h2 className="text-xl font-bold mb-1">Email & Mot de passe</h2>
                <p className="text-gray-400 text-xs">Connexion classique</p>
              </div>

              <div className="space-y-3">
                <div>
                  <label className="text-xs text-gray-400 mb-2 block">Email</label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="alex.martin@email.com"
                      className="w-full pl-10 pr-4 py-3.5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                      required
                    />
                  </div>
                </div>
                
                <div>
                  <label className="text-xs text-gray-400 mb-2 block">Mot de passe</label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                    <input
                      type={showPassword ? "text" : "password"}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full pl-10 pr-12 py-3.5 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 active:text-white transition-colors p-1"
                    >
                      {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>

                <div className="text-right">
                  <button
                    type="button"
                    onClick={() => setShowForgotPassword(true)}
                    className="text-xs text-blue-400 active:text-blue-300 transition-colors font-medium"
                  >
                    Mot de passe oublié ?
                  </button>
                </div>

                <motion.button
                  whileTap={{ scale: 0.98 }}
                  type="submit"
                  disabled={authenticating}
                  className="w-full py-4 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 transition-all disabled:opacity-50 active:scale-95"
                >
                  {authenticating ? "Connexion..." : "Se connecter"}
                </motion.button>
              </div>
            </motion.form>
          )}

          {/* Sign Up Link */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-center pt-1"
          >
            <div className="text-xs text-gray-500">
              Pas encore de compte ?{" "}
              <button
                onClick={() => navigate("/signup")}
                className="text-blue-400 active:text-blue-300 transition-colors font-semibold"
              >
                Créer un compte
              </button>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Security Footer */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.4 }}
        className="relative z-10 px-6 pb-4"
      >
        <div className="max-w-sm mx-auto p-3 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 flex items-start gap-2">
          <Shield className="w-4 h-4 text-emerald-400 flex-shrink-0 mt-0.5" />
          <p className="text-[10px] text-gray-400 leading-relaxed">
            Chiffrement AES-256 • Auth biométrique • Conforme PCI DSS
          </p>
        </div>
      </motion.div>
    </div>
  );
}