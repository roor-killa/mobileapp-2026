from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from database import Base

class TransactionType(enum.Enum):
    debit = "debit"
    credit = "credit"
    transfer = "transfer"

class TransactionStatus(enum.Enum):
    pending = "pending"
    completed = "completed"
    failed = "failed"

class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    wallet_id = Column(Integer, ForeignKey("wallets.id", ondelete="CASCADE"), nullable=False)
    type = Column(Enum(TransactionType), nullable=False)
    montant = Column(Numeric(12, 2), nullable=False)
    solde_avant = Column(Numeric(12, 2), nullable=False)
    solde_apres = Column(Numeric(12, 2), nullable=False)
    description = Column(String(255), nullable=True)
    reference = Column(String(255), unique=True, nullable=False)
    statut = Column(Enum(TransactionStatus), default=TransactionStatus.completed)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    wallet = relationship("Wallet", back_populates="transactions")