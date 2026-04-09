import asyncio

from temporalio.worker import Worker

from app.config import settings
from app.logging import setup_logging
from app.temporal.client import get_temporal_client
from app.temporal.workflows import ExampleWorkflow
from app.temporal.activities import example_activity


async def start_worker() -> None:
    client = await get_temporal_client()

    worker = Worker(
        client,
        task_queue=settings.temporal_task_queue,
        workflows=[ExampleWorkflow],
        activities=[example_activity],
    )
    async with worker:
        print(f"Temporal worker started on queue: {settings.temporal_task_queue}")
        await asyncio.Future()  # run forever


def run() -> None:
    setup_logging(debug=settings.debug)
    asyncio.run(start_worker())
