# Supabase — Solution finale de base de données

Supabase est la **solution actuelle et finale** de base de données du projet BKN.
Elle a été adoptée après avoir testé Docker Desktop en local, puis Render.com en ligne.

---

## Pourquoi Supabase après Render.com ?

○ **Problèmes rencontrés avec Render.com (BDD)** :

    ■ Base de données mise en veille après inactivité → données perdues
    ■ Cold start long à chaque réveil
    ■ Moins stable pour un projet en développement actif

○ **Avantages de Supabase** :

    ■ PostgreSQL toujours actif, jamais en veille
    ■ Connection Pooler sur le port 6543 (optimisé pour les apps web/mobile)
    ■ Interface web pour voir et modifier les données directement
    ■ SSL requis par défaut
    ■ Backups automatiques quotidiens
    ■ Gratuit pour les projets de petite taille

---

## Création du projet Supabase

○ **1. Créer un compte et un projet** :

    ■ Se connecter sur https://app.supabase.com
    ■ Cliquer sur "New Project"
    ■ Name     : bkn-database
    ■ Password : Choisir un mot de passe fort (le noter !)
    ■ Region   : US West (Oregon) — même région que Render pour cohérence
    ■ Cliquer "Create new project" — attendre ~2 min

○ **2. Récupérer les informations de connexion** :

    ■ Aller dans Settings → Database
    ■ Section "Connection Pooling" (mode Transaction) :
        - Host     : aws-0-us-west-2.pooler.supabase.com
        - Port     : 6543  (utiliser ce port, pas le 5432)
        - Database : postgres
        - User     : postgres.VOTRE_PROJECT_ID
        - Password : mot de passe choisi à la création

    Note : toujours utiliser le port 6543 (Connection Pooler).
    Le port 5432 (direct) ne fonctionne pas bien avec le pooling.

○ **3. Créer les tables** :

    ■ Aller dans SQL Editor → New Query
    ■ Copier-coller le contenu de : infrastructure/database/schema.sql
    ■ Cliquer "Run" pour exécuter
    ■ Les 5 tables et les 6 index sont créés en une seule exécution

○ **4. Vérifier la création des tables** :

    ■ Aller dans Table Editor
    ■ Les tables suivantes doivent apparaître :
        - users
        - transactions
        - crypto_transactions
        - user_settings
        - user_sessions

○ **5. Injecter les données de test** *(automatique)* :

    ■ Les données de test sont insérées automatiquement au premier lancement de server.py
    ■ La fonction init_database() vérifie si la table users est vide
    ■ Si vide → elle crée les 4 utilisateurs, les transactions et les sessions par défaut

---

## Informations de connexion actuelles

○ **Connexion Supabase (production)** :

    ■ Host     : aws-0-us-west-2.pooler.supabase.com
    ■ Port     : 6543 (Connection Pooler — mode Transaction)
    ■ Database : postgres
    ■ SSL      : require (obligatoire)

---

## Interface Supabase — Ce qui est utile

○ **Table Editor** :

    ■ Voir toutes les données (users, transactions, crypto...)
    ■ Modifier/supprimer des lignes directement
    ■ Utile pour déboguer pendant le développement

○ **SQL Editor** :

    ■ Exécuter des requêtes SQL manuellement
    ■ Lancer schema.sql et seed.sql si besoin

○ **Logs** :

    ■ Consulter les erreurs de connexion
    ■ Voir les requêtes lentes

---

## Reset complet de la base de données

○ **Pour repartir de zéro** (exécuter dans le SQL Editor) :

```sql
-- DANGER — Supprime TOUTES les données
DROP TABLE IF EXISTS crypto_transactions;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS user_settings;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS users;
```

○ **Reconstruire** :

    ■ Ré-exécuter infrastructure/database/schema.sql dans le SQL Editor
    ■ Relancer python server.py → les données de test sont recréées automatiquement
