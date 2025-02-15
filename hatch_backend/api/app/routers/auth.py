from fastapi import Depends, HTTPException, APIRouter
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import Utilisateur

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@router.get("/me")
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    Retrieve the current authenticated user's profile.
    """
    utilisateur = db.query(Utilisateur).filter(Utilisateur.token == token).first()
    if not utilisateur:
        raise HTTPException(status_code=401, detail="Utilisateur non authentifié")
    return {"email": utilisateur.email, "message": "Utilisateur authentifié"}
