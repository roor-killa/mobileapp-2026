# FirstApp — Application de transfert

Application Flutter de gestion de portefeuilles et de transferts d'argent.

> Dépôt : [roor-killa/mobileapp-2026](https://github.com/roor-killa/mobileapp-2026/tree/meranville) (branche `meranville`)

## Fonctionnalités

FirstApp permet de :
- **S'inscrire et se connecter** avec un compte utilisateur
- **Créer des portefeuilles** pour gérer son argent
- **Recharger** un portefeuille (top-up)
- **Transférer** de l'argent entre portefeuilles ou vers d'autres utilisateurs

## Prérequis

- [Flutter SDK](https://flutter.dev) installé (vérifier avec `flutter doctor`)
- Un backend API configuré et accessible

## Installation

1. **Cloner le dépôt** :
   ```bash
   git clone -b meranville https://github.com/roor-killa/mobileapp-2026.git
   cd mobileapp-2026/project/firstapp
   ```

2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Configurer l'API** : modifier l’URL du backend dans `lib/services/api_service.dart` si elle diffère de `localhost`.

## Lancement

- **Chrome** : `flutter run -d chrome`
- **Simulateur iOS** : `flutter run -d ios`
- **Simulateur Android** : `flutter run -d android`
- **macOS** : `flutter run -d macos`

## Structure du projet

```
lib/
├── main.dart              # Point d'entrée, écran de chargement et authentification
├── models/
│   ├── auth_response.dart # Modèle de réponse d'authentification
│   └── wallet.dart        # Modèle de portefeuille
├── screens/
│   ├── login_screen.dart      # Connexion
│   ├── register_screen.dart  # Inscription
│   ├── home_screen.dart      # Accueil (liste des portefeuilles)
│   ├── transfer_screen.dart  # Transfert d'argent
│   ├── topup_screen.dart     # Recharge de portefeuille
│   └── create_wallet_screen.dart # Création de portefeuille
└── services/
    ├── auth_service.dart  # Gestion de l'authentification
    └── api_service.dart  # Appels API
```

## Configuration

- **URL du backend** : `baseUrl` dans `lib/services/api_service.dart` (défaut : `http://localhost:8001/api`)
- **Stripe** (si utilisé) : clé publique dans `lib/main.dart` (`Stripe.publishableKey`)

## Dépôt GitHub

[**mobileapp-2026**](https://github.com/roor-killa/mobileapp-2026/tree/meranville) — branche `meranville`

## Licence

Projet privé — non publié sur pub.dev.
