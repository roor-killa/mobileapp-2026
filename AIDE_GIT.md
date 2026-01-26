# 🚀 Aide-Mémoire Git Rapide

Voici les commandes essentielles pour travailler sur le projet au quotidien.

## 📋 Tableau de Bord

| Action | Commande | Explication |
| :--- | :--- | :--- |
| **Changer de branche** | `git checkout nom` | Pour aller travailler sur une autre version (ex: `git checkout louisy`) |
| **Voir les changements** | `git status` | Vérifie quels fichiers ont été modifiés (en rouge = pas encore prêts) |
| **Tout préparer** | `git add .` | Ajoute **tous** les fichiers modifiés dans la zone de validation |
| **Enregistrer** | `git commit -m "..."` | Crée un point de sauvegarde local (ex: `git commit -m "Ajout menu"`) |
| **Envoyer (Upload)** | `git push` | Envoie vos sauvegardes locales vers GitHub (Internet) |
| **Récupérer (Download)** | `git pull` | Télécharge les dernières modifications faites par les autres |
| **Créer une branche** | `git checkout -b nom` | Crée une nouvelle branche et bascule dessus immédiatement |

## ⚠️ En cas de blocage au "Push"
Si c'est la première fois que vous envoyez une nouvelle branche, utilisez :
```bash
git push -u origin nom-de-votre-branche
