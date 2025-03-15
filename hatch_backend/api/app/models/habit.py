import os
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ARRAY, create_engine, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Literal
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
    desc = Column(String, nullable=True)
    statut = Column(Integer, default = 1)
    cree_le = Column(DateTime, default=datetime.utcnow)
    maj_le = Column(DateTime)
    termine_le = Column(DateTime)
    freq =Column(String, nullable=True) #Quotidien, hebdomadaire etc
    prio = Column(Enum("haute", "moyenne", "basse", name="priorite_enum"), nullable=True)  # Enum pour limiter à 3 valeurs [haute, moyenne, basse]
    labels = Column(ARRAY(String), nullable=True)

# Modèles Pydantic pour l'API
class CreerHabitude(BaseModel):
    nom: str
    statut: int
    user_id: Optional[int] = None
    freq: Optional[str] = None
    prio: Optional[Literal["haute", "moyenne", "basse"]] = None
    desc: Optional[str] = None
    labels: Optional[List[str]] = None

class ModifierHabitude(BaseModel):
    id: Optional[int] = None
    nom: Optional[str] = None
    desc: Optional[str] = None
    statut: Optional[int] = None
    freq: Optional[str] = None
    prio: Optional[Literal["haute", "moyenne", "basse"]] = None
    labels: Optional[List[str]] = None

class LireHabitude(BaseModel):
    id: Optional[int] = None
    user_id: Optional[int] = None
    nom: Optional[str] = None
    desc: Optional[str] = None
    statut: Optional[int] = None
    cree_le: Optional[datetime] = None
    maj_le: Optional[datetime] = None
    freq: Optional[str] = None
    prio: Optional[Literal["haute", "moyenne", "basse"]] = None
    labels: Optional[List[str]] = None

    model_config = ConfigDict(from_attributes=True)


# Création des tables avec gestion des erreurs
try:
    Base.metadata.create_all(engine)
except SQLAlchemyError as e:
    print(f"Erreur lors de la création des tables : {e}")
