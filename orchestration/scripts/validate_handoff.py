#!/usr/bin/env python3
"""Опциональный машинный валидатор handoff-пакета (agent-kit).

Канон handoff — Markdown по шаблонам `orchestration/templates/`. Если команда ВЕДЁТ ДОПОЛНИТЕЛЬНО
машиночитаемый JSON-слепок handoff (для CI/скриптов), этот скрипт проверяет его обязательные секции.
Формат слепка определяет команда; скрипт поставляется вместе с комплектом (Zero Hidden Scripts),
зависимостей нет (только stdlib).

Использование:
    python scripts/validate_handoff.py .ai-team/handoff-coder.json

Коды выхода: 0 — валиден; 1 — дефект/не читается; 2 — неверный вызов.
"""
from __future__ import annotations

import json
import sys

REQUIRED_KEYS = ("task_id", "author_role", "artifacts", "decisions", "open_questions")
NON_EMPTY_KEYS = ("decisions", "open_questions")


def main() -> int:
    if len(sys.argv) != 2:
        print("Использование: validate_handoff.py <handoff.json>")
        return 2
    try:
        with open(sys.argv[1], encoding="utf-8") as fh:
            data = json.load(fh)
    except OSError as exc:
        print(f"ОШИБКА: не удалось открыть {sys.argv[1]}: {exc}")
        return 1
    except json.JSONDecodeError as exc:
        print(f"ОШИБКА: файл не является валидным JSON: {exc}")
        return 1

    missing = [key for key in REQUIRED_KEYS if key not in data]
    if missing:
        print(f"ОШИБКА: В пакете отсутствуют обязательные секции: {missing}")
        return 1

    empty = [key for key in NON_EMPTY_KEYS if not data.get(key)]
    if empty:
        print(f"ОШИБКА: Секции должны быть непусты: {empty}")
        return 1

    print("OK: handoff-пакет валиден")
    return 0


if __name__ == "__main__":
    sys.exit(main())
