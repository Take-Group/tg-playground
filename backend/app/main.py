from contextlib import asynccontextmanager

import structlog
import uvicorn
from fastapi import FastAPI

from app.api.router import api_router
from app.config import settings
from app.database import engine
from app.logging import setup_logging
from app.redis import redis_client

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging(debug=settings.debug)
    logger.info("Starting application", app_name=settings.app_name)
    yield
    await redis_client.aclose()
    await engine.dispose()
    logger.info("Application shutdown complete")


app = FastAPI(
    title=settings.app_name,
    debug=settings.debug,
    lifespan=lifespan,
)

app.include_router(api_router)


def run() -> None:
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
