const express = require('express');
const db = require('../database');
const authenticate = require('../middleware/auth');

const router = express.Router();

// GET /api/accounts/me - Obtenir le compte de l'utilisateur connecté
router.get('/me', authenticate, async (req, res) => {
    try {
        const userId = req.userId;

        const account = await db.queryOne(
            `SELECT * FROM accounts WHERE user_id = $1 ORDER BY created_at ASC LIMIT 1`,
            [userId]
        );

        if (!account) {
            return res.status(404).json({ error: 'Aucun compte trouvé' });
        }

        res.json({
            success: true,
            id: account.id,
            account_number: account.account_number,
            account_type: account.account_type,
            currency: account.currency,
            balance: account.balance,
            iban: account.iban
        });
    } catch (err) {
        console.error('Erreur /me:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET /api/accounts/:id - Obtenir un compte
router.get('/:id', authenticate, async (req, res) => {
    try {
        const accountId = req.params.id;

        const account = await db.queryOne(
            `SELECT a.*, u.first_name, u.last_name, u.email
       FROM accounts a
       JOIN users u ON a.user_id = u.id
       WHERE a.id = $1`,
            [accountId]
        );

        if (!account) {
            return res.status(404).json({ error: 'Compte non trouvé' });
        }

        res.json({
            success: true,
            account: {
                id: account.id,
                accountNumber: account.account_number,
                accountType: account.account_type,
                currency: account.currency,
                balance: account.balance,
                iban: account.iban,
                holder: {
                    firstName: account.first_name,
                    lastName: account.last_name,
                    email: account.email
                }
            }
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET /api/accounts/user/:userId - Obtenir tous les comptes d'un utilisateur
router.get('/user/:userId', authenticate, async (req, res) => {
    try {
        const userId = req.params.userId;

        const accounts = await db.queryMany(
            `SELECT * FROM accounts WHERE user_id = $1`,
            [userId]
        );

        res.json({
            success: true,
            accounts: accounts.map(acc => ({
                id: acc.id,
                accountNumber: acc.account_number,
                accountType: acc.account_type,
                currency: acc.currency,
                balance: acc.balance,
                iban: acc.iban
            }))
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// POST /api/accounts - Créer un compte
router.post('/', authenticate, async (req, res) => {
    try {
        const { userId, accountType, currency } = req.body;

        if (!userId) {
            return res.status(400).json({ error: 'userId requis' });
        }

        // Générer un numéro de compte
        const accountNumber = Math.random().toString(36).substr(2, 9);
        const iban = `FR76${Math.random().toString().substr(2, 14)}`;

        const result = await db.query(
            `INSERT INTO accounts (user_id, account_number, account_type, currency, iban, balance)
       VALUES ($1, $2, $3, $4, $5, 0.00)
       RETURNING *`,
            [userId, accountNumber, accountType || 'Compte Courant', currency || 'EUR', iban]
        );

        res.status(201).json({
            success: true,
            message: 'Compte créé avec succès',
            account: result.rows[0]
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// PUT /api/accounts/:id - Mettre à jour un compte
router.put('/:id', authenticate, async (req, res) => {
    try {
        const accountId = req.params.id;
        const { accountType } = req.body;

        const result = await db.query(
            `UPDATE accounts SET account_type = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
            [accountType, accountId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Compte non trouvé' });
        }

        res.json({
            success: true,
            message: 'Compte mis à jour',
            account: result.rows[0]
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

module.exports = router;
