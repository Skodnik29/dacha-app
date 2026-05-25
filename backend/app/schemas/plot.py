from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class PlotCreate(BaseModel):
    name: str
    address: Optional[str] = None
    area_sqm: Optional[float] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class PlotUpdate(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None
    area_sqm: Optional[float] = None
    description: Optional[str] = None


class PlotResponse(BaseModel):
    id: str
    name: str
    address: Optional[str] = None
    area_sqm: Optional[float] = None
    description: Optional[str] = None
    is_archived: bool
    created_at: datetime
    role: Optional[str] = None

    model_config = {"from_attributes": True}


class ZoneCreate(BaseModel):
    name: str
    zone_type: str = "garden"
    color: Optional[str] = None
    icon: Optional[str] = None
    description: Optional[str] = None


class ZoneResponse(BaseModel):
    id: str
    plot_id: str
    name: str
    zone_type: str
    color: Optional[str] = None
    icon: Optional[str] = None
    description: Optional[str] = None
    created_at: datetime

    model_config = {"from_attributes": True}
