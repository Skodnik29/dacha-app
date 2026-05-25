from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    work_type: str = "other"
    planned_date: date
    zone_id: Optional[str] = None
    assigned_to: Optional[str] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    planned_date: Optional[date] = None
    status: Optional[str] = None
    completion_note: Optional[str] = None


class TaskResponse(BaseModel):
    id: str
    plot_id: str
    zone_id: Optional[str] = None
    title: str
    description: Optional[str] = None
    work_type: str
    planned_date: date
    completed_at: Optional[datetime] = None
    status: str
    assigned_to: Optional[str] = None
    created_by: str
    created_at: datetime

    model_config = {"from_attributes": True}
