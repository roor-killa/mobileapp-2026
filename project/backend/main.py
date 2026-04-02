from typing import Optional, List
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from pydantic import BaseModel

# ── Base de données SQLite ────────────────────────────────────────────────────
DATABASE_URL = "sqlite:///./vltbank.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ── Modèles SQLAlchemy ────────────────────────────────────────────────────────
class Utilisateur(Base):
    __tablename__ = "utilisateurs"
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String)
    email = Column(String, unique=True, index=True)
    mot_de_passe = Column(String)
    solde_initial = Column(Float)
    solde_actuel = Column(Float)
    cree_le = Column(String)


class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True, index=True)
    utilisateur_id = Column(Integer, ForeignKey("utilisateurs.id"))
    montant = Column(Float)
    solde_avant = Column(Float)
    solde_apres = Column(Float)
    statut = Column(String)
    message = Column(String)
    date_heure = Column(String)
    type = Column(String, nullable=True)
    autre_partie_nom = Column(String, nullable=True)


class Objectif(Base):
    __tablename__ = "objectifs"
    id = Column(Integer, primary_key=True, index=True)
    utilisateur_id = Column(Integer, ForeignKey("utilisateurs.id"))
    nom = Column(String)
    emoji = Column(String, default="🎯")
    montant_cible = Column(Float)
    montant_actuel = Column(Float, default=0.0)
    date_creation = Column(String)
    date_echeance = Column(String, nullable=True)


class Favori(Base):
    __tablename__ = "favoris"
    user_id = Column(Integer, ForeignKey("utilisateurs.id"), primary_key=True)
    destinataire_id = Column(Integer, ForeignKey("utilisateurs.id"), primary_key=True)


Base.metadata.create_all(bind=engine)


# ── Schémas Pydantic ──────────────────────────────────────────────────────────
class UtilisateurCreate(BaseModel):
    nom: str
    email: str
    mot_de_passe: str
    solde_initial: float
    solde_actuel: float
    cree_le: str


class UtilisateurUpdate(BaseModel):
    nom: Optional[str] = None
    mot_de_passe: Optional[str] = None


class SoldeUpdate(BaseModel):
    solde_actuel: float


class UtilisateurOut(BaseModel):
    id: int
    nom: str
    email: str
    mot_de_passe: str
    solde_initial: float
    solde_actuel: float
    cree_le: str

    model_config = {"from_attributes": True}


class TransactionCreate(BaseModel):
    utilisateur_id: int
    montant: float
    solde_avant: float
    solde_apres: float
    statut: str
    message: str
    date_heure: str
    type: Optional[str] = None
    autre_partie_nom: Optional[str] = None


class TransactionOut(TransactionCreate):
    id: int
    model_config = {"from_attributes": True}


class ObjectifCreate(BaseModel):
    utilisateur_id: int
    nom: str
    emoji: str = "🎯"
    montant_cible: float
    montant_actuel: float = 0.0
    date_creation: str
    date_echeance: Optional[str] = None


class ObjectifOut(ObjectifCreate):
    id: int
    model_config = {"from_attributes": True}


class ObjectifUpdate(BaseModel):
    montant_actuel: float


# ── Application FastAPI ───────────────────────────────────────────────────────
app = FastAPI(title="VLT Bank API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ── Utilisateurs ──────────────────────────────────────────────────────────────
@app.get("/users/existe")
def email_existe(email: str, db: Session = Depends(get_db)):
    user = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    return {"existe": user is not None}


@app.post("/users", response_model=UtilisateurOut)
def creer_utilisateur(u: UtilisateurCreate, db: Session = Depends(get_db)):
    if db.query(Utilisateur).filter(Utilisateur.email == u.email).first():
        raise HTTPException(status_code=400, detail="EMAIL_EXISTE")
    user = Utilisateur(**u.model_dump())
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@app.get("/users/par-email", response_model=UtilisateurOut)
def trouver_par_email(email: str, db: Session = Depends(get_db)):
    user = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return user


@app.get("/users", response_model=List[UtilisateurOut])
def get_tous_utilisateurs(exclude: int, db: Session = Depends(get_db)):
    return db.query(Utilisateur).filter(Utilisateur.id != exclude).all()


@app.get("/users/{user_id}", response_model=UtilisateurOut)
def get_utilisateur(user_id: int, db: Session = Depends(get_db)):
    user = db.query(Utilisateur).filter(Utilisateur.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return user


@app.patch("/users/{user_id}/solde")
def mettre_a_jour_solde(user_id: int, body: SoldeUpdate, db: Session = Depends(get_db)):
    user = db.query(Utilisateur).filter(Utilisateur.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    user.solde_actuel = body.solde_actuel
    db.commit()
    return {"ok": True}


@app.patch("/users/{user_id}")
def mettre_a_jour_utilisateur(user_id: int, body: UtilisateurUpdate, db: Session = Depends(get_db)):
    user = db.query(Utilisateur).filter(Utilisateur.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    if body.nom is not None:
        user.nom = body.nom
    if body.mot_de_passe is not None:
        user.mot_de_passe = body.mot_de_passe
    db.commit()
    return {"ok": True}


# ── Favoris ───────────────────────────────────────────────────────────────────
@app.get("/users/{user_id}/favoris")
def get_favoris(user_id: int, db: Session = Depends(get_db)):
    favoris = db.query(Favori).filter(Favori.user_id == user_id).all()
    return {"favoris": [f.destinataire_id for f in favoris]}


@app.post("/users/{user_id}/favoris/{destinataire_id}/toggle")
def toggle_favori(user_id: int, destinataire_id: int, db: Session = Depends(get_db)):
    existing = db.query(Favori).filter(
        Favori.user_id == user_id,
        Favori.destinataire_id == destinataire_id,
    ).first()
    if existing:
        db.delete(existing)
        db.commit()
        return {"favori": False}
    db.add(Favori(user_id=user_id, destinataire_id=destinataire_id))
    db.commit()
    return {"favori": True}


@app.get("/users/{user_id}/favoris/{destinataire_id}")
def est_favori(user_id: int, destinataire_id: int, db: Session = Depends(get_db)):
    existing = db.query(Favori).filter(
        Favori.user_id == user_id,
        Favori.destinataire_id == destinataire_id,
    ).first()
    return {"favori": existing is not None}


# ── Transactions ──────────────────────────────────────────────────────────────
@app.post("/transactions", response_model=TransactionOut)
def enregistrer_transaction(t: TransactionCreate, db: Session = Depends(get_db)):
    transaction = Transaction(**t.model_dump())
    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction


@app.get("/transactions", response_model=List[TransactionOut])
def get_transactions(user_id: int, limit: Optional[int] = None, db: Session = Depends(get_db)):
    query = (
        db.query(Transaction)
        .filter(Transaction.utilisateur_id == user_id)
        .order_by(Transaction.date_heure.desc())
    )
    if limit:
        query = query.limit(limit)
    return query.all()


# ── Objectifs d'épargne ───────────────────────────────────────────────────────
@app.post("/objectifs", response_model=ObjectifOut)
def creer_objectif(goal: ObjectifCreate, db: Session = Depends(get_db)):
    obj = Objectif(**goal.model_dump())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


@app.get("/objectifs", response_model=List[ObjectifOut])
def get_objectifs(user_id: int, db: Session = Depends(get_db)):
    return db.query(Objectif).filter(Objectif.utilisateur_id == user_id).all()


@app.patch("/objectifs/{goal_id}")
def mettre_a_jour_objectif(goal_id: int, body: ObjectifUpdate, db: Session = Depends(get_db)):
    obj = db.query(Objectif).filter(Objectif.id == goal_id).first()
    if not obj:
        raise HTTPException(status_code=404, detail="Objectif non trouvé")
    obj.montant_actuel = body.montant_actuel
    db.commit()
    return {"ok": True}


@app.delete("/objectifs/{goal_id}")
def supprimer_objectif(goal_id: int, db: Session = Depends(get_db)):
    obj = db.query(Objectif).filter(Objectif.id == goal_id).first()
    if not obj:
        raise HTTPException(status_code=404, detail="Objectif non trouvé")
    db.delete(obj)
    db.commit()
    return {"ok": True}
