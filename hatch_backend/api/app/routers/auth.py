from fastapi import Depends, HTTPException, APIRouter, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import Utilisateur, CreerUtilisateur, MiseAJourUtilisateur, LireUtilisateur
from app.internal.auth_utils import hash_password, verify_password, create_access_token
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from app.internal.auth_utils import decode_access_token

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@router.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Authenticate a user and return a JWT token."""
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == form_data.username).first()
    if not utilisateur or not verify_password(form_data.password, utilisateur.mot_de_passe_hache):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Generate JWT token
    access_token = create_access_token(data={"sub": utilisateur.email})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me")
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Retrieve the authenticated user profile from JWT."""
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    email = payload.get("sub")
    utilisateur = db.query(Utilisateur).filter(Utilisateur.email == email).first()
    if not utilisateur:
        raise HTTPException(status_code=401, detail="User not found")

    return {"email": utilisateur.email, "message": "Authenticated"}

@router.post("/register")
def register_user(user: CreerUtilisateur, db: Session = Depends(get_db)):
    """Inscription d'un nouvel utilisateur avec génération d'un JWT token."""

    # Vérifier si l'email ou le téléphone existent déjà
    existing_user = db.query(Utilisateur).filter(
        (Utilisateur.email == user.email) | (Utilisateur.telephone == user.telephone)
    ).first()

    if existing_user:
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

    access_token = create_access_token(data={"sub": new_user.email})

    return {
        "message": "Utilisateur créé avec succès",
        "user_id": new_user.id,
        "access_token": access_token,
        "token_type": "bearer"
    }
