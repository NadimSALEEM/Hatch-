import os
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from pydantic import BaseModel
from typing import Optional

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
    mot_de_passe_hache = Column(String, nullable=False)
    telephone = Column(String, unique=True, index=True, nullable=False)
    date_naissance = Column(DateTime, nullable=True)
    cree_le = Column(DateTime, default=datetime.utcnow)
    photo_profil = Column(String, nullable=True)  # Lien vers l'image de profil
    biographie = Column(String, nullable=True)
    coach_assigne = Column(Integer, nullable=True)  # ID du coach si assigné


# Modèles Pydantic pour l'API Utilisateur
class CreerUtilisateur(BaseModel):
    nom_utilisateur: str
    email: str
    telephone: str  # Ajout du champ téléphone
    mot_de_passe: str
    date_naissance: Optional[datetime] = None
    photo_profil: Optional[str] = None  # Ajout du champ optionnel pour l'affichage
    biographie: Optional[str] = None  # Ajout du champ optionnel pour l'affichage
    coach_assigne: Optional[int] = None  # Ajout du champ optionnel pour l'affichage


class MiseAJourUtilisateur(BaseModel):
    nom_utilisateur: Optional[str] = None
    email: Optional[str] = None
    telephone: Optional[str] = None
    date_naissance: Optional[datetime] = None
    photo_profil: Optional[str] = None
    biographie: Optional[str] = None
    coach_assigne: Optional[int] = None


class LireUtilisateur(BaseModel):
    id: int
    nom_utilisateur: str
    email: str
    telephone: Optional[str] = None
    date_naissance: Optional[datetime] = None
    photo_profil: Optional[str] = None
    biographie: Optional[str] = None
    coach_assigne: Optional[int] = None

    class Config:
        orm_mode = True

class SupprimerUtilisateur(BaseModel):
    id: int

Base.metadata.create_all(engine)
