import os
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from pydantic import BaseModel, ConfigDict
from typing import Optional
from sqlalchemy.exc import SQLAlchemyError

# Charger l'URL de la base de données depuis les variables d'environnement
DB_URL = os.getenv('DATABASE_URL')

engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Coach(Base):
    __tablename__ = "coach"

    id = Column(Integer, nullable = False, primary_key = True)
    nom = Column(String, nullable = False)
    mbti = Column(String, nullable = False)
    desc = Column(String)

class CreerCoach(BaseModel):
    nom: str
    mbti: str
    desc: Optional[str] = None

class ModifierCoach(BaseModel):
    id: int
    nom: Optional[str] = None
    mbti: Optional[str] = None
    desc: Optional[str] = None

class LireCoach(BaseModel):
    id: int
    nom: Optional[str] = None
    mbti: Optional[str] = None
    desc: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

# Création des tables avec gestion des erreurs
try:
    Base.metadata.create_all(engine)
except SQLAlchemyError as e:
    print(f"Erreur lors de la création des tables : {e}")