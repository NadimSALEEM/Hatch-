from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import Utilisateur
from app.models.user import CreerUtilisateur, MiseAJourUtilisateur, LireUtilisateur
from app.routers.auth import get_current_user

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/me", response_model=LireUtilisateur)
def lire_profil(utilisateur: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Récupère les informations du profil de l'utilisateur connecté.
    """
    utilisateur_db = db.query(Utilisateur).filter(Utilisateur.email == utilisateur["email"]).first()
    if not utilisateur_db:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return utilisateur_db

@router.put("/me/update")
def mettre_a_jour_profil(update_data: MiseAJourUtilisateur, utilisateur: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Met à jour les informations du profil de l'utilisateur (nom, email, téléphone, date de naissance, photo, bio, coach assigné).
    """
    utilisateur_db = db.query(Utilisateur).filter(Utilisateur.email == utilisateur["email"]).first()
    if not utilisateur_db:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    if update_data.nom_utilisateur:
        utilisateur_db.nom_utilisateur = update_data.nom_utilisateur
    if update_data.email:
        utilisateur_db.email = update_data.email
    if update_data.telephone:
        utilisateur_db.telephone = update_data.telephone
    if update_data.date_naissance:
        utilisateur_db.date_naissance = update_data.date_naissance
    if update_data.photo_profil:
        utilisateur_db.photo_profil = update_data.photo_profil
    if update_data.biographie:
        utilisateur_db.biographie = update_data.biographie
    if update_data.coach_assigne is not None:
        utilisateur_db.coach_assigne = update_data.coach_assigne

    db.commit()
    return {"result": "success", "code": 200, "detail": "Profil mis à jour"}

@router.delete("/me/supprimer")
def supprimer_profil(utilisateur: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Supprime le compte de l'utilisateur connecté.
    """
    utilisateur_db = db.query(Utilisateur).filter(Utilisateur.email == utilisateur["email"]).first()
    if not utilisateur_db:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    db.delete(utilisateur_db)
    db.commit()
    return {"message": "Compte utilisateur supprimé avec succès"}
