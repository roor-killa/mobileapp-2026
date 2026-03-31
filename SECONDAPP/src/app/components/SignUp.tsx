import { motion } from "motion/react";
import { User, Mail, Phone, Lock, Eye, EyeOff, ArrowLeft, CheckCircle2, MapPin, Calendar } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router";
import { useTheme } from "../contexts/ThemeContext";

export default function SignUp() {
  const [step, setStep] = useState(1);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isCreating, setIsCreating] = useState(false);
  const [accountCreated, setAccountCreated] = useState(false);
  
  // Form data
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [dateOfBirth, setDateOfBirth] = useState("");
  const [address, setAddress] = useState("");
  const [city, setCity] = useState("");
  const [postalCode, setPostalCode] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [acceptTerms, setAcceptTerms] = useState(false);
  
  const navigate = useNavigate();
  const { theme } = useTheme();

  const handleStep1Submit = (e: React.FormEvent) => {
    e.preventDefault();
    setStep(2);
  };

  const handleStep2Submit = (e: React.FormEvent) => {
    e.preventDefault();
    setStep(3);
  };

  const handleFinalSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      alert("Les mots de passe ne correspondent pas");
      return;
    }
    if (!acceptTerms) {
      alert("Veuillez accepter les conditions d'utilisation");
      return;
    }
    
    setIsCreating(true);
    // Simulate account creation
    setTimeout(() => {
      setIsCreating(false);
      setAccountCreated(true);
      setTimeout(() => {
        navigate("/login");
      }, 2500);
    }, 2000);
  };

  // Success screen
  if (accountCreated) {
    return (
      <div className="h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 text-white flex items-center justify-center px-6">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", duration: 0.6, delay: 0.2 }}
            className="inline-flex p-6 rounded-full bg-gradient-to-br from-emerald-500/20 to-green-500/20 backdrop-blur-xl border border-emerald-500/20 mb-6"
          >
            <CheckCircle2 className="w-20 h-20 text-emerald-400" />
          </motion.div>
          <h1 className="text-3xl font-bold mb-3">Compte créé !</h1>
          <p className="text-gray-400 mb-2">
            Bienvenue chez NexBank, {firstName} !
          </p>
          <p className="text-sm text-gray-500">
            Redirection vers la connexion...
          </p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950 text-white flex flex-col relative overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 -left-20 w-72 h-72 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-40 -right-20 w-80 h-80 bg-purple-500/20 rounded-full blur-3xl animate-pulse" style={{ animationDelay: "1.5s" }}></div>
      </div>

      {/* Header */}
      <div className="relative z-10 p-4 flex items-center justify-between">
        <button
          onClick={() => step === 1 ? navigate("/login") : setStep(step - 1)}
          className="p-2.5 rounded-xl bg-white/5 hover:bg-white/10 transition-all active:scale-95"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div className="text-center flex-1">
          <h2 className="text-lg font-bold">Créer un compte</h2>
          <p className="text-xs text-gray-400">Étape {step}/3</p>
        </div>
        <div className="w-10"></div>
      </div>

      {/* Progress Bar */}
      <div className="relative z-10 px-6 pb-4">
        <div className="h-1.5 bg-slate-800 rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-gradient-to-r from-blue-500 to-purple-500"
            initial={{ width: "33%" }}
            animate={{ width: `${(step / 3) * 100}%` }}
            transition={{ duration: 0.3 }}
          />
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 relative z-10 px-6 overflow-y-auto pb-4">
        <div className="max-w-sm mx-auto">
          {/* Step 1: Personal Info */}
          {step === 1 && (
            <motion.form
              key="step1"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              onSubmit={handleStep1Submit}
              className="space-y-3"
            >
              <div className="text-center mb-4">
                <div className="inline-flex p-4 rounded-2xl bg-gradient-to-br from-blue-500/20 to-purple-500/20 mb-3">
                  <User className="w-8 h-8 text-blue-400" />
                </div>
                <h3 className="text-xl font-bold mb-1">Informations personnelles</h3>
                <p className="text-xs text-gray-400">Commençons par vous connaître</p>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs text-gray-400 mb-1.5 block">Prénom</label>
                  <input
                    type="text"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    placeholder="Alex"
                    className="w-full px-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
                <div>
                  <label className="text-xs text-gray-400 mb-1.5 block">Nom</label>
                  <input
                    type="text"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                    placeholder="Martin"
                    className="w-full px-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">Email</label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="alex.martin@email.com"
                    className="w-full pl-10 pr-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">Téléphone</label>
                <div className="relative">
                  <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+33 6 12 34 56 78"
                    className="w-full pl-10 pr-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">Date de naissance</label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                  <input
                    type="date"
                    value={dateOfBirth}
                    onChange={(e) => setDateOfBirth(e.target.value)}
                    className="w-full pl-10 pr-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-blue-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
              </div>

              <motion.button
                whileTap={{ scale: 0.98 }}
                type="submit"
                className="w-full py-3.5 rounded-xl bg-gradient-to-r from-blue-500 to-purple-500 font-semibold shadow-xl shadow-blue-500/30 transition-all active:scale-95 mt-4"
              >
                Continuer
              </motion.button>
            </motion.form>
          )}

          {/* Step 2: Address */}
          {step === 2 && (
            <motion.form
              key="step2"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              onSubmit={handleStep2Submit}
              className="space-y-3"
            >
              <div className="text-center mb-4">
                <div className="inline-flex p-4 rounded-2xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 mb-3">
                  <MapPin className="w-8 h-8 text-purple-400" />
                </div>
                <h3 className="text-xl font-bold mb-1">Adresse</h3>
                <p className="text-xs text-gray-400">Où pouvons-nous vous contacter ?</p>
              </div>

              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">Adresse complète</label>
                <input
                  type="text"
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="123 Rue de la Paix"
                  className="w-full px-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-purple-500/50 focus:bg-white/10 transition-all text-sm"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs text-gray-400 mb-1.5 block">Ville</label>
                  <input
                    type="text"
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    placeholder="Paris"
                    className="w-full px-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-purple-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
                <div>
                  <label className="text-xs text-gray-400 mb-1.5 block">Code postal</label>
                  <input
                    type="text"
                    value={postalCode}
                    onChange={(e) => setPostalCode(e.target.value)}
                    placeholder="75001"
                    className="w-full px-3 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-purple-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                </div>
              </div>

              <motion.button
                whileTap={{ scale: 0.98 }}
                type="submit"
                className="w-full py-3.5 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 font-semibold shadow-xl shadow-purple-500/30 transition-all active:scale-95 mt-4"
              >
                Continuer
              </motion.button>
            </motion.form>
          )}

          {/* Step 3: Security */}
          {step === 3 && (
            <motion.form
              key="step3"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              onSubmit={handleFinalSubmit}
              className="space-y-3"
            >
              <div className="text-center mb-4">
                <div className="inline-flex p-4 rounded-2xl bg-gradient-to-br from-emerald-500/20 to-green-500/20 mb-3">
                  <Lock className="w-8 h-8 text-emerald-400" />
                </div>
                <h3 className="text-xl font-bold mb-1">Sécurité</h3>
                <p className="text-xs text-gray-400">Créez un mot de passe sécurisé</p>
              </div>

              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">Mot de passe</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                  <input
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    minLength={8}
                    className="w-full pl-10 pr-12 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-emerald-500/50 focus:bg-white/10 transition-all text-sm"
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
                <p className="text-[10px] text-gray-500 mt-1">Minimum 8 caractères</p>
              </div>

              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">Confirmer le mot de passe</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                  <input
                    type={showConfirmPassword ? "text" : "password"}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="••••••••"
                    minLength={8}
                    className="w-full pl-10 pr-12 py-3 rounded-xl bg-white/5 backdrop-blur-xl border border-white/10 outline-none focus:border-emerald-500/50 focus:bg-white/10 transition-all text-sm"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 active:text-white transition-colors p-1"
                  >
                    {showConfirmPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Password Match Indicator */}
              {password && confirmPassword && (
                <div className={`text-xs px-3 py-2 rounded-lg ${
                  password === confirmPassword 
                    ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" 
                    : "bg-red-500/10 text-red-400 border border-red-500/20"
                }`}>
                  {password === confirmPassword ? "✓ Les mots de passe correspondent" : "✗ Les mots de passe ne correspondent pas"}
                </div>
              )}

              {/* Terms & Conditions */}
              <div className="flex items-start gap-2 p-3 rounded-xl bg-white/5 border border-white/10">
                <input
                  type="checkbox"
                  id="terms"
                  checked={acceptTerms}
                  onChange={(e) => setAcceptTerms(e.target.checked)}
                  className="mt-0.5 w-4 h-4 rounded accent-blue-500"
                  required
                />
                <label htmlFor="terms" className="text-xs text-gray-400 leading-relaxed">
                  J'accepte les{" "}
                  <button type="button" className="text-blue-400 underline">
                    conditions d'utilisation
                  </button>
                  {" "}et la{" "}
                  <button type="button" className="text-blue-400 underline">
                    politique de confidentialité
                  </button>
                </label>
              </div>

              <motion.button
                whileTap={{ scale: 0.98 }}
                type="submit"
                disabled={isCreating}
                className="w-full py-3.5 rounded-xl bg-gradient-to-r from-emerald-500 to-green-500 font-semibold shadow-xl shadow-emerald-500/30 transition-all active:scale-95 disabled:opacity-50 mt-4"
              >
                {isCreating ? "Création du compte..." : "Créer mon compte"}
              </motion.button>
            </motion.form>
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="relative z-10 px-6 pb-4">
        <div className="max-w-sm mx-auto text-center">
          <p className="text-xs text-gray-500">
            Déjà un compte ?{" "}
            <button
              onClick={() => navigate("/login")}
              className="text-blue-400 active:text-blue-300 transition-colors font-semibold"
            >
              Se connecter
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}