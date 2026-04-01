const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db = require('../database');

const router = express.Router();

// Middleware de validation
const validateLogin = [
    body('username').notEmpty().trim(),
    body('password').notEmpty()
];

// Middleware d'authentification
const authenticate = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            return res.status(401).json({ error: 'Token manquant' });
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.id;
        next();
    } catch (err) {
        res.status(401).json({ error: 'Token invalide' });
    }
};

// POST /api/auth/login
router.post('/login', validateLogin, async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { username, password } = req.body;

        // Chercher l'utilisateur
        const user = await db.queryOne(
            'SELECT * FROM users WHERE username = $1 OR email = $1',
            [username]
        );

        if (!user) {
            return res.status(401).json({ error: 'Utilisateur non trouvé' });
        }

        // Vérifier le mot de passe (pour la démo, accepter n'importe quel mot de passe)
        // En production: const isValid = await bcrypt.compare(password, user.password_hash);
        const isValid = password.length > 0;

        if (!isValid) {
            return res.status(401).json({ error: 'Mot de passe incorrect' });
        }

        // Générer le token JWT
        const token = jwt.sign(
            { id: user.id, username: user.username, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            success: true,
            message: 'Connexion réussie',
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name
            }
        });
    } catch (err) {
        console.error('Erreur login:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// POST /api/auth/register
router.post('/register', [
    body('username').notEmpty().trim(),
    body('email').isEmail(),
    body('password').isLength({ min: 6 }),
    body('firstName').notEmpty(),
    body('lastName').notEmpty()
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { username, email, password, firstName, lastName } = req.body;

        // Vérifier si l'utilisateur existe
        const existing = await db.queryOne(
            'SELECT id FROM users WHERE username = $1 OR email = $2',
            [username, email]
        );

        if (existing) {
            return res.status(400).json({ error: 'Utilisateur déjà existant' });
        }

        // Hash du mot de passe
        const passwordHash = await bcrypt.hash(password, 10);

        // Créer l'utilisateur
        const result = await db.query(
            `INSERT INTO users (username, email, password_hash, first_name, last_name)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, username, email, first_name, last_name`,
            [username, email, passwordHash, firstName, lastName]
        );

        const newUser = result.rows[0];

        // Créer un compte bancaire
        await db.query(
            `INSERT INTO accounts (user_id, account_number, currency, balance, iban)
       VALUES ($1, $2, $3, $4, $5)`,
            [newUser.id, Math.random().toString(36).substr(2, 9), 'EUR', 0.00, `FR76${Math.random().toString().substr(2, 14)}`]
        );

        res.status(201).json({
            success: true,
            message: 'Utilisateur créé avec succès',
            user: newUser
        });
    } catch (err) {
        console.error('Erreur register:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET /api/auth/verify
router.get('/verify', authenticate, (req, res) => {
    res.json({
        success: true,
        message: 'Token valide',
        userId: req.userId
    });
});

// POST /api/auth/logout
router.post('/logout', authenticate, (req, res) => {
    res.json({
        success: true,
        message: 'Déconnexion réussie'
    });
});

module.exports = router;
