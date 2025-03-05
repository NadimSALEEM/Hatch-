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

class Objectif(Base):
    __tablename__ = "objectifs"

    id = Column(Integer, primary_key = True, index = True)
    habit_id = Column(Integer, nullable = False)
    user_id = Column(Integer, nullable = False)
    nom = Column(String, nullable = False)
    coach_id = Column(Integer)
    compteur = Column(Integer)
    total = Column(Integer, nullable = False)
    unite_compteur = Column(String, nullable = False)
    statut = Column(Integer, nullable = False)
    debut = Column(DateTime)

class CreerObjectif(BaseModel):
    id: int
    habit_id: int
    user_id: int
    nom: str
    statut: int
    compteur: int
    total: int
    coach_id: int
    unite_compteur: str

class LireObjectif(BaseModel):
    id: int
    habit_id: Optional[int] = None
    user_id: Optional[int] = None
    nom: Optional[str] = None
    coach_id: Optional[int] = None
    compteur: Optional[int] = None
    total: Optional[int] = None
    unite_compteur: Optional[str] = None
    statut: Optional[int] = None
    debut: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class ModifierObjectif(BaseModel):
    id: int
    user_id: Optional[int] = None
    nom: Optional[str] = None
    coach_id: Optional[int] = None
    compteur: Optional[int] = None
    total: Optional[int] = None
    unite_compteur: Optional[str] = None
    statut: Optional[int] = None


# Création des tables avec gestion des erreurs
try:
    Base.metadata.create_all(engine)
except SQLAlchemyError as e:
    print(f"Erreur lors de la création des tables : {e}")