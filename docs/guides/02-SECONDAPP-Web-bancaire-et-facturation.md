# Guide débutant — SECONDAPP (web bancaire + facturation)

**Objectif** : ouvrir l’application **dans le navigateur** (Chrome, Edge…), voir le tableau de bord avec données fictives, et utiliser le module **Facturation** (brouillons, création, édition).

**Dossier du projet** : `c:\Users\titou\mobileapp-2026\SECONDAPP`

---

## Étape 1 — Installer Node.js

Installe **Node.js** (version LTS) depuis le site officiel. Vérifie dans un terminal :

```powershell
node -v
npm -v
```

---

## Étape 2 — Installer Docker Desktop

L’application lit des données dans un fichier JSON servi par un petit serveur dans Docker.

1. Installe **Docker Desktop** pour Windows.
2. Démarre Docker (icône dans la barre des tâches = actif).

---

## Étape 3 — Télécharger les librairies du projet

```powershell
cd c:\Users\titou\mobileapp-2026\SECONDAPP
npm install
```

À refaire si le fichier `package.json` change.

---

## Étape 4 — Démarrer les « fausses données » (Docker)

```powershell
cd c:\Users\titou\mobileapp-2026\SECONDAPP
npm run docker:up
```

*(Équivalent : `docker compose up -d` dans ce dossier.)*

- Les données viennent du fichier **`docker\db.json`**.
- Le serveur écoute sur ton PC au port **3001** (en interne pour le navigateur, l’app passe par un **proxy** pour éviter les blocages de sécurité).

**Sans Docker** : l’interface s’affiche quand même, mais le **tableau de bord** et la **facturation** peuvent être **vides** ou afficher un message d’absence de données.

---

## Étape 5 — Lancer le site en mode développement

```powershell
cd c:\Users\titou\mobileapp-2026\SECONDAPP
npm run dev
```

Le terminal affiche une adresse du type **`http://localhost:5173`**. Ouvre-la dans le navigateur.

---

## Étape 6 — Utiliser le tableau de bord (Home)

1. Tu arrives sur l’**accueil** avec solde, graphique, transactions, encarts « insights ».
2. Si tout est vide : vérifie que Docker tourne et que `npm run docker:up` a bien été fait, puis **rafraîchis** la page (F5).
3. Explore les boutons du bas : **Transferts**, **Crypto**, **Invest** — ce sont des écrans de démonstration (boutons, modales, graphiques selon l’écran).

---

## Étape 7 — Menu du haut (icônes)

En haut à droite, des icônes mènent vers :

- **Facturation** (icône type reçu / facture) → voir ci-dessous.
- **Analytics**, **Cartes**, **Sécurité**, **Profil** : navigation entre écrans du prototype.

---

## Étape 8 — Module Facturation

### Ouvrir la facturation

1. Clique sur l’icône **Facturation** (reçu).
2. Tu vois la liste des **factures** avec des **filtres** : Toutes, Brouillon, À encaisser, Payées.

### Consulter une facture « envoyée » / comptabilisée

- Les factures **comptabilisées** ou **payées** s’ouvrent en **lecture seule** (comme une vraie facture déjà validée).

### Modifier un brouillon

1. Clique sur une facture en **Brouillon**.
2. Un **formulaire** s’ouvre : tu peux changer le numéro, le client, les dates, les **lignes** (libellé, quantité, prix, TVA).
3. Tu peux **ajouter** ou **supprimer** des lignes.
4. Clique **Enregistrer le brouillon** : les changements sont stockés dans le **navigateur** (localStorage), pas dans le fichier Docker (lecture seule).

### Créer une nouvelle facture

1. Clique **Nouvelle facture (brouillon)**.
2. Remplis client, dates, lignes.
3. **Enregistrer le brouillon**.

### Supprimer un brouillon créé dans l’app

- Les brouillons **créés** dans l’interface ont souvent un comportement de **suppression** dédié (bouton visible dans le formulaire).

### Annuler tes modifications sur un brouillon venant du fichier JSON

- Si la facture existait déjà dans `db.json`, un bouton du type **Reprendre la version du serveur** annule tes changements locaux pour cette facture.

---

## Étape 9 — Arrêter Docker (optionnel)

```powershell
cd c:\Users\titou\mobileapp-2026\SECONDAPP
npm run docker:down
```

---

## En cas de problème

| Symptôme | Piste |
|----------|--------|
| Données toujours vides avec Docker | Redémarre le conteneur : `docker compose restart` dans `SECONDAPP`. |
| Erreur au `npm install` | Vérifie ta version de Node (LTS). |
| Page blanche | Regarde la console du terminal où tourne `npm run dev` pour les erreurs. |

---

## Rapport détaillé (SECONDAPP)

Pour un document long sur l’historique et la technique : `SECONDAPP\docs\RAPPORT-UTILISATION-DETAILLE.md` et `npm run report:html` dans `SECONDAPP` pour un HTML imprimable en PDF.
