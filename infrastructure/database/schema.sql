-- ============================================================
--  BKN DATABASE — Schéma complet PostgreSQL
--  Projet : mobileapp-2026 | Auteur : Patrice Beausoleil
--  À exécuter sur Supabase ou PostgreSQL local
-- ============================================================

-- ─────────────────────────────────────────
-- TABLE 1 : users
-- Comptes utilisateurs + solde BKN
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id                 VARCHAR(50)    PRIMARY KEY,
    email              VARCHAR(255)   UNIQUE NOT NULL,
    nom                VARCHAR(100)   NOT NULL,
    prenom             VARCHAR(100)   NOT NULL,
    pseudo             VARCHAR(50)    UNIQUE NOT NULL,
    phone              VARCHAR(20),
    password_hash      VARCHAR(255)   NOT NULL,
    solde              DECIMAL(15,2)  DEFAULT 1500.00,
    created_at         TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    verification_level VARCHAR(50)    DEFAULT 'Niveau 1',
    is_active          BOOLEAN        DEFAULT TRUE,
    last_login         TIMESTAMP,
    avatar_url         TEXT
);

-- ─────────────────────────────────────────
-- TABLE 2 : transactions
-- Historique des opérations BKN
-- Types : 'achat', 'vente', 'transfert', 'reception'
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
    id              VARCHAR(50)    PRIMARY KEY,
    type            VARCHAR(20)    NOT NULL,
    montant         DECIMAL(15,2)  NOT NULL,
    date            TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    description     TEXT,
    expediteur_id   VARCHAR(50)    REFERENCES users(id),
    destinataire_id VARCHAR(50)    REFERENCES users(id),
    status          VARCHAR(20)    DEFAULT 'completed',
    metadata        JSONB
);

-- ─────────────────────────────────────────
-- TABLE 3 : user_settings
-- Paramètres de sécurité par utilisateur
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_settings (
    user_id                VARCHAR(50)  PRIMARY KEY REFERENCES users(id),
    biometric_enabled      BOOLEAN      DEFAULT FALSE,
    notifications_enabled  BOOLEAN      DEFAULT TRUE,
    two_factor_enabled     BOOLEAN      DEFAULT FALSE,
    updated_at             TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
-- TABLE 4 : user_sessions
-- Sessions actives et appareils connectés
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_sessions (
    id           VARCHAR(50)   PRIMARY KEY,
    user_id      VARCHAR(50)   NOT NULL REFERENCES users(id),
    device_name  VARCHAR(255),
    device_type  VARCHAR(50),
    ip_address   VARCHAR(50),
    last_active  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    is_active    BOOLEAN       DEFAULT TRUE
);

-- ─────────────────────────────────────────
-- TABLE 5 : crypto_transactions
-- Achats et ventes de cryptomonnaies
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS crypto_transactions (
    id                    VARCHAR(50)    PRIMARY KEY,
    user_id               VARCHAR(50)    NOT NULL REFERENCES users(id),
    type                  VARCHAR(20)    NOT NULL,  -- 'buy' ou 'sell'
    crypto                VARCHAR(50)    NOT NULL,  -- 'bitcoin', 'ethereum', etc.
    amount_bkn            DECIMAL(15,2)  NOT NULL,
    amount_crypto         DECIMAL(15,8)  NOT NULL,
    price_at_transaction  DECIMAL(15,2)  NOT NULL,
    wallet_address        TEXT,
    status                VARCHAR(20)    DEFAULT 'completed',
    created_at            TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
-- INDEX — Performances des requêtes
-- ─────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_transactions_date   ON transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_user   ON transactions(expediteur_id, destinataire_id);
CREATE INDEX IF NOT EXISTS idx_users_email         ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_pseudo        ON users(pseudo);
CREATE INDEX IF NOT EXISTS idx_crypto_user         ON crypto_transactions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_user       ON user_sessions(user_id, last_active DESC);
