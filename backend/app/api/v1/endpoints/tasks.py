from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import date, timezone
from datetime import datetime

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.plot import UserPlotRole
from app.models.task import Task
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse

router = APIRouter()


async def _check_plot_access(plot_id: str, user_id: str, db: AsyncSession, roles=None):
    q = select(UserPlotRole).where(
        UserPlotRole.plot_id == plot_id,
        UserPlotRole.user_id == user_id,
    )
    if roles:
        q = q.where(UserPlotRole.role.in_(roles))
    result = await db.execute(q)
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Нет доступа к участку")


@router.get("/{plot_id}/tasks", response_model=list[TaskResponse])
async def get_tasks(
    plot_id: str,
    status: str | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_plot_access(plot_id, current_user.id, db)

    q = select(Task).where(Task.plot_id == plot_id)
    if status:
        q = q.where(Task.status == status)
    if date_from:
        q = q.where(Task.planned_date >= date_from)
    if date_to:
        q = q.where(Task.planned_date <= date_to)
    q = q.order_by(Task.planned_date)

    result = await db.execute(q)
    return result.scalars().all()


@router.post("/{plot_id}/tasks", response_model=TaskResponse, status_code=201)
async def create_task(
    plot_id: str,
    data: TaskCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_plot_access(plot_id, current_user.id, db, roles=["admin", "member"])

    task = Task(
        plot_id=plot_id,
        created_by=current_user.id,
        **data.model_dump()
    )
    db.add(task)
    await db.flush()
    await db.refresh(task)
    return task


@router.patch("/{plot_id}/tasks/{task_id}", response_model=TaskResponse)
async def update_task(
    plot_id: str,
    task_id: str,
    data: TaskUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_plot_access(plot_id, current_user.id, db, roles=["admin", "member"])

    result = await db.execute(
        select(Task).where(Task.id == task_id, Task.plot_id == plot_id)
    )
    task = result.scalar_one_or_none()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")

    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(task, key, value)

    if data.status == "done" and not task.completed_at:
        task.completed_at = datetime.now(timezone.utc)

    await db.flush()
    await db.refresh(task)
    return task


@router.post("/{plot_id}/tasks/{task_id}/complete", response_model=TaskResponse)
async def complete_task(
    plot_id: str,
    task_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_plot_access(plot_id, current_user.id, db, roles=["admin", "member"])

    result = await db.execute(
        select(Task).where(Task.id == task_id, Task.plot_id == plot_id)
    )
    task = result.scalar_one_or_none()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")

    task.status = "done"
    task.completed_at = datetime.now(timezone.utc)
    await db.flush()
    await db.refresh(task)
    return task


@router.delete("/{plot_id}/tasks/{task_id}", status_code=204)
async def delete_task(
    plot_id: str,
    task_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _check_plot_access(plot_id, current_user.id, db, roles=["admin", "member"])

    result = await db.execute(
        select(Task).where(Task.id == task_id, Task.plot_id == plot_id)
    )
    task = result.scalar_one_or_none()
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")

    await db.delete(task)
