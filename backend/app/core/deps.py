from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import decode_token
from app.models.user import User

# auto_error=False — отключаем встроенное поведение HTTPBearer, которое
# при отсутствии/некорректном заголовке Authorization само поднимает
# HTTPException(403, "Not authenticated"). Из-за этого Flutter-клиент видел
# 403 вместо 401 и не запускал цикл refresh. Теперь мы сами решаем, какой
# статус отдавать, и в любой ситуации с битой/отсутствующей авторизацией
# возвращаем 401, как и положено по семантике HTTP.
bearer_scheme = HTTPBearer(auto_error=False)


def _unauthorized(detail: str = "Недействительный токен") -> HTTPException:
    """Единая фабрика 401 — добавляем WWW-Authenticate, как требует RFC 6750."""
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    # Заголовок не пришёл вовсе или схема не Bearer — это 401, а не 403.
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise _unauthorized("Отсутствует или некорректный заголовок Authorization")

    token = credentials.credentials
    payload = decode_token(token)

    if not payload or payload.get("type") != "access":
        raise _unauthorized()

    user_id = payload.get("sub")
    if not user_id:
        raise _unauthorized()

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise _unauthorized("Пользователь не найден или заблокирован")

    return user
