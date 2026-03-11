from fastapi import FastAPI, HTTPException, Query, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
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
from enum import Enum
import shutil
from datetime import timedelta

# Débug
print("🔥 SERVER.PY EST EXÉCUTÉ !")
print(f"📝 __name__ = {__name__}")

# UTILITAIRES SÉCURITÉ 
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# MODÈLES de données
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

class UpdateProfileRequest(BaseModel):
    nom: str
    prenom: str
    email: str
    phone: str
    pseudo: str

class ChangePasswordRequest(BaseModel):
    user_id: str
    old_password: str
    new_password: str

class UpdateSettingsRequest(BaseModel):
    user_id: str
    biometric_enabled: Optional[bool] = None
    notifications_enabled: Optional[bool] = None
    two_factor_enabled: Optional[bool] = None

# MODÈLES CRYPTO
class CryptoPriceRequest(BaseModel):
    crypto: str
    fiat: str = 'eur'

class CryptoBuyRequest(BaseModel):
    user_id: str
    crypto: str
    amount_bkn: float
    wallet_address: Optional[str] = None

class CryptoSellRequest(BaseModel):
    user_id: str
    crypto: str
    amount_crypto: float
    wallet_address: Optional[str] = None
    
# Modèles pour la gestion des mots de passe oubliés
class ForgotPasswordRequest(BaseModel):
    email: str

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

# Configuration Render
DB_HOST = "dpg-d6nhn0nafjfc73flf4t0-a.oregon-postgres.render.com"
DB_PORT = "5432"
DB_NAME = "bkn_db"
DB_USER = "bkn_user"
DB_PASSWORD = "Tlq4zDyX9CFQcWqGYxAEFSFMJYL6hUk1"

print(f" Configuration DB: {DB_HOST}:{DB_PORT}/{DB_NAME}")

app = FastAPI(title="BKN API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Constantes crypto
CRYPTO_PRICES = {
    'bitcoin': 45000.0,
    'ethereum': 2800.0,
    'solana': 98.0,
    'cardano': 0.45,
    'polkadot': 6.50,
    'avalanche': 35.0,
}

# Connexion à Render
def get_db():
    print(f"🔌 Tentative de connexion à Render...")
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        sslmode='require',
        cursor_factory=RealDictCursor
    )

def init_database():
    """Initialise la base de données avec les tables et données par défaut"""
    print(" Début de l'initialisation de la base de données...")
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            conn = get_db()
            cur = conn.cursor()
            print(f"Connexion à la base de données établie (tentative {attempt + 1})")
            break
        except Exception as e:
            print(f"Attente de la base de données... ({attempt + 1}/{max_attempts})")
            print(f"Erreur: {e}")
            time.sleep(2)
    else:
        print("Impossible de se connecter à la base de données")
        return
    
    # Table users
    print("Création de la table users...")
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
    print("Création de la table transactions...")
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
    
    # Table user_settings
    print("Création de la table user_settings...")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS user_settings (
            user_id VARCHAR(50) PRIMARY KEY,
            biometric_enabled BOOLEAN DEFAULT FALSE,
            notifications_enabled BOOLEAN DEFAULT TRUE,
            two_factor_enabled BOOLEAN DEFAULT FALSE,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    """)
    
    # Table user_sessions
    print("Création de la table user_sessions...")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS user_sessions (
            id VARCHAR(50) PRIMARY KEY,
            user_id VARCHAR(50) NOT NULL,
            device_name VARCHAR(255),
            device_type VARCHAR(50),
            ip_address VARCHAR(50),
            last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            is_active BOOLEAN DEFAULT TRUE,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    """)
    
    # Table crypto_transactions
    print("Création de la table crypto_transactions...")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS crypto_transactions (
            id VARCHAR(50) PRIMARY KEY,
            user_id VARCHAR(50) NOT NULL,
            type VARCHAR(20) NOT NULL,
            crypto VARCHAR(50) NOT NULL,
            amount_bkn DECIMAL(15,2) NOT NULL,
            amount_crypto DECIMAL(15,8) NOT NULL,
            price_at_transaction DECIMAL(15,2) NOT NULL,
            wallet_address TEXT,
            status VARCHAR(20) DEFAULT 'completed',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    """)
    
    # Index pour performances
    print("Création des index...")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(expediteur_id, destinataire_id)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_users_pseudo ON users(pseudo)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_crypto_user ON crypto_transactions(user_id, created_at DESC)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id, last_active DESC)")
    
    # Insérer utilisateurs par défaut
    cur.execute("SELECT COUNT(*) FROM users")
    count = cur.fetchone()['count']
    print(f"Nombre d'utilisateurs existants: {count}")
    
    if count == 0:
        print("Création des utilisateurs par défaut...")
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
        
        print("Création des transactions par défaut...")
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, expediteur_id, destinataire_id)
            VALUES 
            ('TR1', 'achat', 1800, '2024-02-02 01:00:00', 'Achat BKN', NULL, '1'),
            ('TR2', 'vente', 1600, '2024-02-04 04:00:00', 'Vente BKN', '1', NULL),
            ('TR3', 'transfert', 500, '2024-02-05 14:30:00', 'Transfert vers @jane', '1', '2'),
            ('TR4', 'reception', 300, '2024-02-06 10:15:00', 'Reçu de @bob', '3', '1')
        """)
        
        print("Création des paramètres par défaut...")
        for user in users:
            cur.execute("""
                INSERT INTO user_settings (user_id, biometric_enabled, notifications_enabled, two_factor_enabled)
                VALUES (%s, FALSE, TRUE, FALSE)
                ON CONFLICT (user_id) DO NOTHING
            """, (user[0],))
        
        print("Création des transactions crypto par défaut...")
        cur.execute("""
            INSERT INTO crypto_transactions (id, user_id, type, crypto, amount_bkn, amount_crypto, price_at_transaction, wallet_address)
            VALUES 
            ('CRYPTO1', '1', 'buy', 'bitcoin', 1000, 0.0222, 45000, 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'),
            ('CRYPTO2', '1', 'buy', 'ethereum', 500, 0.1786, 2800, '0x742d35Cc6634C0532925a3b844Bc5e9c5f3a7d3a'),
            ('CRYPTO3', '2', 'buy', 'solana', 300, 3.0612, 98, '5YNmS1R9nNSCDzb5a7mMJ1dwK9uHeAAF4CmPEwKgVWr5')
        """)
        
        # Ajout des sessions par défaut
        cur.execute("""
            INSERT INTO user_sessions (id, user_id, device_name, device_type, ip_address)
            VALUES 
            ('SESS1', '1', 'iPhone 14 Pro', 'mobile', '192.168.1.42'),
            ('SESS2', '1', 'MacBook Pro', 'desktop', '192.168.1.42'),
            ('SESS3', '2', 'Chrome - Windows', 'web', '89.123.45.67')
            ON CONFLICT DO NOTHING
        """)
        
        print("Utilisateurs par défaut créés avec mot de passe: password123")
    
    conn.commit()
    cur.close()
    conn.close()
    print("Base de données initialisée avec succès!")

# Utilitaires réseau et mDNS
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
    print(f"Service mDNS '{name}' annoncé sur {local_ip}:{port}")
    return zeroconf, info

# Routes API
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
        
        # Bonus de bienvenue
        cur.execute("""
            INSERT INTO transactions (id, type, montant, date, description, destinataire_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (f"WEL{user_id}", 'reception', 100.00, datetime.now(), '🎉 Bonus de bienvenue', user_id))
        
        # Paramètres par défaut
        cur.execute("""
            INSERT INTO user_settings (user_id, biometric_enabled, notifications_enabled, two_factor_enabled)
            VALUES (%s, FALSE, TRUE, FALSE)
        """, (user_id,))
        
        conn.commit()
        return {"success": True, "user_id": new_user['id'], "pseudo": new_user['pseudo'], "email": new_user['email'], "bonus": 100}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

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
        
        cur.execute("SELECT solde FROM users WHERE id = %s", (request.expediteur_id,))
        expediteur = cur.fetchone()
        if not expediteur:
            raise HTTPException(status_code=404, detail="Expéditeur non trouvé")
        
        if float(expediteur['solde']) < request.montant:
            raise HTTPException(status_code=400, detail="Solde insuffisant")
        
        cur.execute("""
            SELECT id FROM users 
            WHERE id = %s OR pseudo = %s OR email = %s
        """, (request.destinataire, request.destinataire, request.destinataire))
        destinataire = cur.fetchone()
        if not destinataire:
            raise HTTPException(status_code=404, detail="Destinataire non trouvé")
        
        cur.execute("UPDATE users SET solde = solde - %s WHERE id = %s", 
                   (request.montant, request.expediteur_id))
        cur.execute("UPDATE users SET solde = solde + %s WHERE id = %s", 
                   (request.montant, destinataire['id']))
        
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
            SELECT 
                t.*,
                expediteur.pseudo as expediteur_pseudo,
                destinataire.pseudo as destinataire_pseudo
            FROM transactions t
            LEFT JOIN users expediteur ON t.expediteur_id = expediteur.id
            LEFT JOIN users destinataire ON t.destinataire_id = destinataire.id
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

# Routes pour la gestion du profil et de la sécurité
@app.put("/user/{user_id}")
async def update_profile(user_id: str, request: UpdateProfileRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT id FROM users 
            WHERE (email = %s OR pseudo = %s) AND id != %s
        """, (request.email, request.pseudo, user_id))
        
        if cur.fetchone():
            raise HTTPException(status_code=400, detail="Email ou pseudo déjà utilisé")
        
        cur.execute("""
            UPDATE users 
            SET nom = %s, prenom = %s, email = %s, phone = %s, pseudo = %s
            WHERE id = %s
            RETURNING id, nom, prenom, email, phone, pseudo, solde, verification_level
        """, (
            request.nom, request.prenom, request.email, 
            request.phone, request.pseudo, user_id
        ))
        
        updated_user = cur.fetchone()
        if not updated_user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        conn.commit()
        
        updated_user['solde'] = float(updated_user['solde'])
        
        return {"success": True, "user": updated_user}
        
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

@app.post("/user/change-password")
async def change_password(request: ChangePasswordRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("SELECT password_hash FROM users WHERE id = %s", (request.user_id,))
        user = cur.fetchone()
        
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        if not verify_password(request.old_password, user['password_hash']):
            raise HTTPException(status_code=401, detail="Ancien mot de passe incorrect")
        
        cur.execute("""
            UPDATE users 
            SET password_hash = %s
            WHERE id = %s
        """, (hash_password(request.new_password), request.user_id))
        
        conn.commit()
        return {"success": True, "message": "Mot de passe modifié avec succès"}
        
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

# Routes pour la gestion des paramètres de sécurité
@app.get("/user/{user_id}/settings")
async def get_user_settings(user_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            INSERT INTO user_settings (user_id, biometric_enabled, notifications_enabled, two_factor_enabled)
            VALUES (%s, FALSE, TRUE, FALSE)
            ON CONFLICT (user_id) DO NOTHING
            RETURNING *
        """, (user_id,))
        conn.commit()
        
        cur.execute("""
            SELECT * FROM user_settings WHERE user_id = %s
        """, (user_id,))
        
        settings = cur.fetchone()
        cur.close()
        conn.close()
        
        if not settings:
            return {
                "biometric_enabled": False,
                "notifications_enabled": True,
                "two_factor_enabled": False
            }
        
        return settings
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/user/{user_id}/settings")
async def update_user_settings(user_id: str, request: UpdateSettingsRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        updates = []
        values = []
        
        if request.biometric_enabled is not None:
            updates.append("biometric_enabled = %s")
            values.append(request.biometric_enabled)
        
        if request.notifications_enabled is not None:
            updates.append("notifications_enabled = %s")
            values.append(request.notifications_enabled)
        
        if request.two_factor_enabled is not None:
            updates.append("two_factor_enabled = %s")
            values.append(request.two_factor_enabled)
        
        updates.append("updated_at = %s")
        values.append(datetime.now())
        values.append(user_id)
        
        query = f"""
            UPDATE user_settings 
            SET {', '.join(updates)}
            WHERE user_id = %s
            RETURNING *
        """
        
        cur.execute(query, values)
        updated_settings = cur.fetchone()
        
        conn.commit()
        cur.close()
        conn.close()
        
        return {"success": True, "settings": updated_settings}
        
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            cur.close()
            conn.close()

# Routes pour les sessions utilisateur
@app.get("/user/{user_id}/sessions")
async def get_user_sessions(user_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM user_sessions WHERE user_id = %s", (user_id,))
        count = cur.fetchone()['count']
        
        if count == 0:
            sessions_test = [
                (f"SESS{uuid.uuid4().hex[:8]}", user_id, "iPhone 14 Pro", "mobile", "192.168.1.42"),
                (f"SESS{uuid.uuid4().hex[:8]}", user_id, "MacBook Pro", "desktop", "192.168.1.42"),
                (f"SESS{uuid.uuid4().hex[:8]}", user_id, "Chrome - Windows", "web", "89.123.45.67"),
            ]
            cur.executemany("""
                INSERT INTO user_sessions (id, user_id, device_name, device_type, ip_address)
                VALUES (%s, %s, %s, %s, %s)
            """, sessions_test)
            conn.commit()
        
        cur.execute("""
            SELECT * FROM user_sessions 
            WHERE user_id = %s AND is_active = TRUE
            ORDER BY last_active DESC
        """, (user_id,))
        
        sessions = cur.fetchall()
        cur.close()
        conn.close()
        
        for s in sessions:
            s['created_at'] = s['created_at'].isoformat() if s['created_at'] else None
            s['last_active'] = s['last_active'].isoformat() if s['last_active'] else None
        
        return {"sessions": sessions}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/user/session/{session_id}")
async def terminate_session(session_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            UPDATE user_sessions 
            SET is_active = FALSE 
            WHERE id = %s
            RETURNING id
        """, (session_id,))
        
        result = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        if not result:
            raise HTTPException(status_code=404, detail="Session non trouvée")
        
        return {"success": True, "message": "Session terminée"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/user/{user_id}/sessions")
async def terminate_all_sessions(user_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            UPDATE user_sessions 
            SET is_active = FALSE 
            WHERE user_id = %s
            RETURNING id
        """, (user_id,))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return {"success": True, "message": "Toutes les sessions ont été terminées"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Routes pour la gestion des cryptomonnaies
@app.get("/crypto/prices")
async def get_crypto_prices():
    return {
        "prices": CRYPTO_PRICES,
        "base_fiat": "EUR",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/crypto/estimate")
async def estimate_crypto(request: CryptoPriceRequest):
    if request.crypto not in CRYPTO_PRICES:
        raise HTTPException(status_code=400, detail="Cryptomonnaie non supportée")
    
    price = CRYPTO_PRICES[request.crypto]
    return {
        "crypto": request.crypto,
        "price_eur": price,
        "bkn_to_crypto_rate": 1 / price,
        "timestamp": datetime.now().isoformat()
    }

@app.post("/crypto/buy")
async def buy_crypto(request: CryptoBuyRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("SELECT solde FROM users WHERE id = %s", (request.user_id,))
        user = cur.fetchone()
        
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
        if float(user['solde']) < request.amount_bkn:
            raise HTTPException(status_code=400, detail="Solde BKN insuffisant")
        
        if request.crypto not in CRYPTO_PRICES:
            raise HTTPException(status_code=400, detail="Cryptomonnaie non supportée")
        
        crypto_price = CRYPTO_PRICES[request.crypto]
        amount_crypto = request.amount_bkn / crypto_price
        
        cur.execute("UPDATE users SET solde = solde - %s WHERE id = %s", 
                   (request.amount_bkn, request.user_id))
        
        transaction_id = f"CRYPTO{uuid.uuid4().hex[:8]}"
        
        cur.execute("""
            INSERT INTO crypto_transactions 
            (id, user_id, type, crypto, amount_bkn, amount_crypto, price_at_transaction, wallet_address)
            VALUES (%s, %s, 'buy', %s, %s, %s, %s, %s)
        """, (
            transaction_id, request.user_id, request.crypto,
            request.amount_bkn, amount_crypto, crypto_price,
            request.wallet_address
        ))
        
        cur.execute("""
            INSERT INTO transactions (id, type, montant, description, expediteur_id, metadata)
            VALUES (%s, 'crypto_buy', %s, %s, %s, %s)
        """, (
            f"TR{uuid.uuid4().hex[:8]}",
            request.amount_bkn,
            f"Achat de {amount_crypto:.8f} {request.crypto}",
            request.user_id,
            {"crypto": request.crypto, "amount_crypto": amount_crypto}
        ))
        
        conn.commit()
        
        return {
            "success": True,
            "message": f"Achat de {amount_crypto:.8f} {request.crypto} effectué",
            "transaction_id": transaction_id,
            "crypto_amount": amount_crypto,
            "bkn_spent": request.amount_bkn,
            "price": crypto_price
        }
        
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

@app.post("/crypto/sell")
async def sell_crypto(request: CryptoSellRequest):
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        if request.crypto not in CRYPTO_PRICES:
            raise HTTPException(status_code=400, detail="Cryptomonnaie non supportée")
        
        cur.execute("""
            SELECT SUM(amount_crypto) as total_crypto
            FROM crypto_transactions
            WHERE user_id = %s AND crypto = %s AND type = 'buy'
        """, (request.user_id, request.crypto))
        
        bought = cur.fetchone()['total_crypto'] or 0
        
        cur.execute("""
            SELECT SUM(amount_crypto) as total_crypto
            FROM crypto_transactions
            WHERE user_id = %s AND crypto = %s AND type = 'sell'
        """, (request.user_id, request.crypto))
        
        sold = cur.fetchone()['total_crypto'] or 0
        
        balance_crypto = float(bought) - float(sold)
        
        if balance_crypto < request.amount_crypto:
            raise HTTPException(status_code=400, detail="Solde crypto insuffisant")
        
        crypto_price = CRYPTO_PRICES[request.crypto]
        amount_bkn = request.amount_crypto * crypto_price
        
        cur.execute("UPDATE users SET solde = solde + %s WHERE id = %s", 
                   (amount_bkn, request.user_id))
        
        transaction_id = f"CRYPTO{uuid.uuid4().hex[:8]}"
        
        cur.execute("""
            INSERT INTO crypto_transactions 
            (id, user_id, type, crypto, amount_bkn, amount_crypto, price_at_transaction, wallet_address)
            VALUES (%s, %s, 'sell', %s, %s, %s, %s, %s)
        """, (
            transaction_id, request.user_id, request.crypto,
            amount_bkn, request.amount_crypto, crypto_price,
            request.wallet_address
        ))
        
        cur.execute("""
            INSERT INTO transactions (id, type, montant, description, destinataire_id, metadata)
            VALUES (%s, 'crypto_sell', %s, %s, %s, %s)
        """, (
            f"TR{uuid.uuid4().hex[:8]}",
            amount_bkn,
            f"Vente de {request.amount_crypto:.8f} {request.crypto}",
            request.user_id,
            {"crypto": request.crypto, "amount_crypto": request.amount_crypto}
        ))
        
        conn.commit()
        
        return {
            "success": True,
            "message": f"Vente de {request.amount_crypto:.8f} {request.crypto} effectuée",
            "transaction_id": transaction_id,
            "crypto_amount": request.amount_crypto,
            "bkn_received": amount_bkn,
            "price": crypto_price
        }
        
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

@app.get("/crypto/balance/{user_id}")
async def get_crypto_balance(user_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                crypto,
                SUM(CASE WHEN type = 'buy' THEN amount_crypto ELSE 0 END) as total_bought,
                SUM(CASE WHEN type = 'sell' THEN amount_crypto ELSE 0 END) as total_sold
            FROM crypto_transactions
            WHERE user_id = %s
            GROUP BY crypto
        """, (user_id,))
        
        balances = cur.fetchall()
        cur.close()
        conn.close()
        
        result = {}
        for balance in balances:
            bought = float(balance['total_bought']) if balance['total_bought'] else 0
            sold = float(balance['total_sold']) if balance['total_sold'] else 0
            result[balance['crypto']] = bought - sold
        
        return {"balances": result}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/crypto/history/{user_id}")
async def get_crypto_history(user_id: str):
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT * FROM crypto_transactions
            WHERE user_id = %s
            ORDER BY created_at DESC
        """, (user_id,))
        
        transactions = cur.fetchall()
        cur.close()
        conn.close()
        
        for t in transactions:
            t['amount_bkn'] = float(t['amount_bkn'])
            t['amount_crypto'] = float(t['amount_crypto'])
            t['price_at_transaction'] = float(t['price_at_transaction'])
            t['created_at'] = t['created_at'].isoformat() if t['created_at'] else None
        
        return {"transactions": transactions}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/forgot-password")
async def forgot_password(request: ForgotPasswordRequest):
    """
    Demande de réinitialisation de mot de passe
    """
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        # Vérifier si l'utilisateur existe
        cur.execute("SELECT id, email FROM users WHERE email = %s", (request.email,))
        user = cur.fetchone()
        
        if not user:
            # Message générique pour des raisons de sécurité
            return {
                "success": True, 
                "message": "Si cet email existe, un lien de réinitialisation a été envoyé"
            }
        
        # Générer un token unique
        token = str(uuid.uuid4())
        expiry = datetime.now() + timedelta(hours=24)
        
        # Créer la table si elle n'existe pas
        cur.execute("""
            CREATE TABLE IF NOT EXISTS password_resets (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(50) NOT NULL,
                token VARCHAR(255) NOT NULL UNIQUE,
                expires_at TIMESTAMP NOT NULL,
                used BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        """)
        
        # Supprimer les anciens tokens pour cet utilisateur
        cur.execute("DELETE FROM password_resets WHERE user_id = %s", (user['id'],))
        
        # Insérer le nouveau token
        cur.execute("""
            INSERT INTO password_resets (user_id, token, expires_at)
            VALUES (%s, %s, %s)
        """, (user['id'], token, expiry))
        
        conn.commit()
        
        # Log du token pour le développement (à retirer en production)
        print(f"Token pour {user['email']}: {token}")
        print(f"Lien de réinitialisation: appbkn://reset-password?token={token}")
        
        return {
            "success": True,
            "message": "Si cet email existe, un lien de réinitialisation a été envoyé"
        }
        
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn:
            cur.close()
            conn.close()


@app.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    """
    Réinitialiser le mot de passe avec un token
    """
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()
        
        # Vérifier si la table existe
        cur.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'password_resets'
            )
        """)
        table_exists = cur.fetchone()['exists']
        
        if not table_exists:
            raise HTTPException(status_code=400, detail="Token invalide ou expiré")
        
        # Chercher le token valide
        cur.execute("""
            SELECT pr.*, u.id as user_id
            FROM password_resets pr
            JOIN users u ON pr.user_id = u.id
            WHERE pr.token = %s 
            AND pr.used = FALSE 
            AND pr.expires_at > NOW()
        """, (request.token,))
        
        reset = cur.fetchone()
        
        if not reset:
            raise HTTPException(status_code=400, detail="Token invalide ou expiré")
        
        # Mettre à jour le mot de passe
        cur.execute("""
            UPDATE users 
            SET password_hash = %s
            WHERE id = %s
        """, (hash_password(request.new_password), reset['user_id']))
        
        # Marquer le token comme utilisé
        cur.execute("""
            UPDATE password_resets 
            SET used = TRUE 
            WHERE token = %s
        """, (request.token,))
        
        conn.commit()
        
        return {
            "success": True,
            "message": "Mot de passe réinitialisé avec succès"
        }
        
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


@app.get("/validate-reset-token/{token}")
async def validate_reset_token(token: str):
    """
    Vérifier si un token de réinitialisation est valide
    """
    try:
        conn = get_db()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT EXISTS (
                SELECT 1 FROM password_resets 
                WHERE token = %s 
                AND used = FALSE 
                AND expires_at > NOW()
            )
        """, (token,))
        
        is_valid = cur.fetchone()['exists']
        cur.close()
        conn.close()
        
        return {"valid": is_valid}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Routes pour la gestion des avatars
# Créer un dossier pour les avatars s'il n'existe pas
AVATAR_DIR = "avatars"
os.makedirs(AVATAR_DIR, exist_ok=True)

@app.post("/user/{user_id}/avatar")
async def upload_avatar(user_id: str, file: UploadFile = File(...)):
    try:
        print(f"Réception d'un fichier: {file.filename}")
        print(f"Content type: {file.content_type}")
        
        # Vérifier que c'est une image
        if not file.content_type.startswith('image/'):
            print(f"Pas une image: {file.content_type}")
            raise HTTPException(status_code=400, detail="Le fichier doit être une image")
        
        # Créer un nom de fichier unique
        file_extension = file.filename.split('.')[-1]
        filename = f"avatar_{user_id}_{uuid.uuid4().hex[:8]}.{file_extension}"
        file_path = os.path.join(AVATAR_DIR, filename)
        
        print(f"Sauvegarde dans: {file_path}")
        
        # Sauvegarder le fichier
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        print(f"Fichier sauvegardé: {filename}")
        
        # URL de l'avatar
        avatar_url = f"/avatars/{filename}"
        
        # Mettre à jour la base de données
        conn = get_db()
        cur = conn.cursor()
        cur.execute("UPDATE users SET avatar_url = %s WHERE id = %s", (avatar_url, user_id))
        conn.commit()
        cur.close()
        conn.close()
        
        print(f"Base de données mise à jour pour user {user_id}")
        
        return {"success": True, "avatar_url": avatar_url}
        
    except Exception as e:
        print(f" ERREUR: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Monter le dossier des avatars pour servir les fichiers statiques
app.mount("/avatars", StaticFiles(directory="avatars"), name="avatars")

# DÉMARRAGE
if __name__ == "__main__":
    print("Dans if __name__ == '__main__'")
    print("Initialisation de la base de données...")
    init_database()
    
    local_ip = get_local_ip()
    
    try:
        print("\n" + "="*10)
        print("🚀 BKN API DÉMARRÉE".center(60))
        print("="*10)
        print(f"📡 API réseau local: http://{local_ip}:8000")
        print(f"📊 Swagger docs: http://{local_ip}:8000/docs")
        print("="*10)
        print("👤 Utilisateurs par défaut: john.doe@email.com / password123")
        print("="*10)
        print("💰 Routes Crypto disponibles:")
        print("   • GET /crypto/prices - Prix des cryptos")
        print("   • POST /crypto/buy - Acheter crypto")
        print("   • POST /crypto/sell - Vendre crypto")
        print("   • GET /crypto/balance/{user_id} - Solde crypto")
        print("   • GET /crypto/history/{user_id} - Historique crypto")
        print("="*10)
        print(" Route Avatar disponible:")
        print("   • POST /user/{user_id}/avatar - Upload photo de profil")
        print("   • GET /avatars/{filename} - Accès aux photos")
        print("="*10)
        print("🚀 Lancement de uvicorn...")
        uvicorn.run(app, host="0.0.0.0", port=8000)
    finally:
        pass
    
else:
    print(f"Le script est importé comme module (__name__ = {__name__})")