import uuid
from datetime import datetime, timezone, date
from sqlalchemy import String, Boolean, DateTime, ForeignKey, Text, Integer, Date, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class PlantCatalog(Base):
    """Справочник культур — Яблоня, Томат, Роза и т.д."""
    __tablename__ = "plant_catalog"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    name: Mapped[str] = mapped_column(String(200), nullable=False)           # Яблоня
    name_latin: Mapped[str | None] = mapped_column(String(200))              # Malus domestica
    plant_type: Mapped[str] = mapped_column(String(50), nullable=False)      # tree/vegetable/...
    description: Mapped[str | None] = mapped_column(Text)
    days_to_harvest: Mapped[int | None] = mapped_column(Integer)
    sowing_months: Mapped[str | None] = mapped_column(String(50))           # "3,4,5"
    harvest_months: Mapped[str | None] = mapped_column(String(50))          # "8,9,10"
    is_custom: Mapped[bool] = mapped_column(Boolean, default=False)
    created_by: Mapped[str | None] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    varieties: Mapped[list["PlantVariety"]] = relationship(
        back_populates="plant", cascade="all, delete-orphan"
    )
    instances: Mapped[list["PlantInstance"]] = relationship(back_populates="plant")


class PlantVariety(Base):
    """Сорта культуры — Антоновка, Черри, Флорибунда и т.д."""
    __tablename__ = "plant_varieties"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    plant_id: Mapped[str] = mapped_column(
        ForeignKey("plant_catalog.id", ondelete="CASCADE"), nullable=False
    )
    name: Mapped[str] = mapped_column(String(200), nullable=False)          # Антоновка
    description: Mapped[str | None] = mapped_column(Text)
    is_custom: Mapped[bool] = mapped_column(Boolean, default=False)
    created_by: Mapped[str | None] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    plant: Mapped["PlantCatalog"] = relationship(back_populates="varieties")
    instances: Mapped[list["PlantInstance"]] = relationship(back_populates="variety")


class PlantInstance(Base):
    """Экземпляр растения пользователя в конкретной зоне."""
    __tablename__ = "plant_instances"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    zone_id: Mapped[str] = mapped_column(
        ForeignKey("zones.id", ondelete="CASCADE"), nullable=False
    )
    plant_id: Mapped[str] = mapped_column(
        ForeignKey("plant_catalog.id"), nullable=False
    )
    variety_id: Mapped[str | None] = mapped_column(
        ForeignKey("plant_varieties.id"), nullable=True
    )
    custom_name: Mapped[str | None] = mapped_column(String(200))            # «Томат у теплицы»
    planted_date: Mapped[date | None] = mapped_column(Date)
    quantity: Mapped[int | None] = mapped_column(Integer)
    area_sqm: Mapped[float | None] = mapped_column(Numeric(8, 2))
    notes: Mapped[str | None] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(20), default="active")       # planned/active/harvested/removed
    created_by: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    plant: Mapped["PlantCatalog"] = relationship(back_populates="instances")
    variety: Mapped["PlantVariety | None"] = relationship(back_populates="instances")
    zone: Mapped["Zone"] = relationship()  # noqa