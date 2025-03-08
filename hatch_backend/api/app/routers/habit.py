import logging
import traceback
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.habit import Habitude, LireHabitude, ModifierHabitude, CreerHabitude
from typing import List
from app.models.user import Utilisateur
from app.routers.auth import get_current_user
from app.models.objectif import Objectif
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
        labels=habitude_data.labels,
        freq=habitude_data.freq,
        prio=habitude_data.prio,
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
    if habitude_data.labels is not None:
        habitude.labels = habitude_data.labels
    if habitude_data.prio is not None:
        habitude.prio = habitude_data.prio

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

@router.get("/{habitude_id}/stats")
def get_progress_stats(
    habitude_id: int,
    utilisateur: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Récupère les statistiques de progression pour une habitude spécifique de l'utilisateur.
    """
    today = datetime.utcnow().date()
    streak = 0
    jours_parfaits = 0
    objectifs_completes = 0
    total_progress = 0
    total_objectifs = 0

    # Récupérer les objectifs de l'utilisateur pour cette habitude
    objectifs = db.query(Objectif).filter(
        Objectif.habit_id == habitude_id,
        Objectif.user_id == utilisateur["id"]
    ).all()

    if not objectifs:
        raise HTTPException(status_code=404, detail="Aucun objectif trouvé pour cette habitude")

    # Stocker les progrès par jour
    progress_par_jour = {}

    for obj in objectifs:
        if obj.compteur >= obj.total:
            objectifs_completes += 1  # Objectifs totalement complétés

        total_progress += obj.compteur
        total_objectifs += obj.total

        # Parcourir l'historique des progrès
        for record in obj.historique_progression or []:
            jour = record["date"]
            valeur = record["valeur"]

            # Ajouter la valeur au jour correspondant
            if jour not in progress_par_jour:
                progress_par_jour[jour] = []
            progress_par_jour[jour].append(valeur)

    # 🔥 Calcul des streaks (jours consécutifs avec au moins un objectif réussi)
    sorted_days = sorted(progress_par_jour.keys(), reverse=True)
    for i, day in enumerate(sorted_days):
        if i == 0 or sorted_days[i - 1] == (datetime.strptime(day, "%Y-%m-%d").date() + timedelta(days=1)):
            streak += 1
        else:
            break  # La chaîne s'arrête si un jour est manqué

    # 🌟 Calcul des jours parfaits (tous les objectifs d'un jour réussis)
    for day, values in progress_par_jour.items():
        if sum(values) >= total_objectifs:
            jours_parfaits += 1

    # 📈 Calcul du % d'avancement global
    avancement = (total_progress / total_objectifs) * 100 if total_objectifs > 0 else 0

    return {
        "streak": streak,
        "avancement": round(avancement, 1),
        "objectifs_completes": objectifs_completes,
        "jours_parfaits": jours_parfaits
    }

