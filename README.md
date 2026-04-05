<div align="center">

<img src="assets/images/Campusconnect.png" alt="CampusConnect Logo" width="120" />

# CampusConnect

**La plateforme mobile des étudiants**

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.5+-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Présentation

CampusConnect est une application mobile développée en **Flutter** pour les étudiants du campus. Elle centralise la vie étudiante autour de quatre fonctionnalités principales : annonces, événements, messagerie instantanée et assistant virtuel.

### Fonctionnalités principales

| Fonctionnalité | Description |
|---|---|
| Annonces | Publier et consulter des annonces par catégorie (cours, covoiturage, logement, entraide) |
| Événements | Créer et rejoindre des événements campus |
| Messagerie | Conversations privées en temps réel entre étudiants |
| Profil | Personnalisation du profil avec photo et bio |
| Chatbot | Assistant virtuel pour naviguer dans l'application |

---

## Prérequis

Avant de lancer le projet, assure-toi d'avoir installé les éléments suivants :

### Outils obligatoires

| Outil | Version minimale | Lien |
|---|---|---|
| **Flutter SDK** | 3.5.0 | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | 3.5.0 | Inclus avec Flutter |
| **Android Studio** | 2023.x | [developer.android.com/studio](https://developer.android.com/studio) |
| **VS Code** | Recommandé | [code.visualstudio.com](https://code.visualstudio.com) |
| **Git** | 2.x | [git-scm.com](https://git-scm.com) |

### Extensions VS Code recommandées

- **Flutter** (`Dart-Code.flutter`)
- **Dart** (`Dart-Code.dart-code`)
- **Pubspec Assist** (`jeroen-meijer.pubspec-assist`)

### Compte Supabase

- Créer un compte sur [supabase.com](https://supabase.com)
- Créer un nouveau projet
- Récupérer l'**URL** et la clé **anon public** dans *Settings → API*

---

## Structure du projet

```
campusconnect/
│
├── assets/
│   └── images/
│       ├── Campusconnect.png         # Logo de l'application
│       └── splash/                   # Images de fond de l'écran de démarrage
│           ├── martinique.jpg
│           └── ...
│
├── lib/
│   ├── main.dart                     # Point d'entrée + routage authentification
│   │
│   ├── models/                       # Modèles de données (DTOs)
│   │   ├── user_model.dart
│   │   ├── announcement_model.dart
│   │   ├── event_model.dart
│   │   ├── message_model.dart
│   │   └── conversation_model.dart
│   │
│   ├── providers/                    # Gestion d'état global (ChangeNotifier)
│   │   ├── auth_provider.dart
│   │   └── theme_provider.dart
│   │
│   ├── services/                     # Accès aux données Supabase
│   │   ├── auth_service.dart
│   │   ├── announcement_service.dart
│   │   ├── event_service.dart
│   │   ├── message_service.dart
│   │   └── chatbot_service.dart
│   │
│   ├── screens/                      # Écrans de l'application
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── announcements/
│   │   │   ├── announcements_screen.dart
│   │   │   ├── announcement_detail_screen.dart
│   │   │   └── create_announcement_screen.dart
│   │   ├── events/
│   │   │   ├── events_screen.dart
│   │   │   ├── event_detail_screen.dart
│   │   │   └── create_event_screen.dart
│   │   ├── messages/
│   │   │   ├── conversations_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   └── search_users_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   └── chatbot/
│   │       └── chat_screen.dart
│   │
│   ├── widgets/                      # Composants UI réutilisables
│   │   ├── announcement_card.dart
│   │   ├── event_card.dart
│   │   ├── user_avatar.dart
│   │   ├── glass_card.dart
│   │   └── chat_bubble.dart
│   │
│   └── utils/                        # Thème, constantes, configuration
│       ├── app_theme.dart
│       ├── constants.dart
│       └── supabase_config.dart
│
├── pubspec.yaml                      # Dépendances du projet
└── README.md
```

---

## Installation et lancement

### Étape 1 — Cloner le dépôt

```bash
git clone https://github.com/ton-compte/campusconnect.git
cd campusconnect
```

### Étape 2 — Installer les dépendances

```bash
flutter pub get
```

### Étape 3 — Configurer Supabase

Ouvre le fichier [lib/utils/supabase_config.dart](lib/utils/supabase_config.dart) et remplace les valeurs par celles de ton projet Supabase :

```dart
class SupabaseConfig {
  static const String url = 'https://TON-PROJET.supabase.co';
  static const String anonKey = 'TA_CLE_ANON';
}
```

### Étape 4 — Configurer la base de données Supabase

Exécute les scripts SQL suivants dans l'ordre dans le **SQL Editor** de ton Dashboard Supabase.

#### 4.1 — Créer les tables

```sql
-- Table des utilisateurs
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nom TEXT NOT NULL,
  email TEXT,
  bio TEXT,
  filiere TEXT,
  photo_url TEXT,
  cover_photo_url TEXT,
  date_inscription TIMESTAMPTZ DEFAULT NOW(),
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0
);

-- Table des annonces
CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titre TEXT NOT NULL,
  description TEXT NOT NULL,
  categorie TEXT NOT NULL DEFAULT 'autre',
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  date_publication TIMESTAMPTZ DEFAULT NOW()
);

-- Table des favoris
CREATE TABLE public.announcement_favoris (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID REFERENCES public.announcements(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  UNIQUE(announcement_id, user_id)
);

-- Table des événements
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titre TEXT NOT NULL,
  description TEXT,
  lieu TEXT,
  date TIMESTAMPTZ NOT NULL,
  organisateur_id UUID REFERENCES public.users(id) ON DELETE CASCADE
);

-- Table des participants aux événements
CREATE TABLE public.event_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  UNIQUE(event_id, user_id)
);

-- Table des conversations
CREATE TABLE public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dernier_message TEXT,
  dernier_message_date TIMESTAMPTZ,
  dernier_message_expediteur_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des participants aux conversations
CREATE TABLE public.conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  UNIQUE(conversation_id, user_id)
);

-- Table des messages
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  expediteur_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  contenu TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  lu BOOLEAN DEFAULT FALSE
);
```

#### 4.2 — Créer les vues

```sql
-- Vue annonces enrichies
CREATE OR REPLACE VIEW public.announcements_full AS
SELECT
  a.*,
  u.nom AS user_nom,
  u.photo_url AS user_photo_url,
  COUNT(f.id) AS nb_favoris
FROM public.announcements a
JOIN public.users u ON u.id = a.user_id
LEFT JOIN public.announcement_favoris f ON f.announcement_id = a.id
GROUP BY a.id, u.nom, u.photo_url;

-- Vue conversations avec l'autre participant
CREATE OR REPLACE VIEW public.conversations_with_other
WITH (security_invoker = true) AS
SELECT
  c.id,
  c.dernier_message,
  c.dernier_message_date,
  c.dernier_message_expediteur_id,
  c.created_at,
  cp_me.user_id     AS my_user_id,
  cp_other.user_id  AS other_user_id,
  u.nom             AS other_nom,
  u.photo_url       AS other_photo_url
FROM public.conversations c
JOIN public.conversation_participants cp_me
  ON cp_me.conversation_id = c.id AND cp_me.user_id = auth.uid()
JOIN public.conversation_participants cp_other
  ON cp_other.conversation_id = c.id AND cp_other.user_id <> cp_me.user_id
JOIN public.users u ON u.id = cp_other.user_id;
```

#### 4.3 — Créer les fonctions et triggers

```sql
-- Trigger : création automatique du profil à l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.users (id, nom, email, date_inscription)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'nom', split_part(new.email, '@', 1)),
    new.email,
    NOW()
  ) ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger : mise à jour du dernier message
CREATE OR REPLACE FUNCTION public.update_conversation_last_message()
RETURNS trigger LANGUAGE plpgsql
SECURITY INVOKER SET search_path = ''
AS $$
BEGIN
  UPDATE public.conversations
  SET
    dernier_message               = NEW.contenu,
    dernier_message_date          = NEW.timestamp,
    dernier_message_expediteur_id = NEW.expediteur_id
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_message_sent
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_conversation_last_message();

-- Fonction RPC : obtenir ou créer une conversation
CREATE OR REPLACE FUNCTION public.get_or_create_conversation(user1_id uuid, user2_id uuid)
RETURNS uuid LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE conv_id UUID;
BEGIN
  SELECT cp1.conversation_id INTO conv_id
  FROM public.conversation_participants cp1
  JOIN public.conversation_participants cp2
    ON cp1.conversation_id = cp2.conversation_id
  WHERE cp1.user_id = user1_id AND cp2.user_id = user2_id
  LIMIT 1;

  IF conv_id IS NULL THEN
    INSERT INTO public.conversations DEFAULT VALUES RETURNING id INTO conv_id;
    INSERT INTO public.conversation_participants (conversation_id, user_id)
    VALUES (conv_id, user1_id), (conv_id, user2_id);
  END IF;

  RETURN conv_id;
END;
$$;
```

#### 4.4 — Activer le Row Level Security (RLS)

```sql
-- Activer RLS sur toutes les tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcement_favoris ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Politiques users
CREATE POLICY "Lecture publique des profils" ON public.users FOR SELECT TO authenticated USING (true);
CREATE POLICY "Modification de son propre profil" ON public.users FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Insertion via trigger" ON public.users FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- Politiques announcements
CREATE POLICY "Lecture de toutes les annonces" ON public.announcements FOR SELECT TO authenticated USING (true);
CREATE POLICY "Créer une annonce" ON public.announcements FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Supprimer sa propre annonce" ON public.announcements FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Politiques favoris
CREATE POLICY "Lire ses favoris" ON public.announcement_favoris FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Ajouter un favori" ON public.announcement_favoris FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Supprimer un favori" ON public.announcement_favoris FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Politiques events
CREATE POLICY "Lecture de tous les événements" ON public.events FOR SELECT TO authenticated USING (true);
CREATE POLICY "Créer un événement" ON public.events FOR INSERT TO authenticated WITH CHECK (auth.uid() = organisateur_id);
CREATE POLICY "Supprimer son événement" ON public.events FOR DELETE TO authenticated USING (auth.uid() = organisateur_id);

-- Politiques participants événements
CREATE POLICY "Lire les participants" ON public.event_participants FOR SELECT TO authenticated USING (true);
CREATE POLICY "Rejoindre un événement" ON public.event_participants FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Quitter un événement" ON public.event_participants FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Politiques conversations
CREATE POLICY "Voir ses conversations" ON public.conversations FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_id = id AND user_id = auth.uid()));

-- Politiques conversation_participants
CREATE POLICY "Voir ses participations" ON public.conversation_participants FOR SELECT TO authenticated USING (user_id = auth.uid());

-- Politiques messages
CREATE POLICY "Lire les messages de ses conversations" ON public.messages FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()));
CREATE POLICY "Envoyer un message" ON public.messages FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = expediteur_id);
```

#### 4.5 — Configurer le Storage

Dans le Dashboard Supabase : **Storage → New bucket**
- Nom : `avatars`
- Public : **activé**

Puis exécute :

```sql
CREATE POLICY "Upload de son propre avatar"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Mise à jour de son propre avatar"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Lecture publique des avatars"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');
```

### Étape 5 — Vérifier les appareils disponibles

```bash
flutter devices
```

### Étape 6 — Lancer l'application

```bash
# Sur émulateur Android
flutter run -d emulator-5554

# Sur Windows (desktop)
flutter run -d windows

# Sur Chrome (web)
flutter run -d chrome
```

### Raccourcis pendant le développement

| Touche | Action |
|---|---|
| `r` | Hot reload (applique les modifications sans redémarrage) |
| `R` | Hot restart (redémarre complètement l'app) |
| `q` | Quitter |

---

## Dépendances

```yaml
supabase_flutter: ^2.5.0       # Backend, Auth, Realtime, Storage
provider: ^6.1.2               # Gestion d'état
image_picker: ^1.1.2           # Sélection de photos
cached_network_image: ^3.3.1   # Chargement optimisé des images
intl: ^0.19.0                  # Dates en français
timeago: ^3.7.0                # Temps relatif ("il y a 2 min")
shared_preferences: ^2.3.2     # Persistance locale (thème)
google_fonts: ^8.0.2           # Police Outfit
```

---

## Architecture

```
Interface (Screens)
      ↕  context.watch / context.read
Providers (AuthProvider, ThemeProvider)
      ↕  appels async
Services (AuthService, AnnouncementService, ...)
      ↕  Supabase SDK (HTTP + WebSocket)
Supabase (PostgreSQL + Auth + Storage + Realtime)
```

---

## Problèmes fréquents

| Erreur | Solution |
|---|---|
| `Unable to load AssetManifest.json` | `flutter clean && flutter pub get && flutter run` |
| `violates row level security policy` | Vérifier et créer les politiques RLS manquantes |
| `PGRST116 - cannot coerce to single JSON` | Remplacer `.single()` par `.maybeSingle()` |
| `PGRST204 - column not found` | Ajouter la colonne manquante + `NOTIFY pgrst, 'reload schema'` |
| `permission denied for schema auth` | Utiliser le Dashboard Supabase plutôt que le SQL Editor pour les opérations sur `auth.*` |

---

## Auteur

Développé dans le cadre d'un projet de Licence en Informatique — 2025/2026

---

<div align="center">
  <sub>Fait avec Flutter & Supabase</sub>
</div>
