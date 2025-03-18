import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import update
from app.db import get_db
from app.models.objectif import Objectif, LireObjectif, CreerObjectif, ModifierObjectif
from typing import List, Dict
from app.models.user import Utilisateur
from app.routers.auth import get_current_user
from datetime import datetime
import json

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
        raise HTTPException(status_code=404, detail="Objectif non trouvé")

    # ✅ Vérifier que l'historique est bien chargé
    logger.info(f"Valeur récupérée pour historique_progression : {objectif.historique_progression}")

    # ✅ Assurer que historique_progression est bien une liste
    if not isinstance(objectif.historique_progression, list):
        objectif.historique_progression = []

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



@router.post("/{objectif_id}/addprogress", status_code=status.HTTP_200_OK)
def ajouter_progression(
    habitude_id: int,
    objectif_id: int,
    progression_data: Dict[str, int | bool | str],  
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Ajoute une progression et stocke le score global (%) en base de données en `Integer`.
    """
    objectif = db.query(Objectif).filter(
        Objectif.id == objectif_id,
        Objectif.habit_id == habitude_id,
        Objectif.user_id == utilisateur["id"]
    ).first()

    if not objectif:
        raise HTTPException(status_code=404, detail="Objectif non trouvé ou accès interdit")

    # 🔍 Récupérer les modules activés
    modules_activés = [key for key, value in objectif.modules.items() if value]
    nombre_modules = len(modules_activés)

    if nombre_modules == 0:
        return {
            "message": "Aucun module activé, impossible de calculer le score.",
            "objectif_id": objectif.id,
            "nouveau_compteur": objectif.compteur,
            "score_global": objectif.score_global,
            "historique_progression": objectif.historique_progression
        }

    # 📌 Récupération des valeurs envoyées par l'utilisateur
    compteur_value = progression_data.get("compteur", 0)
    checkbox_value = progression_data.get("checkbox", False)
    chrono_value = progression_data.get("chrono", 0)
    rappel_value = progression_data.get("rappel", None)

    # ✅ Mise à jour des valeurs dans l'objectif
    if compteur_value:
        objectif.compteur += compteur_value

    if isinstance(checkbox_value, bool) and checkbox_value:
        objectif.score_global = 100  # ✅ Si checkbox cochée, objectif terminé à 100%

    if chrono_value:
        objectif.compteur += chrono_value  # Ajoute le temps passé en minutes

    if rappel_value:
        objectif.rappel_heure = rappel_value

    # ✅ Ajout à l'historique (Forcer l'enregistrement si vide)
    if not isinstance(objectif.historique_progression, list):
        objectif.historique_progression = []

    progression_entry = {
        "date": datetime.utcnow().strftime("%Y-%m-%d"),
        "compteur": compteur_value,
        "checkbox": checkbox_value,
        "chrono": chrono_value,
        "rappel": rappel_value if rappel_value is not None else ""
    }
    objectif.historique_progression.append(progression_entry)

    # 🔥 **Calcul du score global de progression (%)**
    if checkbox_value:  # ✅ Si la checkbox est cochée, l'objectif est à 100%
        total_score = 100
    else:
        total_score = 0
        poids_par_module = 100 / nombre_modules  # On répartit 100% entre les modules activés

        if "compteur" in modules_activés and objectif.total > 0:
            total_score += (objectif.compteur / objectif.total) * poids_par_module

        if "chrono" in modules_activés and chrono_value > 0:
            total_score += (chrono_value / 60) * poids_par_module

        if "rappel" in modules_activés and rappel_value:
            total_score += poids_par_module

        total_score = min(total_score, 100)  # 🔥 Ne jamais dépasser 100%

    # ✅ Enregistrer `score_global` en `Integer`
    objectif.score_global = int(total_score)

    # 🔄 Mise à jour explicite dans la base de données
    db.execute(
        update(Objectif)
        .where(Objectif.id == objectif_id)
        .values(
            compteur=objectif.compteur,
            score_global=objectif.score_global,  # 🔥 Stocké en base en tant qu'entier
            rappel_heure=objectif.rappel_heure,
            historique_progression=json.dumps(objectif.historique_progression)
        )
    )

    db.commit()
    db.refresh(objectif)  # 🔄 Rafraîchir les données après commit

    return {
        "message": "Progression ajoutée avec succès",
        "objectif_id": objectif.id,
        "nouveau_compteur": objectif.compteur,
        "score_global": objectif.score_global,  # ✅ Maintenant stocké en `Integer`
        "historique_progression": objectif.historique_progression
    }
