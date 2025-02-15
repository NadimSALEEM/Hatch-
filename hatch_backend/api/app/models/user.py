import os
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from pydantic import BaseModel

# Charger l'URL de la base de données depuis les variables d'environnement
DB_URL = os.getenv('DATABASE_URL')

engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class Utilisateur(Base):
    # Modèle de base de données pour la table "users"
    __tablename__ = "utilisateurs"

    id = Column(Integer, primary_key=True, index=True)
    nom_utilisateur = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    mot_de_passe_haché = Column(String, nullable=False)
    créé_le = Column(DateTime, default=datetime.utcnow)
    photo_profil = Column(String, nullable=True)  # Lien vers l'image de profil
    biographie = Column(String, nullable=True)  # Description personnelle
    coach_assigné = Column(Integer, nullable=True)  # ID du coach si assigné


# Modèles Pydantic pour l'API Utilisateur


class UtilisateurCréationDTO(BaseModel):
    # Modèle pour la création d'un utilisateur
    nom_utilisateur: str
    email: str
    mot_de_passe: str


class UtilisateurMiseÀJourDTO(BaseModel):
    # Modèle pour la mise à jour des informations d'un utilisateur
    photo_profil: str = None
    biographie: str = None
    coach_assigné: int = None


class UtilisateurLectureDTO(BaseModel):
    # Modèle pour la lecture des informations d'un utilisateur
    id: int
    nom_utilisateur: str
    email: str
    photo_profil: str = None
    biographie: str = None
    coach_assigné: int = None

    class Config:
        orm_mode = True


Base.metadata.create_all(engine)
