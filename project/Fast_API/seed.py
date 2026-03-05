"""
Script pour créer des utilisateurs de test avec des wallets
"""
from sqlalchemy.orm import Session
from database import SessionLocal, engine, Base
from models import User, Wallet
from decimal import Decimal

def create_test_data():
    # Créer les tables
    Base.metadata.create_all(bind=engine)
    
    # Créer une session
    db = SessionLocal()
    
    try:
        # Vérifier si l'utilisateur existe déjà
        existing_user = db.query(User).filter(User.email == "test@ikm.com").first()
        
        if existing_user:
            print("⚠️  L'utilisateur test existe déjà")
            print(f"🆔 User ID: {existing_user.id}")
            if existing_user.wallet:
                print(f"💰 Solde: {existing_user.wallet.solde} EUR")
            return
        
        # Créer un utilisateur de test
        user = User(
            name="IKM Test User",
            email="test@ikm.com",
            password="$2b$12$hashed_password_here",  # En production, utiliser bcrypt
            phone="+596696123456"
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        
        # Créer son wallet avec solde initial
        wallet = Wallet(
            user_id=user.id,
            solde=Decimal("1500.50"),
            devise="EUR",
            is_active=True
        )
        
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
        
        print("✅ Utilisateur créé avec succès!")
        print(f"📧 Email: test@ikm.com")
        print(f"🔑 Password: password123")
        print(f"🆔 User ID: {user.id}")
        print(f"💰 Solde initial: {wallet.solde} EUR")
        
        # Créer quelques autres utilisateurs
        for i in range(1, 4):
            other_user = User(
                name=f"User Test {i}",
                email=f"user{i}@test.com",
                password="$2b$12$hashed_password_here",
                phone=f"+59669612345{i}"
            )
            db.add(other_user)
            db.commit()
            db.refresh(other_user)
            
            other_wallet = Wallet(
                user_id=other_user.id,
                solde=Decimal(str(500 + i * 500)),
                devise="EUR",
                is_active=True
            )
            db.add(other_wallet)
            db.commit()
            
            print(f"✅ User {i} créé (ID: {other_user.id})")
        
        print("\n🎉 Toutes les données de test ont été créées!")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_test_data()