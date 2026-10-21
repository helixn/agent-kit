# Направление: web-fastapi (HTTP-сервисы на FastAPI + SQLAlchemy + Alembic)

## Стек по умолчанию
Python 3.12+, FastAPI, SQLAlchemy 2.0 (async), Alembic, PostgreSQL, Pydantic v2, uv, ruff, basedpyright, pytest + pytest-cov.

## Нерушимые правила слоёв
1. `app/api/` — транспорт: приём запроса, валидация схемой Pydantic, вызов сервиса. ЗАПРЕЩЕНЫ: импорт sqlalchemy, AsyncSession, SQL.
2. `app/services/` — бизнес-логика, доменные исключения, владение транзакцией. ЗАПРЕЩЕНЫ: Request/Response/HTTPException.
3. `app/repositories/` — единственная точка доступа к БД: `flush()` здесь; `commit()` — сервис или жизненный цикл `get_db()`.
4. `app/models/` — ORM-модели; любое изменение → миграция Alembic (маятник + `alembic check`).
5. Внешние контракты API неприкосновенны: новые поля — только опциональные со значением по умолчанию.
6. Время: только `datetime.now(timezone.utc)` и колонки `DateTime(timezone=True)` (timestamptz). Наивные datetime запрещены.

## Definition of Done (ворота направления)
```bash
uv run ruff check app tests
uv run ruff format --check .
uv run basedpyright
uv run pytest -q --cov=app --cov-branch --cov-fail-under=<порог>
uv run alembic upgrade head && uv run alembic check
```

## Порядок скилов для типовых задач
- Новая фича: `investigate-codebase` → (если схема) `database-migration` → `fastapi-feature`.
- Сначала в проекте без тестов: `characterization-tests` (порог → 60), затем `tests-integration` (→ 80), затем фичи (→ 85).
- Рефакторинг: `safe-refactoring` (слепок как оракул).

## Изоляция ревьюящих ролей
`orchestration/isolation/opencode.json.example` + `per-file-ignores` для TID251 уже настроены в `docs/gates.pyproject.toml`
(копия из agent-kit; в repositories/models/core sqlalchemy законен, в `app/api/` — запрещён).
