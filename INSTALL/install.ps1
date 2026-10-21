# agent-kit installer (Windows PowerShell)
# Использование:
#   INSTALL\install.ps1 -Target . -Direction web-fastapi
#   INSTALL\install.ps1 -Target C:\work\my-service
param(
    [string]$Target = ".",
    [string]$Direction = ""
)
$ErrorActionPreference = "Stop"
$Kit = Split-Path -Parent $PSScriptRoot   # корень agent-kit

if (-not (Test-Path (Join-Path $Kit "skills"))) {
    throw "ОШИБКА: запускать из комплекта agent-kit (не найден $Kit\skills)"
}
Write-Host "== agent-kit -> $Target (направление: $(if ($Direction) { $Direction } else { 'нет' })) =="

New-Item -ItemType Directory -Force -Path $Target | Out-Null
Push-Location $Target
try {
    # 1. Скилы
    New-Item -ItemType Directory -Force -Path ".agents\skills" | Out-Null
    Copy-Item -Path (Join-Path $Kit "skills\*") -Destination ".agents\skills\" -Recurse -Force

    # 2. Канон правил + входы для агентов
    Copy-Item (Join-Path $Kit "common\AGENTS.template.md") ".agents\AGENTS.md" -Force
    Copy-Item ".agents\AGENTS.md" "AGENTS.md" -Force
    Set-Content -Path "CLAUDE.md" -Value "@AGENTS.md" -Encoding UTF8

    # 3. Оркестрация
    New-Item -ItemType Directory -Force -Path ".ai-team\panel-votes", "specs", "docs", "orchestration" | Out-Null
    Copy-Item -Path (Join-Path $Kit "orchestration\*") -Destination "orchestration\" -Recurse -Force

    # 3b. Онбординг и общие шаблоны — в проект (чтобы ссылки из скилов были валидны без комплекта рядом)
    Copy-Item (Join-Path $Kit "ONBOARDING-AGENT.md") "ONBOARDING-AGENT.md" -Force
    Copy-Item (Join-Path $Kit "common\architecture-map.template.md") "docs\architecture-map.template.md" -Force
    Copy-Item (Join-Path $Kit "common\gates.pyproject.toml") "docs\gates.pyproject.toml" -Force

    # 4. Направление
    if ($Direction) {
        $Pack = Join-Path $Kit "directions\$Direction"
        if (-not (Test-Path $Pack)) {
            Write-Host "ОШИБКА: нет направления '$Direction'. Доступны:"; Get-ChildItem (Join-Path $Kit "directions") -Directory | Select-Object -ExpandProperty Name
            throw "неизвестное направление"
        }
        if (Test-Path (Join-Path $Pack "skills")) {
            Copy-Item -Path (Join-Path $Pack "skills\*") -Destination ".agents\skills\" -Recurse -Force
        }
        Copy-Item (Join-Path $Pack "README.md") "docs\DIRECTION-$Direction.md" -Force
    }

    # 5. .gitignore
    $gi = ".gitignore"
    if (-not (Test-Path $gi) -or -not (Select-String -Path $gi -Pattern "^\.bak/$" -Quiet)) {
        Add-Content -Path $gi -Value ".bak/"
    }

    # 6. Итог
    $skillCount = (Get-ChildItem ".agents\skills" -Directory).Count
    $ph = (Select-String -Path ".agents\AGENTS.md" -Pattern "\{\{" -AllMatches).Matches.Count
    Write-Host ""
    Write-Host "Готово. Скилов установлено: $skillCount; плейсхолдеров {{...}} в AGENTS.md: $ph"
    Write-Host "Дальше: 1) заполнить {{PLACEHOLDER}} в .agents\AGENTS.md и AGENTS.md;"
    Write-Host "        2) перенести docs\gates.pyproject.toml в pyproject.toml;"
    Write-Host "        3) первый запуск агента — ONBOARDING-AGENT.md + investigate-codebase."
}
finally {
    Pop-Location
}
