"""Migration SQLite (démo) : ajoute le support Wallet crypto (cash_usd + tables holdings/transactions).

À lancer UNE FOIS depuis le dossier server :
    python migrate_wallet_schema.py
"""

from __future__ import annotations

import sqlite3
from pathlib import Path


DB_PATH = Path(__file__).with_name("wallet.db")


def column_exists(cur: sqlite3.Cursor, table: str, col: str) -> bool:
    cur.execute(f"PRAGMA table_info({table})")
    return any(row[1] == col for row in cur.fetchall())


def table_exists(cur: sqlite3.Cursor, table: str) -> bool:
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?", (table,))
    return cur.fetchone() is not None


def main() -> None:
    if not DB_PATH.exists():
        print(f"[INFO] {DB_PATH} n'existe pas. Lance d'abord le serveur une fois pour créer la DB.")
        return

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # USERS: cash_usd
    if table_exists(cur, "users"):
        if not column_exists(cur, "users", "cash_usd"):
            print("[MIGRATE] Ajout colonne users.cash_usd ...")
            cur.execute("ALTER TABLE users ADD COLUMN cash_usd NUMERIC NOT NULL DEFAULT 10000.00")
        else:
            print("[OK] users.cash_usd déjà présent.")
    else:
        print("[WARN] Table users absente. Lance le serveur une fois, puis relance ce script.")
        conn.close()
        return

    # HOLDINGS
    if not table_exists(cur, "holdings"):
        print("[MIGRATE] Création table holdings ...")
        cur.execute(
            """
            CREATE TABLE holdings (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                coin_id TEXT NOT NULL,
                amount NUMERIC NOT NULL DEFAULT 0,
                FOREIGN KEY(user_id) REFERENCES users(id)
            )
            """
        )
        cur.execute("CREATE INDEX idx_holdings_user_id ON holdings(user_id)")
        cur.execute("CREATE INDEX idx_holdings_coin_id ON holdings(coin_id)")
    else:
        print("[OK] holdings déjà présent.")

    # TRANSACTIONS
    if not table_exists(cur, "transactions"):
        print("[MIGRATE] Création table transactions ...")
        cur.execute(
            """
            CREATE TABLE transactions (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                side TEXT NOT NULL,
                coin_id TEXT NOT NULL,
                price_usd NUMERIC NOT NULL,
                usd_amount NUMERIC NOT NULL,
                coin_amount NUMERIC NOT NULL,
                fee_usd NUMERIC NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL DEFAULT (datetime('now')),
                FOREIGN KEY(user_id) REFERENCES users(id)
            )
            """
        )
        cur.execute("CREATE INDEX idx_transactions_user_id ON transactions(user_id)")
        cur.execute("CREATE INDEX idx_transactions_created_at ON transactions(created_at)")
    else:
        print("[OK] transactions déjà présent.")

    conn.commit()
    conn.close()
    print("[DONE] Migration wallet terminée.")


if __name__ == "__main__":
    main()
