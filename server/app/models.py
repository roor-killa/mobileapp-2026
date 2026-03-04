from sqlalchemy import Column, Integer, String, DateTime, Numeric, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from .db import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String(320), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    cash_usd = Column(Numeric(18, 8), nullable=False, default=10000)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    holdings = relationship("Holding", back_populates="user", cascade="all, delete-orphan")
    txs = relationship("Transaction", back_populates="user", cascade="all, delete-orphan")

class Holding(Base):
    __tablename__ = "holdings"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    coin_id = Column(String(64), index=True, nullable=False)
    amount = Column(Numeric(28, 12), nullable=False, default=0)

    user = relationship("User", back_populates="holdings")

class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)

    side = Column(String(4), nullable=False)  # BUY / SELL
    coin_id = Column(String(64), nullable=False)

    price_usd = Column(Numeric(18, 8), nullable=False)
    usd_amount = Column(Numeric(18, 8), nullable=False)     # montant USD côté utilisateur
    coin_amount = Column(Numeric(28, 12), nullable=False)   # quantité coin

    fee_usd = Column(Numeric(18, 8), nullable=False, default=0)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="txs")
