# Configuration Appwrite pour NodEX

Pour que les méthodes de connexion **Code** (email OTP), **SMS** et **Lien** (Magic URL) fonctionnent, ainsi que l'**email de vérification à l'inscription**, vous devez configurer Appwrite dans la [Console Appwrite](https://cloud.appwrite.io/).

## 0. Email à l'inscription

**Comportement :** Lors de l'inscription, un email de vérification est envoyé à l'utilisateur. Il reste connecté et voit un écran lui demandant de cliquer sur le lien reçu.

**Configuration :** Identique au Code (Email OTP) — configurer SMTP dans Auth → Settings.

## 1. Connexion par Code (Email OTP)

**Problème :** "Erreur lors de l'envoi du code"

**Solution :** Configurer un serveur SMTP pour l'envoi d'emails.

1. Allez dans **Auth** → **Settings** (ou **Email**)
2. Configurez un fournisseur SMTP (Gmail, SendGrid, Mailgun, etc.)
3. Entrez les identifiants SMTP fournis par votre hébergeur

Sans SMTP, Appwrite ne peut pas envoyer les codes à 6 chiffres par email.

---

## 2. Connexion par SMS

**Problème :** "Erreur lors de l'envoi du SMS"

**Solution :** Configurer un fournisseur SMS (Twilio recommandé).

1. Allez dans **Auth** → **Settings** → **Phone**
2. Ajoutez un fournisseur (ex. Twilio)
3. Entrez votre Account SID, Auth Token et numéro Twilio

**Format du numéro :** L'utilisateur doit entrer son numéro avec l'indicatif pays, ex. `+33612345678` (sans espaces).

---

## 3. Connexion par Lien (Magic URL)

**Problème :** "Erreur lors de l'envoi du lien" ou le lien ne redirige pas correctement

**Solution :**

1. **SMTP** : Comme pour le Code, un SMTP doit être configuré pour envoyer l'email contenant le lien
2. **URL de redirection :** Appwrite autorise `localhost` par défaut. Si vous utilisez un autre domaine :
   - Allez dans **Auth** → **Settings** → **Platforms**
   - Ajoutez une plateforme **Web app** avec votre domaine (ex. `votredomaine.com`)

L'URL de redirection utilisée est l'origine de l'app (ex. `http://localhost:8080`). Après clic sur le lien, l'utilisateur est redirigé vers votre app avec `userId` et `secret` dans l'URL.

---

## Résumé

| Méthode | Configuration requise |
|---------|----------------------|
| **Code** (Email OTP) | SMTP dans Auth → Settings |
| **SMS** | Fournisseur SMS (Twilio) dans Auth → Settings → Phone |
| **Lien** (Magic URL) | SMTP + plateforme Web si domaine custom |

---

## Vérification

Pour tester que tout fonctionne :

1. **Code** : Entrez un email, cliquez "Envoyer le code", vérifiez votre boîte mail
2. **SMS** : Entrez un numéro au format `+33XXXXXXXXX`, cliquez "Envoyer le code", vérifiez votre téléphone
3. **Lien** : Entrez un email, cliquez "Envoyer le lien", ouvrez la boîte mail, cliquez sur le lien reçu
