# from .habit1 import router as habit_router
from .user import router as user_router
from .auth import router as auth_router

__all__ = ["user_router, auth_router"]
