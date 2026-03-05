-- Migration manuelle : ajoute la colonne supabaseId à la table User
-- À exécuter dans Supabase : Dashboard → SQL Editor → New query → coller ce script → Run

-- Ajoute la colonne si elle n'existe pas encore
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "supabaseId" TEXT;

-- Index unique pour les requêtes par supabaseId
CREATE UNIQUE INDEX IF NOT EXISTS "User_supabaseId_key" ON "User"("supabaseId");
