# Migration bénéficiaires

Si tu as l'erreur :
sqlite3.OperationalError: no such column: beneficiaries.owner_user_id

=> ton fichier wallet.db a un ancien schéma.

1) Va dans le dossier server/ (là où se trouve wallet.db et main.py)
2) Active le venv
   - PowerShell: .\.venv\Scripts\Activate.ps1
3) Lance la migration :
   python migrate_beneficiaries.py

Alternative rapide (perd les comptes & transactions) :
   Supprime wallet.db puis relance uvicorn (les tables seront recréées).
