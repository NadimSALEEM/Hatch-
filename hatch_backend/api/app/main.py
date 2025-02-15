from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, PlainTextResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from .routers import user, auth  # Importer les nouveaux routeurs

app = FastAPI()

# Configuration du Middleware CORS (Autorisation des requêtes cross-origin)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Autorise toutes les origines (Flutter, Postman, etc.)
    allow_credentials=True,
    allow_methods=["*"],  # Autorise tous les verbes HTTP (GET, POST, etc.)
    allow_headers=["*"],  # Autorise tous les headers HTTP
)

# Inclusion des routeurs
app.include_router(auth.router, prefix="/auth")  # Authentification
app.include_router(user.router, prefix="/users")  # Gestion des utilisateurs
# app.include_router(habits.router, prefix="/habits")  # Gestion des habitudes
# app.include_router(coach.router, prefix="/coach")  # Gestion des recommandations du coach


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
    return {"message": "Hatch Habits API 🚀"}
