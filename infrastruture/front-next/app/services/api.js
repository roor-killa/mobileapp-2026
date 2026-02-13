// front-next/app/services/api.js

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8001/api';

export const api = {
  // Enregistrer le token
  setToken: (token) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('token', token);
    }
  },

  // Récupérer le token
  getToken: () => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('token');
    }
    return null;
  },

  // Effacer le token (Déconnexion)
  logout: () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token');
    }
  },

  // Fonction générique pour les requêtes
  request: async (endpoint, method = 'GET', body = null) => {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    const token = api.getToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const config = {
      method,
      headers,
    };

    if (body) {
      config.body = JSON.stringify(body);
    }

    const res = await fetch(`${API_URL}${endpoint}`, config);
    const data = await res.json();

    if (!res.ok) {
      throw new Error(data.message || 'Une erreur est survenue');
    }

    return data;
  }
};
