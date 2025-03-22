import os
from datetime import datetime
import datetime
from sqlalchemy import Column, Integer, String, DateTime, JSON, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict
from sqlalchemy.exc import SQLAlchemyError


# Charger l'URL de la base de données depuis les variables d'environnement
DB_URL = os.getenv('DATABASE_URL')

engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Objectif(Base):
    __tablename__ = "objectifs"

    id = Column(Integer, primary_key=True, index=True)
    habit_id = Column(Integer, nullable=False)
    user_id = Column(Integer, nullable=False)
    nom = Column(String, nullable=False)  # Nom de l'objectif
    unite_compteur = Column(String, nullable=False)  # Unité de mesure du compteur
    compteur = Column(Integer, default=0)  # Progression actuelle
    total = Column(Integer, nullable=False)  # Objectif final
    score_global = Column(Integer, default=0)  # score_global de l'objectif

    statut = Column(Integer, nullable=False, default=1)  # 0 = en pause, 1 = actif
    debut = Column(DateTime, nullable=True)  # Date de début de l'objectif
    dernier_update = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    # JSON pour stocker les modules interactifs activés 
    modules = Column(JSON, default={})
    """
    Exemple :
    {
        "compteur": true,
        "checkbox": false,
        "chrono": true,
        "rappel": true
    }
    """

    # Stocker l'historique des progrès
    historique_progression = Column(JSON, default=lambda: [])
    """
    Exemple :
    [
        {"date": "2024-03-01", "valeur": 10},  # 10 pompes faites le 1er mars
        {"date": "2024-03-02", "valeur": 15},  # 15 pompes le 2 mars
    ]
    """

    # Heure de rappel si "rappel" est activé
    rappel_heure = Column(String, nullable=True)  # Format HH:MM


class CreerObjectif(BaseModel):
    habit_id: int
    user_id: Optional[int]
    nom: str
    statut: int
    compteur: int = 0  # Valeur par défaut
    total: int
    unite_compteur: str
    modules: Dict[str, bool] = Field(default_factory=dict)  # Modules sélectionnés
    rappel_heure: Optional[str] = None  # Heure de rappel
    historique_progression: List[Dict[str, str | int]] = Field(default_factory=list)

class LireObjectif(BaseModel):
    id: int
    habit_id: Optional[int] = None
    user_id: Optional[int] = None
    nom: Optional[str] = None
    compteur: Optional[int] = None
    unite_compteur: Optional[str] = None
    total: Optional[int] = None
    score_global : Optional[int] = None
    statut: Optional[int] = None
    debut: Optional[datetime.datetime] = None
    modules: Dict[str, bool] = Field(default_factory=dict)  # Ajouté pour voir les modules
    historique_progression: List[Dict[str, str | int]]  = Field(default_factory=list)  # Ajouté pour suivre l'historique

    model_config = ConfigDict(from_attributes=True)

class ModifierObjectif(BaseModel):
    id: int
    user_id: Optional[int] = None
    nom: Optional[str] = None
    compteur: Optional[int] = None
    total: Optional[int] = None
    unite_compteur: Optional[str] = None
    statut: Optional[int] = None
    modules: Optional[Dict[str, bool]] = None  # Ajouté pour pouvoir modifier les modules
    historique_progression: List[Dict[str, str | int]]  = None  # Modifier l'historique si besoin


# Création des tables avec gestion des erreurs
try:
    Base.metadata.create_all(engine)
    print("Tables créées avec succès !")
except SQLAlchemyError as e:
    print(f"Erreur lors de la création des tables : {e}")