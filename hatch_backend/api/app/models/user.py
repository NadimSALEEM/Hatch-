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

class Utilisateur(Base):
    __tablename__ = "utilisateurs"

    id = Column(Integer, primary_key=True, index=True)
    nom_utilisateur = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    mot_de_passe_hache = Column(String, nullable=False)
    telephone = Column(String, unique=True, index=True, nullable=False)
    date_naissance = Column(String, nullable=True)
    cree_le = Column(DateTime, default=datetime.utcnow)
    photo_profil = Column(String, nullable=True)
    biographie = Column(String, nullable=True)
    coach_assigne = Column(Integer, nullable=True)

# Modèles Pydantic pour l'API
class CreerUtilisateur(BaseModel):
    nom_utilisateur: str
    email: str
    telephone: str
    mot_de_passe: str
    date_naissance: Optional[str] = None
    photo_profil: Optional[str] = None
    biographie: Optional[str] = None
    coach_assigne: Optional[int] = None

class MiseAJourUtilisateur(BaseModel):
    nom_utilisateur: Optional[str] = None
    email: Optional[str] = None
    telephone: Optional[str] = None
    date_naissance: Optional[str] = None
    photo_profil: Optional[str] = None
    biographie: Optional[str] = None
    coach_assigne: Optional[int] = None

class MiseAJourMotDePasse(BaseModel):
    nom_utilisateur: Optional[str] = None
    email: Optional[str] = None
    mot_de_passe_hache: str

class LireUtilisateur(BaseModel):
    id: int
    nom_utilisateur: str
    email: str
    telephone: Optional[str] = None
    date_naissance: Optional[str] = None
    photo_profil: Optional[str] = None
    biographie: Optional[str] = None
    coach_assigne: Optional[int] = None

    class Config:
        orm_mode = True

class SupprimerUtilisateur(BaseModel):
    email: Optional[str] = None
    id: Optional[int] = None

# Création des tables avec gestion des erreurs
try:
    Base.metadata.create_all(engine)
except SQLAlchemyError as e:
    print(f"Erreur lors de la création des tables : {e}")
