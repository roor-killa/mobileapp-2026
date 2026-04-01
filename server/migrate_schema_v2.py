"""
Migration SQLite (idempotente) pour aligner wallet.db avec la version "beneficiaries + watchlist + orders + counterparty".

Usage (Windows PowerShell):
  cd server
  .\.venv\Scripts\Activate.ps1
  python migrate_schema_v2.py

Par défaut, utilise DATABASE_URL (env) ou sqlite:///./wallet.db.
"""

import os
import sqlite3
from urllib.parse import urlparse

DEFAULT_DB_URL = os.getenv("DATABASE_URL", "sqlite:///./wallet.db")


def _sqlite_path(db_url: str) -> str:
    # attend "sqlite:///./wallet.db" ou "sqlite:////abs/path.db"
    if not db_url.startswith("sqlite"):
        raise SystemExit("Ce script ne gère que SQLite (DATABASE_URL doit commencer par sqlite).")
    u = urlparse(db_url)
    path = u.path or ""
    # windows: /C:/... -> C:/...
    if path.startswith("/") and len(path) > 2 and path[2] == ":":
        path = path[1:]
    if path.startswith("/"):
        path = path[1:]
    return path or "wallet.db"


def table_exists(cur, name: str) -> bool:
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?", (name,))
    return cur.fetchone() is not None


def columns(cur, table: str) -> set[str]:
    cur.execute(f"PRAGMA table_info({table})")
    return {row[1] for row in cur.fetchall()}


def add_column(cur, table: str, col_sql: str):
    cur.execute(f"ALTER TABLE {table} ADD COLUMN {col_sql}")


def main():
    path = _sqlite_path(DEFAULT_DB_URL)
    print(f"[migrate] DB: {path}")
    con = sqlite3.connect(path)
    try:
        cur = con.cursor()

        # --- beneficiaries ---
        if table_exists(cur, "beneficiaries"):
            cols = columns(cur, "beneficiaries")
            if "owner_user_id" not in cols:
                print("[migrate] beneficiaries: add owner_user_id")
                add_column(cur, "beneficiaries", "owner_user_id INTEGER")
                # backfill from legacy "user_id" if present
                cols2 = columns(cur, "beneficiaries")
                if "user_id" in cols2:
                    print("[migrate] beneficiaries: backfill owner_user_id <- user_id")
                    cur.execute("UPDATE beneficiaries SET owner_user_id = user_id WHERE owner_user_id IS NULL")
            else:
                print("[migrate] beneficiaries: ok")

        # --- bank_txs counterparty ---
        if table_exists(cur, "bank_txs"):
            cols = columns(cur, "bank_txs")
            if "counterparty_user_id" not in cols:
                print("[migrate] bank_txs: add counterparty_user_id")
                add_column(cur, "bank_txs", "counterparty_user_id INTEGER")
            if "counterparty_email" not in cols:
                print("[migrate] bank_txs: add counterparty_email")
                add_column(cur, "bank_txs", "counterparty_email TEXT NOT NULL DEFAULT ''")

            # backfill simple: parse "Reçu de <email>" for TRANSFER_IN
            print("[migrate] bank_txs: backfill counterparty_email for TRANSFER_IN (best-effort)")
            cur.execute(
                """
                UPDATE bank_txs
                SET counterparty_email = TRIM(REPLACE(note, 'Reçu de ', ''))
                WHERE kind = 'TRANSFER_IN'
                  AND counterparty_email = ''
                  AND note LIKE 'Reçu de %'
                """
            )

        # --- watchlist table ---
        if not table_exists(cur, "watchlist"):
            print("[migrate] create watchlist")
            cur.execute(
                """
                CREATE TABLE watchlist (
                    id INTEGER PRIMARY KEY,
                    user_id INTEGER NOT NULL,
                    coin_id TEXT NOT NULL,
                    created_at TEXT NOT NULL
                )
                """
            )
            cur.execute("CREATE UNIQUE INDEX uq_watchlist_user_coin ON watchlist(user_id, coin_id)")
            cur.execute("CREATE INDEX ix_watchlist_user_id ON watchlist(user_id)")
            cur.execute("CREATE INDEX ix_watchlist_coin_id ON watchlist(coin_id)")

        # --- orders table ---
        if not table_exists(cur, "orders"):
            print("[migrate] create orders")
            cur.execute(
                """
                CREATE TABLE orders (
                    id INTEGER PRIMARY KEY,
                    user_id INTEGER NOT NULL,
                    coin_id TEXT NOT NULL,
                    side TEXT NOT NULL,
                    order_type TEXT NOT NULL,
                    trigger_price_usd NUMERIC NOT NULL,
                    usd_amount NUMERIC,
                    coin_amount NUMERIC,
                    use_all INTEGER NOT NULL DEFAULT 0,
                    status TEXT NOT NULL DEFAULT 'OPEN',
                    created_at TEXT NOT NULL,
                    triggered_at TEXT
                )
                """
            )
            cur.execute("CREATE INDEX ix_orders_user_id ON orders(user_id)")
            cur.execute("CREATE INDEX ix_orders_coin_id ON orders(coin_id)")
        else:
            cols = columns(cur, "orders")
            if "use_all" not in cols:
                print("[migrate] orders: add use_all")
                add_column(cur, "orders", "use_all INTEGER NOT NULL DEFAULT 0")

        con.commit()
        print("[migrate] done ✅")
    finally:
        con.close()


if __name__ == "__main__":
    main()
