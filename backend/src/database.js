const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'ecobank_db',
    user: process.env.DB_USER || 'ecobank_user',
    password: process.env.DB_PASSWORD || 'ecobank_password',
});

// Gestion des erreurs de connexion
pool.on('error', (err) => {
    console.error('Erreur non attendue sur le pool de connexion', err);
});

// Fonctions utilitaires
const db = {
    // Exécuter une requête simple
    query: (text, params) => {
        return pool.query(text, params);
    },

    // Obtenir une seule ligne
    queryOne: (text, params) => {
        return pool.query(text, params).then(res => res.rows[0]);
    },

    // Obtenir plusieurs lignes
    queryMany: (text, params) => {
        return pool.query(text, params).then(res => res.rows);
    },

    // Transaction
    transaction: async (callback) => {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const result = await callback(client);
            await client.query('COMMIT');
            return result;
        } catch (err) {
            await client.query('ROLLBACK');
            throw err;
        } finally {
            client.release();
        }
    },

    // Vérifier la connexion
    connect: async () => {
        try {
            const res = await pool.query('SELECT NOW()');
            console.log('✅ Connexion à PostgreSQL réussie');
            return true;
        } catch (err) {
            console.error('❌ Erreur de connexion PostgreSQL:', err.message);
            throw err;
        }
    },

    // Fermer le pool
    end: () => {
        return pool.end();
    }
};

module.exports = db;
