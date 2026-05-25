from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.plot import UserPlotRole
from app.models.journal import JournalEntry

router = APIRouter()


class JournalCreate(BaseModel):
    text: str
    zone_id: Optional[str] = None
    tags: Optional[list[str]] = []


class JournalResponse(BaseModel):
    id: str
    plot_id: str
    zone_id: Optional[str] = None
    user_id: str
    text: str
    photos: Optional[list] = []
    tags: Optional[list] = []
    created_at: datetime

    model_config = {"from_attributes": True}


@router.get("/{plot_id}/journal", response_model=list[JournalResponse])
async def get_journal(
    plot_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserPlotRole).where(
            UserPlotRole.plot_id == plot_id,
            UserPlotRole.user_id == current_user.id
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Нет доступа")

    result = await db.execute(
        select(JournalEntry)
        .where(JournalEntry.plot_id == plot_id)
        .order_by(JournalEntry.created_at.desc())
    )
    return result.scalars().all()


@router.post("/{plot_id}/journal", response_model=JournalResponse, status_code=201)
async def create_journal_entry(
    plot_id: str,
    data: JournalCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserPlotRole).where(
            UserPlotRole.plot_id == plot_id,
            UserPlotRole.user_id == current_user.id,
            UserPlotRole.role.in_(["admin", "member"])
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Нет прав")

    entry = JournalEntry(
        plot_id=plot_id,
        user_id=current_user.id,
        **data.model_dump()
    )
    db.add(entry)
    await db.flush()
    await db.refresh(entry)
    return entry
