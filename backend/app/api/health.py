from fastapi import APIRouter
from sqlalchemy import text

from app.database import async_session
from app.redis import redis_client

router = APIRouter()


@router.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/health/ready")
async def readiness() -> dict[str, str | bool]:
    checks: dict[str, str | bool] = {}

    try:
        async with async_session() as session:
            await session.execute(text("SELECT 1"))
        checks["database"] = True
    except Exception:
        checks["database"] = False

    try:
        await redis_client.ping()
        checks["redis"] = True
    except Exception:
        checks["redis"] = False

    all_ok = all(checks.values())
    checks["status"] = "ok" if all_ok else "degraded"
    return checks
