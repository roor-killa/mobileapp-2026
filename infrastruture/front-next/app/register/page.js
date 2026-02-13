'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '../services/api';
import { User, Mail, Lock, CheckCircle, ArrowRight, UserPlus } from 'lucide-react';

export default function RegisterPage() {
  const router = useRouter();
  const [form, setForm] = useState({ username: '', name: '', email: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleRegister = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      const data = await api.request('/register', 'POST', form);
      api.setToken(data.token);
      router.push('/dashboard');
    } catch (err) {
      setError(err.message || "Une erreur est survenue lors de l'inscription");
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-indigo-900 via-purple-800 to-blue-900 p-4">
      
      {/* Carte d'inscription */}
      <div className="w-full max-w-md bg-white/10 backdrop-blur-xl p-8 rounded-3xl shadow-2xl border border-white/20 relative overflow-hidden">
        
        {/* Cercles déco en arrière plan */}
        <div className="absolute top-[-50px] left-[-50px] w-32 h-32 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>
        <div className="absolute bottom-[-50px] right-[-50px] w-32 h-32 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>

        <div className="text-center mb-8 relative z-10">
          <div className="bg-gradient-to-br from-green-400 to-emerald-600 w-16 h-16 rounded-2xl rotate-3 flex items-center justify-center mx-auto mb-4 shadow-lg shadow-green-900/20">
            <UserPlus className="text-white w-8 h-8" />
          </div>
          <h1 className="text-3xl font-bold text-white">Rejoignez BKN</h1>
          <p className="text-indigo-200 text-sm mt-2">Commencez votre aventure financière aujourd'hui</p>
        </div>
        
        {error && (
          <div className="bg-red-500/80 border border-red-500 text-white p-3 rounded-xl mb-6 text-sm text-center animate-pulse">
            {error}
          </div>
        )}

        <form onSubmit={handleRegister} className="space-y-4 relative z-10">
          
          {/* ID Perso */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <span className="text-indigo-300 font-bold group-focus-within:text-white transition-colors">@</span>
            </div>
            <input 
              name="username" 
              placeholder="Votre ID unique (ex: dark_sasuke)" 
              className="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-indigo-200/50 focus:outline-none focus:ring-2 focus:ring-green-400 focus:bg-white/10 transition-all"
              onChange={handleChange} 
              required 
            />
          </div>

          {/* Nom Complet */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <User className="h-5 w-5 text-indigo-300 group-focus-within:text-white transition-colors" />
            </div>
            <input 
              name="name" 
              placeholder="Nom Complet" 
              className="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-indigo-200/50 focus:outline-none focus:ring-2 focus:ring-green-400 focus:bg-white/10 transition-all"
              onChange={handleChange} 
              required 
            />
          </div>

          {/* Email */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Mail className="h-5 w-5 text-indigo-300 group-focus-within:text-white transition-colors" />
            </div>
            <input 
              name="email" 
              type="email" 
              placeholder="Email" 
              className="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-indigo-200/50 focus:outline-none focus:ring-2 focus:ring-green-400 focus:bg-white/10 transition-all"
              onChange={handleChange} 
              required 
            />
          </div>

          {/* Mot de passe */}
          <div className="relative group">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Lock className="h-5 w-5 text-indigo-300 group-focus-within:text-white transition-colors" />
            </div>
            <input 
              name="password" 
              type="password" 
              placeholder="Mot de passe" 
              className="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-indigo-200/50 focus:outline-none focus:ring-2 focus:ring-green-400 focus:bg-white/10 transition-all"
              onChange={handleChange} 
              required 
            />
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-400 hover:to-emerald-500 text-white font-bold py-3 px-4 rounded-xl shadow-lg transform hover:-translate-y-1 transition-all duration-200 flex items-center justify-center gap-2 mt-6"
          >
            {loading ? 'Création en cours...' : "S'inscrire"}
            {!loading && <ArrowRight className="w-5 h-5" />}
          </button>
        </form>
        
        <div className="mt-8 text-center relative z-10">
          <p className="text-indigo-200 text-sm">
            Déjà membre ?{' '}
            <a href="/" className="text-white font-semibold hover:underline hover:text-green-300 transition-colors">
              Se connecter
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
