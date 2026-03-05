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
import socket
from zeroconf import ServiceInfo, Zeroconf

# ==================== DEBUG ====================
print("🔥 SERVER.PY EST EXÉCUTÉ !")
print(f"📝 __name__ = {__name__}")

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

print(f"📊 Configuration DB: {DB_HOST}:{DB_PORT}/{DB_NAME}")

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
    print(f"🔌 Tentative de connexion à {DB_HOST}:{DB_PORT}")
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
    print("🗄️ Début de l'initialisation de la base de données...")
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            conn = get_db()
            cur = conn.cursor()
            print(f"✅ Connexion à la base de données établie (tentative {attempt + 1})")
            break
        except Exception as e:
            print(f"⏳ Attente de la base de données... ({attempt + 1}/{max_attempts})")
            print(f"❌ Erreur: {e}")
            time.sleep(2)
    else:
        print("❌ Impossible de se connecter à la base de données")
        return
    
    # Table users
    print("📦 Création de la table users...")
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
    print("📦 Création de la table transactions...")
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
    print("📊 Création des index...")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(expediteur_id, destinataire_id)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)")
    
    # Insérer utilisateurs par défaut
    cur.execute("SELECT COUNT(*) FROM users")
    count = cur.fetchone()['count']
    print(f"👥 Nombre d'utilisateurs existants: {count}")
    
    if count == 0:
        print("➕ Création des utilisateurs par défaut...")
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
        
        print("➕ Création des transactions par défaut...")
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
    print("✅ Base de données initialisée avec succès!")

# ==================== UTIL ====================
def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

def register_mdns_service(port: int = 8000, name: str = "BKN API"):
    local_ip = get_local_ip()
    desc = {'path': '/'}
    hostname = socket.gethostname()
    info = ServiceInfo(
        type_="_bkn._tcp.local.",
        name=f"{name}._bkn._tcp.local.",
        addresses=[socket.inet_aton(local_ip)],
        port=port,
        properties=desc,
        server=f"{hostname}.local."
    )
    zeroconf = Zeroconf()
    zeroconf.register_service(info)
    print(f"📡 Service mDNS '{name}' annoncé sur {local_ip}:{port}")
    return zeroconf, info

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

@app.post("/login")
async def login(request: LoginRequest):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, pseudo, email, nom, prenom, password_hash, solde, verification_level, created_at
        FROM users WHERE email = %s AND is_active = TRUE
    """, (request.email,))
    user = cur.fetchone()
    cur.close()
    conn.close()
    
    if not user or not verify_password(request.password, user['password_hash']):
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE users SET last_login = %s WHERE id = %s", 
                (datetime.now(), user['id']))
    conn.commit()
    cur.close()
    conn.close()
    
    del user['password_hash']
    user['solde'] = float(user['solde'])
    user['created_at'] = user['created_at'].isoformat() if user['created_at'] else None
    return {"success": True, "user": user}

@app.post("/register")
async def register(request: RegisterRequest):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id FROM users WHERE email = %s OR pseudo = %s", (request.email, request.pseudo))
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
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, destinataire_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (f"WEL{user_id}", 'reception', 100.00, datetime.now(), '🎉 Bonus de bienvenue', user_id))
        conn.commit()
        return {"success": True, "user_id": new_user['id'], "pseudo": new_user['pseudo'], "email": new_user['email'], "bonus": 100}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

# ==================== AUTRES ROUTES ====================
@app.get("/users")
async def get_users():
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT id, pseudo, nom, prenom, email FROM users WHERE is_active = TRUE")
        users = cur.fetchall()
        cur.close()
        conn.close()
        return {"users": users}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/user/{identifier}")
async def get_user(identifier: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("""
            SELECT id, pseudo, nom, prenom, email, phone, solde, verification_level, created_at
            FROM users WHERE id = %s OR pseudo = %s OR email = %s
        """, (identifier, identifier, identifier))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        user['solde'] = float(user['solde'])
        return user
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/balance/{user_id}")
async def get_balance(user_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT solde FROM users WHERE id = %s", (user_id,))
        result = cur.fetchone()
        cur.close()
        conn.close()
        if not result:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        return {"solde": float(result['solde'])}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/transfer")
async def transfer(request: TransferRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        # Vérifier le solde de l'expéditeur
        cur.execute("SELECT solde FROM users WHERE id = %s", (request.expediteur_id,))
        expediteur = cur.fetchone()
        if not expediteur:
            raise HTTPException(status_code=404, detail="Expéditeur non trouvé")
        
        if float(expediteur['solde']) < request.montant:
            raise HTTPException(status_code=400, detail="Solde insuffisant")
        
        # Trouver le destinataire (par ID, pseudo ou email)
        cur.execute("""
            SELECT id FROM users 
            WHERE id = %s OR pseudo = %s OR email = %s
        """, (request.destinataire, request.destinataire, request.destinataire))
        destinataire = cur.fetchone()
        if not destinataire:
            raise HTTPException(status_code=404, detail="Destinataire non trouvé")
        
        # Effectuer le transfert
        cur.execute("UPDATE users SET solde = solde - %s WHERE id = %s", 
                   (request.montant, request.expediteur_id))
        cur.execute("UPDATE users SET solde = solde + %s WHERE id = %s", 
                   (request.montant, destinataire['id']))
        
        # Enregistrer la transaction
        transaction_id = f"TR{uuid.uuid4().hex[:8]}"
        cur.execute("""
            INSERT INTO transactions (id, type, montant, description, expediteur_id, destinataire_id)
            VALUES (%s, 'transfert', %s, 'Transfert', %s, %s)
        """, (transaction_id, request.montant, request.expediteur_id, destinataire['id']))
        
        conn.commit()
        return {"success": True, "message": "Transfert effectué", "transaction_id": transaction_id}
    except HTTPException:
        if conn:
            conn.rollback()
        raise
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            cur.close()
            conn.close()

@app.post("/buy")
async def buy(request: BuyRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("UPDATE users SET solde = solde + %s WHERE id = %s", 
                   (request.montant, request.user_id))
        
        transaction_id = f"BUY{uuid.uuid4().hex[:8]}"
        cur.execute("""
            INSERT INTO transactions (id, type, montant, description, destinataire_id, metadata)
            VALUES (%s, 'achat', %s, %s, %s, %s)
        """, (transaction_id, request.montant, f"Achat via {request.methode}", request.user_id, 
              {"methode": request.methode}))
        
        conn.commit()
        return {"success": True, "message": "Achat effectué", "transaction_id": transaction_id}
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            cur.close()
            conn.close()

@app.post("/sell")
async def sell(request: SellRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("SELECT solde FROM users WHERE id = %s", (request.user_id,))
        user = cur.fetchone()
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        if float(user['solde']) < request.montant:
            raise HTTPException(status_code=400, detail="Solde insuffisant")
        
        cur.execute("UPDATE users SET solde = solde - %s WHERE id = %s", 
                   (request.montant, request.user_id))
        
        transaction_id = f"SELL{uuid.uuid4().hex[:8]}"
        cur.execute("""
            INSERT INTO transactions (id, type, montant, description, expediteur_id)
            VALUES (%s, 'vente', %s, 'Vente de BKN', %s)
        """, (transaction_id, request.montant, request.user_id))
        
        conn.commit()
        return {"success": True, "message": "Vente effectuée", "transaction_id": transaction_id}
    except HTTPException:
        if conn:
            conn.rollback()
        raise
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            cur.close()
            conn.close()

@app.get("/history/{user_id}")
async def get_history(user_id: str, limit: int = 20):
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("""
            SELECT * FROM transactions 
            WHERE expediteur_id = %s OR destinataire_id = %s
            ORDER BY date DESC
            LIMIT %s
        """, (user_id, user_id, limit))
        transactions = cur.fetchall()
        cur.close()
        conn.close()
        
        for t in transactions:
            t['montant'] = float(t['montant'])
            t['date'] = t['date'].isoformat() if t['date'] else None
        
        return {"transactions": transactions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/stats")
async def get_stats():
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) as total_users FROM users")
        total_users = cur.fetchone()['total_users']
        
        cur.execute("SELECT COUNT(*) as total_transactions FROM transactions")
        total_transactions = cur.fetchone()['total_transactions']
        
        cur.execute("SELECT SUM(montant) as volume_total FROM transactions")
        volume = cur.fetchone()['volume_total'] or 0
        
        cur.close()
        conn.close()
        
        return {
            "total_users": total_users,
            "total_transactions": total_transactions,
            "volume_total": float(volume)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==================== DÉMARRAGE ====================
if __name__ == "__main__":
    print("🎯 Dans if __name__ == '__main__'")
    print("🔄 Initialisation de la base de données...")
    init_database()
    
    print("📡 Configuration mDNS...")
    local_ip = get_local_ip()
    zeroconf, mdns_info = register_mdns_service(port=8000, name="BKN API")
    
    try:
        print("\n" + "="*60)
        print("🚀 BKN API DÉMARRÉE".center(60))
        print("="*60)
        print(f"📡 API réseau local: http://{local_ip}:8000")
        print(f"📊 Swagger docs: http://{local_ip}:8000/docs")
        print("📈 Adminer: http://localhost:8081")
        print("="*60)
        print("👤 Utilisateurs par défaut: john.doe@email.com / password123")
        print("="*60)
        
        print("🚀 Lancement de uvicorn...")
        uvicorn.run(app, host="0.0.0.0", port=8000)
    finally:
        if zeroconf:
            zeroconf.unregister_service(mdns_info)
            zeroconf.close()
else:
    print(f"⚠️ Le script est importé comme module (__name__ = {__name__})")