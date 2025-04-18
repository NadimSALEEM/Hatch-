from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, PlainTextResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from app.routers import coach

from .routers import habit, user, auth, objectif, coach  # Importer les nouveaux routeurs

app = FastAPI()

# Initialisation des coachs statiques
coach.init_static_coachs()

# Configuration du Middleware CORS (Autorisation des requêtes cross-origin)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Autorise toutes les origines (Flutter, Postman, etc.)
    allow_credentials=True,
    allow_methods=["*"],  # Autorise tous les verbes HTTP (GET, POST, etc.)
    allow_headers=["*"],  # Autorise tous les headers HTTP
)


# Inclusion des routeurs
app.include_router(auth.router)  # Authentification
app.include_router(user.router)  # Gestion des utilisateurs
app.include_router(habit.router)  # Gestion des habitudes
app.include_router(objectif.router) # Gestion des objectifs
app.include_router(coach.router)  # Gestion des recommandations du coach


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    """
    Intercepte toutes les erreurs de validation générées par Pydantic
    et retourne une erreur générique "Bad Request"
    """
    return JSONResponse({"detail": "Bad Request"}, status_code=400)


@app.get("/")
def read_root():
    """
    Racine de l'API
    """
    return {"message": "Hatch Habits API"}
