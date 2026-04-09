# Skill: New Temporal Workflow

## What it does
Adds a new Temporal workflow with activities for background/async processing.

## Files involved
- `app/temporal/workflows.py` — workflow definition (or new file if complex)
- `app/temporal/activities.py` — activity definitions (or new file if complex)
- `app/temporal/worker.py` — register workflow and activities with the worker
- `app/temporal/client.py` — used to start workflows from API endpoints

## Flow
1. **Define activities** in `app/temporal/activities.py`:
   - Each activity is an `async def` decorated with `@activity.defn`
   - Activities do the actual work (DB calls, HTTP requests, etc.)
2. **Define workflow** in `app/temporal/workflows.py`:
   - Class decorated with `@workflow.defn`
   - `@workflow.run` method orchestrates the activities
   - Call activities via `workflow.execute_activity()`
3. **Register in worker** — add workflow class and activity functions to `app/temporal/worker.py`
4. **Trigger from API** — use `temporal_client` from `app/temporal/client.py` to start the workflow

## Example
```python
# app/temporal/activities.py
from temporalio import activity

@activity.defn
async def send_email(to: str, subject: str, body: str) -> bool:
    # actual email sending logic
    return True

# app/temporal/workflows.py
from datetime import timedelta
from temporalio import workflow

with workflow.unsafe.imports_passed_through():
    from app.temporal.activities import send_email

@workflow.defn
class SendEmailWorkflow:
    @workflow.run
    async def run(self, to: str, subject: str, body: str) -> bool:
        return await workflow.execute_activity(
            send_email,
            args=[to, subject, body],
            start_to_close_timeout=timedelta(seconds=30),
        )

# app/temporal/worker.py — add to registrations:
# workflows=[..., SendEmailWorkflow]
# activities=[..., send_email]

# Trigger from endpoint:
from app.temporal.client import get_temporal_client

client = await get_temporal_client()
await client.start_workflow(
    SendEmailWorkflow.run,
    args=["user@example.com", "Hello", "Body"],
    id=f"send-email-{uuid4()}",
    task_queue=settings.temporal_task_queue,
)
```

## How to extend
- If a workflow gets complex (many activities) — move it to its own file under `app/temporal/`
- Keep activities small and focused (one responsibility each)
- Use `timedelta` for timeouts — always set explicit timeouts on activities
