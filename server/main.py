# -*- coding: utf-8 -*-
from __future__ import annotations

import asyncio
import time
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_DOWN
from typing import List, Dict, Any, Optional

import httpx
import numpy as np
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import jwt
from passlib.context import CryptContext
from pydantic import BaseModel, Field
from sklearn.linear_model import Ridge
from sqlalchemy import (
    create_engine, Column, Integer, String, DateTime, Numeric, ForeignKey, func
)
from sqlalchemy.orm import sessionmaker, declarative_base, relationship, Session


# =========================
# CONFIG
# =========================
DATABASE_URL = "sqlite:///./wallet.db"
COINGECKO = "https://api.coingecko.com/api/v3"

# ⚠️ DEV ONLY
SECRET_KEY = "dev-secret-change-me-please"
ALGORITHM = "HS256"
TOKEN_EXPIRE_MINUTES = 60 * 24

FEE_RATE = Decimal("0.002")  # 0.2% frais (démo)

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

# ✅ pbkdf2_sha256 => pas de souci bcrypt
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
bearer = HTTPBearer()


# =========================
# DB MODELS
# =========================
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String(320), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    holdings = relationship("Holding", back_populates="user", cascade="all, delete-orphan")
    txs = relationship("TradeTx", back_populates="user", cascade="all, delete-orphan")
    bank_entries = relationship("BankEntry", back_populates="user", cascade="all, delete-orphan")


class Holding(Base):
    __tablename__ = "holdings"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    coin_id = Column(String(64), index=True, nullable=False)
    amount = Column(Numeric(28, 12), nullable=False, default=Decimal("0"))

    user = relationship("User", back_populates="holdings")


class TradeTx(Base):
    """
    Historique des trades (BUY/SELL) côté investissement.
    (Séparé du ledger bancaire, mais lié via bank_entries.ref si tu veux.)
    """
    __tablename__ = "trade_transactions"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)

    side = Column(String(4), nullable=False)  # BUY / SELL
    coin_id = Column(String(64), nullable=False)

    price_usd = Column(Numeric(18, 8), nullable=False)
    usd_amount = Column(Numeric(18, 8), nullable=False)     # montant USD (gross pour sell)
    coin_amount = Column(Numeric(28, 12), nullable=False)   # quantité coin

    fee_usd = Column(Numeric(18, 8), nullable=False, default=Decimal("0"))
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="txs")


class BankEntry(Base):
    """
    Ledger bancaire (fiat) : on stocke des montants SIGNÉS.
    - credit => amount_usd > 0
    - debit  => amount_usd < 0
    """
    __tablename__ = "bank_entries"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)

    kind = Column(String(32), nullable=False)  # INIT, DEPOSIT, WITHDRAW, TRANSFER_IN, TRANSFER_OUT, BUY, SELL, FEE
    amount_usd = Column(Numeric(18, 8), nullable=False)      # signé
    note = Column(String(255), nullable=True)
    ref = Column(String(64), nullable=True)                  # ex: transfer_id
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="bank_entries")


# =========================
# Pydantic Schemas
# =========================
class RegisterRequest(BaseModel):
    email: str = Field(min_length=3, max_length=320)
    password: str = Field(min_length=6, max_length=72)


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


# ---- BANK (NOUVEAU) ----
class BankBalanceOut(BaseModel):
    balance_usd: float
    updated_at: datetime


class BankEntryOut(BaseModel):
    id: int
    kind: str
    amount_usd: float
    note: Optional[str] = None
    ref: Optional[str] = None
    created_at: datetime


class BankDepositRequest(BaseModel):
    usd_amount: float = Field(gt=0)
    note: Optional[str] = None


class BankWithdrawRequest(BaseModel):
    usd_amount: float = Field(gt=0)
    note: Optional[str] = None


class BankTransferRequest(BaseModel):
    to_email: str = Field(min_length=3, max_length=320)
    usd_amount: float = Field(gt=0)
    note: Optional[str] = None


class BankTransferResponse(BaseModel):
    success: bool
    message: str
    from_balance_usd: float
    to_email: str
    amount_usd: float
    transfer_ref: str


# =========================
# FastAPI App
# =========================
app = FastAPI(title="Wallet Démo API", version="1.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def _startup():
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health():
    return {"ok": True}


# =========================
# DB / AUTH Utils
# =========================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def hash_password(p: str) -> str:
    return pwd_context.hash(p)


def verify_password(p: str, h: str) -> bool:
    return pwd_context.verify(p, h)


def create_access_token(user_id: int) -> str:
    now = datetime.now(timezone.utc)
    exp = now + timedelta(minutes=TOKEN_EXPIRE_MINUTES)
    payload = {"sub": str(user_id), "iat": int(now.timestamp()), "exp": exp}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def get_current_user(
    cred: HTTPAuthorizationCredentials = Depends(bearer),
    db: Session = Depends(get_db),
) -> User:
    token = cred.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        sub = payload.get("sub")
        if not sub:
            raise Exception("missing sub")
        user_id = int(sub)
    except Exception:
        raise HTTPException(status_code=401, detail="Token invalide")

    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=401, detail="Utilisateur introuvable")
    return user


def _d(x: float) -> Decimal:
    return Decimal(str(x))


def _q8(x: Decimal) -> Decimal:
    return x.quantize(Decimal("0.00000001"), rounding=ROUND_DOWN)


# =========================
# BANK LEDGER (NOUVEAU)
# =========================
def bank_balance(db: Session, user_id: int) -> Decimal:
    s = db.query(func.coalesce(func.sum(BankEntry.amount_usd), 0)).filter(BankEntry.user_id == user_id).scalar()
    return _q8(Decimal(s))


def add_bank_entry(
    db: Session,
    user_id: int,
    kind: str,
    amount_signed: Decimal,
    note: Optional[str] = None,
    ref: Optional[str] = None,
) -> BankEntry:
    e = BankEntry(
        user_id=user_id,
        kind=kind,
        amount_usd=_q8(amount_signed),
        note=note,
        ref=ref,
    )
    db.add(e)
    return e


@app.get("/bank/balance", response_model=BankBalanceOut)
def bank_get_balance(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    bal = bank_balance(db, user.id)
    return BankBalanceOut(balance_usd=float(bal), updated_at=datetime.utcnow())


@app.get("/bank/transactions", response_model=List[BankEntryOut])
def bank_transactions(
    limit: int = 50,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    limit = max(1, min(limit, 200))
    rows = (
        db.query(BankEntry)
        .filter(BankEntry.user_id == user.id)
        .order_by(BankEntry.created_at.desc())
        .limit(limit)
        .all()
    )
    return [
        BankEntryOut(
            id=r.id,
            kind=r.kind,
            amount_usd=float(r.amount_usd),
            note=r.note,
            ref=r.ref,
            created_at=r.created_at,
        )
        for r in rows
    ]


@app.post("/bank/deposit", response_model=BankBalanceOut)
def bank_deposit(
    payload: BankDepositRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    amt = _d(payload.usd_amount)
    if amt <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")

    add_bank_entry(db, user.id, "DEPOSIT", amt, note=payload.note)
    db.commit()

    bal = bank_balance(db, user.id)
    return BankBalanceOut(balance_usd=float(bal), updated_at=datetime.utcnow())


@app.post("/bank/withdraw", response_model=BankBalanceOut)
def bank_withdraw(
    payload: BankWithdrawRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    amt = _d(payload.usd_amount)
    if amt <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")

    bal = bank_balance(db, user.id)
    if bal < amt:
        raise HTTPException(status_code=400, detail="Solde insuffisant")

    add_bank_entry(db, user.id, "WITHDRAW", -amt, note=payload.note)
    db.commit()

    bal2 = bank_balance(db, user.id)
    return BankBalanceOut(balance_usd=float(bal2), updated_at=datetime.utcnow())


@app.post("/bank/transfer", response_model=BankTransferResponse)
def bank_transfer(
    payload: BankTransferRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    to_email = payload.to_email.strip().lower()
    if to_email == user.email:
        raise HTTPException(status_code=400, detail="Impossible de se transférer à soi-même")

    amt = _d(payload.usd_amount)
    if amt <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")

    receiver = db.query(User).filter(User.email == to_email).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Destinataire introuvable")

    bal = bank_balance(db, user.id)
    if bal < amt:
        raise HTTPException(status_code=400, detail="Solde insuffisant")

    transfer_ref = f"tr_{int(time.time())}_{user.id}_{receiver.id}"

    # Atomicité: on écrit les 2 entrées puis commit
    add_bank_entry(db, user.id, "TRANSFER_OUT", -amt, note=payload.note, ref=transfer_ref)
    add_bank_entry(db, receiver.id, "TRANSFER_IN", amt, note=payload.note, ref=transfer_ref)
    db.commit()

    bal2 = bank_balance(db, user.id)
    return BankTransferResponse(
        success=True,
        message="Virement effectué",
        from_balance_usd=float(bal2),
        to_email=receiver.email,
        amount_usd=float(_q8(amt)),
        transfer_ref=transfer_ref,
    )


# =========================
# MARKET (CoinGecko) + CACHE + 429 SAFE
# =========================
_PRICE_TTL_SEC = 30  # ✅ plus long pour éviter spam
_price_cache: Dict[str, Dict[str, Any]] = {}  # { coin_id: {"ts": float, "price": float} }
_price_lock = asyncio.Lock()


async def _get_prices_usd(coin_ids: List[str]) -> Dict[str, float]:
    if not coin_ids:
        return {}
    url = f"{COINGECKO}/simple/price"
    async with httpx.AsyncClient(timeout=25) as client:
        r = await client.get(url, params={"ids": ",".join(coin_ids), "vs_currencies": "usd"})
        # ✅ gestion rate limit
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit marché (CoinGecko). Réessaie dans 20-30s.")
        if r.status_code != 200:
            raise HTTPException(status_code=502, detail=f"Erreur marché: {r.status_code}")
        data = r.json()

    out: Dict[str, float] = {}
    for cid in coin_ids:
        out[cid] = float((data.get(cid) or {}).get("usd") or 0.0)
    return out


async def _get_prices_cached(coin_ids: List[str]) -> Dict[str, float]:
    now = time.time()
    fresh: Dict[str, float] = {}
    missing: List[str] = []

    async with _price_lock:
        for cid in coin_ids:
            entry = _price_cache.get(cid)
            if entry and (now - float(entry["ts"])) < _PRICE_TTL_SEC:
                fresh[cid] = float(entry["price"])
            else:
                missing.append(cid)

    if missing:
        try:
            fetched = await _get_prices_usd(missing)
        except HTTPException as e:
            # ✅ si rate limit, on renvoie au moins le cache existant (stale)
            if e.status_code == 503:
                async with _price_lock:
                    for cid in missing:
                        entry = _price_cache.get(cid)
                        if entry:
                            fresh[cid] = float(entry["price"])
                        else:
                            fresh[cid] = 0.0
                return fresh
            raise

        async with _price_lock:
            for cid, p in fetched.items():
                _price_cache[cid] = {"ts": now, "price": float(p)}
                fresh[cid] = float(p)

    return fresh


@app.get("/prices")
async def prices(ids: str):
    coin_ids = [x.strip().lower() for x in ids.split(",") if x.strip()]
    if not coin_ids:
        raise HTTPException(status_code=400, detail="ids requis")
    data = await _get_prices_cached(coin_ids)
    return {"ts": time.time(), "prices": data}


@app.get("/price/{coin_id}")
async def price_one(coin_id: str):
    cid = coin_id.strip().lower()
    data = await _get_prices_cached([cid])
    p = float(data.get(cid, 0.0))
    if p <= 0:
        raise HTTPException(status_code=404, detail="coin_id invalide")
    return {"ts": time.time(), "coin_id": cid, "price_usd": p}


@app.get("/search")
async def search(query: str):
    url = f"{COINGECKO}/search"
    async with httpx.AsyncClient(timeout=25) as client:
        r = await client.get(url, params={"query": query})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit marché (CoinGecko). Réessaie dans 20-30s.")
        if r.status_code != 200:
            raise HTTPException(status_code=502, detail=f"Erreur marché: {r.status_code}")
        data = r.json()

    coins = []
    for c in data.get("coins", []):
        coins.append({
            "id": c.get("id"),
            "name": c.get("name"),
            "symbol": c.get("symbol"),
            "thumb": c.get("thumb"),
            "market_cap_rank": c.get("market_cap_rank"),
        })
    return {"query": query, "coins": coins[:12]}


@app.get("/history/{coin_id}")
async def history(coin_id: str, days: int = 90):
    url = f"{COINGECKO}/coins/{coin_id}/market_chart"
    async with httpx.AsyncClient(timeout=30) as client:
        r = await client.get(url, params={"vs_currency": "usd", "days": days})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit marché (CoinGecko). Réessaie dans 20-30s.")
        if r.status_code != 200:
            raise HTTPException(status_code=404, detail="coin_id invalide")
        data = r.json()
    return {"coin_id": coin_id, "prices": data.get("prices", [])}


@app.get("/predict/{coin_id}")
async def predict(coin_id: str, horizon: int = 7):
    url = f"{COINGECKO}/coins/{coin_id}/market_chart"
    async with httpx.AsyncClient(timeout=35) as client:
        r = await client.get(url, params={"vs_currency": "usd", "days": 365})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit marché (CoinGecko). Réessaie dans 20-30s.")
        if r.status_code != 200:
            raise HTTPException(status_code=404, detail="coin_id invalide")
        data = r.json()

    prices = data.get("prices", [])
    if len(prices) < 60:
        raise HTTPException(status_code=400, detail="Pas assez de données")

    series = np.array([float(p[1]) for p in prices], dtype=np.float64)

    L = 12
    if len(series) <= L + 20:
        raise HTTPException(status_code=400, detail="Série trop courte")

    X, y = [], []
    for i in range(L, len(series)):
        X.append(series[i - L:i])
        y.append(series[i])

    X = np.array(X, dtype=np.float64)
    y = np.array(y, dtype=np.float64)

    split = int(len(X) * 0.8)
    Xtr, Xte = X[:split], X[split:]
    ytr, yte = y[:split], y[split:]

    model = Ridge(alpha=1.0)
    model.fit(Xtr, ytr)

    pred_te = model.predict(Xte) if len(Xte) else np.array([])
    mae = float(np.mean(np.abs(pred_te - yte))) if len(yte) else None

    window = series[-L:].copy()
    preds: List[float] = []
    for _ in range(int(horizon)):
        next_price = float(model.predict(window.reshape(1, -1))[0])
        preds.append(next_price)
        window = np.roll(window, -1)
        window[-1] = next_price

    return {
        "success": True,
        "coin_id": coin_id,
        "horizon": int(horizon),
        "current_price": float(series[-1]),
        "predicted_prices": preds,
        "model": f"Ridge(lags={L})",
        "mae": mae,
        "message": "Prédiction ML (démo)",
    }


# =========================
# AUTH
# =========================
@app.post("/auth/register", response_model=UserMe)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    email = payload.email.strip().lower()
    exists = db.query(User).filter(User.email == email).first()
    if exists:
        raise HTTPException(status_code=409, detail="Email déjà utilisé")

    user = User(email=email, password_hash=hash_password(payload.password))
    db.add(user)
    db.commit()
    db.refresh(user)

    # ✅ solde de départ (banque)
    add_bank_entry(db, user.id, "INIT", Decimal("10000.00"), note="Solde initial (démo)")
    db.commit()

    bal = bank_balance(db, user.id)
    return UserMe(id=user.id, email=user.email, cash_usd=float(bal))


@app.post("/auth/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    email = payload.email.strip().lower()
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Identifiants invalides")

    token = create_access_token(user.id)
    return TokenResponse(access_token=token)


@app.get("/me", response_model=UserMe)
def me(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    bal = bank_balance(db, user.id)
    return UserMe(id=user.id, email=user.email, cash_usd=float(bal))


# =========================
# WALLET (portefeuille investissement)
# =========================
@app.get("/wallet", response_model=WalletOut)
async def wallet(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    holdings = db.query(Holding).filter(Holding.user_id == user.id).all()
    coin_ids = [h.coin_id for h in holdings if Decimal(h.amount) > 0]
    prices = await _get_prices_cached(list(set(coin_ids)))

    out_holdings: List[HoldingOut] = []
    total_holdings = Decimal("0")

    for h in holdings:
        amount = Decimal(h.amount)
        if amount <= 0:
            continue
        p = Decimal(str(prices.get(h.coin_id, 0.0)))
        val = amount * p
        total_holdings += val
        out_holdings.append(HoldingOut(
            coin_id=h.coin_id,
            amount=float(amount),
            price_usd=float(p),
            value_usd=float(val),
        ))

    cash = bank_balance(db, user.id)
    total = cash + total_holdings
    return WalletOut(
        cash_usd=float(cash),
        holdings=out_holdings,
        total_usd=float(total),
    )


# =========================
# TRADING (paper) - utilise le cash bancaire
# =========================
@app.post("/trade/buy", response_model=TradeResponse)
async def buy(
    payload: BuyRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    coin_id = payload.coin_id.strip().lower()
    usd_amount = _d(payload.usd_amount)

    prices = await _get_prices_cached([coin_id])
    price = Decimal(str(prices.get(coin_id, 0.0)))
    if price <= 0:
        raise HTTPException(status_code=404, detail="coin_id invalide (prix introuvable)")

    bal = bank_balance(db, user.id)
    if bal < usd_amount:
        raise HTTPException(status_code=400, detail="Solde USD insuffisant")

    fee = _q8(usd_amount * FEE_RATE)
    net = usd_amount - fee
    coin_amount = _q8(net / price)

    # debit banque
    add_bank_entry(db, user.id, "BUY", -usd_amount, note=f"Achat {coin_id}")

    # update holding
    holding = db.query(Holding).filter(
        Holding.user_id == user.id,
        Holding.coin_id == coin_id
    ).first()
    if not holding:
        holding = Holding(user_id=user.id, coin_id=coin_id, amount=Decimal("0"))
        db.add(holding)
    holding.amount = _q8(Decimal(holding.amount) + coin_amount)

    tx = TradeTx(
        user_id=user.id,
        side="BUY",
        coin_id=coin_id,
        price_usd=_q8(price),
        usd_amount=_q8(usd_amount),
        coin_amount=_q8(coin_amount),
        fee_usd=_q8(fee),
    )
    db.add(tx)
    db.commit()

    w = await wallet(user=user, db=db)
    return TradeResponse(
        success=True,
        message="Achat effectué (démo)",
        cash_usd=w.cash_usd,
        coin_id=coin_id,
        coin_amount=float(coin_amount),
        price_usd=float(price),
        fee_usd=float(fee),
        total_usd=w.total_usd,
    )


@app.post("/trade/sell", response_model=TradeResponse)
async def sell(
    payload: SellRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    coin_id = payload.coin_id.strip().lower()
    coin_amount = _d(payload.coin_amount)

    holding = db.query(Holding).filter(
        Holding.user_id == user.id,
        Holding.coin_id == coin_id
    ).first()
    if not holding or Decimal(holding.amount) < coin_amount:
        raise HTTPException(status_code=400, detail="Solde crypto insuffisant")

    prices = await _get_prices_cached([coin_id])
    price = Decimal(str(prices.get(coin_id, 0.0)))
    if price <= 0:
        raise HTTPException(status_code=404, detail="coin_id invalide (prix introuvable)")

    gross = _q8(coin_amount * price)
    fee = _q8(gross * FEE_RATE)
    net = gross - fee

    holding.amount = _q8(Decimal(holding.amount) - coin_amount)

    # credit banque
    add_bank_entry(db, user.id, "SELL", net, note=f"Vente {coin_id}")

    tx = TradeTx(
        user_id=user.id,
        side="SELL",
        coin_id=coin_id,
        price_usd=_q8(price),
        usd_amount=_q8(gross),
        coin_amount=_q8(coin_amount),
        fee_usd=_q8(fee),
    )
    db.add(tx)
    db.commit()

    w = await wallet(user=user, db=db)
    return TradeResponse(
        success=True,
        message="Vente effectuée (démo)",
        cash_usd=w.cash_usd,
        coin_id=coin_id,
        coin_amount=float(coin_amount),
        price_usd=float(price),
        fee_usd=float(fee),
        total_usd=w.total_usd,
    )


@app.get("/transactions", response_model=List[TxOut])
def transactions(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    txs = (
        db.query(TradeTx)
        .filter(TradeTx.user_id == user.id)
        .order_by(TradeTx.created_at.desc())
        .limit(50)
        .all()
    )
    return [
        TxOut(
            id=t.id,
            side=t.side,
            coin_id=t.coin_id,
            price_usd=float(t.price_usd),
            usd_amount=float(t.usd_amount),
            coin_amount=float(t.coin_amount),
            fee_usd=float(t.fee_usd),
            created_at=t.created_at,
        )
        for t in txs
    ]