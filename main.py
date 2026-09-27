from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # 1. Importamos el middleware de CORS
from sqlalchemy import create_engine, text
from pymongo import MongoClient
import os

app = FastAPI(title="Backend Entorno Dev")

# 2. Configurar los permisos de CORS para permitir conexiones externas
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite que cualquier origen (como tu Flutter Web) se conecte
    allow_credentials=True,
    allow_methods=["*"],  # Permite todos los métodos (GET, POST, etc.)
    allow_headers=["*"],  # Permite todas las cabeceras
)

# Configuración de conexiones usando los nombres de servicios de tu Docker Compose
DATABASE_URL = "postgresql+psycopg2://admin:admin123@postgres:5432/app_db"
MONGO_URL = "mongodb://admin:admin123@mongo:27017/"

# Inicializar clientes de bases de datos
engine = create_engine(DATABASE_URL)
mongo_client = MongoClient(MONGO_URL)

@app.get("/")
def read_root():
    return {"status": "online", "message": "Backend funcionando con FastAPI"}

@app.get("/healthcheck")
def health_check():
    health_status = {}
    
    # Probar conexión con PostgreSQL
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        health_status["postgres"] = "Connected"
    except Exception as e:
        health_status["postgres"] = f"Disconnected: {str(e)}"
        
    # Probar conexión con MongoDB
    try:
        mongo_client.admin.command('ping')
        health_status["mongodb"] = "Connected"
    except Exception as e:
        health_status["mongodb"] = f"Disconnected: {str(e)}"
        
    return health_status
