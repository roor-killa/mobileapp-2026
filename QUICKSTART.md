# 🚀 Guide de Démarrage Rapide - MyBank

## ⚡ Démarrage en 5 minutes

### 1. Backend (Terminal 1)

```bash
# Navigate au dossier Laravel
cd infrastructure/back-laravel

# Si première fois: installer les dépendances
composer install

# Configurer l'environnement
cp .env.example .env
php artisan key:generate

# Créer la base de données SQLite
touch database/database.sqlite

# Migrer la base de données
php artisan migrate

# Charger les données de test (optionnel)
php artisan db:seed

# Démarrer le serveur
php artisan serve
# 🟢 Serveur disponible sur http://localhost:8000
```

### 2. Frontend (Terminal 2)

```bash
# Navigate au dossier Flutter
cd project/firstapp

# Installer/mettre à jour les dépendances
flutter pub get

# Lancer sur mobile ou émulateur
flutter run

# Ou spécifier un device:
flutter emulators --launch <emulator_name>
flutter run
```

## 📝 Données de Test

Une fois le seeder lancé (`php artisan db:seed`), vous avez 4 utilisateurs:

| Email | Mot de passe | Solde initial |
|-------|-------------|---------------|
| jean.dupont@example.com | password123 | 6000 EUR |
| marie.martin@example.com | password123 | 7500 EUR |
| pierre.bernard@example.com | password123 | 9000 EUR |
| sophie.lefebvre@example.com | password123 | 10500 EUR |

## 🎯 Première utilisation

### Créer un compte
1. Cliquer sur "Créer un nouveau compte"
2. Remplir les informations (prénom, nom, email, téléphone, mot de passe)
3. Cliquer sur "S'inscrire"
4. ✅ Compte créé avec crédit initial de 1000 EUR

### Effectuer un virement
1. Se connecter
2. Cliquer sur "Effectuer un virement"
3. Sélectionner compte source et destination
4. Entrer le montant
5. Ajouter une description (optionnel)
6. Confirmer
7. ✅ Virement effectué avec numéro de référence

## 🔧 Configuration

### Changer l'URL de l'API

Si le serveur n'est pas sur localhost:8000, éditer:

**`project/firstapp/lib/config/api_config.dart`**

```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

Puis redémarrer Flutter (`flutter run`)

### Configurer la base de données

Dans **`infrastructure/back-laravel/.env`**:

```env
DB_CONNECTION=sqlite
# ou
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mybank
DB_USERNAME=root
DB_PASSWORD=
```

## 🧪 Tests API avec cURL

```bash
# Inscription
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "User",
    "email": "test@example.com",
    "phone": "0123456789",
    "password": "password123",
    "password_confirmation": "password123"
  }'

# Connexion
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Récupérer les comptes (remplacer TOKEN)
curl -X GET http://localhost:8000/api/accounts \
  -H "Authorization: Bearer TOKEN"
```

## 📊 Architecture Technique

### Stack Frontend
- **Flutter** 3.4+ pour l'interface mobile
- **Dart** pour la logique applicative
- **HTTP** pour les appels API
- **SharedPreferences** pour le stockage local

### Stack Backend
- **Laravel** 12 pour l'API REST
- **Sanctum** pour l'authentification
- **SQLite/MySQL** pour la base de données
- **Eloquent ORM** pour l'accès aux données

## 🚨 Erreurs Courantes

### "Connection refused"
→ Vérifier que le serveur Laravel est démarré: `php artisan serve`

### "Package not found" (Flutter)
→ Exécuter: `flutter pub get`

### "SQLSTATE[HY000]: General error"
→ Créer le fichier: `touch database/database.sqlite`

### "Validation failed"
→ Vérifier les critères: email unique, mot de passe 8 caractères min

## 📱 Tester sur un vrai téléphone

### Android
```bash
# Connecter le téléphone en USB
adb devices  # Vérifier la détection
flutter run
```

### iOS
```bash
# Sur Mac uniquement
open ios/Runner.xcworkspace
# Puis build dans Xcode ou:
flutter run
```

## 🔒 Sécurité

- ✅ Mots de passe hashés (bcrypt)
- ✅ Tokens d'authentification Sanctum
- ✅ Validation des montants et comptes
- ✅ Vérification de propriété des ressources
- ✅ HTTPS en production (à configurer)

## 📦 Passer en Production

### 1. Sécurité
```bash
# Regénérer la clé APP
php artisan key:generate

# Activer HTTPS
# Configurer les headers CORS
```

### 2. Build Mobile
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### 3. Déploiement
- Builder une image Docker
- Configurez un serveur d'hébergement
- Mettre à jour l'URL API en production

## 📞 Support

Pour des questions:
- Vérifier les logs: `php artisan logs`
- Utiliser `flutter logs` pour les logs Flutter
- Consulter la documentation dans `BANKING_APP_README.md`

---

**Bon développement ! 🚀**
