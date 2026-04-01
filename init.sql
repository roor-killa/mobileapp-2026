-- Créer les tables pour Ecobank
-- ===============================

-- Table des utilisateurs
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des comptes
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    account_type VARCHAR(50) DEFAULT 'Compte Courant',
    currency VARCHAR(3) DEFAULT 'EUR',
    balance DECIMAL(15, 2) DEFAULT 0.00,
    iban VARCHAR(34) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des transactions
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- 'income', 'expense', 'transfer'
    amount DECIMAL(15, 2) NOT NULL,
    description VARCHAR(500),
    recipient_name VARCHAR(255),
    category VARCHAR(100),
    status VARCHAR(50) DEFAULT 'completed',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des cartes bancaires
CREATE TABLE cards (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    card_number VARCHAR(16) UNIQUE NOT NULL,
    card_holder_name VARCHAR(255) NOT NULL,
    expiry_date VARCHAR(7) NOT NULL, -- MM/YY
    cvv VARCHAR(3) NOT NULL,
    card_type VARCHAR(50) DEFAULT 'Debit', -- 'Debit', 'Credit'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des objectifs d'épargne
CREATE TABLE savings_goals (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    goal_name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(15, 2) NOT NULL,
    saved_amount DECIMAL(15, 2) DEFAULT 0.00,
    goal_date DATE,
    description VARCHAR(500),
    icon VARCHAR(100),
    color VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des notifications
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message VARCHAR(500),
    type VARCHAR(50), -- 'transaction', 'alert', 'info'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- Données initiales pour les tests
-- ===============================

-- Insérer un utilisateur de test
INSERT INTO users (username, email, password_hash, first_name, last_name, phone)
VALUES (
    'fatoumata',
    'fatoumata@ecobank.com',
    '$2b$10$abcdefghijklmnopqrstuvwxyz', -- Hash du mot de passe (exemple)
    'Fatoumata',
    'Cissé',
    '+33123456789'
);

-- Insérer un compte pour l'utilisateur
INSERT INTO accounts (user_id, account_number, account_type, currency, balance, iban)
VALUES (
    1,
    '4829',
    'Compte Courant',
    'EUR',
    4250.85,
    'FR1420041010050500013M02606'
);

-- Insérer une carte
INSERT INTO cards (account_id, card_number, card_holder_name, expiry_date, cvv, card_type)
VALUES (
    1,
    '4824000000007392',
    'FATOUMATA CISSE',
    '03/26',
    '123',
    'Debit'
);

-- Insérer des transactions
INSERT INTO transactions (account_id, transaction_type, amount, description, recipient_name, category, transaction_date)
VALUES
    (1, 'transfer', -1500.00, 'Virement à Fatoumata', 'Fatoumata', 'Virement', '2024-03-04 10:30:00'),
    (1, 'expense', -12.99, 'Abonnement Netflix', 'Netflix', 'Divertissement', '2024-03-02 14:15:00'),
    (1, 'income', 2500.00, 'Salaire mensuel', 'Employeur', 'Revenu', '2024-02-28 09:00:00'),
    (1, 'expense', -87.45, 'Courses supermarché', 'Supermarché', 'Alimentation', '2024-02-27 16:45:00'),
    (1, 'transfer', -200.00, 'Virement à Paul', 'Paul', 'Virement', '2024-02-26 11:20:00');

-- Insérer des objectifs d'épargne
INSERT INTO savings_goals (account_id, goal_name, target_amount, saved_amount, goal_date, description, icon, color)
VALUES
    (1, 'Vacances', 2000.00, 1500.00, '2024-07-31', 'Vacances d''été en Europe', 'flight', '#6C63FF'),
    (1, 'Nouvel ordinateur', 1500.00, 750.00, '2024-12-31', 'Laptop pour développement', 'laptop', '#FFA502'),
    (1, 'Fonds d''urgence', 5000.00, 4250.85, NULL, 'Fonds de secours', 'shield', '#FF6B6B');

-- Créer des index pour les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_cards_account_id ON cards(account_id);
CREATE INDEX idx_goals_account_id ON savings_goals(account_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);

-- Afficher les tables créées
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
