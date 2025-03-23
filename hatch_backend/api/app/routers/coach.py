import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.coach import Coach, LireCoach, CreerCoach, ModifierCoach
from typing import List
from app.models.user import Utilisateur
from app.routers.auth import get_current_user
from uuid import uuid4
from datetime import datetime
import traceback

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/coach",
    tags=["coach"]
)

@router.get("/{coach_id}", response_model=LireCoach)
def lire_coach(
    coach_id: int,
    #utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère toutes les caractéristiques d'un coach spécifique de l'utilisateur connecté.
    """
    try:
        # Vérifier que `utilisateur` contient bien un ID
        #user_id = utilisateur.get("id")
        #if user_id is None:
        #    raise HTTPException(status_code=400, detail="Utilisateur non valide, ID manquant")

        # Vérification dans la base de données
        coach = db.query(Coach).filter(
            Coach.id == coach_id,
        ).first()

        if not coach:
            raise HTTPException(status_code=404, detail="coach non trouvée ou accès interdit")

        print(f"Objectif trouvé: {coach}")

        #Retourne l'objet `habitude` converti en `LireHabitude`
        return LireCoach.from_orm(coach)

    except HTTPException as http_err:
        raise http_err

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne du serveur: {str(e)}")

@router.get("/", response_model=List[LireCoach])
def get_all_coachs(db: Session = Depends(get_db)):
    """
    Récupère la liste complète des coachs.
    """
    try:
        return db.query(Coach).all()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/create", response_model=CreerCoach, status_code=status.HTTP_201_CREATED)
def creer_coach(
    coach_data: CreerCoach,
    db: Session = Depends(get_db)
):
    # Création de l'objet Coach
    nouveau_coach = Coach(
        nom=coach_data.nom,
        desc=coach_data.desc,
        mbti=coach_data.mbti
   )

    # Ajouter et enregistrer dans la base de données
    db.add(nouveau_coach)
    db.commit()
    db.refresh(nouveau_coach)

    return nouveau_coach

@router.put("/edit")
def modifier_coach(
    coach_data: ModifierCoach,
    db: Session = Depends(get_db)
):
    """
    Modifie un coach existant
    """

    if not coach_data.id:
        logger.info("Modification échouée : L'ID de l'objectif est requis")
        raise HTTPException(status_code=400, detail="L'ID de l'objectif est requis")

    coach = db.query(Coach).filter(
        Coach.id == coach_data.id, 
    ).first()

    if not coach:
        logger.info(f"Modification échouée : Objectif ID {coach_data.id} non trouvé")
        raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès non autorisé")

    if coach_data.nom is not None:
        coach.nom = coach_data.nom
    if coach_data.desc is not None:
        coach.desc = coach_data.desc
    if coach_data.mbti is not None:
        coach.mbti = coach_data.mbti
    


    db.commit()
    logger.info(f"Modification réussie : Objectif ID {coach.id} mise à jour")

    return {"result": "success", "code": 200, "detail": "Objectif mis à jour"}


@router.delete("/delete")
def supprimer_coach(
    coach_data: ModifierCoach,
    db: Session = Depends(get_db)
):
    
    # Vérifier si le coach existe et appartient à l'utilisateur
    coach = db.query(Coach).filter(
        Coach.id == coach_data.id, 
    ).first()

    if not coach:
        raise HTTPException(status_code=404, detail="Coach non trouvé ou accès non autorisé")
    
    db.delete(coach)
    db.commit()

    return {"message": "Coach supprimé avec succès"}