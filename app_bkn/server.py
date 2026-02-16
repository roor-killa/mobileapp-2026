from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from datetime import datetime
import uuid
from pydantic import BaseModel
from typing import Optional, List
import uvicorn
from passlib.context import CryptContext
import time

# ==================== CONFIGURATION HACHAGE ====================
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# ==================== MODÈLES ====================
class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    email: str
    nom: str
    prenom: str
    pseudo: str
    phone: str
    password: str

class TransferRequest(BaseModel):
    expediteur_id: str
    destinataire: str
    montant: float

class BuyRequest(BaseModel):
    user_id: str
    montant: float
    methode: str = "Stripe"

class SellRequest(BaseModel):
    user_id: str
    montant: float

# ==================== CONFIGURATION ====================
DB_HOST = os.getenv('DB_HOST', 'postgres')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'bkn_db')
DB_USER = os.getenv('DB_USER', 'bkn_admin')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'BknSecurePass2026!')

app = FastAPI(title="BKN API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== BASE DE DONNÉES ====================
def get_db():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        cursor_factory=RealDictCursor
    )

def init_database():
    """Initialise la base de données avec les tables et données par défaut"""
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            conn = get_db()
            cur = conn.cursor()
            print(f"✅ Connexion à la base de données établie (tentative {attempt + 1})")
            break
        except Exception as e:
            print(f"⏳ Attente de la base de données... ({attempt + 1}/{max_attempts})")
            time.sleep(2)
    else:
        print("❌ Impossible de se connecter à la base de données")
        return
    
    # Table users avec mot de passe
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id VARCHAR(50) PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            nom VARCHAR(100) NOT NULL,
            prenom VARCHAR(100) NOT NULL,
            pseudo VARCHAR(50) UNIQUE NOT NULL,
            phone VARCHAR(20),
            password_hash VARCHAR(255) NOT NULL,
            solde DECIMAL(15,2) DEFAULT 1500.00,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            verification_level VARCHAR(50) DEFAULT 'Niveau 1',
            is_active BOOLEAN DEFAULT TRUE,
            last_login TIMESTAMP,
            avatar_url TEXT
        )
    """)
    
    # Table transactions
    cur.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id VARCHAR(50) PRIMARY KEY,
            type VARCHAR(20) NOT NULL,
            montant DECIMAL(15,2) NOT NULL,
            date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            description TEXT,
            expediteur_id VARCHAR(50),
            destinataire_id VARCHAR(50),
            status VARCHAR(20) DEFAULT 'completed',
            metadata JSONB,
            FOREIGN KEY (expediteur_id) REFERENCES users(id),
            FOREIGN KEY (destinataire_id) REFERENCES users(id)
        )
    """)
    
    # Index pour performances
    cur.execute("CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(expediteur_id, destinataire_id)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)")
    
    # Insérer utilisateurs par défaut avec mots de passe
    cur.execute("SELECT COUNT(*) FROM users")
    if cur.fetchone()['count'] == 0:
        default_password = hash_password("password123")
        users = [
            ('1', 'john.doe@email.com', 'Doe', 'John', '@john', '0612345678', default_password, 5000.00, 'Niveau 2'),
            ('2', 'jane.smith@email.com', 'Smith', 'Jane', '@jane', '0687654321', default_password, 3000.00, 'Niveau 1'),
            ('3', 'bob.martin@email.com', 'Martin', 'Bob', '@bob', '0655555555', default_password, 2000.00, 'Niveau 1'),
            ('4', 'alice.wonder@email.com', 'Wonder', 'Alice', '@alice', '0644444444', default_password, 4500.00, 'Niveau 2'),
        ]
        cur.executemany("""
            INSERT INTO users (id, email, nom, prenom, pseudo, phone, password_hash, solde, verification_level)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, users)
        
        # Transactions de démonstration
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, expediteur_id, destinataire_id)
            VALUES 
            ('TR1', 'achat', 1800, '2024-02-02 01:00:00', 'Achat BKN', NULL, '1'),
            ('TR2', 'vente', 1600, '2024-02-04 04:00:00', 'Vente BKN', '1', NULL),
            ('TR3', 'transfert', 500, '2024-02-05 14:30:00', 'Transfert vers @jane', '1', '2'),
            ('TR4', 'reception', 300, '2024-02-06 10:15:00', 'Reçu de @bob', '3', '1')
        """)
        print("✅ Utilisateurs par défaut créés avec mot de passe: password123")
    
    conn.commit()
    cur.close()
    conn.close()
    print("✅ Base de données initialisée")

# ==================== ROUTES API ====================

@app.get("/")
async def root():
    return {
        "name": "BKN API",
        "version": "1.0.0",
        "status": "online",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health():
    try:
        conn = get_db()
        conn.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": str(e)}

# ================ AUTHENTIFICATION ================

@app.post("/login")
async def login(request: LoginRequest):
    """Connexion avec email et mot de passe"""
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT id, pseudo, email, nom, prenom, password_hash, solde, verification_level, created_at
        FROM users WHERE email = %s AND is_active = TRUE
    """, (request.email,))
    
    user = cur.fetchone()
    cur.close()
    conn.close()
    
    if not user:
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    
    if not verify_password(request.password, user['password_hash']):
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    
    # Mettre à jour la dernière connexion
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE users SET last_login = %s WHERE id = %s", 
                (datetime.now(), user['id']))
    conn.commit()
    cur.close()
    conn.close()
    
    # Ne pas renvoyer le mot de passe
    del user['password_hash']
    user['solde'] = float(user['solde'])
    user['created_at'] = user['created_at'].isoformat() if user['created_at'] else None
    
    return {
        "success": True,
        "user": user
    }

@app.post("/register")
async def register(request: RegisterRequest):
    """Inscription avec mot de passe"""
    conn = get_db()
    cur = conn.cursor()
    
    # Vérifier si l'email ou le pseudo existe déjà
    cur.execute("SELECT id FROM users WHERE email = %s OR pseudo = %s", 
                (request.email, request.pseudo))
    if cur.fetchone():
        raise HTTPException(status_code=400, detail="Email ou pseudo déjà utilisé")
    
    user_id = str(uuid.uuid4())[:8]
    pseudo = request.pseudo if request.pseudo.startswith('@') else f'@{request.pseudo}'
    
    try:
        cur.execute("""
            INSERT INTO users (id, email, nom, prenom, pseudo, phone, password_hash, solde, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id, pseudo, email
        """, (
            user_id, request.email, request.nom, request.prenom,
            pseudo, request.phone, hash_password(request.password), 
            100.00, datetime.now()
        ))
        
        new_user = cur.fetchone()
        
        # Bonus de bienvenue
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, destinataire_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            f"WEL{user_id}", 'reception', 100.00, datetime.now(),
            '🎉 Bonus de bienvenue', user_id
        ))
        
        conn.commit()
        
        return {
            "success": True,
            "user_id": new_user['id'],
            "pseudo": new_user['pseudo'],
            "email": new_user['email'],
            "bonus": 100
        }
        
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

# ================ UTILISATEURS ================

@app.get("/users")
async def get_users():
    """Liste tous les utilisateurs actifs (protégé, à utiliser avec précaution)"""
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, pseudo, nom, prenom, email, phone, solde, verification_level, created_at
        FROM users WHERE is_active = TRUE ORDER BY nom ASC
    """)
    users = cur.fetchall()
    cur.close()
    conn.close()
    
    for user in users:
        user['solde'] = float(user['solde'])
        user['created_at'] = user['created_at'].isoformat() if user['created_at'] else None
    
    return {"users": users, "total": len(users)}

@app.get("/user/{identifier}")
async def get_user(identifier: str):
    """Récupère un utilisateur par ID ou pseudo"""
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT id, pseudo, nom, prenom, email, phone, solde, verification_level, created_at
        FROM users WHERE (id = %s OR pseudo = %s) AND is_active = TRUE
    """, (identifier, identifier))
    
    user = cur.fetchone()
    cur.close()
    conn.close()
    
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    user['solde'] = float(user['solde'])
    user['created_at'] = user['created_at'].isoformat() if user['created_at'] else None
    return user

@app.get("/balance/{user_id}")
async def get_balance(user_id: str):
    """Récupère le solde d'un utilisateur"""
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT solde, pseudo FROM users WHERE id = %s AND is_active = TRUE", (user_id,))
    result = cur.fetchone()
    cur.close()
    conn.close()
    
    if not result:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    return {
        "user_id": user_id,
        "pseudo": result['pseudo'],
        "solde": float(result['solde']),
        "devise": "BKN"
    }

# ================ TRANSACTIONS ================

@app.post("/transfer")
async def transfer(request: TransferRequest):
    """Effectue un transfert entre utilisateurs"""
    if request.montant <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")
    
    conn = get_db()
    cur = conn.cursor()
    
    try:
        # Vérifier expéditeur
        cur.execute("SELECT id, solde, pseudo FROM users WHERE id = %s AND is_active = TRUE", 
                   (request.expediteur_id,))
        expediteur = cur.fetchone()
        if not expediteur:
            raise HTTPException(status_code=404, detail="Expéditeur non trouvé")
        
        # Vérifier destinataire
        dest_pseudo = request.destinataire
        if not dest_pseudo.startswith('@'):
            dest_pseudo = f'@{dest_pseudo}'
        
        cur.execute("SELECT id, solde, pseudo FROM users WHERE pseudo = %s AND is_active = TRUE", 
                   (dest_pseudo,))
        destinataire = cur.fetchone()
        if not destinataire:
            raise HTTPException(status_code=404, detail="Destinataire non trouvé")
        
        if expediteur['id'] == destinataire['id']:
            raise HTTPException(status_code=400, detail="Transfert à soi-même non autorisé")
        
        if float(expediteur['solde']) < request.montant:
            raise HTTPException(status_code=400, detail="Solde insuffisant")
        
        # Effectuer transfert
        transaction_id = f"TR{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4]}"
        
        cur.execute("UPDATE users SET solde = solde - %s WHERE id = %s", 
                   (request.montant, expediteur['id']))
        cur.execute("UPDATE users SET solde = solde + %s WHERE id = %s", 
                   (request.montant, destinataire['id']))
        
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, expediteur_id, destinataire_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            transaction_id, 'transfert', request.montant, datetime.now(),
            f'Transfert vers {destinataire["pseudo"]}',
            expediteur['id'], destinataire['id']
        ))
        
        conn.commit()
        
        # Nouveau solde
        cur.execute("SELECT solde FROM users WHERE id = %s", (expediteur['id'],))
        nouveau_solde = float(cur.fetchone()['solde'])
        
        return {
            "success": True,
            "transaction_id": transaction_id,
            "montant": request.montant,
            "destinataire": destinataire['pseudo'],
            "nouveau_solde": nouveau_solde,
            "date": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Erreur transfert: {str(e)}")
    finally:
        cur.close()
        conn.close()

@app.post("/buy")
async def buy(request: BuyRequest):
    """Achat de BKN"""
    if request.montant <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")
    
    conn = get_db()
    cur = conn.cursor()
    
    try:
        transaction_id = f"BUY{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4]}"
        
        cur.execute("UPDATE users SET solde = solde + %s WHERE id = %s RETURNING solde", 
                   (request.montant, request.user_id))
        result = cur.fetchone()
        
        if not result:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        nouveau_solde = float(result['solde'])
        
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, destinataire_id, metadata)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            transaction_id, 'achat', request.montant, datetime.now(),
            f'Achat via {request.methode}', request.user_id,
            {'methode': request.methode}
        ))
        
        conn.commit()
        
        return {
            "success": True,
            "transaction_id": transaction_id,
            "montant": request.montant,
            "nouveau_solde": nouveau_solde,
            "methode": request.methode
        }
        
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.post("/sell")
async def sell(request: SellRequest):
    """Vente de BKN"""
    if request.montant <= 0:
        raise HTTPException(status_code=400, detail="Montant invalide")
    
    conn = get_db()
    cur = conn.cursor()
    
    try:
        cur.execute("SELECT solde FROM users WHERE id = %s AND is_active = TRUE", (request.user_id,))
        user = cur.fetchone()
        
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        if float(user['solde']) < request.montant:
            raise HTTPException(status_code=400, detail="Solde insuffisant")
        
        transaction_id = f"SELL{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4]}"
        
        cur.execute("UPDATE users SET solde = solde - %s WHERE id = %s RETURNING solde", 
                   (request.montant, request.user_id))
        nouveau_solde = float(cur.fetchone()['solde'])
        
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, expediteur_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            transaction_id, 'vente', request.montant, datetime.now(),
            'Vente de BKN', request.user_id
        ))
        
        conn.commit()
        
        return {
            "success": True,
            "transaction_id": transaction_id,
            "montant": request.montant,
            "nouveau_solde": nouveau_solde
        }
        
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.get("/history/{user_id}")
async def get_history(user_id: str, limit: int = Query(20, ge=1, le=100)):
    """Récupère l'historique des transactions d'un utilisateur"""
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT 
            t.id, t.type, t.montant, t.date, t.description, t.status,
            u1.pseudo as expediteur_pseudo,
            u1.nom as expediteur_nom,
            u1.prenom as expediteur_prenom,
            u2.pseudo as destinataire_pseudo,
            u2.nom as destinataire_nom,
            u2.prenom as destinataire_prenom,
            t.metadata
        FROM transactions t
        LEFT JOIN users u1 ON t.expediteur_id = u1.id
        LEFT JOIN users u2 ON t.destinataire_id = u2.id
        WHERE t.expediteur_id = %s OR t.destinataire_id = %s
        ORDER BY t.date DESC
        LIMIT %s
    """, (user_id, user_id, limit))
    
    transactions = cur.fetchall()
    cur.close()
    conn.close()
    
    for t in transactions:
        t['montant'] = float(t['montant'])
        t['date'] = t['date'].isoformat() if t['date'] else None
    
    return {"transactions": transactions, "total": len(transactions)}

@app.get("/stats")
async def get_stats():
    """Statistiques globales"""
    conn = get_db()
    cur = conn.cursor()
    
    cur.execute("SELECT COUNT(*) FROM users WHERE is_active = TRUE")
    total_users = cur.fetchone()['count']
    
    cur.execute("SELECT COALESCE(SUM(montant), 0) FROM transactions WHERE status = 'completed'")
    total_volume = float(cur.fetchone()['coalesce'])
    
    cur.execute("""
        SELECT COUNT(*), COALESCE(SUM(montant), 0)
        FROM transactions 
        WHERE DATE(date) = CURRENT_DATE AND status = 'completed'
    """)
    today = cur.fetchone()
    
    cur.close()
    conn.close()
    
    return {
        "total_users": total_users,
        "total_transactions_volume": total_volume,
        "today_transactions": {
            "count": today['count'],
            "volume": float(today['coalesce'])
        },
        "timestamp": datetime.now().isoformat()
    }

# ==================== DÉMARRAGE ====================
if __name__ == "__main__":
    init_database()
    
    print("\n" + "="*60)
    print("🚀 BKN API DÉMARRÉE".center(60))
    print("="*60)
    print("📡 http://localhost:8000")
    print("📊 http://localhost:8000/docs")
    print("📈 Adminer: http://localhost:8081")
    print("="*60)
    print("👤 Utilisateurs par défaut: john.doe@email.com / password123")
    print("="*60)
    
    uvicorn.run(app, host="0.0.0.0", port=8000)