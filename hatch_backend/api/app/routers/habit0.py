import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.habit0 import Habitude, LireHabitude, ModifierHabitude, CreerHabitude
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

import traceback

@router.get("/{habitude_id}", response_model=LireHabitude)
def lire_habitude(
    habitude_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère toutes les caractéristiques d'une habitude spécifique de l'utilisateur connecté.
    """
    try:
        # Vérifier que `utilisateur` contient bien un ID
        user_id = utilisateur.get("id")
        if user_id is None:
            raise HTTPException(status_code=400, detail="Utilisateur non valide, ID manquant")

        # Vérification dans la base de données
        habitude = db.query(Habitude).filter(
            Habitude.id == habitude_id,
            Habitude.user_id == user_id
        ).first()

        if not habitude:
            raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès interdit")

        print(f"Habitude trouvée: {habitude}")

        #Retourne l'objet `habitude` converti en `LireHabitude`
        return LireHabitude.from_orm(habitude)

    except HTTPException as http_err:
        raise http_err

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne du serveur: {str(e)}")



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

    # Création de l'objet Habitude
    nouvelle_habitude = Habitude(
        user_id=utilisateur_db.id,
        nom=habitude_data.nom,
        desc=habitude_data.desc,
        statut=habitude_data.statut,
        label= habitude_data.label,
        freq=habitude_data.freq,
        cree_le=datetime.utcnow(),
        maj_le=datetime.utcnow()
    )

    # Ajouter et enregistrer dans la base de données
    db.add(nouvelle_habitude)
    db.commit()
    db.refresh(nouvelle_habitude)

    return nouvelle_habitude


@router.put("/edit")
def modifier_habitude(
    habitude_data: ModifierHabitude,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Modifie une habitude existante appartenant à l'utilisateur connecté.
    """

    if not habitude_data.id:
        logger.info("Modification échouée : L'ID de l'habitude est requis")
        raise HTTPException(status_code=400, detail="L'ID de l'habitude est requis")

    habitude = db.query(Habitude).filter(
        Habitude.id == habitude_data.id, 
        Habitude.user_id == utilisateur["id"]
    ).first()

    if not habitude:
        logger.info(f"Modification échouée : Habitude ID {habitude_data.id} non trouvée pour l'utilisateur {utilisateur['id']}")
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

    db.commit()
    logger.info(f"Modification réussie : Habitude ID {habitude.id} mise à jour par l'utilisateur {utilisateur['id']}")

    return {"result": "success", "code": 200, "detail": "Habitude mis à jour"}


@router.delete("/delete")
def supprimer_habitude(
    habitude_data: ModifierHabitude,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    
    # Vérifier si l'habitude existe et appartient à l'utilisateur
    habitude = db.query(Habitude).filter(
        Habitude.id == habitude_data.id, 
        Habitude.user_id == utilisateur["id"]
    ).first()

    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès non autorisé")
    
    db.delete(habitude)
    db.commit()

    return {"message": "Habitude supprimée avec succès"}