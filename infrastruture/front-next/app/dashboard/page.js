'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '../services/api';
import { Wallet, Send, LogOut, TrendingUp, ArrowDownLeft, ArrowUpRight, CreditCard, History } from 'lucide-react';

export default function Dashboard() {
  const router = useRouter();
  const [user, setUser] = useState(null);
  const [usersList, setUsersList] = useState([]);
  const [transactions, setTransactions] = useState([]); // Nouvelle liste !
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      // On lance les 3 requêtes en parallèle pour aller plus vite
      const [meData, usersData, transactionsData] = await Promise.all([
        api.request('/me'),
        api.request('/users'),
        api.request('/transactions') // <-- Nouvelle requête API
      ]);

      setUser(meData);
      setUsersList(usersData);
      setTransactions(transactionsData);
      
    } catch (err) {
      router.push('/');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleTransfer = async (receiverUsername) => {
    if (!amount || amount <= 0) return alert("Montant invalide");
    
    try {
      await api.request('/transfer', 'POST', { 
        receiver_username: receiverUsername, 
        amount: parseInt(amount) 
      });
      alert(`Virement de ${amount} BKN envoyé ! 💸`);
      setAmount('');
      fetchData(); // On recharge tout (solde + historique)
    } catch (err) {
      alert('Erreur : ' + err.message);
    }
  };

  if (loading) return (
    <div className="flex items-center justify-center min-h-screen bg-slate-900">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-indigo-500"></div>
    </div>
  );

  return (
    <div className="min-h-screen bg-slate-50 relative overflow-hidden pb-10">
      
      {/* Déco Arrière-plan */}
      <div className="absolute top-[-10%] right-[-5%] w-96 h-96 bg-indigo-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob"></div>
      <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-purple-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob animation-delay-2000"></div>
      
      <div className="max-w-5xl mx-auto px-6 py-10 relative z-10">
        
        {/* Navbar */}
        <div className="flex justify-between items-center mb-10">
          <div className="flex items-center gap-2">
            <div className="bg-indigo-600 p-2 rounded-lg">
               <Wallet className="text-white w-6 h-6" />
            </div>
            <span className="text-2xl font-bold text-slate-800 tracking-tight">BKN App</span>
          </div>
          <button 
            onClick={() => { api.logout(); router.push('/'); }} 
            className="flex items-center gap-2 text-slate-500 hover:text-red-500 transition-colors px-4 py-2 rounded-full hover:bg-red-50"
          >
            <LogOut className="w-5 h-5" />
            <span className="font-medium">Déconnexion</span>
          </button>
        </div>

        {/* Section du Haut (Carte + Stats) */}
        <div className="grid md:grid-cols-3 gap-6 mb-12">
          
          {/* Carte Bancaire */}
          <div className="md:col-span-2 bg-gradient-to-r from-indigo-600 to-purple-600 rounded-3xl p-8 text-white shadow-xl shadow-indigo-200 transform hover:scale-[1.01] transition-transform duration-300 relative overflow-hidden">
            <div className="absolute right-0 top-0 opacity-10">
               <svg width="200" height="200" viewBox="0 0 200 200"><path fill="currentColor" d="M45,-76.3C58.9,-69.3,71.4,-59.1,81.3,-46.7C91.2,-34.3,98.6,-19.7,97.6,-5.3C96.6,9.1,87.3,23.3,77.3,37.3C67.3,51.3,56.6,65.1,43.3,73.6C30,82.1,14.1,85.3,-0.6,86.3C-15.3,87.3,-29.3,86.1,-41.8,78.8C-54.3,71.5,-65.3,58.1,-73.4,43.3C-81.5,28.5,-86.7,12.3,-85.4,-3.2C-84.1,-18.7,-76.3,-33.5,-65.7,-45.5C-55.1,-57.5,-41.7,-66.7,-27.9,-73.8C-14.1,-80.9,0.1,-85.9,13.9,-85.5L14.4,-76.3Z" transform="translate(100 100)" /></svg>
            </div>
            <div className="flex justify-between items-start mb-12">
              <div>
                <p className="text-indigo-200 text-sm font-medium mb-1">Solde actuel</p>
                <h2 className="text-5xl font-bold tracking-tight">{user?.balance} BKN</h2>
              </div>
              <CreditCard className="w-10 h-10 opacity-50" />
            </div>
            <div className="flex justify-between items-end">
              <div>
                <p className="text-indigo-200 text-xs uppercase tracking-wider mb-1">Titulaire</p>
                <p className="font-semibold text-lg">{user?.name}</p>
              </div>
              <div className="text-right">
                <p className="text-indigo-200 text-xs uppercase tracking-wider mb-1">ID Utilisateur</p>
                <p className="font-mono bg-white/20 px-3 py-1 rounded-lg backdrop-blur-sm">@{user?.username}</p>
              </div>
            </div>
          </div>

          {/* Stats Rapides */}
          <div className="bg-white rounded-3xl p-6 shadow-lg border border-slate-100 flex flex-col justify-center items-center text-center">
            <div className="bg-green-100 p-4 rounded-full mb-4">
              <TrendingUp className="w-8 h-8 text-green-600" />
            </div>
            <h3 className="text-lg font-bold text-slate-800">Mouvements</h3>
            <p className="text-slate-500 text-sm mt-2">{transactions.length} transactions récentes</p>
          </div>
        </div>

        <div className="grid md:grid-cols-2 gap-8">
          
          {/* Colonne Gauche : Envoyer de l'argent */}
          <div className="bg-white rounded-3xl p-8 shadow-xl shadow-slate-200/50 border border-slate-100 h-full">
            <h3 className="text-xl font-bold text-slate-800 mb-6 flex items-center gap-2">
              <Send className="w-5 h-5 text-indigo-500" />
              Envoyer de l'argent
            </h3>
            <div className="space-y-4 max-h-[400px] overflow-y-auto pr-2">
              {usersList.map((u) => (
                <div key={u.id} className="group bg-slate-50 hover:bg-white border border-slate-100 hover:border-indigo-200 p-4 rounded-2xl transition-all duration-200">
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-10 h-10 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-full flex items-center justify-center text-white font-bold text-sm shadow-sm">
                      {u.username[0].toUpperCase()}
                    </div>
                    <div>
                      <p className="font-bold text-slate-700 text-sm group-hover:text-indigo-600">{u.name}</p>
                      <p className="text-xs text-slate-400 font-mono">@{u.username}</p>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <input 
                      type="number" 
                      placeholder="Montant" 
                      className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
                      value={amount}
                      onChange={(e) => setAmount(e.target.value)}
                    />
                    <button 
                      onClick={() => handleTransfer(u.username)}
                      className="bg-slate-900 text-white p-2 rounded-xl hover:bg-indigo-600 transition-colors shadow-lg"
                    >
                      <Send className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Colonne Droite : Historique (NOUVEAU !) */}
          <div className="bg-white rounded-3xl p-8 shadow-xl shadow-slate-200/50 border border-slate-100 h-full">
            <h3 className="text-xl font-bold text-slate-800 mb-6 flex items-center gap-2">
              <History className="w-5 h-5 text-purple-500" />
              Historique récent
            </h3>
            
            {transactions.length === 0 ? (
              <div className="text-center text-slate-400 py-10">
                Aucune transaction pour le moment.
              </div>
            ) : (
              <div className="space-y-4 max-h-[400px] overflow-y-auto pr-2">
                {transactions.map((tx) => {
                  // Est-ce que j'ai reçu (+) ou envoyé (-) ?
                  const isReceived = tx.receiver_name === user?.username;
                  
                  return (
                    <div key={tx.id} className="flex items-center justify-between p-4 rounded-2xl border border-slate-50 hover:bg-slate-50 transition-colors">
                      <div className="flex items-center gap-4">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${isReceived ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}`}>
                          {isReceived ? <ArrowDownLeft className="w-5 h-5" /> : <ArrowUpRight className="w-5 h-5" />}
                        </div>
                        <div>
                          <p className="font-bold text-slate-700 text-sm">
                            {isReceived ? `Reçu de ${tx.sender_name}` : `Envoyé à ${tx.receiver_name}`}
                          </p>
                          <p className="text-xs text-slate-400">
                            {new Date(tx.created_at).toLocaleDateString()} à {new Date(tx.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                          </p>
                        </div>
                      </div>
                      <span className={`font-bold text-lg ${isReceived ? 'text-green-600' : 'text-red-600'}`}>
                        {isReceived ? '+' : '-'}{tx.amount} BKN
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

        </div>
      </div>
    </div>
  );
}
