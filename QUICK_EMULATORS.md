# ⚡ QUICK START - Deux Émulateurs (5 minutes)

## 🚀 Si vous avez Flutter & Android Studio

### 1️⃣ Vérifier l'Installation

```powershell
flutter doctor
adb devices
```

---

## 2️⃣ Lancer les Deux Émulateurs (2 PowerShell)

### PowerShell 1:
```powershell
emulator -avd Emulator1_Bank_User1 -no-snapshot-load
```

### PowerShell 2:
```powershell
emulator -avd Emulator2_Bank_User2 -no-snapshot-load
```

**Attendre 30-60 secondes de boot** ⏳

Vérifier:
```powershell
adb devices
```

Résultat attendu:
```
emulator-5554    device
emulator-5556    device
```

---

## 3️⃣ Lancer le Backend Laravel (PowerShell 3)

```powershell
cd "C:\Users\Fayzel\OneDrive\Bureau\L3I\ProgMob\mobileapp-2026\infrastructure\back-laravel"
php artisan serve
```

API sur: http://localhost:8000

---

## 4️⃣ Lancer l'App sur Émulateur 1 (PowerShell 4)

```powershell
cd "C:\Users\Fayzel\OneDrive\Bureau\L3I\ProgMob\mobileapp-2026\project\firstapp"
flutter run -d emulator-5554
```

---

## 5️⃣ Lancer l'App sur Émulateur 2 (PowerShell 5)

```powershell
cd "C:\Users\Fayzel\OneDrive\Bureau\L3I\ProgMob\mobileapp-2026\project\firstapp"
flutter run -d emulator-5556
```

---

## 🧪 TESTER LES VIREMENTS

### Émulateur 1 - Se Connecter:
```
Email: jean.dupont@example.com
Mot de passe: password123
```

### Émulateur 2 - Se Connecter:
```
Email: marie.martin@example.com  
Mot de passe: password123
```

### Effectuer un Virement (Émulateur 1):
1. Tap "Effectuer un virement"
2. From: "Compte Chèques" (1000 EUR)
3. To: "Compte d'Épargne" (5000 EUR)
4. Amount: "100"
5. Tap "Confirmer le virement"

✅ **Solde Compte Chèques: 1000 → 900**  
✅ **Solde Compte d'Épargne: 5000 → 5100**

### Voir en Temps Réel (Émulateur 2):
1. Refresh le dashboard
2. Historique des transactions mis à jour
3. Voir tous les détails du virement

---

## 🛑 Si Problème

### Émulateur ne démarre?
```powershell
taskkill /IM emulator.exe /F
emulator -avd Emulator1_Bank_User1 -no-snapshot-load
```

### Flutter ne voit pas l'émulateur?
```powershell
adb kill-server
adb start-server
flutter devices
```

### API non accessible?
Éditer `lib/config/api_config.dart`:
```dart
// Changer de:
static const String baseUrl = 'http://localhost:8000/api';
// À:
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

---

**C'est prêt ! Vous pouvez tester ! 🎉**
