from __future__ import annotations

import asyncio
import time
import threading
import secrets
import hashlib
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_DOWN
from typing import Any, Dict, List

import httpx
import numpy as np
from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import jwt
from passlib.context import CryptContext
from pydantic import AliasChoices, BaseModel, Field
from sklearn.linear_model import Ridge
from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String, create_engine, func, or_
from sqlalchemy.orm import Session, declarative_base, relationship, sessionmaker

# =========================
# CONFIG
# =========================
DATABASE_URL = "sqlite:///./wallet.db"
COINGECKO = "https://api.coingecko.com/api/v3"

# ⚠️ DEV ONLY
SECRET_KEY = "dev-secret-change-me-please"
ALGORITHM = "HS256"
TOKEN_EXPIRE_MINUTES = 60 * 24

# Refresh token (démo)
REFRESH_EXPIRE_DAYS = 30

# Validations banque (démo)
MIN_TRANSFER_USD = Decimal("1.00")
MAX_TRANSFER_USD = Decimal("50000.00")

FEE_RATE = Decimal("0.002")  # 0.2% frais (démo)

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
bearer = HTTPBearer()

# =========================
# FastAPI APP
# =========================
app = FastAPI(title="Wallet Démo API", version="1.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# DB MODELS
# =========================
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String(320), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)

    first_name = Column(String(80), nullable=False, default="")
    last_name = Column(String(80), nullable=False, default="")
    phone = Column(String(32), nullable=False, default="")

    cash_usd = Column(Numeric(18, 8), nullable=False, default=Decimal("10000.00"))
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    # Refresh token (hashé) pour renouveler l'access_token (démo)
    refresh_token_hash = Column(String(128), nullable=True)
    refresh_expires_at = Column(DateTime, nullable=True)

    holdings = relationship("Holding", back_populates="user", cascade="all, delete-orphan")
    txs = relationship("Transaction", back_populates="user", cascade="all, delete-orphan")
    bank_txs = relationship("BankTx", back_populates="user", cascade="all, delete-orphan")

    beneficiaries = relationship(
        "Beneficiary",
        back_populates="owner",
        cascade="all, delete-orphan",
        foreign_keys="Beneficiary.owner_user_id",
    )


class Holding(Base):
    __tablename__ = "holdings"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    coin_id = Column(String(64), index=True, nullable=False)
    amount = Column(Numeric(28, 12), nullable=False, default=Decimal("0"))

    user = relationship("User", back_populates="holdings")


class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)

    side = Column(String(8), nullable=False)  # BUY / SELL
    coin_id = Column(String(64), nullable=False)

    price_usd = Column(Numeric(18, 8), nullable=False)
    usd_amount = Column(Numeric(18, 8), nullable=False)
    coin_amount = Column(Numeric(28, 12), nullable=False)

    fee_usd = Column(Numeric(18, 8), nullable=False, default=Decimal("0"))
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="txs")


class BankTx(Base):
    __tablename__ = "bank_txs"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)

    kind = Column(String(20), nullable=False)  # INIT / TRANSFER_OUT / TRANSFER_IN
    amount_usd = Column(Numeric(18, 8), nullable=False)
    note = Column(String(255), nullable=False, default="")
    ref = Column(String(64), nullable=False, default="")

    counterparty_email = Column(String(320), nullable=True, default=None)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    user = relationship("User", back_populates="bank_txs")



class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)

    coin_id = Column(String(64), index=True, nullable=False)
    side = Column(String(4), nullable=False)  # BUY / SELL
    order_type = Column(String(16), nullable=False)  # LIMIT / STOP_LOSS / TAKE_PROFIT
    qty = Column(Numeric(18, 8), nullable=False)

    limit_price = Column(Numeric(18, 8), nullable=True)
    trigger_price = Column(Numeric(18, 8), nullable=True)

    status = Column(String(12), nullable=False, default="OPEN")  # OPEN / FILLED / CANCELED / REJECTED
    reason = Column(String(255), nullable=False, default="")

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    filled_at = Column(DateTime, nullable=True)
    filled_price = Column(Numeric(18, 8), nullable=True)


class Beneficiary(Base):
    __tablename__ = "beneficiaries"
    id = Column(Integer, primary_key=True)
    owner_user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    beneficiary_user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    alias = Column(String(80), nullable=False, default="")
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    owner = relationship("User", foreign_keys=[owner_user_id], back_populates="beneficiaries")
    beneficiary_user = relationship("User", foreign_keys=[beneficiary_user_id])


# =========================
# Schemas
# =========================
class RegisterRequest(BaseModel):
    email: str = Field(min_length=3, max_length=320)
    password: str = Field(min_length=6, max_length=72)
    first_name: str = Field(default="", max_length=80)
    last_name: str = Field(default="", max_length=80)
    phone: str = Field(default="", max_length=32)


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str | None = None
    expires_in: int = TOKEN_EXPIRE_MINUTES * 60
    token_type: str = "bearer"


class UserMe(BaseModel):
    id: int
    email: str
    cash_usd: float
    first_name: str
    last_name: str
    phone: str


class ChangePasswordRequest(BaseModel):
    old_password: str = Field(min_length=6, max_length=72)
    new_password: str = Field(min_length=6, max_length=72)


class HoldingOut(BaseModel):
    coin_id: str
    amount: float
    price_usd: float
    value_usd: float

    # Coût d'acquisition estimé (méthode du coût moyen pondéré) pour la quantité détenue
    cost_basis_usd: float = 0.0
    avg_cost_usd: float = 0.0

    # PnL latent (valeur - coût)
    pnl_usd: float = 0.0
    pnl_pct: float = 0.0


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

class OrderCreate(BaseModel):
    coin_id: str
    side: str  # BUY | SELL
    order_type: str  # LIMIT | STOP_LOSS | TAKE_PROFIT
    qty: float
    limit_price: float | None = None
    trigger_price: float | None = None


class OrderOut(BaseModel):
    id: int
    coin_id: str
    side: str
    order_type: str
    qty: float
    limit_price: float | None
    trigger_price: float | None
    status: str
    reason: str
    created_at: datetime
    filled_at: datetime | None
    filled_price: float | None



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


class BankBalanceOut(BaseModel):
    balance_usd: float
    updated_at: datetime


class BankTransferRequest(BaseModel):
    to_email: str
    usd_amount: float = Field(gt=0)
    note: str = Field(default="", max_length=255)


class BankTransferOut(BaseModel):
    success: bool
    message: str
    from_balance_usd: float
    to_email: str
    amount_usd: float
    transfer_ref: str


class BankTxOut(BaseModel):
    id: int
    kind: str
    amount_usd: float
    note: str
    ref: str
    created_at: datetime
    counterparty_email: str | None = None


class UserSuggestion(BaseModel):
    id: int
    email: str
    first_name: str
    last_name: str


class BeneficiaryCreate(BaseModel):
    email: str = Field(
        validation_alias=AliasChoices("email", "to_email"),
        min_length=3,
        max_length=320,
    )
    alias: str = Field(
        default="",
        validation_alias=AliasChoices("alias", "name", "label"),
        max_length=80,
    )


class BeneficiaryOut(BaseModel):
    id: int
    email: str
    first_name: str
    last_name: str
    alias: str
    created_at: datetime


# =========================
# Utils
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



def _hash_refresh(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def _new_refresh_token() -> str:
    # 32 bytes -> 64 hex chars
    return secrets.token_hex(32)

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
# PRICE CACHE
# =========================
_PRICE_TTL_SEC = 15
_price_cache: Dict[str, Dict[str, Any]] = {}
_price_lock = asyncio.Lock()

# Cache prix + variation 24h (CoinGecko)
_market_cache: Dict[str, Dict[str, Any]] = {}
_market_lock = asyncio.Lock()


async def _get_prices_usd(coin_ids: List[str]) -> Dict[str, float]:
    if not coin_ids:
        return {}
    url = f"{COINGECKO}/simple/price"
    async with httpx.AsyncClient(timeout=25) as client:
        r = await client.get(url, params={"ids": ",".join(coin_ids), "vs_currencies": "usd"})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit CoinGecko (réessaie plus tard)")
        r.raise_for_status()
        data = r.json()
    out: Dict[str, float] = {}
    for cid in coin_ids:
        out[cid] = float((data.get(cid) or {}).get("usd") or 0.0)
    return out



async def _get_market_usd(coin_ids: List[str]) -> Dict[str, Dict[str, float]]:
    """Retourne {coin_id: {price_usd, change_24h_pct}} via CoinGecko /simple/price."""
    if not coin_ids:
        return {}

    params = {
        "ids": ",".join(coin_ids),
        "vs_currencies": "usd",
        "include_24hr_change": "true",
    }

    async with httpx.AsyncClient(timeout=12) as client:
        r = await client.get(f"{COINGECKO}/simple/price", params=params)
        r.raise_for_status()
        data = r.json()

    out: Dict[str, Dict[str, float]] = {}
    for cid in coin_ids:
        row = data.get(cid)
        if not isinstance(row, dict):
            continue
        price = float(row.get("usd") or 0.0)
        ch = float(row.get("usd_24h_change") or 0.0)
        if price > 0:
            out[cid] = {"price_usd": price, "change_24h_pct": ch}
    return out


async def _get_market_cached(coin_ids: List[str]) -> Dict[str, Dict[str, float]]:
    now = time.time()
    fresh: Dict[str, Dict[str, float]] = {}
    missing: List[str] = []

    async with _market_lock:
        for cid in coin_ids:
            entry = _market_cache.get(cid)
            if entry and (now - float(entry["ts"])) < _PRICE_TTL_SEC:
                fresh[cid] = {"price_usd": float(entry["price"]), "change_24h_pct": float(entry.get("ch", 0.0))}
            else:
                missing.append(cid)

    if missing:
        fetched = await _get_market_usd(missing)
        async with _market_lock:
            for cid, row in fetched.items():
                _market_cache[cid] = {"ts": now, "price": float(row["price_usd"]), "ch": float(row["change_24h_pct"])}
                fresh[cid] = row

    return fresh



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
        fetched = await _get_prices_usd(missing)
        async with _price_lock:
            for cid, p in fetched.items():
                _price_cache[cid] = {"ts": now, "price": float(p)}
                fresh[cid] = float(p)

    return fresh



# =========================
# ORDER ENGINE (thread) - démo
# =========================
_ORDER_THREAD_STARTED = False
_order_price_cache: Dict[str, Dict[str, Any]] = {}


def _get_prices_usd_sync(coin_ids: List[str]) -> Dict[str, float]:
    if not coin_ids:
        return {}
    now = time.time()
    fresh: Dict[str, float] = {}
    missing: List[str] = []

    # petite cache locale au thread
    for cid in coin_ids:
        e = _order_price_cache.get(cid)
        if e and (now - float(e["ts"])) < _PRICE_TTL_SEC:
            fresh[cid] = float(e["price"])
        else:
            missing.append(cid)

    if missing:
        try:
            params = {"ids": ",".join(missing), "vs_currencies": "usd"}
            r = httpx.get(f"{COINGECKO}/simple/price", params=params, timeout=12)
            r.raise_for_status()
            data = r.json()
            for cid in missing:
                row = data.get(cid)
                if isinstance(row, dict) and row.get("usd"):
                    p = float(row["usd"])
                    if p > 0:
                        _order_price_cache[cid] = {"ts": now, "price": p}
                        fresh[cid] = p
        except Exception:
            pass

    return fresh


def _should_fill(o: "Order", px: Decimal) -> bool:
    if o.order_type == "LIMIT":
        lp = Decimal(o.limit_price) if o.limit_price is not None else Decimal("0")
        if o.side == "BUY":
            return px <= lp
        else:  # SELL
            return px >= lp

    if o.order_type == "STOP_LOSS":
        tp = Decimal(o.trigger_price) if o.trigger_price is not None else Decimal("0")
        # stop-loss typiquement SELL
        if o.side == "SELL":
            return px <= tp
        else:
            # stop-buy
            return px >= tp

    if o.order_type == "TAKE_PROFIT":
        tp = Decimal(o.trigger_price) if o.trigger_price is not None else Decimal("0")
        if o.side == "SELL":
            return px >= tp
        else:
            return px <= tp

    return False


def _fill_order(db: Session, o: "Order", px: Decimal):
    user = db.query(User).filter(User.id == o.user_id).first()
    if not user:
        o.status = "REJECTED"
        o.reason = "User introuvable"
        return

    cid = o.coin_id
    qty = Decimal(o.qty)

    if qty <= 0 or px <= 0:
        o.status = "REJECTED"
        o.reason = "Données invalides"
        return

    if o.side == "BUY":
        usd = qty * px
        fee = usd * FEE_RATE
        total = usd + fee

        cash = Decimal(user.cash_usd)
        if cash < total:
            o.status = "REJECTED"
            o.reason = "Solde insuffisant au moment du fill"
            return

        # update cash
        user.cash_usd = _q8(cash - total)

        # update holding
        h = db.query(Holding).filter(Holding.user_id == user.id, Holding.coin_id == cid).first()
        if not h:
            h = Holding(user_id=user.id, coin_id=cid, amount=Decimal("0"))
            db.add(h)
        h.amount = _q8(Decimal(h.amount) + qty)

        tx = Transaction(
            user_id=user.id,
            coin_id=cid,
            side="BUY",
            usd_amount=_q8(total),
            coin_amount=_q8(qty),
            price_usd=_q8(px),
            fee_usd=_q8(fee),
        )
        db.add(tx)

    else:  # SELL
        h = db.query(Holding).filter(Holding.user_id == user.id, Holding.coin_id == cid).first()
        if not h or Decimal(h.amount) < qty:
            o.status = "REJECTED"
            o.reason = "Quantité insuffisante au moment du fill"
            return

        usd = qty * px
        fee = usd * FEE_RATE
        net = usd - fee

        # update holding
        h.amount = _q8(Decimal(h.amount) - qty)

        # update cash
        user.cash_usd = _q8(Decimal(user.cash_usd) + net)

        tx = Transaction(
            user_id=user.id,
            coin_id=cid,
            side="SELL",
            usd_amount=_q8(usd),
            coin_amount=_q8(qty),
            price_usd=_q8(px),
            fee_usd=_q8(fee),
        )
        db.add(tx)

    o.status = "FILLED"
    o.reason = ""
    o.filled_at = datetime.utcnow()
    o.filled_price = _q8(px)
    db.add(o)
    db.add(user)


def _order_engine_loop():
    while True:
        time.sleep(5)

        db = SessionLocal()
        try:
            open_orders = db.query(Order).filter(Order.status == "OPEN").order_by(Order.created_at.asc()).all()
            if not open_orders:
                continue

            coin_ids = sorted({o.coin_id for o in open_orders})
            prices = _get_prices_usd_sync(coin_ids)

            for o in open_orders:
                p = prices.get(o.coin_id)
                if not p:
                    continue
                px = Decimal(str(p))
                if _should_fill(o, px):
                    _fill_order(db, o, px)

            db.commit()
        except Exception:
            db.rollback()
        finally:
            db.close()


# =========================
# Startup
# =========================
@app.on_event("startup")
def _startup():
    global _ORDER_THREAD_STARTED
    Base.metadata.create_all(bind=engine)
    if not _ORDER_THREAD_STARTED:
        _ORDER_THREAD_STARTED = True
        t = threading.Thread(target=_order_engine_loop, daemon=True)
        t.start()


# =========================
# Health
# =========================
@app.get("/health")
def health():
    return {"ok": True}


# =========================
# Users (autocomplete)
# =========================
@app.get("/users/search", response_model=List[UserSuggestion])
def users_search(
    q: str,
    limit: int = 10,
    me: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = (q or "").strip().lower()
    if len(q) < 2:
        return []

    limit = max(1, min(int(limit), 20))
    pattern = f"%{q}%"

    rows = (
        db.query(User)
        .filter(User.id != me.id)
        .filter(
            or_(
                func.lower(User.email).like(pattern),
                func.lower(User.first_name).like(pattern),
                func.lower(User.last_name).like(pattern),
            )
        )
        .order_by(User.email.asc())
        .limit(limit)
        .all()
    )

    return [UserSuggestion(id=u.id, email=u.email, first_name=u.first_name, last_name=u.last_name) for u in rows]


# =========================
# Prices
# =========================
@app.get("/prices")
async def prices(ids: str):
    coin_ids = [x.strip().lower() for x in ids.split(",") if x.strip()]
    if not coin_ids:
        raise HTTPException(status_code=400, detail="ids requis")
    data = await _get_prices_cached(coin_ids)
    return {"ts": time.time(), "prices": data}

@app.get("/prices/market")
async def prices_market(ids: str):
    """Prix + variation 24h (pour watchlist)."""
    coin_ids = [x.strip().lower() for x in ids.split(",") if x.strip()]
    if not coin_ids:
        raise HTTPException(status_code=400, detail="ids requis")
    data = await _get_market_cached(coin_ids)
    return {"ts": time.time(), "market": data}



@app.get("/price/{coin_id}")
async def price_one(coin_id: str):
    cid = coin_id.strip().lower()
    data = await _get_prices_cached([cid])
    p = float(data.get(cid, 0.0))
    if p <= 0:
        raise HTTPException(status_code=404, detail="coin_id invalide")
    return {"ts": time.time(), "coin_id": cid, "price_usd": p}


# =========================
# AUTH
# =========================
@app.post("/auth/register", response_model=UserMe)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    email = payload.email.strip().lower()
    exists = db.query(User).filter(User.email == email).first()
    if exists:
        raise HTTPException(status_code=409, detail="Email déjà utilisé")

    user = User(
        email=email,
        password_hash=hash_password(payload.password),
        cash_usd=Decimal("10000.00"),
        first_name=(payload.first_name or "").strip(),
        last_name=(payload.last_name or "").strip(),
        phone=(payload.phone or "").strip(),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    init = BankTx(
        user_id=user.id,
        kind="INIT",
        amount_usd=_q8(Decimal("10000.00")),
        note="Solde initial (démo)",
        ref="",
    )
    db.add(init)
    db.commit()

    return UserMe(
        id=user.id,
        email=user.email,
        cash_usd=float(user.cash_usd),
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
    )


@app.post("/auth/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    email = payload.email.strip().lower()
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Identifiants invalides")

    token = create_access_token(user.id)
    refresh = _new_refresh_token()
    user.refresh_token_hash = _hash_refresh(refresh)
    user.refresh_expires_at = datetime.utcnow() + timedelta(days=REFRESH_EXPIRE_DAYS)
    db.add(user)
    db.commit()

    return TokenResponse(access_token=token, refresh_token=refresh)
class RefreshRequest(BaseModel):
    refresh_token: str


@app.post("/auth/refresh", response_model=TokenResponse)
def refresh_token(payload: RefreshRequest, db: Session = Depends(get_db)):
    rt = (payload.refresh_token or "").strip()
    if not rt:
        raise HTTPException(status_code=400, detail="refresh_token requis")

    h = _hash_refresh(rt)
    user = db.query(User).filter(User.refresh_token_hash == h).first()
    if not user:
        raise HTTPException(status_code=401, detail="Refresh token invalide")

    exp = user.refresh_expires_at
    if exp is None or exp < datetime.utcnow():
        raise HTTPException(status_code=401, detail="Refresh token expiré")

    # rotation
    new_access = create_access_token(user.id)
    new_refresh = _new_refresh_token()
    user.refresh_token_hash = _hash_refresh(new_refresh)
    user.refresh_expires_at = datetime.utcnow() + timedelta(days=REFRESH_EXPIRE_DAYS)
    db.add(user)
    db.commit()

    return TokenResponse(access_token=new_access, refresh_token=new_refresh)



@app.get("/me", response_model=UserMe)
def me(user: User = Depends(get_current_user)):
    return UserMe(
        id=user.id,
        email=user.email,
        cash_usd=float(user.cash_usd),
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
    )


@app.post("/auth/change-password")
def change_password(
    payload: ChangePasswordRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not verify_password(payload.old_password, user.password_hash):
        raise HTTPException(status_code=400, detail="Ancien mot de passe incorrect")

    user.password_hash = hash_password(payload.new_password)
    db.add(user)
    db.commit()
    return {"success": True, "message": "Mot de passe modifié (démo)"}


# =========================
# MARKET
# =========================
@app.get("/search")
async def search(query: str):
    url = f"{COINGECKO}/search"
    async with httpx.AsyncClient(timeout=25) as client:
        r = await client.get(url, params={"query": query})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit CoinGecko (réessaie)")
        r.raise_for_status()
        data = r.json()

    coins = []
    for c in data.get("coins", []):
        coins.append(
            {
                "id": c.get("id"),
                "name": c.get("name"),
                "symbol": c.get("symbol"),
                "thumb": c.get("thumb"),
                "market_cap_rank": c.get("market_cap_rank"),
            }
        )
    return {"query": query, "coins": coins[:12]}


@app.get("/history/{coin_id}")
async def history(coin_id: str, days: int = 90):
    cid = coin_id.strip().lower()
    url = f"{COINGECKO}/coins/{cid}/market_chart"
    async with httpx.AsyncClient(timeout=30) as client:
        r = await client.get(url, params={"vs_currency": "usd", "days": days})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit CoinGecko (réessaie)")
        if r.status_code != 200:
            raise HTTPException(status_code=404, detail="coin_id invalide")
        data = r.json()
    return {"coin_id": cid, "prices": data.get("prices", [])}


@app.get("/predict/{coin_id}")
async def predict(coin_id: str, horizon: int = 7):
    cid = coin_id.strip().lower()
    url = f"{COINGECKO}/coins/{cid}/market_chart"
    async with httpx.AsyncClient(timeout=35) as client:
        r = await client.get(url, params={"vs_currency": "usd", "days": 365})
        if r.status_code == 429:
            raise HTTPException(status_code=503, detail="Rate limit CoinGecko (réessaie)")
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
        X.append(series[i - L : i])
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
        "coin_id": cid,
        "horizon": int(horizon),
        "current_price": float(series[-1]),
        "predicted_prices": preds,
        "model": f"Ridge(lags={L})",
        "mae": mae,
        "message": "Prédiction ML (démo)",
    }


# =========================
# WALLET
# =========================

# =========================
# ORDERS (LIMIT / SL / TP) - démo
# =========================
@app.get("/orders", response_model=List[OrderOut])
def list_orders(status: str = "open", user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    q = db.query(Order).filter(Order.user_id == user.id)
    s = (status or "open").lower()
    if s in ("open", "opened"):
        q = q.filter(Order.status == "OPEN")
    elif s in ("filled",):
        q = q.filter(Order.status == "FILLED")
    elif s in ("canceled", "cancelled"):
        q = q.filter(Order.status == "CANCELED")
    # else: all

    rows = q.order_by(Order.created_at.desc(), Order.id.desc()).limit(200).all()
    return [
        OrderOut(
            id=o.id,
            coin_id=o.coin_id,
            side=o.side,
            order_type=o.order_type,
            qty=float(o.qty),
            limit_price=float(o.limit_price) if o.limit_price is not None else None,
            trigger_price=float(o.trigger_price) if o.trigger_price is not None else None,
            status=o.status,
            reason=o.reason,
            created_at=o.created_at,
            filled_at=o.filled_at,
            filled_price=float(o.filled_price) if o.filled_price is not None else None,
        )
        for o in rows
    ]


@app.post("/orders", response_model=OrderOut)
def create_order(payload: OrderCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    cid = (payload.coin_id or "").strip().lower()
    if not cid:
        raise HTTPException(status_code=400, detail="coin_id requis")

    side = (payload.side or "").strip().upper()
    if side not in ("BUY", "SELL"):
        raise HTTPException(status_code=400, detail="side invalide (BUY/SELL)")

    otype = (payload.order_type or "").strip().upper()
    if otype not in ("LIMIT", "STOP_LOSS", "TAKE_PROFIT"):
        raise HTTPException(status_code=400, detail="order_type invalide")

    qty = _d(payload.qty)
    if qty <= 0:
        raise HTTPException(status_code=400, detail="qty invalide")

    lp = _d(payload.limit_price) if payload.limit_price is not None else None
    tp = _d(payload.trigger_price) if payload.trigger_price is not None else None

    if otype == "LIMIT" and (lp is None or lp <= 0):
        raise HTTPException(status_code=400, detail="limit_price requis pour LIMIT")
    if otype in ("STOP_LOSS", "TAKE_PROFIT") and (tp is None or tp <= 0):
        raise HTTPException(status_code=400, detail="trigger_price requis pour STOP/TP")

    o = Order(
        user_id=user.id,
        coin_id=cid,
        side=side,
        order_type=otype,
        qty=_q8(qty),
        limit_price=_q8(lp) if lp is not None else None,
        trigger_price=_q8(tp) if tp is not None else None,
        status="OPEN",
        reason="",
    )
    db.add(o)
    db.commit()
    db.refresh(o)

    return OrderOut(
        id=o.id,
        coin_id=o.coin_id,
        side=o.side,
        order_type=o.order_type,
        qty=float(o.qty),
        limit_price=float(o.limit_price) if o.limit_price is not None else None,
        trigger_price=float(o.trigger_price) if o.trigger_price is not None else None,
        status=o.status,
        reason=o.reason,
        created_at=o.created_at,
        filled_at=o.filled_at,
        filled_price=float(o.filled_price) if o.filled_price is not None else None,
    )


@app.post("/orders/{order_id}/cancel", response_model=OrderOut)
def cancel_order(order_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    o = db.query(Order).filter(Order.id == int(order_id), Order.user_id == user.id).first()
    if not o:
        raise HTTPException(status_code=404, detail="Order introuvable")
    if o.status != "OPEN":
        raise HTTPException(status_code=400, detail="Order non annulable")

    o.status = "CANCELED"
    o.reason = "Canceled by user"
    db.add(o)
    db.commit()
    db.refresh(o)

    return OrderOut(
        id=o.id,
        coin_id=o.coin_id,
        side=o.side,
        order_type=o.order_type,
        qty=float(o.qty),
        limit_price=float(o.limit_price) if o.limit_price is not None else None,
        trigger_price=float(o.trigger_price) if o.trigger_price is not None else None,
        status=o.status,
        reason=o.reason,
        created_at=o.created_at,
        filled_at=o.filled_at,
        filled_price=float(o.filled_price) if o.filled_price is not None else None,
    )

@app.get("/wallet", response_model=WalletOut)
async def wallet(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Holdings actuels
    holdings = db.query(Holding).filter(Holding.user_id == user.id).all()

    # Prix live (CoinGecko)
    coin_ids = [h.coin_id for h in holdings if Decimal(h.amount) > 0]
    prices = await _get_prices_cached(list(set(coin_ids)))

    # ==========================
    # Cost basis + PnL (démo)
    # Méthode : coût moyen pondéré (WAC)
    # ==========================
    txs = (
        db.query(Transaction)
        .filter(Transaction.user_id == user.id)
        .order_by(Transaction.created_at.asc(), Transaction.id.asc())
        .all()
    )

    state: Dict[str, Dict[str, Decimal]] = {}  # coin_id -> {"qty":..., "cost":...}

    for tx in txs:
        cid = (tx.coin_id or "").strip().lower()
        if not cid:
            continue

        s = state.setdefault(cid, {"qty": Decimal("0"), "cost": Decimal("0")})
        qty = s["qty"]
        cost = s["cost"]

        if tx.side == "BUY":
            q = Decimal(tx.coin_amount)
            # On considère le coût total payé (inclut les frais) comme coût d'acquisition.
            c = Decimal(tx.usd_amount)
            s["qty"] = _q8(qty + q)
            s["cost"] = _q8(cost + c)

        elif tx.side == "SELL":
            q = Decimal(tx.coin_amount)
            if qty <= 0:
                continue
            if q <= 0:
                continue

            # retire le coût correspondant à la quantité vendue au coût moyen
            avg = cost / qty if qty > 0 else Decimal("0")
            sold = q if q <= qty else qty
            new_qty = qty - sold
            new_cost = cost - (avg * sold)

            # garde des valeurs propres
            if new_qty <= 0:
                s["qty"] = Decimal("0")
                s["cost"] = Decimal("0")
            else:
                s["qty"] = _q8(new_qty)
                s["cost"] = _q8(max(new_cost, Decimal("0")))

    out_holdings: List[HoldingOut] = []
    total_holdings = Decimal("0")

    for h in holdings:
        amount = Decimal(h.amount)
        if amount <= 0:
            continue

        cid = h.coin_id.strip().lower()
        p = Decimal(str(prices.get(cid, 0.0)))
        val = amount * p
        total_holdings += val

        # calc WAC (avg cost) depuis les transactions
        s = state.get(cid)
        avg_cost = Decimal("0")
        if s and s["qty"] > 0:
            avg_cost = (s["cost"] / s["qty"])

        # cost basis aligné sur la quantité détenue (évite les écarts de rounding)
        cost_basis = _q8(avg_cost * amount)

        # Si on n'a pas de coût d'acquisition (pas de trades), on n'affiche pas un "gain" artificiel.
        if cost_basis <= 0:
            pnl = Decimal("0")
            pnl_pct = Decimal("0")
        else:
            pnl = _q8(val - cost_basis)
            pnl_pct = _q8(pnl / cost_basis * Decimal("100"))
            pnl_pct = _q8(pnl / cost_basis * Decimal("100"))

        out_holdings.append(
            HoldingOut(
                coin_id=cid,
                amount=float(amount),
                price_usd=float(p),
                value_usd=float(val),
                cost_basis_usd=float(cost_basis),
                avg_cost_usd=float(_q8(avg_cost)),
                pnl_usd=float(pnl),
                pnl_pct=float(pnl_pct),
            )
        )

    cash = Decimal(user.cash_usd)
    total = cash + total_holdings
    return WalletOut(cash_usd=float(cash), holdings=out_holdings, total_usd=float(total))


@app.post("/trade/buy", response_model=TradeResponse)
async def buy(payload: BuyRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    coin_id = payload.coin_id.strip().lower()
    usd_amount = _d(payload.usd_amount)

    prices = await _get_prices_cached([coin_id])
    price = Decimal(str(prices.get(coin_id, 0.0)))
    if price <= 0:
        raise HTTPException(status_code=404, detail="coin_id invalide (prix introuvable)")

    cash = Decimal(user.cash_usd)
    if cash < usd_amount:
        raise HTTPException(status_code=400, detail="Solde USD insuffisant")

    fee = _q8(usd_amount * FEE_RATE)
    net = usd_amount - fee
    coin_amount = _q8(net / price)

    user.cash_usd = _q8(cash - usd_amount)

    holding = db.query(Holding).filter(Holding.user_id == user.id, Holding.coin_id == coin_id).first()
    if not holding:
        holding = Holding(user_id=user.id, coin_id=coin_id, amount=Decimal("0"))
        db.add(holding)
    holding.amount = _q8(Decimal(holding.amount) + coin_amount)

    tx = Transaction(
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
async def sell(payload: SellRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    coin_id = payload.coin_id.strip().lower()
    coin_amount = _d(payload.coin_amount)

    holding = db.query(Holding).filter(Holding.user_id == user.id, Holding.coin_id == coin_id).first()
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
    user.cash_usd = _q8(Decimal(user.cash_usd) + net)

    tx = Transaction(
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
def transactions(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    txs = (
        db.query(Transaction)
        .filter(Transaction.user_id == user.id)
        .order_by(Transaction.created_at.desc())
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


# =========================
# BANK
# =========================
@app.get("/bank/balance", response_model=BankBalanceOut)
def bank_balance(user: User = Depends(get_current_user)):
    return BankBalanceOut(balance_usd=float(user.cash_usd), updated_at=datetime.utcnow())


@app.post("/bank/transfer", response_model=BankTransferOut)
def bank_transfer(
    payload: BankTransferRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    to_email = payload.to_email.strip().lower()
    amount = _d(payload.usd_amount)

    if amount <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")
    if amount < MIN_TRANSFER_USD:
        raise HTTPException(status_code=400, detail=f"Montant minimum: {MIN_TRANSFER_USD} USD")
    if amount > MAX_TRANSFER_USD:
        raise HTTPException(status_code=400, detail=f"Montant maximum: {MAX_TRANSFER_USD} USD")
    if user.email == to_email:
        raise HTTPException(status_code=400, detail="Impossible de virer vers soi-même")

    to_user = db.query(User).filter(User.email == to_email).first()
    if not to_user:
        raise HTTPException(status_code=404, detail="Destinataire introuvable")

    from_cash = Decimal(user.cash_usd)
    if from_cash < amount:
        raise HTTPException(status_code=400, detail="Solde insuffisant")

    ref = f"tr_{int(time.time())}_{user.id}_{to_user.id}"

    user.cash_usd = _q8(from_cash - amount)
    to_user.cash_usd = _q8(Decimal(to_user.cash_usd) + amount)

    out_tx = BankTx(
        user_id=user.id,
        kind="TRANSFER_OUT",
        amount_usd=_q8(-amount),
        note=payload.note or "",
        ref=ref,
        counterparty_email=to_email,
    )
    in_tx = BankTx(
        user_id=to_user.id,
        kind="TRANSFER_IN",
        amount_usd=_q8(amount),
        note=f"Reçu de {user.email}",
        ref=ref,
        counterparty_email=user.email,
    )
    db.add(out_tx)
    db.add(in_tx)
    db.add(user)
    db.add(to_user)
    db.commit()

    return BankTransferOut(
        success=True,
        message="Virement effectué",
        from_balance_usd=float(user.cash_usd),
        to_email=to_email,
        amount_usd=float(amount),
        transfer_ref=ref,
    )


@app.get("/bank/transactions", response_model=List[BankTxOut])
def bank_transactions(
    limit: int = 20,
    direction: str = "all",  # all | in | out
    from_date: str | None = None,  # YYYY-MM-DD (local) ou ISO datetime
    to_date: str | None = None,
    counterparty: str | None = None,  # email (exact ou partiel)
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    limit = max(1, min(int(limit), 200))

    q = db.query(BankTx).filter(BankTx.user_id == user.id)

    d = (direction or "all").lower().strip()
    if d in ("in", "incoming"):
        q = q.filter(BankTx.kind == "TRANSFER_IN")
    elif d in ("out", "outgoing"):
        q = q.filter(BankTx.kind == "TRANSFER_OUT")

    def _parse(dt: str) -> datetime | None:
        try:
            # date simple
            if len(dt) == 10 and dt[4] == "-" and dt[7] == "-":
                return datetime.fromisoformat(dt + "T00:00:00")
            return datetime.fromisoformat(dt)
        except Exception:
            return None

    if from_date:
        d0 = _parse(from_date)
        if d0:
            q = q.filter(BankTx.created_at >= d0)

    if to_date:
        d1 = _parse(to_date)
        if d1:
            # inclusif -> ajoute 1 jour si c'est un format date
            if len(to_date) == 10:
                d1 = d1 + timedelta(days=1)
            q = q.filter(BankTx.created_at < d1)

    if counterparty:
        cp = counterparty.strip().lower()
        if cp:
            q = q.filter(or_(BankTx.counterparty_email == cp, BankTx.counterparty_email.like(f"%{cp}%")))

    rows = q.order_by(BankTx.created_at.desc()).limit(limit).all()

    return [
        BankTxOut(
            id=r.id,
            kind=r.kind,
            amount_usd=float(r.amount_usd),
            note=r.note,
            ref=r.ref,
            created_at=r.created_at,
            counterparty_email=getattr(r, "counterparty_email", None),
        )
        for r in rows
    ]


# =========================
# BENEFICIARIES

# =========================
# BENEFICIARIES
# =========================
def _beneficiary_to_out(b: Beneficiary) -> BeneficiaryOut:
    u = b.beneficiary_user
    return BeneficiaryOut(
        id=b.id,
        email=u.email,
        first_name=u.first_name,
        last_name=u.last_name,
        alias=b.alias or "",
        created_at=b.created_at,
    )


@app.get("/bank/beneficiaries", response_model=List[BeneficiaryOut])
def bank_beneficiaries_list(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(Beneficiary)
        .filter(Beneficiary.owner_user_id == user.id)
        .order_by(Beneficiary.created_at.desc())
        .all()
    )
    return [_beneficiary_to_out(b) for b in rows]


@app.post("/bank/beneficiaries", response_model=BeneficiaryOut)
def bank_beneficiaries_add(
    payload: BeneficiaryCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    email = payload.email.strip().lower()
    if email == user.email:
        raise HTTPException(status_code=400, detail="Impossible de s'ajouter soi-même")

    target = db.query(User).filter(User.email == email).first()
    if not target:
        raise HTTPException(status_code=404, detail="Aucun compte trouvé avec cet email")

    exists = (
        db.query(Beneficiary)
        .filter(
            Beneficiary.owner_user_id == user.id,
            Beneficiary.beneficiary_user_id == target.id,
        )
        .first()
    )
    if exists:
        exists.alias = (payload.alias or "").strip()
        db.add(exists)
        db.commit()
        db.refresh(exists)
        return _beneficiary_to_out(exists)

    b = Beneficiary(
        owner_user_id=user.id,
        beneficiary_user_id=target.id,
        alias=(payload.alias or "").strip(),
    )
    db.add(b)
    db.commit()
    db.refresh(b)
    return _beneficiary_to_out(b)


@app.delete("/bank/beneficiaries/{id}")
def bank_beneficiaries_delete(id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = (
        db.query(Beneficiary)
        .filter(Beneficiary.id == id, Beneficiary.owner_user_id == user.id)
        .first()
    )
    if not b:
        raise HTTPException(status_code=404, detail="Bénéficiaire introuvable")
    db.delete(b)
    db.commit()
    return {"ok": True}
