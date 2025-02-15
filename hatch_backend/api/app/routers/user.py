from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import Utilisateur
from app.models.user import UtilisateurLectureDTO, UtilisateurMiseÀJourDTO, UtilisateurCréationDTO
from app.routers.auth import get_current_user

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/me", response_model=UtilisateurLectureDTO)
def lire_profil(utilisateur_email: str = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Récupère les informations du profil de l'utilisateur connecté.
    """
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == utilisateur_email).first()
    if not utilisateur:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return utilisateur

@router.put("/me/update")
def mettre_a_jour_profil(update_data: UtilisateurMiseÀJourDTO, utilisateur_email: str = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Met à jour les informations du profil de l'utilisateur (photo, bio, coach assigné).
    """
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == utilisateur_email).first()
    if not utilisateur:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    if update_data.photo_profil:
        utilisateur.photo_profil = update_data.photo_profil
    if update_data.biographie:
        utilisateur.biographie = update_data.biographie
    # if update_data.coach_assigné is not None:
    #     utilisateur.coach_assigné = update_data.coach_assigné

    db.commit()
    return {"result": "success", "code": 200, "detail": "Profil mis à jour"}
