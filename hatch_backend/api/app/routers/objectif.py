import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.objectif import Objectif, LireObjectif, CreerObjectif, ModifierObjectif
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
    prefix="/objectifs",
    tags=["objectifs"]
)

@router.get("/{objectif_id}", response_model=LireObjectif)
def lire_objectif(
    objectif_id: int,
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
        objectif = db.query(Objectif).filter(
            Objectif.id == objectif_id,
            Objectif.user_id == user_id
        ).first()

        if not objectif:
            raise HTTPException(status_code=404, detail="Objectif non trouvée ou accès interdit")

        print(f"Objectif trouvé: {objectif}")

        #Retourne l'objet `habitude` converti en `LireHabitude`
        return LireObjectif.from_orm(objectif)

    except HTTPException as http_err:
        raise http_err

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne du serveur: {str(e)}")
    

@router.post("/create", response_model=CreerObjectif, status_code=status.HTTP_201_CREATED)
def creer_habitude(
    objectif_data: CreerObjectif,
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
    nouvel_objectif = Objectif(
        habit_id=objectif_data.habit_id,
        user_id=utilisateur_db.id,
        nom=objectif_data.nom,
        statut=objectif_data.statut,
        coach_id=objectif_data.coach_id,
        compteur=objectif_data.compteur,
        total=objectif_data.total,
        unite_compteur=objectif_data.unite_compteur,
        debut=datetime.utcnow()
    )

    # Ajouter et enregistrer dans la base de données
    db.add(nouvel_objectif)
    db.commit()
    db.refresh(nouvel_objectif)

    return nouvel_objectif

@router.put("/edit")
def modifier_objectif(
    objectif_data: ModifierObjectif,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Modifie un objectif existant appartenant à l'utilisateur connecté.
    """

    if not objectif_data.id:
        logger.info("Modification échouée : L'ID de l'objectif est requis")
        raise HTTPException(status_code=400, detail="L'ID de l'objectif est requis")

    objectif = db.query(Objectif).filter(
        Objectif.id == objectif_data.id, 
        Objectif.user_id == utilisateur["id"]
    ).first()

    if not objectif:
        logger.info(f"Modification échouée : Objectif ID {objectif_data.id} non trouvée pour l'utilisateur {utilisateur['id']}")
        raise HTTPException(status_code=404, detail="Habitude non trouvée ou accès non autorisé")

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
    if objectif_data.coach_id is not None:
        objectif.coach_id = objectif_data.coach_id
    if objectif_data.user_id is not None:
        objectif.user_id = objectif_data.user_id
    


    db.commit()
    logger.info(f"Modification réussie : Objectif ID {objectif.id} mise à jour par l'utilisateur {utilisateur['id']}")

    return {"result": "success", "code": 200, "detail": "Objectif mis à jour"}


@router.delete("/delete")
def supprimer_objectif(
    habitude_data: ModifierObjectif,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    
    # Vérifier si l'habitude existe et appartient à l'utilisateur
    objectif = db.query(Objectif).filter(
        Objectif.id == habitude_data.id, 
        Objectif.user_id == utilisateur["id"]
    ).first()

    if not objectif:
        raise HTTPException(status_code=404, detail="Objectif non trouvée ou accès non autorisé")
    
    db.delete(objectif)
    db.commit()

    return {"message": "Objectif supprimé avec succès"}