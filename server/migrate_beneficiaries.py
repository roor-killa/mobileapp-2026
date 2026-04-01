"""
Migration helper for SQLite schema mismatch on "beneficiaries" table.

Problem:
- Your existing SQLite table "beneficiaries" was created with an old schema.
- New FastAPI/SQLAlchemy model expects columns:
    owner_user_id, beneficiary_user_id, alias, created_at
- SQLite + SQLAlchemy Base.metadata.create_all() does NOT auto-migrate existing tables.

This script:
- Inspects current columns
- If schema mismatched, rebuilds the table and tries to preserve data when possible
  (by mapping old columns like user_id/owner_id + email/beneficiary_email to users.id).
- If it cannot map a row to a real user id, it will SKIP that row.

Run from the same folder that contains wallet.db (typically server/):
    python migrate_beneficiaries.py
"""

import sqlite3
from datetime import datetime

DB_PATH = "wallet.db"

REQUIRED = {"id", "owner_user_id", "beneficiary_user_id", "alias", "created_at"}


def cols(conn, table: str):
    cur = conn.execute(f"PRAGMA table_info({table})")
    return [r[1] for r in cur.fetchall()]


def table_exists(conn, table: str) -> bool:
    cur = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        (table,),
    )
    return cur.fetchone() is not None


def pick_first(existing: set[str], candidates: list[str]):
    for c in candidates:
        if c in existing:
            return c
    return None


def main():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row

    if not table_exists(conn, "beneficiaries"):
        print("OK: table beneficiaries does not exist; nothing to migrate.")
        return

    current_cols = set(cols(conn, "beneficiaries"))
    print("Current beneficiaries columns:", sorted(current_cols))

    if REQUIRED.issubset(current_cols):
        print("OK: beneficiaries schema already matches the required columns.")
        return

    # Guess mapping
    owner_col = pick_first(current_cols, ["owner_user_id", "owner_id", "user_id", "owner"])
    email_col = pick_first(current_cols, ["email", "beneficiary_email", "to_email", "target_email"])
    ben_id_col = pick_first(current_cols, ["beneficiary_user_id", "beneficiary_id", "target_user_id"])
    alias_col = pick_first(current_cols, ["alias", "name", "label"])
    created_col = pick_first(current_cols, ["created_at", "created", "ts", "timestamp"])

    print("Guessed mapping:")
    print("  owner_col   =", owner_col)
    print("  ben_id_col  =", ben_id_col)
    print("  email_col   =", email_col)
    print("  alias_col   =", alias_col)
    print("  created_col =", created_col)

    if owner_col is None:
        raise SystemExit("Cannot migrate: could not find an owner column (user_id/owner_id/owner_user_id).")

    # Build new table
    conn.execute("BEGIN")
    conn.execute("DROP TABLE IF EXISTS beneficiaries_new")
    conn.execute(
        """
        CREATE TABLE beneficiaries_new (
            id INTEGER PRIMARY KEY,
            owner_user_id INTEGER NOT NULL,
            beneficiary_user_id INTEGER NOT NULL,
            alias TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
        )
        """
    )

    # Read old rows
    cur = conn.execute("SELECT * FROM beneficiaries")
    rows = cur.fetchall()

    kept = 0
    skipped = 0

    for r in rows:
        owner_id = r[owner_col]

        # Determine beneficiary_user_id
        beneficiary_user_id = None
        if ben_id_col is not None and r[ben_id_col] is not None:
            beneficiary_user_id = int(r[ben_id_col])
        elif email_col is not None and r[email_col]:
            email = str(r[email_col]).strip().lower()
            u = conn.execute("SELECT id FROM users WHERE lower(email)=?", (email,)).fetchone()
            if u:
                beneficiary_user_id = int(u["id"])
        else:
            beneficiary_user_id = None

        if beneficiary_user_id is None:
            skipped += 1
            continue

        alias = (str(r[alias_col]).strip() if alias_col and r[alias_col] is not None else "")
        created_at = (str(r[created_col]) if created_col and r[created_col] else datetime.utcnow().isoformat())

        conn.execute(
            """
            INSERT INTO beneficiaries_new (id, owner_user_id, beneficiary_user_id, alias, created_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (
                int(r["id"]) if "id" in r.keys() and r["id"] is not None else None,
                int(owner_id),
                int(beneficiary_user_id),
                alias,
                created_at,
            ),
        )
        kept += 1

    # Replace table
    conn.execute("DROP TABLE beneficiaries")
    conn.execute("ALTER TABLE beneficiaries_new RENAME TO beneficiaries")
    conn.commit()

    print(f"Migration done. kept={kept}, skipped={skipped}.")
    print("New beneficiaries columns:", cols(conn, "beneficiaries"))


if __name__ == "__main__":
    main()
