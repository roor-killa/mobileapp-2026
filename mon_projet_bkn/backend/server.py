import sqlite3
import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

DB_NAME = "bkn_app.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    # 1. Table des utilisateurs (Portefeuilles)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS wallets (
            user_id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            balance REAL NOT NULL
        )
    ''')
    
    # 2. NOUVEAU : Table des transactions (Historique)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_id INTEGER,
            receiver_id INTEGER,
            amount REAL,
            date TEXT
        )
    ''')
    
    # Données initiales si vide
    cursor.execute('SELECT count(*) FROM wallets')
    if cursor.fetchone()[0] == 0:
        print("Initialisation des données de test...")
        cursor.execute('INSERT INTO wallets VALUES (1, "User 1", 5000.0)')
        cursor.execute('INSERT INTO wallets VALUES (2, "User 2", 1500.0)')
        conn.commit()
    
    conn.close()

# --- API TRANSFERT (Mise à jour pour enregistrer l'historique) ---
@app.route('/api/transfer', methods=['POST'])
def transfer_money():
    data = request.get_json()
    sender_id = int(data.get('sender_id', 1))
    amount = float(data.get('amount', 0))
    receiver_id = 2 if sender_id == 1 else 1 

    if amount <= 0:
        return jsonify({"success": False, "message": "Montant invalide"}), 400

    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute('SELECT balance FROM wallets WHERE user_id = ?', (sender_id,))
    sender_row = cursor.fetchone()
    cursor.execute('SELECT balance FROM wallets WHERE user_id = ?', (receiver_id,))
    receiver_row = cursor.fetchone()
    
    if not sender_row or not receiver_row:
        conn.close()
        return jsonify({"success": False, "message": "Utilisateur introuvable"}), 404

    if sender_row[0] < amount:
        conn.close()
        return jsonify({
            "success": False, 
            "message": "Solde insuffisant",
            "nouveau_solde": sender_row[0]
        })

    try:
        # 1. Mise à jour des soldes
        new_sender_balance = sender_row[0] - amount
        cursor.execute('UPDATE wallets SET balance = ? WHERE user_id = ?', (new_sender_balance, sender_id))
        cursor.execute('UPDATE wallets SET balance = balance + ? WHERE user_id = ?', (amount, receiver_id))
        
        # 2. ENREGISTREMENT DANS L'HISTORIQUE
        date_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cursor.execute('''
            INSERT INTO transactions (sender_id, receiver_id, amount, date)
            VALUES (?, ?, ?, ?)
        ''', (sender_id, receiver_id, amount, date_str))
        
        conn.commit()
        
        response = {
            "success": True,
            "message": "Transfert réussi !",
            "nouveau_solde": new_sender_balance
        }
        
    except Exception as e:
        conn.rollback()
        response = {"success": False, "message": str(e)}
    
    finally:
        conn.close()

    return jsonify(response)

# --- API SOLDE ---
@app.route('/api/balance/<int:user_id>', methods=['GET'])
def get_balance(user_id):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('SELECT balance FROM wallets WHERE user_id = ?', (user_id,))
    row = cursor.fetchone()
    conn.close()
    return jsonify({"balance": row[0] if row else 0.0})

# --- NOUVEAU : API HISTORIQUE ---
@app.route('/api/history', methods=['GET'])
def get_history():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row # Pour avoir les noms de colonnes
    cursor = conn.cursor()
    
    # On récupère les 50 dernières transactions, de la plus récente à la plus ancienne
    cursor.execute('SELECT * FROM transactions ORDER BY id DESC LIMIT 50')
    rows = cursor.fetchall()
    
    # Conversion en liste de dictionnaires (JSON)
    history = []
    for row in rows:
        history.append({
            "id": row["id"],
            "sender_id": row["sender_id"],
            "receiver_id": row["receiver_id"],
            "amount": row["amount"],
            "date": row["date"]
        })
        
    conn.close()
    return jsonify(history)

if __name__ == '__main__':
    init_db()
    app.run(port=8000, debug=True)
