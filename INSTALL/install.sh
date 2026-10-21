#!/usr/bin/env bash
# agent-kit installer (Git Bash / Linux / macOS)
# Использование:  bash INSTALL/install.sh [целевой_каталог] [направление]
# Примеры:
#   bash INSTALL/install.sh . web-fastapi
#   bash INSTALL/install.sh ~/work/my-service quant-ml
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-.}"
DIRECTION="${2:-}"

[ -d "$KIT/skills" ] || { echo "ОШИБКА: запусти из комплекта agent-kit (не найден $KIT/skills)"; exit 1; }

echo "== agent-kit -> $TARGET (направление: ${DIRECTION:-нет}) =="
mkdir -p "$TARGET"
cd "$TARGET"

# 1. Процедурные скилы (формат .agents/skills/<name>/SKILL.md)
mkdir -p .agents/skills
cp -r "$KIT/skills/"* .agents/skills/

# 2. Канон правил + входы для агентов (копии, Windows-безопасно)
cp "$KIT/common/AGENTS.template.md" .agents/AGENTS.md
cp -f .agents/AGENTS.md AGENTS.md
printf '@AGENTS.md\n' > CLAUDE.md

# 3. Оркестрация (роли, шаблоны, изоляция, скрипты)
mkdir -p .ai-team/panel-votes specs docs orchestration
cp -r "$KIT/orchestration/." orchestration/

# 3b. Онбординг и общие шаблоны — в проект (чтобы ссылки из скилов были валидны без комплекта рядом)
cp "$KIT/ONBOARDING-AGENT.md" ONBOARDING-AGENT.md
cp "$KIT/common/architecture-map.template.md" docs/architecture-map.template.md
cp "$KIT/common/gates.pyproject.toml" docs/gates.pyproject.toml

# 4. Направление (если указано)
if [ -n "$DIRECTION" ]; then
  PACK="$KIT/directions/$DIRECTION"
  [ -d "$PACK" ] || { echo "ОШИБКА: нет направления '$DIRECTION'. Доступны:"; ls "$KIT/directions"; exit 1; }
  if [ -d "$PACK/skills" ]; then cp -r "$PACK/skills/"* .agents/skills/; fi
  cp "$PACK/README.md" "docs/DIRECTION-$DIRECTION.md"
fi

# 5. .gitignore: следы откатов не коммитим
grep -q '^.bak/$' .gitignore 2>/dev/null || echo ".bak/" >> .gitignore

# 6. Итог
echo ""
echo "Готово. Скилов установлено: $(ls -1 .agents/skills | wc -l)"
echo "СТРАНЦЫ ДЛЯ ЗАПОЛНЕНИЯ ({{PLACEHOLDER}}):"
grep -c "{{" .agents/AGENTS.md || true
echo ""
echo "Дальше:"
echo "  1) Заполни {{PLACEHOLDER}} в .agents/AGENTS.md и продублируй в AGENTS.md (корневой — копия)."
echo "  2) Перенеси секции из docs/gates.pyproject.toml в pyproject.toml (без дублей таблиц)."
echo "  3) Первый запуск агента: пусть прочитает ONBOARDING-AGENT.md и выполнит investigate-codebase."
