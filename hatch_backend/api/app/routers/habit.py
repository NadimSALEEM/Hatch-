from fastapi import APIRouter, HTTPException, Depends, status, Response
from sqlalchemy.orm import Session
from typing import List
from uuid import uuid4
from datetime import datetime
from app.models.habit import Habitude, HabitudeCréationDTO, HabitudeLectureDTO, HabitudeMiseÀJourDTO, StatutHabitude
from app.db import get_db

router = APIRouter(
    prefix="/habits",
    tags=["habits"]
)

@router.get("/endpoint")
async def endpoint_personnalisé():
    return {"message": "Ceci est un endpoint personnalisé pour les habitudes"}

@router.post("/", status_code=201)
def créer_habitude(habitude: HabitudeCréationDTO, db: Session = Depends(get_db)):
    habitude_nouvelle = Habitude(
        id=str(uuid4()),
        nom=habitude.nom,
        description=habitude.description,
        statut=habitude.statut,
        fréquence=habitude.fréquence,
        échéance=habitude.échéance
    )
    db.add(habitude_nouvelle)
    db.commit()
    db.refresh(habitude_nouvelle)
    return {"result": "success", "code": 201, "detail": "Habitude créée", "habitude": habitude_nouvelle}

@router.get("/", response_model=List[HabitudeLectureDTO])
def lire_toutes_les_habitudes(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    habitudes = db.query(Habitude).offset(skip).limit(limit).all()
    return habitudes

@router.get("/{habitude_id}")
def lire_une_habitude(habitude_id: str, db: Session = Depends(get_db)):
    habitude = db.query(Habitude).filter(Habitude.id == habitude_id).first()
    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée")
    return {"result": "success", "code": 200, "habitude": habitude}

@router.put("/{habitude_id}", status_code=200)
def mettre_a_jour_habitude(habitude_id: str, habitude_update: HabitudeMiseÀJourDTO, db: Session = Depends(get_db)):
    if habitude_id != habitude_update.id:
        raise HTTPException(status_code=400, detail="L'ID de l'habitude ne correspond pas")

    habitude = db.query(Habitude).filter(Habitude.id == habitude_id).first()

    if not habitude:
        habitude_nouvelle = Habitude(
            id=habitude_update.id,
            nom=habitude_update.nom,
            description=habitude_update.description,
            statut=habitude_update.statut,
            fréquence=habitude_update.fréquence,
            échéance=habitude_update.échéance
        )
        db.add(habitude_nouvelle)
        db.commit()
        db.refresh(habitude_nouvelle)
        return {"result": "success", "code": 201, "detail": "Nouvelle habitude créée", "habitude": habitude_nouvelle}

    for key, value in habitude_update.dict(exclude_unset=True).items():
        setattr(habitude, key, value)

    if habitude.statut == StatutHabitude.terminé:
        habitude.terminé_le = datetime.now()
    else:
        habitude.terminé_le = None

    db.commit()
    db.refresh(habitude)
    return {"result": "success", "code": 200, "detail": "Habitude mise à jour", "habitude": habitude}

@router.patch("/{habitude_id}")
def mettre_a_jour_statut(habitude_id: str, statut_update: StatutHabitude, db: Session = Depends(get_db)):
    habitude = db.query(Habitude).filter(Habitude.id == habitude_id).first()
    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée")

    habitude.statut = statut_update

    if habitude.statut == StatutHabitude.terminé:
        habitude.terminé_le = datetime.now()
    else:
        habitude.terminé_le = None

    db.commit()
    db.refresh(habitude)
    return {"result": "success", "code": 200, "detail": "Statut de l'habitude mis à jour", "habitude": habitude}

@router.delete("/{habitude_id}", status_code=200)
def supprimer_habitude(habitude_id: str, db: Session = Depends(get_db)):
    habitude = db.query(Habitude).filter(Habitude.id == habitude_id).first()
    if not habitude:
        raise HTTPException(status_code=404, detail="Habitude non trouvée")

    db.delete(habitude)
    db.commit()
    return {"result": "success", "code": 200, "detail": "Habitude supprimée"}
