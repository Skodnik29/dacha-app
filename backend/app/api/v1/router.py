from fastapi import APIRouter
from app.api.v1.endpoints import auth, plots, tasks, journal, plants  # ← добавили plants

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Авторизация"])
api_router.include_router(plots.router, prefix="/plots", tags=["Участки"])
api_router.include_router(tasks.router, prefix="/plots", tags=["Задачи"])
api_router.include_router(journal.router, prefix="/plots", tags=["Журнал"])
api_router.include_router(plants.router, prefix="/plants", tags=["Культуры и растения"])  # ← новый