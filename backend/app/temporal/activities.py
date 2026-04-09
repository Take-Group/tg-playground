import structlog
from temporalio import activity

logger = structlog.get_logger()


@activity.defn
async def example_activity(name: str) -> str:
    logger.info("Running example activity", name=name)
    return f"Hello, {name}!"
