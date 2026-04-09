# Skill: New Endpoint

## What it does
Adds a new REST API endpoint to the FastAPI application.

## Files involved
- `app/api/<module>.py` — new route module (create)
- `app/api/router.py` — register the new router
- `app/schemas/<module>.py` — request/response Pydantic models (create if needed)
- `app/services/<module>.py` — business logic (create if needed)
- `app/api/deps.py` — shared dependencies (SessionDep, etc.)

## Flow
1. **Define schemas** in `app/schemas/<module>.py` — Pydantic models for request body and response
2. **Create service** in `app/services/<module>.py` — business logic function that takes deps (session, redis, etc.) and returns data
3. **Create route module** in `app/api/<module>.py`:
   - Import `APIRouter`
   - Import schemas and service
   - Import deps from `app/api/deps.py`
   - Define endpoint function, call service, return response
4. **Register router** in `app/api/router.py`:
   ```python
   from app.api.<module> import router as <module>_router
   router.include_router(<module>_router, prefix="/<module>", tags=["<module>"])
   ```

## Example
```python
# app/schemas/users.py
from pydantic import BaseModel

class UserResponse(BaseModel):
    id: int
    name: str

# app/services/users.py
from sqlalchemy.ext.asyncio import AsyncSession

async def get_user(session: AsyncSession, user_id: int) -> dict:
    # business logic here
    ...

# app/api/users.py
from fastapi import APIRouter
from app.api.deps import SessionDep
from app.schemas.users import UserResponse
from app.services.users import get_user

router = APIRouter()

@router.get("/{user_id}", response_model=UserResponse)
async def read_user(user_id: int, session: SessionDep):
    return await get_user(session, user_id)
```

## How to extend
- Add more endpoints to the same route module
- If the module grows past 600 lines — split into sub-routers
- Always keep business logic in services, not in route handlers
