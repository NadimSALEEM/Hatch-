import logging
import traceback
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.habit import Habitude, LireHabitude, ModifierHabitude, CreerHabitude
from typing import List
from app.models.user import Utilisateur
from app.routers.auth import get_current_user
from uuid import uuid4
from datetime import datetime

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/habits",
    tags=["habits"]
)

@router.get("/", response_model=List[LireHabitude])
def lire_toutes_habitudes(
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère toutes les habitudes de l'utilisateur connecté.
    """
    user_id = utilisateur.get("id")
    if user_id is None:
        raise HTTPException(status_code=400, detail="Utilisateur non valide, ID manquant")

    habitudes = db.query(Habitude).filter(Habitude.user_id == user_id).all()

    return [LireHabitude.from_orm(h) for h in habitudes]


@router.get("/{habitude_id}", response_model=LireHabitude)
def lire_habitude(
    habitude_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère les détails d'une habitude spécifique.
    """
    habitude = db.query(Habitude).filter(
        Habitude.id == habitude_id,
        Habitude.user_id == utilisateur["id"]
    ).first()

    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès interdit")

    return LireHabitude.from_orm(habitude)


@router.post("/create", response_model=CreerHabitude, status_code=status.HTTP_201_CREATED)
def creer_habitude(
    habitude_data: CreerHabitude,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Crée une nouvelle habitude pour l'utilisateur connecté.
    """
    utilisateur_db = db.query(Utilisateur).filter(Utilisateur.email == utilisateur["email"]).first()
    if not utilisateur_db:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    nouvelle_habitude = Habitude(
        user_id=utilisateur_db.id,
        nom=habitude_data.nom,
        desc=habitude_data.desc,
        statut=habitude_data.statut,
        label=habitude_data.label,
        freq=habitude_data.freq,
        cree_le=datetime.utcnow(),
        maj_le=datetime.utcnow()
    )

    db.add(nouvelle_habitude)
    db.commit()
    db.refresh(nouvelle_habitude)

    return nouvelle_habitude


@router.put("/{habitude_id}/edit")
def modifier_habitude(
    habitude_id: int,
    habitude_data: ModifierHabitude,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Modifie une habitude spécifique.
    """
    habitude = db.query(Habitude).filter(
        Habitude.id == habitude_id, 
        Habitude.user_id == utilisateur["id"]
    ).first()

    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès non autorisé")

    if habitude_data.nom is not None:
        habitude.nom = habitude_data.nom
    if habitude_data.desc is not None:
        habitude.desc = habitude_data.desc
    if habitude_data.statut is not None:
        habitude.statut = habitude_data.statut
    if habitude_data.freq is not None:
        habitude.freq = habitude_data.freq
    if habitude_data.label is not None:
        habitude.label = habitude_data.label

    # Mise à jour automatique de `maj_le`
    habitude.maj_le = datetime.utcnow()

    db.commit()

    return {"result": "success", "code": 200, "detail": "Habitude mise à jour"}


@router.delete("/{habitude_id}/delete")
def supprimer_habitude(
    habitude_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Supprime une habitude spécifique.
    """
    habitude = db.query(Habitude).filter(
        Habitude.id == habitude_id, 
        Habitude.user_id == utilisateur["id"]
    ).first()

    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès non autorisé")

    db.delete(habitude)
    db.commit()

    return {"message": "Habitude supprimée avec succès"}
