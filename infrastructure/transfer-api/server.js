const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 8001;

app.use(cors());
app.use(express.json());

// Base de données en mémoire (pour la démo)
let users = [
  { id: 1, name: 'Alice Dupont', email: 'alice@example.com', username: 'alice', password: 'password123', balance: 1000.00 },
  { id: 2, name: 'Bob Martin', email: 'bob@example.com', username: 'bob', password: 'password123', balance: 750.50 },
  { id: 3, name: 'Charlie Legros', email: 'charlie@example.com', username: 'charlie', password: 'password123', balance: 500.25 },
  { id: 4, name: 'Diana Vidal', email: 'diana@example.com', username: 'diana', password: 'password123', balance: 2000.00 },
];

let transfers = [];
let sessions = {}; // Stockage des sessions actives

// Routes

/**
 * Login - Authentifier l'utilisateur
 */
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: 'Username et password requis'
    });
  }
  
  const user = users.find(u => u.username === username);
  
  if (!user || user.password !== password) {
    return res.status(401).json({
      success: false,
      message: 'Login ou mot de passe incorrect'
    });
  }
  
  // Créer une session
  const sessionToken = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  sessions[sessionToken] = {
    userId: user.id,
    username: user.username,
    createdAt: new Date()
  };
  
  res.json({
    success: true,
    message: 'Authentification réussie',
    token: sessionToken,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      username: user.username,
      balance: user.balance
    }
  });
});

/**
 * Logout - Déconnecter l'utilisateur
 */
app.post('/api/auth/logout', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (token && sessions[token]) {
    delete sessions[token];
  }
  
  res.json({
    success: true,
    message: 'Déconnecté'
  });
});

/**
 * Vérifier le token de session
 */
app.get('/api/auth/verify', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token || !sessions[token]) {
    return res.status(401).json({
      success: false,
      message: 'Session invalide'
    });
  }
  
  const session = sessions[token];
  const user = users.find(u => u.id === session.userId);
  
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'Utilisateur non trouvé'
    });
  }
  
  res.json({
    success: true,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      username: user.username,
      balance: user.balance
    }
  });
});

// Routes

/**
 * Récupère la liste des utilisateurs (sauf l'utilisateur courant)
 */
app.get('/api/transfers/users', (req, res) => {
  const currentUserId = parseInt(req.query.current_user_id || 1);
  const availableUsers = users.filter(u => u.id !== currentUserId).map(u => ({
    id: u.id,
    name: u.name,
    email: u.email,
    balance: u.balance
  }));
  
  res.json({
    success: true,
    data: availableUsers
  });
});

/**
 * Récupère le solde de l'utilisateur courant
 */
app.get('/api/transfers/balance', (req, res) => {
  const userId = parseInt(req.query.user_id || 1);
  const user = users.find(u => u.id === userId);
  
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'Utilisateur non trouvé'
    });
  }
  
  res.json({
    success: true,
    balance: user.balance,
    user_id: user.id,
    name: user.name
  });
});

/**
 * Effectue un transfert d'argent
 */
app.post('/api/transfers/send', (req, res) => {
  const { from_user_id, to_user_id, amount, description } = req.body;
  
  // Validations
  if (!from_user_id || !to_user_id || !amount) {
    return res.status(400).json({
      success: false,
      message: 'Données manquantes'
    });
  }
  
  if (from_user_id === to_user_id) {
    return res.status(400).json({
      success: false,
      message: 'Impossible de transférer vers le même utilisateur'
    });
  }
  
  const fromUser = users.find(u => u.id === from_user_id);
  const toUser = users.find(u => u.id === to_user_id);
  
  if (!fromUser || !toUser) {
    return res.status(404).json({
      success: false,
      message: 'Utilisateur non trouvé'
    });
  }
  
  if (amount <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Le montant doit être positif'
    });
  }
  
  if (fromUser.balance < amount) {
    return res.status(400).json({
      success: false,
      message: 'Solde insuffisant',
      current_balance: fromUser.balance,
      required_amount: amount
    });
  }
  
  // Effectuer le transfert
  fromUser.balance -= amount;
  toUser.balance += amount;
  
  const transfer = {
    id: transfers.length + 1,
    from_user_id: from_user_id,
    to_user_id: to_user_id,
    amount: amount,
    description: description || null,
    status: 'completed',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };
  
  transfers.push(transfer);
  
  res.json({
    success: true,
    message: 'Transfert effectué avec succès',
    transfer: transfer,
    from_user: {
      id: fromUser.id,
      name: fromUser.name,
      new_balance: fromUser.balance
    },
    to_user: {
      id: toUser.id,
      name: toUser.name,
      new_balance: toUser.balance
    }
  });
});

/**
 * Récupère l'historique des transferts
 */
app.get('/api/transfers/history', (req, res) => {
  const userId = parseInt(req.query.user_id || 1);
  
  const userTransfers = transfers
    .filter(t => t.from_user_id === userId || t.to_user_id === userId)
    .map(t => {
      const fromUser = users.find(u => u.id === t.from_user_id);
      const toUser = users.find(u => u.id === t.to_user_id);
      
      return {
        id: t.id,
        from_user_id: t.from_user_id,
        to_user_id: t.to_user_id,
        amount: t.amount,
        status: t.status,
        description: t.description,
        created_at: t.created_at,
        updated_at: t.updated_at,
        fromUser: { id: fromUser.id, name: fromUser.name },
        toUser: { id: toUser.id, name: toUser.name }
      };
    })
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  
  res.json({
    success: true,
    data: userTransfers
  });
});

/**
 * Route de test
 */
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    users: users.length,
    transfers: transfers.length
  });
});

// Lancer le serveur
app.listen(PORT, () => {
  console.log(`\n✅ API de transfert en cours d'exécution sur http://localhost:${PORT}`);
  console.log(`📚 Documentation :`);
  console.log(`   GET  http://localhost:${PORT}/api/health`);
  console.log(`   GET  http://localhost:${PORT}/api/transfers/users?current_user_id=1`);
  console.log(`   GET  http://localhost:${PORT}/api/transfers/balance?user_id=1`);
  console.log(`   POST http://localhost:${PORT}/api/transfers/send`);
  console.log(`   GET  http://localhost:${PORT}/api/transfers/history?user_id=1`);
  console.log(`\n👥 Utilisateurs de test :`);
  users.forEach(u => console.log(`   ID ${u.id}: ${u.name} (${u.balance.toFixed(2)} €)`));
  console.log('');
});
