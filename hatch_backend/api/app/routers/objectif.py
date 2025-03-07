import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.objectif import Objectif, LireObjectif, CreerObjectif, ModifierObjectif
from typing import List
from app.models.user import Utilisateur
from app.routers.auth import get_current_user
from datetime import datetime

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/habits/{habitude_id}/objectifs",
    tags=["objectifs"]
)

# Récupérer tous les objectifs d'une habitude donnée
@router.get("/", response_model=List[LireObjectif])
def lire_objectifs_habitude(
    habitude_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère tous les objectifs liés à une habitude spécifique de l'utilisateur.
    """
    objectifs = db.query(Objectif).filter(
        Objectif.habit_id == habitude_id,
        Objectif.user_id == utilisateur["id"]
    ).all()

    if not objectifs:
        raise HTTPException(status_code=404, detail="Aucun objectif trouvé pour cette habitude")

    return objectifs


# Récupérer un objectif spécifique
@router.get("/{objectif_id}", response_model=LireObjectif)
def lire_objectif(
    habitude_id: int,
    objectif_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère un objectif spécifique lié à une habitude de l'utilisateur.
    """
    objectif = db.query(Objectif).filter(
        Objectif.id == objectif_id,
        Objectif.habit_id == habitude_id,
        Objectif.user_id == utilisateur["id"]
    ).first()

    if not objectif:
        raise HTTPException(status_code=404, detail="Objectif non trouvé ou accès interdit")

    return objectif


# Créer un nouvel objectif pour une habitude donnée
@router.post("/create", response_model=LireObjectif, status_code=status.HTTP_201_CREATED)
def creer_objectif(
    habitude_id: int,
    objectif_data: CreerObjectif,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Crée un nouvel objectif lié à une habitude spécifique pour l'utilisateur connecté.
    """
    utilisateur_db = db.query(Utilisateur).filter(Utilisateur.email == utilisateur["email"]).first()
    if not utilisateur_db:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    nouvel_objectif = Objectif(
        habit_id=habitude_id,
        user_id=utilisateur_db.id,
        nom=objectif_data.nom,
        statut=objectif_data.statut,
        compteur=objectif_data.compteur,
        total=objectif_data.total,
        unite_compteur=objectif_data.unite_compteur,
        debut=datetime.utcnow(),
        modules=objectif_data.modules,  # Ajout des modules interactifs
        historique_progression=objectif_data.historique_progression,  # Historique des progrès
        rappel_heure=objectif_data.rappel_heure  # Heure de rappel si activé
    )

    db.add(nouvel_objectif)
    db.commit()
    db.refresh(nouvel_objectif)

    return nouvel_objectif


# Modifier un objectif existant
@router.put("/{objectif_id}/edit")
def modifier_objectif(
    habitude_id: int,
    objectif_id: int,
    objectif_data: ModifierObjectif,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Modifie un objectif existant appartenant à l'utilisateur.
    """
    objectif = db.query(Objectif).filter(
        Objectif.id == objectif_id,
        Objectif.habit_id == habitude_id,
        Objectif.user_id == utilisateur["id"]
    ).first()

    if not objectif:
        raise HTTPException(status_code=404, detail="Objectif non trouvé ou accès interdit")

    if objectif_data.nom is not None:
        objectif.nom = objectif_data.nom
    if objectif_data.statut is not None:
        objectif.statut = objectif_data.statut
    if objectif_data.compteur is not None:
        objectif.compteur = objectif_data.compteur
    if objectif_data.unite_compteur is not None:
        objectif.unite_compteur = objectif_data.unite_compteur
    if objectif_data.total is not None:
        objectif.total = objectif_data.total
    if objectif_data.modules is not None:
        objectif.modules = objectif_data.modules
    if objectif_data.historique_progression is not None:
        objectif.historique_progression = objectif_data.historique_progression
    if objectif_data.rappel_heure is not None:
        objectif.rappel_heure = objectif_data.rappel_heure

    db.commit()
    logger.info(f"Objectif ID {objectif.id} mis à jour par l'utilisateur {utilisateur['id']}")

    return {"message": "Objectif mis à jour avec succès"}


# Supprimer un objectif
@router.delete("/{objectif_id}/delete")
def supprimer_objectif(
    habitude_id: int,
    objectif_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Supprime un objectif spécifique appartenant à l'utilisateur.
    """
    objectif = db.query(Objectif).filter(
        Objectif.id == objectif_id,
        Objectif.habit_id == habitude_id,
        Objectif.user_id == utilisateur["id"]
    ).first()

    if not objectif:
        raise HTTPException(status_code=404, detail="Objectif non trouvé ou accès interdit")

    db.delete(objectif)
    db.commit()
    
    return {"message": "Objectif supprimé avec succès"}
