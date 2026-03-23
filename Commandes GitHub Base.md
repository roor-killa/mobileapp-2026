# Guide des Commandes GitHub de Base

---

## 1. Pour aller sur votre branche (au début de la séance)

### Voir la liste des branches disponibles

```bash
git branch
```

### Basculer sur votre branche personnelle

```bash
git checkout louisy   # Remplacer 'louisy' par votre nom
```

### Récupérer les dernières modifications du dépôt distant

Avant de commencer à travailler, pensez toujours à récupérer les changements de vos collègues :

```bash
git pull
```

---

## 2. La routine pour sauvegarder et envoyer (à faire souvent)

Cette séquence est à répéter chaque fois que vous souhaitez sauvegarder votre travail sur GitHub.

**Étape 1 — Voir ce qui a changé**
```bash
git status
```

**Étape 2 — Tout ajouter**
```bash
git add .
```

**Étape 3 — Enregistrer avec un message (gardez les guillemets)**
```bash
git commit -m "Description de ce que j'ai fait"
```

**Étape 4 — Envoyer vers GitHub**
```bash
git push
```

---

## 3. Premier envoi de la branche

Si c'est le tout premier envoi de la branche et que `git push` échoue, utilisez cette commande :

```bash
git push -u origin louisy   # Remplacer 'louisy' par votre nom de branche
```

> Cette commande établit le lien entre votre branche locale et la branche distante sur GitHub.
> Les prochains `git push` fonctionneront sans l'option `-u`.

---

## 4. Mettre à jour un fichier ou des fichiers

Pour modifier et mettre à jour des fichiers existants sur GitHub :

```bash
git add .                              # Prépare la mise à jour
git commit -m "Mise à jour du fichier X"  # Valide avec un message
git push                               # Envoie vers GitHub
```

---

## 5. Voir les modifications avant d'ajouter

Pour voir exactement ce qui a changé dans le code avant de faire un commit :

```bash
git diff                  # Voir les modifications non encore ajoutées
git diff --staged         # Voir les modifications déjà ajoutées (après git add)
git log --oneline         # Voir l'historique des commits en résumé
```

---

## 6. Annuler une modification

| Situation | Commande |
|---|---|
| Annuler les modifications d'un fichier (avant `git add`) | `git restore nom_fichier` |
| Désindexer un fichier (après `git add`, avant `git commit`) | `git restore --staged nom_fichier` |
| Annuler le dernier commit (en gardant les fichiers) | `git reset --soft HEAD~1` |

---

## 7. Conseils pratiques

- Faites des commits **réguliers** avec des messages **clairs et descriptifs**
- Faites toujours un `git pull` **avant** de commencer à travailler
- Utilisez `git status` **fréquemment** pour vérifier l'état de vos fichiers
- Gardez toujours les **guillemets** autour de vos messages de commit
- Préférez des messages de commit explicites :
  - ✅ `"Ajout écran de connexion"`
  - ✅ `"Correction bug affichage solde"`
  - ❌ `"modif"` ou `"update"`

---

## 8. Résumé du workflow quotidien

| Commande | Action |
|---|---|
| `git pull` | Récupérer les dernières modifications |
| `git checkout louisy` | Basculer sur votre branche |
| `git status` | Vérifier les modifications |
| `git add .` | Ajouter tous les fichiers |
| `git commit -m "message"` | Enregistrer les modifications |
| `git push` | Envoyer vers GitHub |

---

## 9. Résolution des problèmes courants

| Problème | Solution |
|---|---|
| `git push` échoue au premier envoi | Utiliser `git push -u origin nom-branche` |
| Conflits de fusion (`merge conflict`) | Ouvrir le fichier en conflit, choisir les bonnes lignes, puis `git add .` et `git commit` |
| Mauvais message de commit | `git commit --amend -m "nouveau message"` (avant le push) |
| Oublié de faire `git pull` avant de travailler | `git pull` puis résoudre les conflits éventuels |
| Voir sur quelle branche on est | `git branch` (la branche active a une `*`) |
