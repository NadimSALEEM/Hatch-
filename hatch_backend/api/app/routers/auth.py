from fastapi import Depends, HTTPException, APIRouter, Response, Request, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import Utilisateur, CreerUtilisateur
from app.internal.auth_utils import (
    hash_password, verify_password, create_access_token,
    create_refresh_token, decode_token
)
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
import logging

router = APIRouter(prefix="/auth", tags=["auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Activer les logs pour mieux voir les erreurs
logging.basicConfig(level=logging.INFO)

@router.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Connexion utilisateur et retour des tokens"""
    logging.info(f"Tentative de connexion : {form_data.username}")

    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == form_data.username).first()

    if not utilisateur or not verify_password(form_data.password, utilisateur.mot_de_passe_hache):
        logging.warning("Email ou mot de passe incorrect")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(data={"sub": utilisateur.email})
    refresh_token = create_refresh_token(data={"sub": utilisateur.email})

    # Stocker le refresh_token dans un cookie HTTPOnly
    response = Response()
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,
        secure=True,
        samesite="Lax"
    )

    logging.info("Connexion réussie : Token généré")

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh")
def refresh_access_token(request: Request, db: Session = Depends(get_db)):
    """Régénère un Access Token à partir du Refresh Token stocké en cookie"""
    refresh_token = request.cookies.get("refresh_token")
    if not refresh_token:
        logging.warning("Refresh token manquant")
        raise HTTPException(status_code=401, detail="Refresh token manquant")

    payload = decode_token(refresh_token)
    if not payload:
        logging.warning("Refresh token invalide ou expiré")
        raise HTTPException(status_code=401, detail="Refresh token invalide ou expiré")

    email = payload["sub"]
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    
    if not utilisateur:
        logging.warning("Utilisateur non trouvé pour le refresh")
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    new_access_token = create_access_token(data={"sub": email})

    return {"access_token": new_access_token, "token_type": "bearer"}

@router.get("/me")
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Récupère le profil utilisateur authentifié à partir du JWT"""
    payload = decode_token(token)

    if not payload:
        logging.warning("Token invalide ou expiré")
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    email = payload["sub"]
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == email).first()

    if not utilisateur:
        logging.warning("Utilisateur non trouvé")
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

    return {"id": utilisateur.id, "email": utilisateur.email, "message": "Authenticated"}

@router.post("/register")
def register_user(user: CreerUtilisateur, db: Session = Depends(get_db)):
    """Inscription d'un nouvel utilisateur avec génération d'un JWT token + Refresh Token."""
    logging.info(f"Tentative d'inscription pour {user.email}")

    # Vérifier si l'email ou le téléphone existent déjà
    existing_user = db.query(Utilisateur).filter(
        (Utilisateur.email == user.email) | (Utilisateur.telephone == user.telephone)
    ).first()

    if existing_user:
        logging.warning("Utilisateur déjà existant")
        raise HTTPException(
            status_code=400,
            detail="Ce compte existe déjà avec cet email ou téléphone."
        )

    hashed_password = hash_password(user.mot_de_passe)

    # Création de l'utilisateur
    new_user = Utilisateur(
        nom_utilisateur=user.nom_utilisateur,
        email=user.email,
        telephone=user.telephone,
        date_naissance=user.date_naissance,
        photo_profil=user.photo_profil,
        biographie=user.biographie,
        mot_de_passe_hache=hashed_password,
        coach_assigne=user.coach_assigne,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Générer l'Access Token & Refresh Token
    access_token = create_access_token(data={"sub": new_user.email})
    refresh_token = create_refresh_token(data={"sub": new_user.email})

    logging.info("Utilisateur créé avec succès")

    return {
        "message": "Utilisateur créé avec succès",
        "user_id": new_user.id,
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/logout")
def logout(response: Response):
    """Déconnecte l'utilisateur en supprimant le cookie du refresh token"""
    response.delete_cookie("refresh_token")
    return {"message": "Déconnexion réussie"}
