import os
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.exc import SQLAlchemyError

# Charger l'URL de la base de données depuis les variables d'environnement
DB_URL = os.getenv('DATABASE_URL')

engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Habitude(Base):
    __tablename__ = "habitudes"

    id = Column(Integer, primary_key = True, index = True)
    user_id = Column(Integer, nullable = False)
    nom = Column(String, nullable = False)
    desc = Column(String)
    statut = Column(Integer, default = 0)
    cree_le = Column(DateTime, default=datetime.utcnow)
    maj_le = Column(DateTime)
    termine_le = Column(DateTime)
    freq = Column(String) #Quotidien, hebdomadaire etc
    echeance = Column(DateTime)
    label = Column(String)

# Modèles Pydantic pour l'API
class CreerHabitude(BaseModel):
    nom: str
    statut: int
    user_id: int
    label: Optional[str] = None
    freq: str
    echeance: Optional[datetime] = None
    desc: Optional[str] = None

class ModifierHabitude(BaseModel):
    id: int
    nom: Optional[str] = None
    desc: Optional[str] = None
    statut: Optional[int] = None
    freq: Optional[str] = None
    label: Optional[str] = None

class LireHabitude(BaseModel):
    id: int
    user_id: Optional[int] = None
    nom: Optional[str] = None
    desc: Optional[str] = None
    statut: Optional[int] = None
    cree_le: Optional[datetime] = None
    maj_le: Optional[datetime] = None
    freq: Optional[str] = None
    label: Optional[str] = None
    echeance: Optional[datetime] = None



# Création des tables avec gestion des erreurs
try:
    Base.metadata.create_all(engine)
except SQLAlchemyError as e:
    print(f"Erreur lors de la création des tables : {e}")
