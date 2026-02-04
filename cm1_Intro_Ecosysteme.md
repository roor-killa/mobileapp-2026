# CM1 - Introduction à Flutter et Dart : Détails pédagogiques

## 📋 Informations générales

**Durée recommandée :** 2h (CM pur) ou 3h (CM + démo live)
**Objectifs :** Comprendre l'écosystème mobile, maîtriser les bases de Dart, préparer l'environnement
**Prérequis mobilisés :** POO (Python), concepts Web2 (composants, state)

---

## 🎯 Structure détaillée du cours

### **PARTIE 1 : Paysage du développement mobile (30-40 min)**

#### **1.1 L'évolution du mobile (5-7 min)**
**Slides suggérées :**
- Timeline : 2007 (iPhone) → 2008 (Android) → 2015 (React Native) → 2017 (Flutter) → 2026
- Statistiques marché : Android vs iOS en 2026 (focus Martinique/Caraïbes si données disponibles)
- Explosion des apps : +2M sur Play Store, +2M sur App Store

**Points clés à développer :**
- La fragmentation Android (versions, constructeurs) vs uniformité iOS
- L'importance du mobile-first dans la Caraïbe (taux de pénétration smartphone)
- Opportunités pour entrepreneurs locaux (moins de concurrence sur niches caribéennes)

---

#### **1.2 Les trois approches techniques (15-20 min)**

**A) Développement Natif**
```dart
// Android (Kotlin/Java)
Button button = findViewById(R.id.myButton);
button.setOnClickListener(new View.OnClickListener() {
    public void onClick(View v) {
        // Action
    }
});

// iOS (Swift)
@IBAction func buttonTapped(_ sender: UIButton) {
    // Action
}
```

**Avantages :** Performance maximale, accès complet aux APIs, UX/UI natifs
**Inconvénients :** 2 codebases, 2 équipes, coûts doublés
**Cas d'usage :** Apps exigeantes (jeux AAA, apps bancaires critiques)

---

**B) Développement Hybride (Ionic, Cordova)**
```html
<!-- Une WebView qui affiche du HTML/CSS/JS -->
<ion-button (click)="handleClick()">
  Click me
</ion-button>
```

**Avantages :** Technologies web familières, une codebase
**Inconvénients :** Performance limitée, UX "web-like", accès API limité
**Cas d'usage :** Apps content-driven, POCs rapides

---

**C) Cross-platform moderne (Flutter, React Native)**
```dart
// Flutter - Un code, rendu natif
ElevatedButton(
  onPressed: () {
    // Action
  },
  child: Text('Click me'),
)
```

**Avantages :** Performance proche du natif, une codebase, hot reload
**Inconvénients :** Courbe d'apprentissage, taille binaire
**Cas d'usage :** Startups, MVPs, apps business standard

---

#### **1.3 Pourquoi Flutter ? (10-12 min)**

**Tableau comparatif à projeter :**

| Critère | Flutter | React Native | Natif |
|---------|---------|--------------|-------|
| Performance | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Productivité | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Courbe apprentissage | ⭐⭐⭐ | ⭐⭐⭐⭐ (si JS connu) | ⭐⭐ |
| Communauté | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Backing | Google | Meta | Apple/Google |

**Architecture Flutter à expliquer :**
```
┌─────────────────────────────────┐
│   Framework (Dart)              │  ← Vous écrivez ici
│   - Material/Cupertino widgets  │
│   - Gestures, Animation         │
└─────────────────────────────────┘
          ↓
┌─────────────────────────────────┐
│   Engine (C/C++)                │  ← Skia rendering
│   - Skia graphics               │
│   - Dart runtime                │
└─────────────────────────────────┘
          ↓
┌─────────────────────────────────┐
│   Platform (Android/iOS)        │  ← Code natif
└─────────────────────────────────┘
```

**Widget tree concept :**
- Tout est widget (bouton, texte, layout, padding...)
- Composition vs héritage (comme les composants React en Web2)
- Immutabilité et rebuild intelligent

**Entreprises utilisant Flutter :**
- Google (Google Ads, Stadia)
- Alibaba, BMW, eBay, Nubank
- **Potentiel local :** Apps gouvernementales, tourisme Caraïbes, EdTech

---

### **PARTIE 2 : Le langage Dart (45-50 min)**

#### **2.1 Introduction et syntaxe (10 min)**

**Positionnement :**
> "Dart = la clarté de Python + la structure de Java + les features modernes de JavaScript"

**Premier programme :**
```dart
void main() {
  print('Bonjour Martinique ! 🇲🇶');
  
  // Variables et typage
  String nom = 'Roor';           // Type explicite
  var age = 25;                  // Inférence de type
  final ville = 'Fort-de-France'; // Immutable
  const pi = 3.14159;            // Compile-time constant
  
  // Interpolation de chaînes
  print('$nom a $age ans et habite à $ville');
  print('${nom.toUpperCase()} - ${age * 2}');
}
```

**Points à souligner :**
- Typage statique fort (comme TypeScript) vs Python dynamique
- `final` vs `const` : runtime vs compile-time
- String interpolation natif (plus élégant que Python f-strings)

---

#### **2.2 Null Safety (10-12 min)**

**Le problème historique :**
```dart
// Avant Dart 2.12 (sound null safety)
String nom;
print(nom.length); // 💥 NullPointerException
```

**La solution Dart :**
```dart
// Types non-nullables par défaut
String nom = 'Roor';         // Ne peut pas être null
String? prenom;              // Peut être null (? = nullable)

// Opérateurs null-aware
print(prenom?.length);       // Safe navigation (null si prenom null)
print(prenom ?? 'Anonyme');  // Null coalescing
prenom ??= 'John';           // Assign si null

// Null assertion (à utiliser avec précaution)
print(prenom!.length);       // Force unwrap (crash si null)

// Conditional member access
if (prenom != null) {
  print(prenom.length);      // Smart cast automatique
}
```

**Analogie pédagogique :**
- Comme TypeScript `strictNullChecks`
- Évite 70% des bugs en production (référence Google)
- Compilateur = filet de sécurité

---

#### **2.3 Collections et opérateurs (12-15 min)**

**Listes :**
```dart
// Déclaration
List<String> fruits = ['Mangue', 'Coco', 'Goyave'];
var nombres = [1, 2, 3, 4, 5]; // Inférence List<int>

// Méthodes
fruits.add('Banane');
fruits.remove('Coco');
print(fruits.length);
print(fruits.first);
print(fruits.contains('Mangue'));

// Spread operator
var tropicalFruits = ['Ananas', ...fruits, 'Papaye'];

// Collection if/for
var evenNumbers = [
  for (var i in nombres) 
    if (i % 2 == 0) i
]; // [2, 4]

// Map, filter, reduce (comme Python/JS)
var carres = nombres.map((n) => n * n).toList();
var pairs = nombres.where((n) => n % 2 == 0).toList();
var somme = nombres.reduce((a, b) => a + b);
```

**Maps :**
```dart
Map<String, dynamic> etudiant = {
  'nom': 'Jean',
  'age': 21,
  'ville': 'Schoelcher',
  'notes': [15, 16, 14]
};

// Accès
print(etudiant['nom']);
etudiant['age'] = 22;

// Itération
etudiant.forEach((key, value) {
  print('$key: $value');
});
```

**Sets :**
```dart
Set<String> villes = {'Fort-de-France', 'Lamentin', 'Schoelcher'};
villes.add('Fort-de-France'); // Pas de doublons
print(villes.length); // 3
```

**Cascade notation (feature unique) :**
```dart
// Au lieu de :
var button = Button();
button.text = 'Click me';
button.color = Colors.blue;
button.onClick = handleClick;

// Cascade :
var button = Button()
  ..text = 'Click me'
  ..color = Colors.blue
  ..onClick = handleClick;
```

---

#### **2.4 Fonctions et programmation fonctionnelle (8-10 min)**

```dart
// Fonction classique
int additionner(int a, int b) {
  return a + b;
}

// Arrow function (expression)
int multiplier(int a, int b) => a * b;

// Paramètres nommés optionnels
void creerUtilisateur({
  required String nom,    // Obligatoire
  int age = 18,          // Optionnel avec valeur par défaut
  String? ville,         // Optionnel nullable
}) {
  print('$nom, $age ans, $ville');
}

creerUtilisateur(nom: 'Marie', ville: 'Trinité');

// Fonctions anonymes et callbacks
List<int> nombres = [1, 2, 3, 4];
var doubles = nombres.map((n) => n * 2).toList();

// Higher-order functions
Function creerMultiplicateur(int facteur) {
  return (int n) => n * facteur;
}

var tripler = creerMultiplicateur(3);
print(tripler(5)); // 15
```

---

#### **2.5 Programmation asynchrone (12-15 min)**

**Future (comme Promise en JS) :**
```dart
// Simuler un appel API
Future<String> obtenirMeteo() async {
  await Future.delayed(Duration(seconds: 2)); // Simule latence réseau
  return 'Soleil 30°C'; // Martinique typique 😎
}

// Utilisation avec async/await
void afficherMeteo() async {
  print('Chargement...');
  String meteo = await obtenirMeteo();
  print('Météo : $meteo');
}

// Gestion d'erreur
Future<void> appelAPI() async {
  try {
    var data = await obtenirMeteo();
    print(data);
  } catch (e) {
    print('Erreur : $e');
  } finally {
    print('Terminé');
  }
}

// Future.wait (parallélisation)
Future<void> chargerDonnees() async {
  var results = await Future.wait([
    obtenirMeteo(),
    obtenirActualites(),
    obtenirUtilisateur(),
  ]);
  print(results); // Toutes les réponses
}
```

**Stream (flux de données continus) :**
```dart
// Stream simple
Stream<int> compteur() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // Émet une valeur
  }
}

// Écoute du stream
void main() async {
  await for (int valeur in compteur()) {
    print(valeur); // 1, 2, 3, 4, 5 (une par seconde)
  }
}

// Cas d'usage Flutter : notifications, chat, GPS temps réel
```

**Comparaison pédagogique :**
- `Future` = `Promise` (JavaScript) / `async/await` (Python)
- `Stream` = `Observable` (RxJS) / Generator (Python)
- Essential pour Firebase, API REST, WebSocket en Flutter

---

### **PARTIE 3 : Environnement de développement (30-35 min)**

#### **3.1 Installation Flutter SDK (10 min)**

**Slides avec captures d'écran :**

**Windows :**
```bash
# 1. Télécharger Flutter SDK depuis flutter.dev
# 2. Extraire dans C:\src\flutter
# 3. Ajouter au PATH système

# Vérification
flutter doctor
```

**macOS/Linux :**
```bash
# Installation via Git
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Ou via gestionnaire de paquets (macOS)
brew install flut
ter

flutter doctor
```

**Output `flutter doctor` à analyser ensemble :**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS (macOS only)
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device
[✓] Network resources
```

---

#### **3.2 Configuration IDE (12-15 min)**

**A) Android Studio (recommandé pour débutants)**
- Installation des plugins Flutter + Dart
- Configuration AVD (Android Virtual Device)
- Premier projet : `File > New > New Flutter Project`
- Démo live : créer projet, explorer structure

**B) VS Code (plus léger, préféré par devs expérimentés)**
```json
// Extensions recommandées
{
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter",
    "nash.awesome-flutter-snippets",
    "alexisvt.flutter-snippets",
    "usernamehw.errorlens" // Affiche erreurs inline
  ]
}
```

**Structure d'un projet Flutter à expliquer :**
```
mon_app/
├── android/          # Code natif Android
├── ios/              # Code natif iOS
├── lib/              # ← VOTRE CODE DART ICI
│   └── main.dart     # Point d'entrée
├── test/             # Tests unitaires
├── pubspec.yaml      # Dépendances (comme package.json)
└── README.md
```

**pubspec.yaml expliqué :**
```yaml
name: mon_app
description: Mon application Flutter
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^1.1.0              # Pour appels API
  provider: ^6.0.0          # State management
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

---

#### **3.3 Émulateurs et devices physiques (8-10 min)**

**Émulateurs Android :**
```bash
# Lister émulateurs disponibles
flutter emulators

# Lancer un émulateur
flutter emulators --launch <emulator_id>

# Créer un nouvel AVD dans Android Studio
Tools > Device Manager > Create Virtual Device
# Recommandé : Pixel 6, API 33 (Android 13)
```

**Tests sur device physique :**

**Android :**
1. Activer mode développeur (7x sur "Numéro de build")
2. Activer débogage USB
3. Connecter via USB
4. Autoriser débogage sur téléphone

**iOS (macOS uniquement) :**
1. Avoir compte développeur Apple
2. Connecter iPhone/iPad
3. Trust computer
4. Sélectionner device dans Xcode

**Vérifier connexion :**
```bash
flutter devices

# Output :
# 3 connected devices:
# sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64    • Android 13 (API 33)
# iPhone 14 Pro (mobile)        • ios           • ios            • com.apple.CoreSimulator.SimRuntime.iOS-16-0
# Chrome (web)                  • chrome        • web-javascript • Google Chrome 120
```

---

#### **3.4 CLI Flutter - Commandes essentielles (5 min)**

```bash
# Créer un projet
flutter create mon_app
flutter create --org com.univ-antilles mon_app  # Avec bundle ID

# Lancer l'app
flutter run
flutter run -d chrome        # Sur navigateur
flutter run -d <device_id>   # Sur device spécifique

# Hot reload pendant développement
r                            # Reload
R                            # Restart complet
q                            # Quitter

# Build de production
flutter build apk            # Android APK
flutter build appbundle      # Android App Bundle (pour Play Store)
flutter build ios            # iOS (macOS uniquement)

# Analyse et nettoyage
flutter analyze              # Linter
flutter test                 # Lancer tests
flutter clean                # Nettoyer build cache

# Gestion dépendances
flutter pub get              # Installer dépendances pubspec.yaml
flutter pub upgrade          # Mettre à jour
flutter pub outdated         # Voir dépendances obsolètes
```

---

## 🎬 Démonstration live (si temps disponible)

**Premier "Hello Martinique" en Flutter :**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MonApp());
}

class MonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Martinique',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ma première app Flutter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bonjour Martinique ! 🇲🇶',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('Bouton cliqué !');
                },
                child: Text('Cliquez-moi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Montrer en direct :**
1. Hot reload en action (modifier texte/couleur)
2. Widget tree dans DevTools
3. Console de debug
4. Inspector pour voir propriétés widgets

---

## 📚 Ressources complémentaires à partager

**Documentation officielle :**
- https://flutter.dev/docs
- https://dart.dev/guides
- https://api.flutter.dev (API reference)

**Tutoriels interactifs :**
- https://dartpad.dev (playground Dart en ligne)
- Flutter Codelabs : https://docs.flutter.dev/codelabs

**Communauté :**
- r/FlutterDev (Reddit)
- Flutter Community on Medium
- FlutterFlow (no-code pour prototypage rapide)

**Chaînes YouTube recommandées :**
- The Flutter Way
- Reso Coder
- Robert Brunhage

---

## ✅ Checklist de fin de CM1

**Les étudiants doivent repartir avec :**
- [ ] Flutter SDK installé et fonctionnel (`flutter doctor` OK)
- [ ] Un IDE configuré (Android Studio ou VS Code)
- [ ] Un émulateur Android opérationnel
- [ ] Leur premier projet Flutter créé et lancé
- [ ] Compréhension des bases de Dart (variables, collections, async)
- [ ] Motivation pour le projet de fin de semestre ! 🚀

---

## 🎯 Transition vers le TD1

**Annonce pour le prochain cours :**
> "Au TD1, vous allez créer votre première vraie application : un compteur interactif avec state management. 
Vous découvrirez les StatefulWidget, le setState(), et comment Flutter reconstruit l'interface. Préparez vos machines, on code dès la première minute !"

**Devoir préparatoire (facultatif mais recommandé) :**
- Lire la documentation sur les Stateless vs Stateful Widgets
- Créer un compte GitHub (pour le workflow Git/branches que vous utiliserez)
- Penser à une idée d'app qui pourrait être utile en Martinique/Caraïbes

---


