from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from decimal import Decimal
import uuid
import time

from database import get_db
from models import User, Wallet, Transaction, TransactionType, TransactionStatus

router = APIRouter(prefix="/api/v1", tags=["Transfers"])

# Schémas Pydantic pour validation
class TransferRequest(BaseModel):
    user_id: int
    montant: float
    description: Optional[str] = None

class CreditRequest(BaseModel):
    user_id: int
    montant: float
    description: Optional[str] = None

class TransferResponse(BaseModel):
    success: bool
    montant_total: float
    montant_transfere: float
    nouveau_solde: float
    message: str
    transaction_id: Optional[int] = None
    reference: Optional[str] = None

class SoldeResponse(BaseModel):
    success: bool
    solde: float
    devise: str

# Endpoint: Récupérer le solde
@router.get("/solde/{user_id}", response_model=SoldeResponse)
def get_solde(user_id: int, db: Session = Depends(get_db)):
    """Récupère le solde actuel d'un utilisateur"""
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        wallet = user.wallet
        if not wallet:
            raise HTTPException(status_code=404, detail="Wallet non trouvé")
        
        return SoldeResponse(
            success=True,
            solde=float(wallet.solde),
            devise=wallet.devise
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur serveur: {str(e)}")

# Endpoint: Effectuer un transfert (débit)
@router.post("/transfer", response_model=TransferResponse)
def transfer(request: TransferRequest, db: Session = Depends(get_db)):
    """Effectue un transfert (débit du wallet)"""
    try:
        # Récupérer l'utilisateur et son wallet
        user = db.query(User).filter(User.id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        wallet = user.wallet
        if not wallet or not wallet.is_active:
            raise HTTPException(status_code=404, detail="Wallet inactif ou non trouvé")
        
        montant = Decimal(str(request.montant))
        montant_total = wallet.solde
        
        # Vérifier le solde
        if wallet.solde < montant:
            return TransferResponse(
                success=False,
                montant_total=float(montant_total),
                montant_transfere=0.0,
                nouveau_solde=float(montant_total),
                message="Solde insuffisant"
            )
        
        # Effectuer le débit
        solde_avant = wallet.solde
        wallet.solde -= montant
        nouveau_solde = wallet.solde
        
        # Créer la transaction
        reference = f"TXN-{uuid.uuid4().hex.upper()[:8]}-{int(time.time())}"
        transaction = Transaction(
            wallet_id=wallet.id,
            type=TransactionType.debit,
            montant=montant,
            solde_avant=solde_avant,
            solde_apres=nouveau_solde,
            description=request.description or "Transfert mobile",
            reference=reference,
            statut=TransactionStatus.completed
        )
        
        db.add(transaction)
        db.commit()
        db.refresh(transaction)
        db.refresh(wallet)
        
        return TransferResponse(
            success=True,
            montant_total=float(montant_total),
            montant_transfere=float(montant),
            nouveau_solde=float(nouveau_solde),
            message="Transfert effectué avec succès",
            transaction_id=transaction.id,
            reference=transaction.reference
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Erreur lors du transfert: {str(e)}")

# Endpoint: Créditer un wallet
@router.post("/credit")
def credit(request: CreditRequest, db: Session = Depends(get_db)):
    """Crédite un wallet (pour tests/admin)"""
    try:
        user = db.query(User).filter(User.id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        wallet = user.wallet
        if not wallet:
            raise HTTPException(status_code=404, detail="Wallet non trouvé")
        
        montant = Decimal(str(request.montant))
        solde_avant = wallet.solde
        wallet.solde += montant
        
        # Créer la transaction
        reference = f"TXN-{uuid.uuid4().hex.upper()[:8]}-{int(time.time())}"
        transaction = Transaction(
            wallet_id=wallet.id,
            type=TransactionType.credit,
            montant=montant,
            solde_avant=solde_avant,
            solde_apres=wallet.solde,
            description=request.description or "Crédit manuel",
            reference=reference,
            statut=TransactionStatus.completed
        )
        
        db.add(transaction)
        db.commit()
        db.refresh(wallet)
        
        return {
            "success": True,
            "nouveau_solde": float(wallet.solde),
            "message": "Crédit effectué avec succès",
            "transaction_id": transaction.id
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Erreur lors du crédit: {str(e)}")

# Endpoint: Historique des transactions
@router.get("/transactions/{user_id}")
def get_transactions(user_id: int, limit: int = 20, db: Session = Depends(get_db)):
    """Récupère l'historique des transactions"""
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        wallet = user.wallet
        if not wallet:
            raise HTTPException(status_code=404, detail="Wallet non trouvé")
        
        transactions = db.query(Transaction).filter(
            Transaction.wallet_id == wallet.id
        ).order_by(Transaction.created_at.desc()).limit(limit).all()
        
        return {
            "success": True,
            "transactions": [
                {
                    "id": t.id,
                    "type": t.type.value,
                    "montant": float(t.montant),
                    "solde_avant": float(t.solde_avant),
                    "solde_apres": float(t.solde_apres),
                    "description": t.description,
                    "reference": t.reference,
                    "statut": t.statut.value,
                    "created_at": t.created_at.isoformat()
                }
                for t in transactions
            ],
            "total": len(transactions)
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur: {str(e)}")