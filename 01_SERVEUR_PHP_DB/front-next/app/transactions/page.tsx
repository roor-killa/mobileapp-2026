'use client';

import { useState, useEffect } from 'react';
import axios from 'axios';
import Link from 'next/link';

interface Transaction {
  id: number;
  amount: number;
  currency: string;
  description: string;
  transaction_type: string;
  status: string;
  created_at: string;
  recipient_name?: string;
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

export default function TransactionsPage() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('all');

  useEffect(() => {
    const fetchTransactions = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get(`${API_URL}/transactions`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setTransactions(response.data.data || response.data);
      } catch (error) {
        console.error('Error fetching transactions:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchTransactions();
  }, []);

  const filteredTransactions = 
    filter === 'all' 
      ? transactions 
      : transactions.filter((tx) => tx.transaction_type === filter);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <header className="bg-slate-900/80 backdrop-blur-md border-b border-slate-700 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Link href="/dashboard" className="flex items-center space-x-3 hover:opacity-75 transition">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg"></div>
              <h1 className="text-2xl font-bold text-white">MoneyFlow</h1>
            </Link>
            <Link href="/dashboard" className="text-gray-400 hover:text-white transition">
              Back to Dashboard
            </Link>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h2 className="text-3xl font-bold text-white mb-8">All Transactions</h2>

        {/* Filter */}
        <div className="flex gap-3 mb-6 flex-wrap">
          {['all', 'transfer', 'card_purchase', 'deposit', 'withdrawal'].map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-2 rounded-lg font-semibold transition ${
                filter === f
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-800 text-gray-300 hover:bg-slate-700'
              }`}
            >
              {f.replace('_', ' ').toUpperCase()}
            </button>
          ))}
        </div>

        {/* Transactions List */}
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredTransactions.map((tx) => (
              <div
                key={tx.id}
                className="bg-slate-800/50 border border-slate-700 rounded-lg p-4 flex items-center justify-between hover:bg-slate-800 transition group"
              >
                <div className="flex items-center space-x-4 flex-1">
                  <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center group-hover:bg-blue-500/30 transition">
                    <span className="text-2xl">
                      {tx.transaction_type === 'transfer'
                        ? '→'
                        : tx.transaction_type === 'card_purchase'
                        ? '💳'
                        : tx.transaction_type === 'deposit'
                        ? '↓'
                        : '↑'}
                    </span>
                  </div>
                  <div>
                    <p className="text-white font-semibold capitalize">
                      {tx.description || tx.transaction_type.replace('_', ' ')}
                    </p>
                    <p className="text-gray-400 text-sm">
                      {new Date(tx.created_at).toLocaleDateString('fr-FR', {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </p>
                    {tx.recipient_name && (
                      <p className="text-gray-500 text-xs mt-1">{tx.recipient_name}</p>
                    )}
                  </div>
                </div>
                <div className="text-right">
                  <p
                    className={`font-bold text-lg ${
                      ['transfer', 'card_purchase', 'withdrawal'].includes(
                        tx.transaction_type
                      )
                        ? 'text-red-400'
                        : 'text-green-400'
                    }`}
                  >
                    {['transfer', 'card_purchase', 'withdrawal'].includes(
                      tx.transaction_type
                    )
                      ? '-'
                      : '+'}
                    {tx.amount}
                    {tx.currency}
                  </p>
                  <span
                    className={`text-xs font-semibold ${
                      tx.status === 'completed'
                        ? 'text-green-400'
                        : tx.status === 'pending'
                        ? 'text-yellow-400'
                        : 'text-red-400'
                    }`}
                  >
                    {tx.status.toUpperCase()}
                  </span>
                </div>
              </div>
            ))}

            {filteredTransactions.length === 0 && (
              <div className="text-center py-12">
                <p className="text-gray-400 text-lg">No transactions found</p>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}
