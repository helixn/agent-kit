---
name: techlead-gate
description: >-
  Финальный шлюз приёмки: пять детерминированных проверок в одной цепочке.
  Слияние допускается только при коде возврата 0 и статусе ACCEPTED.
---

# Скил: techlead-gate

## Триггеры
- Завершены все четыре волны задачи.
- Готовится итоговый Pull Request или пакет приёмки.

## Процедура
1. Выполнить `uv run python3 tools/verify_techlead_gate.py`.
2. Шлюз проходит пять ступеней и останавливается на первой упавшей: синхронизация базы знаний (`verify_kb_sync.py`); ацикличность графа (`build_dependency_graph.py --check-cycles`); границы слоёв (`verify_architecture_layers.py`); бюджет Blast Radius (`verify_blast_radius.py`); тесты `pytest tests/unit tests/integration -q`.
3. Для каждой ступени записать PASS или FAIL с причиной из вывода шлюза.
4. План GSD проверять отдельно: `python3 tools/plan_checker.py`.

## Ворота готовности
- [ ] Все пять ступеней PASS, код возврата 0, строка `TECHLEAD GATE: ACCEPTED`.
- [ ] Требования без тестов перечислены как НЕ ПРОВЕРЕНО.

## Стоп-условия
- Любая ступень FAIL: коммит отклонён, возврат в волну по `ROADMAP.md`.

## Адаптация ALGOInsight (28.10, из ранбука Дня 3)
- Единого `verify_techlead_gate.py` в workspace НЕТ. Локальная цепочка приёмки (эквивалент пяти ступеней, по приказам владельца):
  1) KB-синтетика: `python tools/verify_kb_sync.py` (код 0);
  2) субагент логичности — PASS обязателен до отчёта (приказ 08.10);
  3) числовая верификация на конкретных данных — отдельный верификатор (приказ 24.09/30.09), слово «работает» только после PASS обоих;
  4) тесты по скилам `tests-unit`/`tests-integration`; для данных — сверка таймстемпов с независимого источника;
  5) для кода с ключами/внешними API — `ecc-security-reviewer`, для расчётного — `ecc-silent-failure-hunter`.
- Ролевая панель 2-из-3 (Coder/Reviewer/QA/Gate) — `agent-kit/orchestration/`, скил `pipeline`.
