from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional


# ── Справочник культур ─────────────────────────────────────────────────────

class PlantVarietyResponse(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    is_custom: bool

    model_config = {"from_attributes": True}


class PlantCatalogCreate(BaseModel):
    name: str
    name_latin: Optional[str] = None
    plant_type: str          # vegetable | fruit | berry | flower | tree | shrub | herb
    description: Optional[str] = None
    days_to_harvest: Optional[int] = None
    sowing_months: Optional[str] = None
    harvest_months: Optional[str] = None


class PlantCatalogResponse(BaseModel):
    id: str
    name: str
    name_latin: Optional[str] = None
    plant_type: str
    description: Optional[str] = None
    days_to_harvest: Optional[int] = None
    sowing_months: Optional[str] = None
    harvest_months: Optional[str] = None
    is_custom: bool
    varieties: list[PlantVarietyResponse] = []

    model_config = {"from_attributes": True}


# ── Сорта ──────────────────────────────────────────────────────────────────

class PlantVarietyCreate(BaseModel):
    name: str
    description: Optional[str] = None


# ── Экземпляры растений пользователя ──────────────────────────────────────

class PlantInstanceCreate(BaseModel):
    plant_id: str
    variety_id: Optional[str] = None
    custom_name: Optional[str] = None
    planted_date: Optional[date] = None
    quantity: Optional[int] = None
    area_sqm: Optional[float] = None
    notes: Optional[str] = None
    status: str = "active"


class PlantInstanceUpdate(BaseModel):
    variety_id: Optional[str] = None
    custom_name: Optional[str] = None
    planted_date: Optional[date] = None
    quantity: Optional[int] = None
    area_sqm: Optional[float] = None
    notes: Optional[str] = None
    status: Optional[str] = None


class PlantInstanceResponse(BaseModel):
    id: str
    zone_id: str
    plant_id: str
    variety_id: Optional[str] = None
    custom_name: Optional[str] = None
    planted_date: Optional[date] = None
    quantity: Optional[int] = None
    area_sqm: Optional[float] = None
    notes: Optional[str] = None
    status: str
    created_at: datetime

    # Вложенные данные для удобства
    plant_name: Optional[str] = None
    plant_type: Optional[str] = None
    variety_name: Optional[str] = None

    model_config = {"from_attributes": True}