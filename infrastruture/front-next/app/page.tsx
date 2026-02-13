'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from './services/api';
import { Lock, Mail, ArrowRight, Wallet } from 'lucide-react'; // Icônes sympas

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      const data = await api.request('/login', 'POST', { email, password });
      api.setToken(data.token);
      router.push('/dashboard');
    } catch (err) {
      setError('Email ou mot de passe incorrect');
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-indigo-900 via-purple-800 to-blue-900">
      
      {/* Carte principale avec effet de verre (Glassmorphism) léger */}
      <div className="w-full max-w-md bg-white/10 backdrop-blur-lg p-8 rounded-2xl shadow-2xl border border-white/20">
        
        {/* En-tête avec Logo */}
        <div className="text-center mb-8">
          <div className="bg-white/20 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
            <Wallet className="text-white w-8 h-8" />
          </div>
          <h1 className="text-3xl font-bold text-white tracking-wide">BKN App</h1>
          <p className="text-indigo-200 text-sm mt-2">Gérez votre argent en toute liberté</p>
        </div>
        
        {/* Message d'erreur */}
        {error && (
          <div className="bg-red-500/80 border border-red-500 text-white p-3 rounded-lg mb-6 text-sm text-center animate-pulse">
            {error}
          </div>
        )}

        {/* Formulaire */}
        <form onSubmit={handleLogin} className="space-y-5">
          
          {/* Champ Email */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Mail className="h-5 w-5 text-indigo-300 group-focus-within:text-white transition-colors" />
            </div>
            <input 
              type="email" 
              placeholder="Adresse Email"
              className="w-full pl-10 pr-4 py-3 bg-white/10 border border-white/10 rounded-xl text-white placeholder-indigo-200 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:bg-white/20 transition-all"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          {/* Champ Mot de passe */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Lock className="h-5 w-5 text-indigo-300 group-focus-within:text-white transition-colors" />
            </div>
            <input 
              type="password" 
              placeholder="Mot de passe" 
              className="w-full pl-10 pr-4 py-3 bg-white/10 border border-white/10 rounded-xl text-white placeholder-indigo-200 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:bg-white/20 transition-all"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          {/* Bouton de connexion */}
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-indigo-500 hover:bg-indigo-400 text-white font-bold py-3 px-4 rounded-xl shadow-lg transform hover:-translate-y-1 transition-all duration-200 flex items-center justify-center gap-2 group"
          >
            {loading ? 'Connexion...' : 'Se connecter'}
            {!loading && <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />}
          </button>
        </form>

        {/* Lien inscription */}
        <div className="mt-8 text-center">
          <p className="text-indigo-200 text-sm">
            Pas encore de compte ?{' '}
            <a href="/register" className="text-white font-semibold hover:underline hover:text-indigo-300 transition-colors">
              Créer un compte
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
