from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

from database import engine, Base
from routers import transfer_router

# Charger les variables d'environnement
load_dotenv()

# Créer les tables dans la base de données
Base.metadata.create_all(bind=engine)

# Créer l'application FastAPI
app = FastAPI(
    title="Transfer API",
    description="API REST pour l'application de transfert d'argent IKM Mobile",
    version="1.0.0"
)

# Configuration CORS (pour permettre Flutter d'accéder à l'API)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifier les domaines autorisés
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Route de test
@app.get("/api/ping")
def ping():
    """Endpoint de test pour vérifier que l'API fonctionne"""
    return {
        "success": True,
        "message": "API FastAPI OK",
        "version": "1.0.0"
    }

# Inclure les routes
app.include_router(transfer_router)

# Point d'entrée pour lancer l'application
if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("API_HOST", "0.0.0.0")
    port = int(os.getenv("API_PORT", 8000))
    
    print(f"🚀 Démarrage du serveur sur http://{host}:{port}")
    print(f"📚 Documentation interactive: http://{host}:{port}/docs")
    
    uvicorn.run(app, host=host, port=port, reload=True)