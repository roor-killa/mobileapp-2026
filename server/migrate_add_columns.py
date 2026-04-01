"""
Migration SQLite (simple) pour ajouter les colonnes introduites après coup.

Usage (dans le dossier server, avec .venv activé) :
    python migrate_add_columns.py

Ça ne supprime rien : ça ajoute seulement si absent.
"""

import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent / "wallet.db"


def _cols(conn: sqlite3.Connection, table: str) -> set[str]:
    rows = conn.execute(f"PRAGMA table_info({table});").fetchall()
    return {r[1] for r in rows}


def _add_col(conn: sqlite3.Connection, table: str, ddl: str):
    conn.execute(f"ALTER TABLE {table} ADD COLUMN {ddl};")


def main():
    if not DB_PATH.exists():
        print(f"[!] DB introuvable: {DB_PATH}")
        return

    conn = sqlite3.connect(DB_PATH)
    try:
        # users: refresh token
        ucols = _cols(conn, "users")
        if "refresh_token_hash" not in ucols:
            print("[+] Ajout users.refresh_token_hash")
            _add_col(conn, "users", "refresh_token_hash VARCHAR(128)")
        if "refresh_expires_at" not in ucols:
            print("[+] Ajout users.refresh_expires_at")
            _add_col(conn, "users", "refresh_expires_at DATETIME")

        # bank_txs: counterparty
        tcols = _cols(conn, "bank_txs")
        if "counterparty_email" not in tcols:
            print("[+] Ajout bank_txs.counterparty_email")
            _add_col(conn, "bank_txs", "counterparty_email VARCHAR(320)")

        conn.commit()
        print("[OK] Migration terminée")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
