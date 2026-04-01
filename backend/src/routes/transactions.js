const express = require('express');
const db = require('../database');
const authenticate = require('../middleware/auth');

const router = express.Router();

// GET /api/transactions/me - Obtenir les transactions de l'utilisateur connecté
router.get('/me', authenticate, async (req, res) => {
    try {
        const userId = req.userId;

        // Trouver le compte principal de l'utilisateur
        const account = await db.queryOne(
            'SELECT id FROM accounts WHERE user_id = $1 ORDER BY created_at ASC LIMIT 1',
            [userId]
        );

        if (!account) {
            return res.status(404).json({ error: 'Aucun compte trouvé' });
        }

        const transactions = await db.queryMany(
            `SELECT * FROM transactions
       WHERE account_id = $1
       ORDER BY transaction_date DESC`,
            [account.id]
        );

        res.json({
            success: true,
            transactions: transactions.map(t => ({
                id: t.id,
                type: t.transaction_type,
                amount: t.amount,
                description: t.description,
                recipientName: t.recipient_name,
                category: t.category,
                status: t.status,
                date: t.transaction_date,
                transaction_date: t.transaction_date
            }))
        });
    } catch (err) {
        console.error('Erreur /transactions/me:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET /api/transactions/account/:accountId - Obtenir les transactions d'un compte
router.get('/account/:accountId', authenticate, async (req, res) => {
    try {
        const accountId = req.params.accountId;
        const limit = req.query.limit || 50;
        const offset = req.query.offset || 0;

        const transactions = await db.queryMany(
            `SELECT * FROM transactions
       WHERE account_id = $1
       ORDER BY transaction_date DESC
       LIMIT $2 OFFSET $3`,
            [accountId, limit, offset]
        );

        res.json({
            success: true,
            transactions: transactions.map(t => ({
                id: t.id,
                type: t.transaction_type,
                amount: t.amount,
                description: t.description,
                recipientName: t.recipient_name,
                category: t.category,
                status: t.status,
                date: t.transaction_date
            }))
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// GET /api/transactions/:id - Obtenir une transaction
router.get('/:id', authenticate, async (req, res) => {
    try {
        const transactionId = req.params.id;

        const transaction = await db.queryOne(
            'SELECT * FROM transactions WHERE id = $1',
            [transactionId]
        );

        if (!transaction) {
            return res.status(404).json({ error: 'Transaction non trouvée' });
        }

        res.json({
            success: true,
            transaction
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// POST /api/transactions - Créer une transaction
router.post('/', authenticate, async (req, res) => {
    try {
        const {
            accountId,
            transactionType,
            amount,
            description,
            recipientName,
            category
        } = req.body;

        // Validation
        if (!accountId || !transactionType || !amount) {
            return res.status(400).json({ error: 'Paramètres manquants' });
        }

        // Vérifier le compte
        const account = await db.queryOne(
            'SELECT * FROM accounts WHERE id = $1',
            [accountId]
        );

        if (!account) {
            return res.status(404).json({ error: 'Compte non trouvé' });
        }

        // Pour les dépenses/virements, vérifier le solde
        if ((transactionType === 'expense' || transactionType === 'transfer') && account.balance < Math.abs(amount)) {
            return res.status(400).json({ error: 'Solde insuffisant' });
        }

        // Créer la transaction
        await db.transaction(async (client) => {
            // Insérer la transaction
            await client.query(
                `INSERT INTO transactions 
         (account_id, transaction_type, amount, description, recipient_name, category, status)
         VALUES ($1, $2, $3, $4, $5, $6, 'completed')`,
                [accountId, transactionType, amount, description, recipientName, category]
            );

            // Mettre à jour le solde du compte
            const newBalance = parseFloat(account.balance) + parseFloat(amount);
            await client.query(
                'UPDATE accounts SET balance = $1, updated_at = NOW() WHERE id = $2',
                [newBalance, accountId]
            );
        });

        res.status(201).json({
            success: true,
            message: 'Transaction créée avec succès',
            newBalance: parseFloat(account.balance) + parseFloat(amount)
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
});

// POST /api/transactions/transfer - Effectuer un virement
router.post('/transfer', authenticate, async (req, res) => {
    try {
        const {
            fromAccountId,
            toAccountId,
            amount,
            recipientName
        } = req.body;

        if (!fromAccountId || !toAccountId || !amount || !recipientName) {
            return res.status(400).json({ error: 'Paramètres manquants' });
        }

        await db.transaction(async (client) => {
            // Vérifier les comptes
            const fromAccount = await client.query(
                'SELECT * FROM accounts WHERE id = $1',
                [fromAccountId]
            );
            const toAccount = await client.query(
                'SELECT * FROM accounts WHERE id = $1',
                [toAccountId]
            );

            if (fromAccount.rows.length === 0 || toAccount.rows.length === 0) {
                throw new Error('Compte non trouvé');
            }

            if (fromAccount.rows[0].balance < amount) {
                throw new Error('Solde insuffisant');
            }

            // Transaction sortante
            await client.query(
                `INSERT INTO transactions 
         (account_id, transaction_type, amount, description, recipient_name, category, status)
         VALUES ($1, 'transfer', $2, 'Virement', $3, 'Virement', 'completed')`,
                [fromAccountId, -amount, recipientName]
            );

            // Transaction entrante
            await client.query(
                `INSERT INTO transactions 
         (account_id, transaction_type, amount, description, recipient_name, category, status)
         VALUES ($1, 'transfer', $2, 'Virement reçu', $3, 'Virement', 'completed')`,
                [toAccountId, amount, recipientName]
            );

            // Mettre à jour les soldes
            await client.query(
                'UPDATE accounts SET balance = balance - $1, updated_at = NOW() WHERE id = $2',
                [amount, fromAccountId]
            );
            await client.query(
                'UPDATE accounts SET balance = balance + $1, updated_at = NOW() WHERE id = $2',
                [amount, toAccountId]
            );
        });

        res.status(201).json({
            success: true,
            message: 'Virement effectué avec succès'
        });
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: err.message || 'Erreur serveur' });
    }
});

module.exports = router;
