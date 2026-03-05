# IKM Mobile - Application Flutter

Application de transfert d'argent avec backend FastAPI.

## 🚀 Installation

### Prérequis
- Flutter SDK >= 3.0
- Android Studio ou Xcode
- Backend FastAPI en cours d'exécution

### Étapes

1. **Installer les dépendances**
```bash
flutter pub get
```

2. **Configurer l'URL de l'API**

Éditez `lib/services/api_service.dart` ligne 13 :

```dart
// Pour Android émulateur
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// Pour iOS simulateur  
static const String baseUrl = 'http://localhost:8000/api/v1';

// Pour appareil physique (remplacez par votre IP)
static const String baseUrl = 'http://192.168.1.XXX:8000/api/v1';
```

3. **Lancer l'application**
```bash
flutter run
```

## 📱 Fonctionnalités

- ✅ Affichage du solde en temps réel
- ✅ Transfert d'argent avec validation
- ✅ Historique des transactions
- ✅ Interface moderne et responsive

## 🔧 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   └── transfer_response.dart   # Modèle de données
├── screens/
│   └── transfer_screen.dart     # Écran principal
└── services/
    └── api_service.dart         # Service API HTTP
```

## 🐛 Dépannage

### Erreur "Connection refused"
- Vérifiez que le backend FastAPI est démarré
- Vérifiez l'URL dans `api_service.dart`

### Erreur SSL
- Les configurations HTTP sont déjà activées dans AndroidManifest.xml et Info.plist

## 📚 Documentation

Consultez le guide complet dans `FASTAPI_GUIDE.md` du backend.
