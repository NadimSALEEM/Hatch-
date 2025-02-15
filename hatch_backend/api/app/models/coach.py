import os
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from pydantic import BaseModel

# Charger l'URL de la base de données depuis les variables d'environnement
DB_URL = os.getenv('DATABASE_URL')

engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class Coach(Base):
    # Modèle de base de données pour la table "coaches"
    __tablename__ = "coaches"

    id = Column(Integer, primary_key=True, index=True)
    utilisateur_id = Column(Integer, ForeignKey("utilisateurs.id"), nullable=False)  # Lié à un utilisateur
    recommandation = Column(String, nullable=False)  # Message du coach
    créé_le = Column(DateTime, default=datetime.utcnow)


# Modèles Pydantic pour l'API Coach


class CoachRecommandationDTO(BaseModel):
    # Modèle pour stocker une recommandation du coach
    utilisateur_id: int
    recommandation: str


class CoachLectureDTO(BaseModel):
    # Modèle pour récupérer les recommandations du coach
    id: int
    utilisateur_id: int
    recommandation: str
    créé_le: datetime

    class Config:
        orm_mode = True


Base.metadata.create_all(engine)
