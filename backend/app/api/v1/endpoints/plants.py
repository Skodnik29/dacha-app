from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.plot import Zone, UserPlotRole
from app.models.plant import PlantCatalog, PlantVariety, PlantInstance
from app.schemas.plant import (
    PlantCatalogCreate, PlantCatalogResponse,
    PlantVarietyCreate, PlantVarietyResponse,
    PlantInstanceCreate, PlantInstanceUpdate, PlantInstanceResponse,
)

router = APIRouter()


# ── Справочник культур ─────────────────────────────────────────────────────

@router.get("/catalog", response_model=list[PlantCatalogResponse])
async def get_plant_catalog(
    plant_type: str | None = Query(None, description="Фильтр по типу: vegetable, tree, berry..."),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Получить весь справочник культур (системные + пользовательские)."""
    stmt = select(PlantCatalog)
    if plant_type:
        stmt = stmt.where(PlantCatalog.plant_type == plant_type)
    # Системные + собственные пользователя
    stmt = stmt.where(
        (PlantCatalog.is_custom == False) |
        (PlantCatalog.created_by == current_user.id)
    )
    result = await db.execute(stmt)
    plants = result.scalars().unique().all()
    return plants


@router.post("/catalog", response_model=PlantCatalogResponse, status_code=201)
async def create_plant_in_catalog(
    data: PlantCatalogCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Добавить свою культуру в справочник."""
    plant = PlantCatalog(
        **data.model_dump(),
        is_custom=True,
        created_by=current_user.id,
    )
    db.add(plant)
    await db.flush()
    await db.refresh(plant)
    return plant


@router.get("/catalog/{plant_id}", response_model=PlantCatalogResponse)
async def get_plant(
    plant_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    plant = await db.get(PlantCatalog, plant_id)
    if not plant:
        raise HTTPException(status_code=404, detail="Культура не найдена")
    return plant


# ── Сорта культуры ────────────────────────────────────────────────────────

@router.get("/catalog/{plant_id}/varieties", response_model=list[PlantVarietyResponse])
async def get_varieties(
    plant_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(PlantVariety).where(
            PlantVariety.plant_id == plant_id,
            (PlantVariety.is_custom == False) |
            (PlantVariety.created_by == current_user.id)
        )
    )
    return result.scalars().all()


@router.post(
    "/catalog/{plant_id}/varieties",
    response_model=PlantVarietyResponse,
    status_code=201
)
async def add_variety(
    plant_id: str,
    data: PlantVarietyCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Добавить свой сорт к существующей культуре."""
    plant = await db.get(PlantCatalog, plant_id)
    if not plant:
        raise HTTPException(status_code=404, detail="Культура не найдена")

    variety = PlantVariety(
        plant_id=plant_id,
        name=data.name,
        description=data.description,
        is_custom=True,
        created_by=current_user.id,
    )
    db.add(variety)
    await db.flush()
    await db.refresh(variety)
    return variety


# ── Экземпляры растений в зоне ────────────────────────────────────────────

async def _check_zone_access(zone_id: str, user_id: str, db: AsyncSession, require_write=False):
    """Проверка доступа к зоне через участок."""
    zone = await db.get(Zone, zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail="Зона не найдена")

    stmt = select(UserPlotRole).where(
        UserPlotRole.plot_id == zone.plot_id,
        UserPlotRole.user_id == user_id,
    )
    if require_write:
        stmt = stmt.where(UserPlotRole.role.in_(["admin", "member"]))

    result = await db.execute(stmt)
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Нет доступа к зоне")
    return zone


@router.get("/zones/{zone_id}/plants", response_model=list[PlantInstanceResponse])
async def get_zone_plants(
    zone_id: str,
    status: str | None = Query(None, description="Фильтр по статусу: active, planned..."),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Все растения в зоне."""
    await _check_zone_access(zone_id, current_user.id, db)

    stmt = select(PlantInstance).where(PlantInstance.zone_id == zone_id)
    if status:
        stmt = stmt.where(PlantInstance.status == status)

    result = await db.execute(stmt)
    instances = result.scalars().all()

    # Обогащаем ответ именами из каталога
    out = []
    for inst in instances:
        r = PlantInstanceResponse.model_validate(inst)
        if inst.plant:
            r.plant_name = inst.plant.name
            r.plant_type = inst.plant.plant_type
        if inst.variety:
            r.variety_name = inst.variety.name
        out.append(r)
    return out


@router.post("/zones/{zone_id}/plants", response_model=PlantInstanceResponse, status_code=201)
async def add_plant_to_zone(
    zone_id: str,
    data: PlantInstanceCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Посадить растение в зону."""
    await _check_zone_access(zone_id, current_user.id, db, require_write=True)

    # Проверяем, что культура существует
    plant = await db.get(PlantCatalog, data.plant_id)
    if not plant:
        raise HTTPException(status_code=404, detail="Культура не найдена в справочнике")

    # Проверяем сорт, если указан
    if data.variety_id:
        variety = await db.get(PlantVariety, data.variety_id)
        if not variety or variety.plant_id != data.plant_id:
            raise HTTPException(status_code=400, detail="Сорт не принадлежит данной культуре")

    instance = PlantInstance(
        zone_id=zone_id,
        created_by=current_user.id,
        **data.model_dump(),
    )
    db.add(instance)
    await db.flush()
    await db.refresh(instance)

    r = PlantInstanceResponse.model_validate(instance)
    r.plant_name = plant.name
    r.plant_type = plant.plant_type
    return r


@router.patch("/zones/{zone_id}/plants/{instance_id}", response_model=PlantInstanceResponse)
async def update_plant_instance(
    zone_id: str,
    instance_id: str,
    data: PlantInstanceUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_zone_access(zone_id, current_user.id, db, require_write=True)

    instance = await db.get(PlantInstance, instance_id)
    if not instance or instance.zone_id != zone_id:
        raise HTTPException(status_code=404, detail="Растение не найдено")

    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(instance, key, value)

    await db.flush()
    await db.refresh(instance)

    r = PlantInstanceResponse.model_validate(instance)
    if instance.plant:
        r.plant_name = instance.plant.name
        r.plant_type = instance.plant.plant_type
    if instance.variety:
        r.variety_name = instance.variety.name
    return r


@router.delete("/zones/{zone_id}/plants/{instance_id}", status_code=204)
async def remove_plant_from_zone(
    zone_id: str,
    instance_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_zone_access(zone_id, current_user.id, db, require_write=True)

    instance = await db.get(PlantInstance, instance_id)
    if not instance or instance.zone_id != zone_id:
        raise HTTPException(status_code=404, detail="Растение не найдено")

    await db.delete(instance)