'use client';

import { useState, useEffect } from 'react';
import axios from 'axios';
import Link from 'next/link';

interface User {
  id: number;
  name: string;
  email: string;
  account_balance: number;
  preferred_currency: string;
}

interface BankAccount {
  id: number;
  account_name: string;
  balance: number;
  currency: string;
  account_type: string;
}

interface Card {
  id: number;
  card_holder: string;
  card_type: string;
  card_brand: string;
  card_status: string;
  color: string;
  is_primary: boolean;
}

interface Transaction {
  id: number;
  amount: number;
  currency: string;
  description: string;
  transaction_type: string;
  status: string;
  created_at: string;
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

export default function Dashboard() {
  const [user, setUser] = useState<User | null>(null);
  const [accounts, setAccounts] = useState<BankAccount[]>([]);
  const [cards, setCards] = useState<Card[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = localStorage.getItem('token');
        const headers = { Authorization: `Bearer ${token}` };

        const [userRes, accountsRes, cardsRes, transactionsRes] = await Promise.all([
          axios.get(`${API_URL}/auth/profile`, { headers }),
          axios.get(`${API_URL}/bank-accounts`, { headers }),
          axios.get(`${API_URL}/cards`, { headers }),
          axios.get(`${API_URL}/transactions`, { headers }),
        ]);

        setUser(userRes.data);
        setAccounts(accountsRes.data);
        setCards(cardsRes.data);
        setTransactions(transactionsRes.data.data || transactionsRes.data);
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      {/* Header */}
      <header className="bg-slate-900/80 backdrop-blur-md border-b border-slate-700 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg"></div>
              <h1 className="text-2xl font-bold text-white">MoneyFlow</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-gray-300">{user?.name}</span>
              <button className="text-gray-400 hover:text-white transition">Logout</button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Balance Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="md:col-span-2 bg-gradient-to-br from-blue-600 to-blue-900 rounded-2xl p-8 text-white shadow-xl">
            <p className="text-blue-200 text-sm font-medium mb-2">Total Balance</p>
            <h2 className="text-4xl font-bold mb-6">
              {user?.account_balance.toFixed(2)}€
            </h2>
            <div className="flex justify-between items-end">
              <div>
                <p className="text-blue-200 text-xs">Account Status</p>
                <p className="text-green-300 font-semibold">Active</p>
              </div>
              <button className="bg-white/20 hover:bg-white/30 backdrop-blur-md px-4 py-2 rounded-lg transition">
                Transactions
              </button>
            </div>
          </div>

          <div className="bg-slate-800 border border-slate-700 rounded-2xl p-6">
            <p className="text-gray-400 text-sm mb-4">Quick Stats</p>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Accounts</span>
                <span className="text-white font-semibold">{accounts.length}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Cards</span>
                <span className="text-white font-semibold">{cards.length}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Monthly</span>
                <span className="text-green-400">+€2,950</span>
              </div>
            </div>
          </div>
        </div>

        {/* Cards Section */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-xl font-bold text-white">My Cards</h3>
            <Link href="/cards/new" className="text-blue-400 hover:text-blue-300 text-sm font-semibold">
              + Add Card
            </Link>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {cards.map((card) => (
              <div
                key={card.id}
                className="relative h-56 rounded-xl overflow-hidden shadow-lg transform hover:scale-105 transition"
                style={{
                  background: `linear-gradient(135deg, ${card.color}40 0%, ${card.color}20 100%)`,
                  borderLeft: `4px solid ${card.color}`,
                }}
              >
                <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent"></div>
                <div className="relative h-full p-6 flex flex-col justify-between text-white">
                  <div>
                    <p className="text-sm font-semibold text-gray-300 uppercase">
                      {card.card_brand}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-400 mb-2">Card Number</p>
                    <p className="text-2xl tracking-widest font-mono">•••• •••• •••• 1234</p>
                  </div>
                  <div className="flex justify-between items-end">
                    <div>
                      <p className="text-xs text-gray-400">Card Holder</p>
                      <p className="font-semibold">{card.card_holder}</p>
                    </div>
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                      card.card_status === 'active' 
                        ? 'bg-green-500/30 text-green-300' 
                        : 'bg-red-500/30 text-red-300'
                    }`}>
                      {card.card_status}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Transactions */}
        <div>
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-xl font-bold text-white">Recent Transactions</h3>
            <Link href="/transactions" className="text-blue-400 hover:text-blue-300 text-sm font-semibold">
              View All
            </Link>
          </div>
          <div className="space-y-2">
            {transactions.slice(0, 5).map((tx) => (
              <div
                key={tx.id}
                className="bg-slate-800/50 border border-slate-700 rounded-lg p-4 flex items-center justify-between hover:bg-slate-800 transition"
              >
                <div className="flex items-center space-x-4">
                  <div className="w-10 h-10 rounded-full bg-blue-500/20 flex items-center justify-center">
                    <span className="text-blue-400">
                      {tx.transaction_type === 'transfer' ? '→' : '💳'}
                    </span>
                  </div>
                  <div>
                    <p className="text-white font-semibold">{tx.description}</p>
                    <p className="text-gray-400 text-sm">
                      {new Date(tx.created_at).toLocaleDateString()}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`font-bold ${
                    tx.transaction_type === 'transfer' 
                      ? 'text-red-400' 
                      : 'text-green-400'
                  }`}>
                    {tx.transaction_type === 'transfer' ? '-' : '+'}
                    {tx.amount}€
                  </p>
                  <span className={`text-xs ${
                    tx.status === 'completed' 
                      ? 'text-green-400' 
                      : 'text-yellow-400'
                  }`}>
                    {tx.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
