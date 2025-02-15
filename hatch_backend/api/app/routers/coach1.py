from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from hatch_backend.api.app.models.coach1 import Coach
from app.schemas.coach import CoachRecommandationDTO
from app.routers.auth import get_current_user
from app.models.user import Utilisateur

router = APIRouter(
    prefix="/coach",
    tags=["coach"]
)

# Liste de recommandations statiques du coach
recommandations_coach = [
    "Essayez de vous lever 30 minutes plus tôt pour commencer votre journée avec une bonne habitude !",
    "Buvez au moins 2 litres d'eau par jour pour rester hydraté.",
    "Écrivez vos objectifs quotidiens chaque matin pour rester concentré.",
    "Faites une pause de 10 minutes toutes les heures pour améliorer votre productivité.",
    "Pratiquez 5 minutes de méditation chaque jour pour réduire le stress.",
]

@router.get("/recommend")
def obtenir_recommandations():
    """
    Retourne une liste de recommandations générales du coach.
    """
    return {"recommandations": recommandations_coach}

@router.post("/assign")
def assigner_recommandation(utilisateur_email: str = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Assigne une recommandation aléatoire du coach à l'utilisateur connecté.
    """
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == utilisateur_email).first()
    if not utilisateur:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    recommandation = recommandations_coach[0]  # Vous pouvez ajouter un choix aléatoire ici

    nouvelle_recommandation = Coach(
        utilisateur_id=utilisateur.id,
        recommandation=recommandation
    )
    db.add(nouvelle_recommandation)
    db.commit()
    db.refresh(nouvelle_recommandation)

    return {"result": "success", "code": 201, "detail": "Recommandation assignée", "recommandation": nouvelle_recommandation}

@router.get("/my-recommendations")
def voir_mes_recommandations(utilisateur_email: str = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Récupère toutes les recommandations assignées à l'utilisateur connecté.
    """
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == utilisateur_email).first()
    if not utilisateur:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    recommandations = db.query(Coach).filter(Coach.utilisateur_id == utilisateur.id).all()
    if not recommandations:
        return {"message": "Aucune recommandation trouvée pour cet utilisateur."}

    return recommandations
