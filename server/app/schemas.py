from pydantic import BaseModel, Field
from typing import List
from datetime import datetime

class RegisterRequest(BaseModel):
    email: str = Field(min_length=3, max_length=320)
    password: str = Field(min_length=6, max_length=128)

class LoginRequest(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserMe(BaseModel):
    id: int
    email: str
    cash_usd: float

class HoldingOut(BaseModel):
    coin_id: str
    amount: float
    price_usd: float
    value_usd: float

class WalletOut(BaseModel):
    cash_usd: float
    holdings: List[HoldingOut]
    total_usd: float

class BuyRequest(BaseModel):
    coin_id: str
    usd_amount: float = Field(gt=0)

class SellRequest(BaseModel):
    coin_id: str
    coin_amount: float = Field(gt=0)

class TradeResponse(BaseModel):
    success: bool
    message: str
    cash_usd: float
    coin_id: str
    coin_amount: float
    price_usd: float
    fee_usd: float
    total_usd: float

class TxOut(BaseModel):
    id: int
    side: str
    coin_id: str
    price_usd: float
    usd_amount: float
    coin_amount: float
    fee_usd: float
    created_at: datetime
