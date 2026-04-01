const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const db = require('./database');
const authRoutes = require('./routes/auth');
const accountsRoutes = require('./routes/accounts');
const transactionsRoutes = require('./routes/transactions');
const usersRoutes = require('./routes/users');

const app = express();
const PORT = process.env.API_PORT || 3000;

// Middleware de sécurité
app.use(helmet());
app.use(cors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true
}));

// Middleware de parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware de logging
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/accounts', accountsRoutes);
app.use('/api/transactions', transactionsRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date(),
        uptime: process.uptime()
    });
});

// Route par défaut
app.get('/', (req, res) => {
    res.json({
        message: 'Bienvenue sur l\'API Ecobank',
        version: '1.0.0',
        endpoints: {
            health: '/api/health',
            auth: '/api/auth',
            users: '/api/users',
            accounts: '/api/accounts',
            transactions: '/api/transactions'
        }
    });
});

// Gestion des erreurs 404
app.use((req, res) => {
    res.status(404).json({
        error: 'Route non trouvée',
        path: req.path,
        method: req.method
    });
});

// Gestion des erreurs globales
app.use((err, req, res, next) => {
    console.error('Erreur:', err);
    res.status(err.status || 500).json({
        error: err.message || 'Erreur interne du serveur',
        timestamp: new Date()
    });
});

// Démarrer le serveur
db.connect().then(() => {
    app.listen(PORT, () => {
        console.log(`🚀 Serveur Ecobank démarré sur http://localhost:${PORT}`);
        console.log(`📊 Base de données connectée`);
        console.log(`🔗 API prête pour la communication`);
    });
}).catch(err => {
    console.error('Erreur de connexion à la base de données:', err);
    process.exit(1);
});

module.exports = app;
