from datetime import timedelta

from temporalio import workflow

with workflow.unsafe.imports_passed_through():
    from app.temporal.activities import example_activity


@workflow.defn
class ExampleWorkflow:
    @workflow.run
    async def run(self, name: str) -> str:
        return await workflow.execute_activity(
            example_activity,
            name,
            start_to_close_timeout=timedelta(seconds=30),
        )
