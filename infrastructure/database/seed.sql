-- ============================================================
--  BKN DATABASE — Données de test (seed)
--  Mot de passe de tous les comptes : password123
--  ⚠ À utiliser uniquement en développement / tests
-- ============================================================

-- ─────────────────────────────────────────
-- Utilisateurs de test
-- Hash bcrypt de "password123"
-- ─────────────────────────────────────────
INSERT INTO users (id, email, nom, prenom, pseudo, phone, password_hash, solde, verification_level)
VALUES 
    ('1', 'john.doe@email.com',     'Doe',    'John',  '@john',  '0612345678', '$2b$12$HASH_PASSWORD123', 5000.00, 'Niveau 2'),
    ('2', 'jane.smith@email.com',   'Smith',  'Jane',  '@jane',  '0687654321', '$2b$12$HASH_PASSWORD123', 3000.00, 'Niveau 1'),
    ('3', 'bob.martin@email.com',   'Martin', 'Bob',   '@bob',   '0655555555', '$2b$12$HASH_PASSWORD123', 2000.00, 'Niveau 1'),
    ('4', 'alice.wonder@email.com', 'Wonder', 'Alice', '@alice', '0644444444', '$2b$12$HASH_PASSWORD123', 4500.00, 'Niveau 2')
ON CONFLICT DO NOTHING;

-- NOTE : Le vrai hash est généré par Python/bcrypt au premier lancement de server.py
-- La fonction init_database() dans server.py insère automatiquement ces utilisateurs

-- ─────────────────────────────────────────
-- Transactions BKN de test
-- ─────────────────────────────────────────
INSERT INTO transactions (id, type, montant, date, description, expediteur_id, destinataire_id)
VALUES 
    ('TR1', 'achat',    1800, '2024-02-02 01:00:00', 'Achat BKN',           NULL, '1'),
    ('TR2', 'vente',    1600, '2024-02-04 04:00:00', 'Vente BKN',           '1',  NULL),
    ('TR3', 'transfert', 500, '2024-02-05 14:30:00', 'Transfert vers @jane','1',  '2'),
    ('TR4', 'reception', 300, '2024-02-06 10:15:00', 'Reçu de @bob',        '3',  '1')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────
-- Paramètres de sécurité par défaut
-- ─────────────────────────────────────────
INSERT INTO user_settings (user_id, biometric_enabled, notifications_enabled, two_factor_enabled)
VALUES 
    ('1', FALSE, TRUE, FALSE),
    ('2', FALSE, TRUE, FALSE),
    ('3', FALSE, TRUE, FALSE),
    ('4', FALSE, TRUE, FALSE)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────
-- Sessions actives de test
-- ─────────────────────────────────────────
INSERT INTO user_sessions (id, user_id, device_name, device_type, ip_address)
VALUES 
    ('SESS1', '1', 'iPhone 14 Pro',    'mobile',  '192.168.1.42'),
    ('SESS2', '1', 'MacBook Pro',      'desktop', '192.168.1.42'),
    ('SESS3', '2', 'Chrome - Windows', 'web',     '89.123.45.67')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────
-- Transactions crypto de test
-- ─────────────────────────────────────────
INSERT INTO crypto_transactions (id, user_id, type, crypto, amount_bkn, amount_crypto, price_at_transaction, wallet_address)
VALUES 
    ('CRYPTO1', '1', 'buy', 'bitcoin',  1000, 0.02220000, 45000.00, 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'),
    ('CRYPTO2', '1', 'buy', 'ethereum',  500, 0.17860000,  2800.00, '0x742d35Cc6634C0532925a3b844Bc5e9c5f3a7d3a'),
    ('CRYPTO3', '2', 'buy', 'solana',    300, 3.06120000,    98.00, '5YNmS1R9nNSCDzb5a7mMJ1dwK9uHeAAF4CmPEwKgVWr5')
ON CONFLICT DO NOTHING;
