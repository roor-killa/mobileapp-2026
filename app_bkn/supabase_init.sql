-- Suppression des anciennes tables si elles existent (Attention, cela effacera les données déjà rentrées via le script python)
DROP TABLE IF EXISTS public.crypto_transactions CASCADE;
DROP TABLE IF EXISTS public.user_sessions CASCADE;
DROP TABLE IF EXISTS public.user_settings CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.password_resets CASCADE;

-- Création de la table users (sans le champ password_hash car géré par Supabase Auth)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    pseudo VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20),
    solde DECIMAL(15,2) DEFAULT 100.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    verification_level VARCHAR(50) DEFAULT 'Niveau 1',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    avatar_url TEXT
);

-- Table transactions
CREATE TABLE public.transactions (
    id VARCHAR(50) PRIMARY KEY,
    type VARCHAR(20) NOT NULL,
    montant DECIMAL(15,2) NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    description TEXT,
    expediteur_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    destinataire_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'completed',
    metadata JSONB
);

-- Table user_settings
CREATE TABLE public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    biometric_enabled BOOLEAN DEFAULT FALSE,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Table user_sessions
CREATE TABLE public.user_sessions (
    id VARCHAR(50) PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    device_name VARCHAR(255),
    device_type VARCHAR(50),
    ip_address VARCHAR(50),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    is_active BOOLEAN DEFAULT TRUE
);

-- Table crypto_transactions
CREATE TABLE public.crypto_transactions (
    id VARCHAR(50) PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL,
    crypto VARCHAR(50) NOT NULL,
    amount_bkn DECIMAL(15,2) NOT NULL,
    amount_crypto DECIMAL(15,8) NOT NULL,
    price_at_transaction DECIMAL(15,2) NOT NULL,
    wallet_address TEXT,
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Désactivation du RLS pour faciliter le test initial depuis Flutter
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.crypto_transactions DISABLE ROW LEVEL SECURITY;
