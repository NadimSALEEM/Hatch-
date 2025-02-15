from fastapi import Depends, HTTPException, APIRouter, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import Utilisateur
from app.models.user import UtilisateurLectureDTO, UtilisateurMiseÀJourDTO, UtilisateurCréationDTO
from app.internal.auth_utils import hash_password, verify_password, create_access_token
from fastapi.security import OAuth2PasswordBearer
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
    if not utilisateur or not verify_password(form_data.password, utilisateur.mot_de_passe_haché):
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
def register_user(user: UtilisateurCréationDTO, db: Session = Depends(get_db)):
    """Register a new user with hashed password."""
    existing_user = db.query(Utilisateur).filter(Utilisateur.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_password = hash_password(user.mot_de_passe)
    new_user = Utilisateur(
        nom_utilisateur=user.nom_utilisateur,
        email=user.email,
        mot_de_passe_haché=hashed_password,
    )
    db.add(new_user)
    db.commit()
    return {"message": "User registered successfully"}