# Render.com — Historique et guide de déploiement

Render.com a été utilisé dans ce projet à **deux moments différents** :
d'abord comme **base de données PostgreSQL en ligne**, puis comme
potentielle plateforme d'hébergement pour l'API.

---

## Rôle de Render.com dans ce projet

○ **Phase 2 du projet** (après Docker Desktop) :

    ■ Render.com offre une base de données PostgreSQL gratuite avec chaque compte
    ■ C'était la première solution de BDD en ligne testée après les tests locaux Docker
    ■ Host fourni par Render : dpg-XXXXXX.oregon-postgres.render.com (port 5432)
    ■ Limite : la BDD se mettait en veille après inactivité → données parfois perdues
    ■ Raison du passage à Supabase : plus stable, jamais en veille, pooler SSL

○ **Evolution de l'infrastructure** :

    ■ Etape 1  →  Docker Desktop  : API + PostgreSQL 100% en local
    ■ Etape 2  →  Render.com      : Première BDD en ligne (PostgreSQL Render gratuite)
    ■ Etape 3  →  Supabase        : Migration vers une BDD cloud plus robuste

---

## Pourquoi Render.com en premier ?

○ **Avantages utilisés** :

    ■ Gratuit sans carte bancaire
    ■ PostgreSQL inclus automatiquement avec le compte
    ■ Même région que Supabase (Oregon) donc migration facile
    ■ Interface simple, déploiement rapide

○ **Limites rencontrées** :

    ■ Base de données mise en veille après inactivité (plan gratuit)
    ■ "Cold start" long (30-50 sec) pour réveiller la BDD après inactivité
    ■ Risque de perte de données sur le plan gratuit
    ■ Migration vers Supabase pour plus de fiabilité

---

## Déploiement de l'API sur Render.com *(optionnel)*

Si tu veux héberger l'API FastAPI sur Render.com (en plus de Supabase pour la BDD) :

○ **Créer un Web Service** :

    ■ Se connecter sur https://dashboard.render.com
    ■ Cliquer sur "New +" → "Web Service"
    ■ Connecter le dépôt GitHub : roor-killa/mobileapp-2026
    ■ Sélectionner la branche : beausoleil

○ **Paramètres du service** :

    ■ Name          : bkn-api
    ■ Region        : Oregon (US West)
    ■ Branch        : beausoleil
    ■ Root Dir      : Backend
    ■ Runtime       : Python 3
    ■ Build Command :
    ```bash
    pip install -r requirements.txt
    ```
    ■ Start Command :
    ```bash
    python server.py
    ```
    ■ Plan          : Free

○ **Variables d'environnement à ajouter** :

    ■ DB_HOST     = aws-0-us-west-2.pooler.supabase.com
    ■ DB_PORT     = 6543
    ■ DB_NAME     = postgres
    ■ DB_USER     = postgres.VOTRE_PROJECT_ID
    ■ DB_PASSWORD = VOTRE_MOT_DE_PASSE

○ **Redéploiement automatique** :

    ■ A chaque push sur la branche beausoleil, Render redéploie automatiquement
    ■ Suivi des logs dans l'onglet "Logs" du dashboard

○ **Plan gratuit — comportement** :

    ■ L'API "dort" après 15 min d'inactivité
    ■ Premier appel = 30 à 50 secondes de réponse (cold start)
    ■ 750 heures/mois de service actif incluses

---

## Mettre à jour l'IP dans Flutter après déploiement

○ Modifier `app_bkn/lib/services/api_helper.dart` :

```dart
// En production sur Render.com
static const String _productionUrl = 'https://bkn-api.onrender.com';
```
