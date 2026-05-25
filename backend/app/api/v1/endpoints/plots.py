from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.plot import Plot, UserPlotRole, Zone
from app.schemas.plot import PlotCreate, PlotUpdate, PlotResponse, ZoneCreate, ZoneResponse

router = APIRouter()


@router.get("", response_model=list[PlotResponse])
async def get_plots(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Plot, UserPlotRole.role)
        .join(UserPlotRole, Plot.id == UserPlotRole.plot_id)
        .where(UserPlotRole.user_id == current_user.id)
        .where(Plot.is_archived == False)
    )
    rows = result.all()
    plots = []
    for plot, role in rows:
        pr = PlotResponse.model_validate(plot)
        pr.role = role
        plots.append(pr)
    return plots


@router.post("", response_model=PlotResponse, status_code=201)
async def create_plot(
    data: PlotCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    plot = Plot(owner_id=current_user.id, **data.model_dump())
    db.add(plot)
    await db.flush()

    # Создатель становится admin
    role = UserPlotRole(user_id=current_user.id, plot_id=plot.id, role="admin")
    db.add(role)
    await db.refresh(plot)

    pr = PlotResponse.model_validate(plot)
    pr.role = "admin"
    return pr


@router.get("/{plot_id}", response_model=PlotResponse)
async def get_plot(
    plot_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Plot, UserPlotRole.role)
        .join(UserPlotRole, Plot.id == UserPlotRole.plot_id)
        .where(Plot.id == plot_id)
        .where(UserPlotRole.user_id == current_user.id)
    )
    row = result.first()
    if not row:
        raise HTTPException(status_code=404, detail="Участок не найден")
    plot, role = row
    pr = PlotResponse.model_validate(plot)
    pr.role = role
    return pr


@router.patch("/{plot_id}", response_model=PlotResponse)
async def update_plot(
    plot_id: str,
    data: PlotUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Plot, UserPlotRole.role)
        .join(UserPlotRole, Plot.id == UserPlotRole.plot_id)
        .where(Plot.id == plot_id)
        .where(UserPlotRole.user_id == current_user.id)
    )
    row = result.first()
    if not row:
        raise HTTPException(status_code=404, detail="Участок не найден")
    plot, role = row
    if role != "admin":
        raise HTTPException(status_code=403, detail="Нет прав для редактирования")

    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(plot, key, value)
    await db.flush()
    await db.refresh(plot)

    pr = PlotResponse.model_validate(plot)
    pr.role = role
    return pr


# Зоны
@router.get("/{plot_id}/zones", response_model=list[ZoneResponse])
async def get_zones(
    plot_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Проверяем доступ к участку
    result = await db.execute(
        select(UserPlotRole).where(
            UserPlotRole.plot_id == plot_id,
            UserPlotRole.user_id == current_user.id
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Нет доступа")

    result = await db.execute(select(Zone).where(Zone.plot_id == plot_id))
    return result.scalars().all()


@router.post("/{plot_id}/zones", response_model=ZoneResponse, status_code=201)
async def create_zone(
    plot_id: str,
    data: ZoneCreate,
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

    zone = Zone(plot_id=plot_id, **data.model_dump())
    db.add(zone)
    await db.flush()
    await db.refresh(zone)
    return zone
