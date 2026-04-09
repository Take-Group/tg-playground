# Skill: New Database Model

## What it does
Adds a new SQLAlchemy model and generates an Alembic migration.

## Files involved
- `app/models/<module>.py` — new model definition (create)
- `app/models/__init__.py` — export the model (so Alembic sees it)
- `alembic/versions/<hash>_<message>.py` — auto-generated migration

## Flow
1. **Create model** in `app/models/<module>.py`:
   - Import `Base` from `app.database`
   - Define table using `Mapped` type annotations (SQLAlchemy 2.0 style)
2. **Export model** in `app/models/__init__.py`:
   - Import the new model so Alembic's autogenerate detects it
3. **Generate migration**:
   ```bash
   uv run alembic revision --autogenerate -m "add <table_name> table"
   ```
4. **Review** the generated migration file in `alembic/versions/`
5. **Apply migration**:
   ```bash
   uv run alembic upgrade head
   ```
   In Docker this happens automatically on container start.

## Example
```python
# app/models/user.py
from datetime import datetime
from sqlalchemy import String, func
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255))
    email: Mapped[str] = mapped_column(String(255), unique=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

# app/models/__init__.py
from app.database import Base
from app.models.user import User

__all__ = ["Base", "User"]
```

## How to extend
- Add relationships between models using `relationship()` and `ForeignKey`
- One model per file — keep it simple
- Always generate a separate migration for each schema change
