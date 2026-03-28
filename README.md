# mobileapp-2026
Création application mobile en L3 Informatique - 2026

Après avoir installé les fichiers, 
ouvrez un terminal de commandes et placez-vous dans le dossier "app transfert argent meteo",
puis, entrez la commande "flutter pub get" afin d'installer les dépendances nécessaires aux différents fichiers.

Lors de la création d'un compte, si vous avez une erreur, 
fermez l'émulateur et cliquez sur l'icone "..." à coté de l'icone pour lancer l'émulateur.
Ensuite, cliquez sur "Cold Boot" pour régler l'erreur.

Comme la clé API Groq se trouve dans le fichier .env à la racine du projet, 
il faut désormais utiliser cette commande pour lancer flutter : "flutter run --dart-define-from-file=.env"
Si on lance flutter juste avec : "flutter run", l'appli ne pourra pas utiliser la clé API dans le
fichier .env