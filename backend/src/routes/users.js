const express = require('express');
const db = require('../database');

const router = express.Router();

// Middleware d'authentification
const authenticate = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
        return res.status(401).json({ error: 'Non authentifié' });
    }
    next();
};

// GET /api/users/:id - Obtenir un utilisateur
router.get('/:id', authenticate, async (req, res) => {
    try {
        const userId = req.params.id;

        const user = await db.queryOne(
            `SELECT id, username, email, first_name, last_name, phone, avatar_url, created_at
       FROM users WHERE id = $1`,
            [userId]
        );

        if (!user) {
            return res.status(404).json({ error: 'Utilisateur non trouvé' });
        }

        // Obtenir les comptes de l'utilisateur
        const accounts = await db.queryMany(
            'SELECT id, account_number, account_type, currency, balance FROM accounts WHERE user_id = $1',
            [userId]
        );

        res.json({
            success: true,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                phone: user.phone,
                avatarUrl: user.avatar_url,
                accounts: accounts,
                createdAt: user.created_at
            }
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// PUT /api/users/:id - Mettre à jour un profil utilisateur
router.put('/:id', authenticate, async (req, res) => {
    try {
        const userId = req.params.id;
        const { firstName, lastName, phone, avatarUrl } = req.body;

        const result = await db.query(
            `UPDATE users 
       SET first_name = COALESCE($1, first_name),
           last_name = COALESCE($2, last_name),
           phone = COALESCE($3, phone),
           avatar_url = COALESCE($4, avatar_url),
           updated_at = NOW()
       WHERE id = $5
       RETURNING id, username, email, first_name, last_name, phone, avatar_url`,
            [firstName, lastName, phone, avatarUrl, userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Utilisateur non trouvé' });
        }

        const user = result.rows[0];
        res.json({
            success: true,
            message: 'Profil mis à jour',
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name,
                phone: user.phone,
                avatarUrl: user.avatar_url
            }
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET /api/users/:id/statistics - Obtenir les statistiques d'un utilisateur
router.get('/:id/statistics', authenticate, async (req, res) => {
    try {
        const userId = req.params.id;

        // Total des soldes
        const balances = await db.queryOne(
            `SELECT SUM(balance) as total_balance FROM accounts WHERE user_id = $1`,
            [userId]
        );

        // Statistiques des transactions du mois
        const stats = await db.queryOne(
            `SELECT 
        SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN transaction_type = 'expense' THEN ABS(amount) ELSE 0 END) as total_expense,
        SUM(CASE WHEN transaction_type = 'transfer' THEN ABS(amount) ELSE 0 END) as total_transfer,
        COUNT(*) as total_transactions
      FROM transactions t
      JOIN accounts a ON t.account_id = a.id
      WHERE a.user_id = $1 AND EXTRACT(MONTH FROM t.transaction_date) = EXTRACT(MONTH FROM NOW())
      AND EXTRACT(YEAR FROM t.transaction_date) = EXTRACT(YEAR FROM NOW())`,
            [userId]
        );

        // Transactions par catégorie
        const byCategory = await db.queryMany(
            `SELECT category, COUNT(*) as count, SUM(ABS(amount)) as total
       FROM transactions t
       JOIN accounts a ON t.account_id = a.id
       WHERE a.user_id = $1 AND transaction_type = 'expense'
       GROUP BY category`,
            [userId]
        );

        res.json({
            success: true,
            statistics: {
                totalBalance: balances.total_balance || 0,
                income: stats.total_income || 0,
                expense: stats.total_expense || 0,
                transfer: stats.total_transfer || 0,
                totalTransactions: stats.total_transactions || 0,
                byCategory: byCategory
            }
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

module.exports = router;
