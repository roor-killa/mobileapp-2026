from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uvicorn

app = FastAPI()

# --- MODÈLES DE DONNÉES (Pydantic) ---

# Modèle pour recevoir une demande de virement
class TransferRequest(BaseModel):
    amount: float
    sender_id: int 
    # Pas besoin de receiver_id ici, car dans cette démo simplifiée :
    # Si sender=1 => receiver=2
    # Si sender=2 => receiver=1

# Modèle pour la réponse du virement
class TransferResponse(BaseModel):
    success: bool
    montant_total: float      # Solde avant virement
    montant_transfere: float  # Montant viré
    nouveau_solde: float      # Solde après virement
    message: str

# Modèle pour une transaction dans l'historique
class TransactionLog(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    amount: float
    date: str  # Format lisible "HH:MM:SS"


# --- BASE DE DONNÉES SIMULÉE (RAM) ---

# Soldes initiaux
users_db = {
    1: {"name": "Utilisateur 1", "balance": 5000.0},
    2: {"name": "Utilisateur 2", "balance": 1500.0}
}

# Historique des transactions (liste vide au départ)
transactions_history = []
transaction_counter = 1


# --- ROUTES API ---

@app.get("/")
def read_root():
    return {"message": "Serveur BKN Transfert Actif !"}

# 1. Obtenir le solde d'un utilisateur
@app.get("/api/balance/{user_id}")
def get_balance(user_id: int):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return {"user_id": user_id, "balance": users_db[user_id]["balance"]}

# 2. Effectuer un virement
@app.post("/api/transfer", response_model=TransferResponse)
def transfer_money(request: TransferRequest):
    global transaction_counter
    
    sender_id = request.sender_id
    amount = request.amount

    # Logique simplifiée : Déduire automatiquement le destinataire
    if sender_id == 1:
        receiver_id = 2
    elif sender_id == 2:
        receiver_id = 1
    else:
        raise HTTPException(status_code=400, detail="ID expéditeur invalide (1 ou 2 uniquement)")

    # Vérifications de sécurité
    if amount <= 0:
        return TransferResponse(
            success=False, montant_total=0, montant_transfere=0, nouveau_solde=0, 
            message="Le montant doit être positif."
        )

    sender = users_db[sender_id]
    receiver = users_db[receiver_id]

    if sender["balance"] < amount:
        return TransferResponse(
            success=False, 
            montant_total=sender["balance"], 
            montant_transfere=0, 
            nouveau_solde=sender["balance"], 
            message=f"Solde insuffisant ! (Dispo: {sender['balance']}€)"
        )

    # --- EXÉCUTION DU TRANSFERT ---
    solde_avant = sender["balance"]
    
    sender["balance"] -= amount   # On enlève à l'expéditeur
    receiver["balance"] += amount # On ajoute au destinataire

    # Enregistrement dans l'historique
    now = datetime.now().strftime("%d/%m/%Y %H:%M")
    new_transaction = {
        "id": transaction_counter,
        "sender_id": sender_id,
        "receiver_id": receiver_id,
        "amount": amount,
        "date": now
    }
    transactions_history.insert(0, new_transaction) # Ajouter en haut de la liste (le plus récent)
    transaction_counter += 1

    return TransferResponse(
        success=True,
        montant_total=solde_avant,
        montant_transfere=amount,
        nouveau_solde=sender["balance"],
        message="Transfert réussi !"
    )

# 3. Récupérer l'historique
@app.get("/api/history")
def get_history():
    return transactions_history

# 4. Réinitialiser la base de données (Reset)
@app.post("/api/reset")
def reset_db():
    global users_db, transactions_history, transaction_counter
    # Remettre à zéro
    users_db = {
        1: {"name": "Utilisateur 1", "balance": 5000.0},
        2: {"name": "Utilisateur 2", "balance": 1500.0}
    }
    transactions_history = []
    transaction_counter = 1
    return {"message": "Base de données réinitialisée"}

# --- LANCEMENT DU SERVEUR ---
if __name__ == "__main__":
    # Pour lancer : python server.py
    # L'option reload=True permet de redémarrer auto quand on modifie le code
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
