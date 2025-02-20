import os
import enum
from datetime import datetime
from typing import Optional
from sqlalchemy import (
    create_engine, Column, String, DateTime, Integer, ForeignKey, Enum, Boolean
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel

# Charger l'URL de la base de données depuis les variables d'environnement
DB_URL = os.getenv('DATABASE_URL')

engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class StatutHabitude(str, enum.Enum):
    # Enum pour suivre la progression des habitudes
    non_commence = "non_commencé"
    en_cours = "en_cours"
    termine = "terminé"


class Habitude(Base):
    # Modèle de base de données pour la table "habits"
    __tablename__ = "habitudes"

    id = Column(String, primary_key=True, index=True)
    utilisateur_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # Association à un utilisateur
    nom = Column(String, nullable=False)
    description = Column(String, nullable=True)
    statut = Column(Enum(StatutHabitude), default=StatutHabitude.non_commence)
    cree_le = Column(DateTime, default=datetime.utcnow)
    mis_à_jour_le = Column(DateTime, nullable=True, onupdate=datetime.utcnow)
    termine_le = Column(DateTime, nullable=True)
    frequence = Column(String, nullable=False)  # Exemple : "quotidien", "hebdomadaire"
    echeance = Column(DateTime, nullable=True)


# Modèles Pydantic pour l'API Habitudes


class HabitudeStatutDTO(BaseModel):
    # Modèle pour la mise à jour du statut d'une habitude
    id: str
    statut: StatutHabitude = StatutHabitude.non_commence


class HabitudeCréationDTO(BaseModel):
    # Modèle pour la création d'une nouvelle habitude
    nom: str
    description: Optional[str] = None
    statut: StatutHabitude = StatutHabitude.non_commence
    frequence: str  # "quotidien", "hebdomadaire", "mensuel"
    echeance: Optional[datetime] = None


class HabitudeMiseÀJourDTO(BaseModel):
    # Modèle pour la mise à jour d'une habitude
    id: str
    nom: Optional[str] = None
    description: Optional[str] = None
    statut: Optional[StatutHabitude] = None
    termine_le: Optional[datetime] = None
    echeance: Optional[datetime] = None


class HabitudeLectureDTO(BaseModel):
    # Modèle pour la lecture des détails d'une habitude
    id: str
    nom: str
    description: Optional[str]
    statut: StatutHabitude
    cree_le: datetime
    termine_le: Optional[datetime]
    echeance: Optional[datetime]
    frequence: str

    class Config:
        orm_mode = True


Base.metadata.create_all(engine)
