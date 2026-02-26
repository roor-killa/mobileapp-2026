# 🚀 Guide d'Installation - Deux Émulateurs Android

## 📋 Pré-requis

- **Java SDK 11+** (pour Android SDK)
- **Android Studio** 
- **Flutter SDK**
- **Git** (optionnel)

---

## ✅ Étape 1: Vérifier Java

Ouvrir PowerShell et vérifier:
```powershell
java -version
```

Si erreur, installer Java depuis: https://www.oracle.com/java/technologies/downloads/

---

## 📥 Étape 2: Installer Android Studio

1. Télécharger depuis: https://developer.android.com/studio
2. Exécuter l'installateur
3. Suivre les instructions
4. Installer les composants Android SDK lors du setup initial

**Après installation:**
```powershell
# Vérifier dans PowerShell
$env:ANDROID_SDK_ROOT
```

Devrait afficher: `C:\Users\Fayzel\AppData\Local\Android\Sdk`

---

## 🦸 Étape 3: Installer Flutter

### Méthode 1: Installation Manuelle (Recommandée)

1. Télécharger Flutter depuis: https://flutter.dev/docs/get-started/install/windows
2. Extraire dans: `C:\flutter` (ou un dossier sans espaces)
3. Ajouter au PATH:

**Via PowerShell (Admin):**
```powershell
# Ajouter au PATH utilisateur
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\flutter\bin", "User")

# Redémarrer PowerShell
# Vérifierflutter --version
```

### Méthode 2: Téléchargement Direct
```
https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip
```

**Après l'installation:**
```powershell
flutter doctor
```

Doit afficher: ✓ Flutter SDK ✓ Dart ✓ Android SDK

---

## 📱 Étape 4: Créer les Deux Émulateurs

### Option A: Via Android Studio GUI (Plus facile)

1. Ouvrir Android Studio
2. Tools → Device Manager
3. Create Device (2 fois)

**Première AVD:**
- Nom: `Emulator1_Bank_User1`
- Device: Pixel 4a
- Android: API 30 ou plus
- RAM: 2 GB

**Deuxième AVD:**
- Nom: `Emulator2_Bank_User2`
- Device: Pixel 5
- Android: API 30 ou plus
- RAM: 2 GB

### Option B: Via Command Line

```powershell
# Créer le premier émulateur
"no" | sdkmanager "system-images;android-30;google_apis;x86_64"

avdmanager create avd `
  -n Emulator1_Bank_User1 `
  -k "system-images;android-30;google_apis;x86_64" `
  -d pixel_4a

# Créer le deuxième émulateur
avdmanager create avd `
  -n Emulator2_Bank_User2 `
  -k "system-images;android-30;google_apis;x86_64" `
  -d pixel_5
```

**Vérifier les AVDs créées:**
```powershell
emulator -list-avds
```

---

## 🎮 Étape 5: Lancer les Deux Émulateurs

### Terminal 1 - Premier Émulateur:
```powershell
emulator -avd Emulator1_Bank_User1 -no-snapshot-load &
```

### Terminal 2 - Deuxième Émulateur:
```powershell
emulator -avd Emulator2_Bank_User2 -no-snapshot-load &
```

**Attendre 30-60 secondes pour le boot complet** ⏳

Vérifier que les deux démarent:
```powershell
adb devices
```

Doit afficher:
```
emulator-5554    device
emulator-5556    device
```

---

## 🏦 Étape 6: Backend Laravel

Terminal 3:
```powershell
cd C:\Users\Fayzel\OneDrive\Bureau\L3I\ProgMob\mobileapp-2026\infrastructure\back-laravel

# Vérifier que le serveur est en cours
php artisan serve
```

L'API sera sur: **http://localhost:8000/api**

---

## ⚡ Étape 7: Lancer l'Application Flutter

### Sur le premier émulateur:

Terminal 4:
```powershell
cd C:\Users\Fayzel\OneDrive\Bureau\L3I\ProgMob\mobileapp-2026\project\firstapp

# Lancer explicitement sur l'émulateur 1
flutter run -d emulator-5554
```

### Sur le deuxième émulateur:

Terminal 5 (nouveau PowerShell):
```powershell
cd C:\Users\Fayzel\OneDrive\Bureau\L3I\ProgMob\mobileapp-2026\project\firstapp

# Lancer explicitement sur l'émulateur 2
flutter run -d emulator-5556
```

---

## 🧪 Étape 8: Tester les Virements

### Utilisateur 1 (Émulateur 1):
```
Email: jean.dupont@example.com
Mot de passe: password123
Comptes: Chèques (1000 EUR) + Épargne (5000 EUR)
```

### Utilisateur 2 (Émulateur 2):
```
Email: marie.martin@example.com
Mot de passe: password123
Comptes: Chèques (1500 EUR) + Épargne (6000 EUR)
```

### Procédure:

**Sur Émulateur 1:**
1. Connexion avec jean.dupont@example.com
2. Aller à "Effectuer un virement"
3. Sélectionner "Compte Chèques" → "Compte d'Épargne"
4. Entrer 100 EUR
5. Cliquer "Confirmer le virement"
6. 🎉 Voir le solde diminuer

**Sur Émulateur 2 (en même temps):**
1. Connexion avec marie.martin@example.com
2. Aller à "Tableau de bord"
3. Voir les soldes mis à jour en temps réel
4. Cliquer "Historique des transactions"
5. Voir les virements de l'autre utilisateur

---

## 🚨 Dépannage

### Émulateur ne démarre pas:
```powershell
# Tuer tous les processus emulator
taskkill /IM emulator.exe /F

# Relancer
emulator -avd Emulator1_Bank_User1 -no-snapshot-load
```

### Flutter ne trouvera les émulateurs:
```powershell
# Vérifier les appareils
flutter devices

# Si vide, redémarrer adb
adb kill-server
adb start-server
adb devices
```

### API non accessible depuis l'émulateur:
```powershell
# Dans api_config.dart, utiliser:
# static const String baseUrl = 'http://10.0.2.2:8000/api';
# (10.0.2.2 = localhost depuis l'émulateur)
```

### Laravel dit "Cannot GET /api/accounts":
```powershell
# Relancer le serveur
cd infrastructure/back-laravel
php artisan serve --host=0.0.0.0
```

---

## 📊 Configuration Finale Recommandée

```
PowerShell Terminal 1:
→ emulator -avd Emulator1_Bank_User1 -no-snapshot-load

PowerShell Terminal 2:
→ emulator -avd Emulator2_Bank_User2 -no-snapshot-load

PowerShell Terminal 3:
→ cd infrastructure/back-laravel && php artisan serve

PowerShell Terminal 4:
→ cd project/firstapp && flutter run -d emulator-5554

PowerShell Terminal 5:
→ cd project/firstapp && flutter run -d emulator-5556
```

**Total: 5 terminals ouverts**

---

## ✅ Checklist Final

- [ ] Java installé et fonctionnel
- [ ] Android Studio installé
- [ ] Flutter SDK installé et dans PATH
- [ ] Deux AVDs créés
- [ ] Deux émulateurs démarrés
- [ ] Laravel server running
- [ ] App Flutter lancée sur les 2 émulateurs
- [ ] Deux utilisateurs de test connectés

---

## 🎯 Résultat FINAL

Vous verrez en temps réel:
- **Émulateur 1:** Jean envoie 100 EUR (solde: 900 → 1000)
- **Émulateur 2:** Marie reçoit 100 EUR (solde inchangé car autres comptes)
- **Dashboard:** Historique des transactions mis à jour instantanément

**Durée totale de setup:** 15-20 minutes (dépend de la vitesse Internet)

---

**Bon test ! 🎉**
