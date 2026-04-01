# Etape 2 — Frontend Flutter

## Objectif

Développer l'application mobile Android en Flutter, connectée à l'API Laravel, avec une interface moderne et toutes les fonctionnalités de transfert d'argent.

---

## Technologies utilisées

| Package | Version | Rôle |
|---------|---------|------|
| Flutter | 3.x | Framework mobile cross-platform |
| provider | ^6.1.2 | Gestion d'état (State Management) |
| http | ^1.2.0 | Appels API REST |
| shared_preferences | ^2.2.3 | Stockage local du token |
| qr_flutter | ^4.1.0 | Génération de QR Code |
| mobile_scanner | ^5.2.3 | Scanner QR Code (caméra) |
| google_fonts | ^6.2.1 | Typographie (Poppins) |
| flutter_animate | ^4.5.0 | Animations |
| intl | ^0.19.0 | Formatage des dates |
| url_launcher | ^6.3.0 | Ouvrir les liens Algorand |
| flutter_stripe | ^10.1.1 | Payment Sheet Stripe |

---

## Structure des fichiers

```
Frontend/lib/
├── main.dart                        ← Point d'entrée + routing auth
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       ← URLs des endpoints
│   │   └── stripe_constants.dart    ← Clé publique Stripe
│   └── theme/
│       └── app_theme.dart           ← Couleurs, thème Material 3
├── data/
│   ├── models/
│   │   ├── user_model.dart          ← Modèle utilisateur
│   │   └── transaction_model.dart   ← Modèle transaction
│   └── services/
│       └── api_service.dart         ← Tous les appels HTTP
├── providers/
│   ├── auth_provider.dart           ← État authentification
│   └── transaction_provider.dart    ← État transactions
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── home/
        ├── home_screen.dart         ← Navigation + Dashboard
        ├── send/
        │   └── send_screen.dart
        ├── recharge/
        │   └── recharge_screen.dart
        ├── history/
        │   └── history_screen.dart
        ├── qrcode/
        │   └── qrcode_screen.dart
        ├── chatbot/
        │   └── chatbot_screen.dart
        └── profile/
            └── profile_screen.dart
```

---

## Thème et Design

### Palette de couleurs

```dart
primary      = Color(0xFF1565C0)  // Bleu profond
secondary    = Color(0xFF00ACC1)  // Cyan
success      = Color(0xFF43A047)  // Vert
error        = Color(0xFFE53935)  // Rouge
warning      = Color(0xFFFB8C00)  // Orange
background   = Color(0xFFF5F7FA)  // Gris clair
```

### Gradient (carte de solde)

```dart
LinearGradient(
  colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF00ACC1)],
)
```

### Typographie

Police **Poppins** (Google Fonts) pour toute l'application.

---

## Architecture Flutter

### Pattern Provider

```
Widget (affichage)
    │ context.watch<AuthProvider>()
    ▼
Provider (état)
    │ appel API
    ▼
ApiService (HTTP)
    │ Bearer Token
    ▼
Backend Laravel
```

### Routing automatique selon l'état d'auth

```dart
// main.dart — _AppRoot
switch (auth.status) {
  case AuthStatus.unknown:        → Splash (chargement)
  case AuthStatus.unauthenticated → LoginScreen
  case AuthStatus.authenticated:  → HomeScreen
}
```

Au démarrage, l'app vérifie si un token valide est stocké localement. Si oui → connexion automatique. Sinon → écran de login.

---

## Ecrans

### 1. Login

- Champs : email + mot de passe
- Validation côté Flutter avant envoi
- Affichage des erreurs API (identifiants incorrects)
- Lien vers l'inscription

```
┌─────────────────────────┐
│   [Logo MoneyTransfer]  │
│                         │
│  Email                  │
│  [__________________]   │
│                         │
│  Mot de passe        👁 │
│  [__________________]   │
│                         │
│  [   Se connecter   ]   │
│                         │
│  Pas de compte ? S'inscrire
└─────────────────────────┘
```

### 2. Inscription

- Champs : prénom, nom, email, téléphone (optionnel), mot de passe, PIN
- Validation : mot de passe min 8 caractères + majuscule + chiffre
- PIN : exactement 6 chiffres
- Connexion automatique après inscription

### 3. Dashboard (Accueil)

```
┌─────────────────────────────┐
│ Bonjour, Alice           AM │
│ Solde disponible            │
│ 1 000,00 €                  │   ← Gradient bleu
└─────────────────────────────┘

Actions rapides
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│  ▶   │ │  💳  │ │  QR  │ │  ⏱  │
│Envoy.│ │Rech. │ │Code  │ │Hist. │
└──────┘ └──────┘ └──────┘ └──────┘

Dernières transactions
┌───────────────────────────────┐
│ ↑ Bob Dupont    Transfert -1€ │
│ ↑ Bob Dupont    Transfert -1€ │
│ ↓ Recharge      Recharge  +10€│
└───────────────────────────────┘
```

- Pull-to-refresh pour actualiser le solde
- Bouton flottant → écran Profil
- Actions rapides → navigation directe vers l'onglet correspondant

### 4. Envoyer

- Saisie de l'email du destinataire
- Montant en euros (converti en centimes côté API)
- Note optionnelle
- PIN de confirmation (6 chiffres, masqué)
- Affichage du solde disponible avant envoi
- Snackbar de confirmation ou d'erreur

### 5. Recharge

- Montants rapides : 10€, 20€, 50€, 100€, 200€, 500€
- Montant personnalisé
- Bouton "Payer avec Stripe" → Payment Sheet native
- Bandeau informatif avec la carte de test
- Mise à jour du solde après webhook Stripe

### 6. Historique

```
┌─────────────────────────────────────────┐
│ ↑ Transfert                    - 1,00 € │
│   Bob Dupont                            │
│   08/03/2026 18:09                      │
│   ✓ Vérifié sur Algorand · COBUH...  ↗ │
├─────────────────────────────────────────┤
│ ↓ Recharge                    + 20,00 € │
│   08/03/2026 16:41                      │
└─────────────────────────────────────────┘
```

- Pull-to-refresh
- Direction : rouge (débit) / vert (crédit)
- Badge Algorand cliquable → ouvre Lora testnet explorer

### 7. QR Code

**Onglet "Recevoir" (Générer)**
- Saisie du montant à recevoir
- Génération du QR Code avec token HMAC
- Compte à rebours de 10 secondes (barre de progression)
- Auto-régénération à expiration

```
┌──────────────────────┐
│  Montant : 5,00 €    │
│  [Générer QR Code]   │
│                      │
│  ┌──────────────┐    │
│  │  ████ ████  │    │
│  │  ████ ████  │    │
│  └──────────────┘    │
│  ⏱ Expire dans 7s   │
│  ████████░░          │
└──────────────────────┘
```

**Onglet "Scanner"**
- Ouverture de la caméra
- Détection automatique du QR Code
- Dialogue de confirmation avec saisie du PIN
- Paiement effectué → mise à jour du solde

### 8. Chatbot (Assistant IA)

- Interface de chat (bulles de conversation)
- Messages utilisateur → droite (bleu)
- Réponses Ollama → gauche (blanc)
- Indicateur "L'assistant réfléchit..."
- Détection d'intentions de transfert dans les messages
- Le bot connaît le solde et les 5 dernières transactions

```
┌─────────────────────────────────┐
│ 🤖 Assistant IA   Ollama LLaMA  │
├─────────────────────────────────┤
│                                 │
│  Bonjour ! Je suis votre        │
│  assistant financier...   ←     │
│                                 │
│       Quel est mon solde ? →    │
│                                 │
│  Votre solde actuel est         │
│  981,00 €               ←      │
│                                 │
├─────────────────────────────────┤
│ [Posez votre question...]   ▶  │
└─────────────────────────────────┘
```

### 9. Profil

- Avatar avec initiales
- Formulaire : prénom, nom, email, téléphone
- Changer le mot de passe (dialog)
- Changer le PIN (dialog)
- Bouton déconnexion

---

## Gestion d'état — Providers

### AuthProvider

```dart
AuthStatus  → unknown | authenticated | unauthenticated
UserModel?  → données de l'utilisateur connecté
bool loading → indicateur de chargement

checkAuth()     → vérifie le token au démarrage
login()         → connexion
register()      → inscription
logout()        → déconnexion + suppression token
refreshUser()   → recharge le profil depuis l'API
updateUser()    → mise à jour locale du profil
```

### TransactionProvider

```dart
List<TransactionModel> transactions → liste de l'historique
bool loading → indicateur de chargement

loadHistory()   → charge l'historique depuis l'API
transfer()      → effectue un transfert
generateQr()    → génère un token QR
scanQr()        → valide un scan QR
```

---

## ApiService — Appels HTTP

Tous les appels passent par `ApiService` :

```dart
// Token automatiquement ajouté à chaque requête
Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
    };
}
```

### Gestion des erreurs

```dart
// Toutes les erreurs sont encapsulées dans ApiException
class ApiException implements Exception {
    final String message;
    final int statusCode;
    final Map<String, dynamic>? errors;
}

// Dans les écrans → affichage snackbar
} on ApiException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
    );
}
```

---

## Configuration Android requise

### `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>

<!-- MainActivity doit hériter de FlutterFragmentActivity (Stripe) -->
```

### `MainActivity.kt`
```kotlin
// Obligatoire pour flutter_stripe
class MainActivity : FlutterFragmentActivity()
```

### `styles.xml`
```xml
<!-- Obligatoire pour flutter_stripe -->
<style name="LaunchTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
```

### `build.gradle.kts`
```kotlin
minSdk = 21  // Requis par flutter_stripe
```

---

## URL de l'API

```dart
// Android émulateur → 10.0.2.2 = localhost de la machine hôte
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// Appareil physique → remplacer par l'IP de la machine sur le réseau
// static const String baseUrl = 'http://192.168.1.X:8000/api/v1';
```

---

## Lancer l'application

```bash
cd Frontend

# Première fois : générer les fichiers natifs Android/iOS
flutter create . --project-name money_transfer_app --org com.moneytransfer

# Installer les dépendances
flutter pub get

# Lancer sur émulateur (s'assurer que le Backend Docker tourne)
flutter run -d emulator-5554

# Vérifier la qualité du code
flutter analyze
```
