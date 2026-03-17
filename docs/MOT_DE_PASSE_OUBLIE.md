# Mot de passe oublié — MoneyTransferApp

## Comment ça fonctionne

Le système repose sur un **code à 8 chiffres** envoyé par email. Il se déroule en 2 étapes :

```
[1] Utilisateur saisit son email
        → POST /api/v1/auth/forgot-password
        → Laravel génère un code à 8 chiffres
        → Le code est haché (bcrypt) et stocké en base
        → Un email est envoyé avec le code en clair
        → Réponse 200 OK (même si l'email n'existe pas)

[2] Utilisateur saisit le code + nouveau mot de passe
        → POST /api/v1/auth/reset-password
        → Laravel vérifie : code valide ? pas expiré ?
        → Met à jour le mot de passe
        → Supprime le code (usage unique)
        → Révoque tous les tokens Sanctum
        → Réponse 200 OK
```

---

## Sécurité

| Mécanisme | Détail |
|-----------|--------|
| Code haché en base | Le code brut n'est jamais stocké, seulement son hash bcrypt |
| Expiration 15 minutes | Passé ce délai, le code est refusé et supprimé |
| Usage unique | Le code est supprimé dès qu'il est utilisé |
| Anti-énumération | La réponse est toujours `200 OK` même si l'email n'existe pas |
| Révocation des sessions | Tous les Bearer Tokens Sanctum sont révoqués après le reset |

---

## Fichiers créés

### Backend
| Fichier | Rôle |
|---------|------|
| `app/Http/Controllers/Api/PasswordResetController.php` | Les 2 méthodes : `forgotPassword` et `resetPassword` |
| `app/Mail/ResetPasswordMail.php` | Classe Mailable Laravel |
| `resources/views/emails/reset-password.blade.php` | Template HTML de l'email |

### Routes ajoutées dans `routes/api.php`
```php
Route::post('/auth/forgot-password', [PasswordResetController::class, 'forgotPassword']);
Route::post('/auth/reset-password',  [PasswordResetController::class, 'resetPassword']);
```

### Flutter
| Fichier | Rôle |
|---------|------|
| `lib/screens/auth/forgot_password_screen.dart` | Écran saisie de l'email |
| `lib/screens/auth/reset_password_screen.dart` | Écran saisie du code + nouveau mot de passe |
| `lib/screens/auth/login_screen.dart` | Lien "Mot de passe oublié ?" ajouté |
| `lib/data/services/api_service.dart` | Méthodes `forgotPassword()` et `resetPassword()` |
| `lib/core/constants/api_constants.dart` | Constantes `forgotPassword` et `resetPassword` |

---

## Table base de données

La table `password_reset_tokens` (créée automatiquement par Laravel) :

| Colonne | Type | Description |
|---------|------|-------------|
| `email` | string (PK) | Email de l'utilisateur |
| `token` | string | Code haché en bcrypt |
| `created_at` | timestamp | Date de création (pour l'expiration) |

---

## Configuration mail

Dans le fichier `.env` :

```env
# En développement — écrit dans storage/logs/laravel.log
MAIL_MAILER=log

# En production — utiliser un vrai SMTP (ex: Mailtrap pour les tests)
# MAIL_MAILER=smtp
# MAIL_HOST=sandbox.smtp.mailtrap.io
# MAIL_PORT=2525
# MAIL_USERNAME=votre_username_mailtrap
# MAIL_PASSWORD=votre_password_mailtrap
# MAIL_ENCRYPTION=tls
```

---

## Tests avec Thunder Client

### Étape 1 — Demander un code

**POST** `http://localhost:8000/api/v1/auth/forgot-password`

```json
{
  "email": "alice@test.com"
}
```

Réponse attendue **(200 OK)** :
```json
{
  "message": "Si cet email est enregistré, vous recevrez un code de réinitialisation."
}
```

---

### Étape 2 — Récupérer le code dans les logs

```bash
docker exec moneytransfer_app tail -n 80 storage/logs/laravel.log
```

Chercher la section `token-value` dans le HTML loggué :

```html
<div class="token-value">12345678</div>
```

---

### Étape 3 — Réinitialiser le mot de passe

**POST** `http://localhost:8000/api/v1/auth/reset-password`

```json
{
  "email": "alice@test.com",
  "token": "12345678",
  "password": "NouveauMotDePasse1",
  "password_confirmation": "NouveauMotDePasse1"
}
```

Réponse attendue **(200 OK)** :
```json
{
  "message": "Mot de passe réinitialisé avec succès. Veuillez vous reconnecter."
}
```

---

### Étape 4 — Vérifier l'ancien mot de passe (doit échouer)

**POST** `http://localhost:8000/api/v1/auth/login`

```json
{
  "email": "alice@test.com",
  "password": "password"
}
```

Réponse attendue **(422)** : identifiants incorrects.

---

### Étape 5 — Se connecter avec le nouveau mot de passe

**POST** `http://localhost:8000/api/v1/auth/login`

```json
{
  "email": "alice@test.com",
  "password": "NouveauMotDePasse1"
}
```

Réponse attendue **(200 OK)** avec un nouveau Bearer Token.

---

## Règles de validation du mot de passe

| Règle | Détail |
|-------|--------|
| Longueur minimum | 8 caractères |
| Majuscule requise | Au moins une lettre majuscule |
| Minuscule requise | Au moins une lettre minuscule |
| Chiffre requis | Au moins un chiffre |

Exemple valide : `MonMotDePasse1`
