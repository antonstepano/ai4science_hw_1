param(
    [string]$ModelAlias = "deepseek",
    [int]$WaitMinutes = 0,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# The script is expected to be placed in the root of AI4Science_LunarDust_HW1.
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

New-Item -ItemType Directory -Force -Path "logs" | Out-Null
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "=== AI4Science HW1 finish via Yandex AI Studio ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"
Write-Host "Model alias: $ModelAlias"

if ($WaitMinutes -gt 0) {
    Write-Host "Waiting $WaitMinutes minute(s) before launch..." -ForegroundColor Yellow
    Start-Sleep -Seconds ($WaitMinutes * 60)
}

# 1) Preflight: project/local context must be intact.
Write-Host "`n[1/5] preflight" -ForegroundColor Cyan
python scripts/preflight.py 2>&1 | Tee-Object -FilePath "logs/yandex_finish_preflight_$Stamp.log"
if ($LASTEXITCODE -ne 0) {
    throw "Preflight failed. See logs/yandex_finish_preflight_$Stamp.log"
}

# 2) Check current AI4Science/Yandex configuration.
# This does not print the secret API key itself; doctor only reports whether it is configured.
Write-Host "`n[2/5] ai4science doctor" -ForegroundColor Cyan
$DoctorLog = "logs/yandex_finish_doctor_$Stamp.log"
ai4science doctor 2>&1 | Tee-Object -FilePath $DoctorLog
if ($LASTEXITCODE -ne 0) {
    throw "ai4science doctor failed. See $DoctorLog"
}

$DoctorText = Get-Content $DoctorLog -Raw
if ($DoctorText -notmatch "YANDEX_CLOUD_API_KEY") {
    Write-Warning "doctor output does not mention YANDEX_CLOUD_API_KEY; check the AI4Science .env/config before launch."
}
if ($DoctorText -notmatch "deepseek-v4-flash") {
    Write-Warning "doctor does not show deepseek-v4-flash as the current model. The script will explicitly request alias '$ModelAlias'."
}

# Optional budget guard. Current course builds show e.g. 'budget: 12,104 / 3,000,000'.
$BudgetMatch = [regex]::Match($DoctorText, '(?im)(?:бюджет|budget)\s*:\s*([0-9, ]+)\s*/\s*([0-9, ]+)')
if ($BudgetMatch.Success) {
    $Used = [int64](($BudgetMatch.Groups[1].Value -replace '[, ]',''))
    $Limit = [int64](($BudgetMatch.Groups[2].Value -replace '[, ]',''))
    Write-Host "AI4Science daily budget: $Used / $Limit tokens"
    if ($Used -ge $Limit) {
        Write-Error "Daily AI4Science token limit is still exhausted. Wait for reset and rerun this script."
        exit 88
    }
}

# 3) Check current completion state first. If the previous session finished enough work,
# don't spend any new tokens.
Write-Host "`n[3/5] strict check before agent" -ForegroundColor Cyan
$BeforeLog = "logs/yandex_finish_check_before_$Stamp.log"
python checks/check_hw1.py --strict 2>&1 | Tee-Object -FilePath $BeforeLog
$BeforeCode = $LASTEXITCODE
if (($BeforeCode -eq 0) -and (-not $Force)) {
    Write-Host "HW1 is already complete. No model call is needed." -ForegroundColor Green
    exit 0
}

# 4) Focused continuation prompt. Do NOT repeat the expensive literature pass that is already complete.
$Prompt = @'
Продолжи выполнение ДЗ 1 «Среда и контекст» из ТЕКУЩЕГО состояния проекта на диске.

Сначала прочитай только:
1. AGENT.md
2. INDEX.md
3. STATUS.md
4. results/README.md
5. report/HW1_REPORT_TEMPLATE.md

Затем сразу выполни:
python checks/check_hw1.py --strict

Не переделывай артефакты, которые checker уже считает корректными.
Предыдущий запуск уже сформировал и checker подтвердил:
- ontology.yaml и graph_view.md;
- >=10 concept notes;
- results/sources.csv: 32 источника, включая 8 локальных и 24 внешних;
- results/parameter_evidence.csv: 80 строк, 10 блоков модели;
- provenance для источников и parameter evidence.

Главная задача этого запуска — закрыть ТОЛЬКО оставшиеся FAIL.
По последнему известному check это:

1. results/local_context_examples.md
   - выполни минимум 6 запросов из questions/local_context_queries.md;
   - используй локальный поиск:
     python scripts/local_search.py "<запрос>" --top 8
   - для каждого примера запиши запрос, команду, краткий ответ, SRC-Lxxx, страницу,
     независимую проверку и ограничения/противоречия;
   - не выполняй большой внешний литературный поиск, если он не нужен для конкретного FAIL.

2. report/HW1_environment_context.md
   - используй report/HW1_REPORT_TEMPLATE.md и AGENT.md;
   - обязательно включи: описание среды, карту проекта, локальную библиотеку,
     внешний поиск, ontology/graph, примеры локального контекста,
     generation→verification loop, parameter evidence, DATA GAP, ограничения;
   - Приложение A должно содержать ПОЛНЫЙ текст AGENT.md.

3. diary.md
   - старые записи не менять, только дописать;
   - добавить дату, задачу, что выполнено;
   - обязательно добавить буквальные маркеры «Точка проверки» и «Итог проверки»;
   - указать команду python checks/check_hw1.py --strict и её фактический результат.

4. STATUS.md
   - обновить текущее состояние после завершения.

После записи файлов снова запусти:
python checks/check_hw1.py --strict

Если checker не проходит — исправляй только конкретные FAIL и повторяй проверку.
Работа закончена только если фактический вывод содержит:
HW1 CHECK: PASS

Не изменяй:
- library/local/
- data/input/
- project_context/
- checks/

Не выдумывай источники, DOI, страницы, численные значения или результаты проверки.
Не начинай заново дорогостоящую верификацию всех 24 внешних источников и не перечитывай все PDF,
если уже существующие результаты достаточны для отчёта.
'@

Write-Host "`n[4/5] focused Yandex AI Studio continuation" -ForegroundColor Cyan
$AgentLog = "logs/yandex_finish_agent_$Stamp.log"

# Course AI4Science exposes model aliases including 'deepseek'.
# Placing -m before 'run' follows the course CLI syntax for selecting the model for the session.
ai4science -m $ModelAlias run $Prompt 2>&1 | Tee-Object -FilePath $AgentLog
$AgentCode = $LASTEXITCODE

if ($AgentCode -ne 0) {
    Write-Warning "The agent process returned exit code $AgentCode. A final deterministic check will still run, because files may already have been completed."
}

# 5) Always run the deterministic acceptance check after the agent.
Write-Host "`n[5/5] final strict check" -ForegroundColor Cyan
$FinalLog = "logs/yandex_finish_final_check_$Stamp.log"
python checks/check_hw1.py --strict 2>&1 | Tee-Object -FilePath $FinalLog
$CheckCode = $LASTEXITCODE

if ($CheckCode -eq 0) {
    Write-Host "`n[HW1 CHECK: PASS]" -ForegroundColor Green
    Write-Host "Agent log: $AgentLog"
    Write-Host "Check log: $FinalLog"
    exit 0
}

Write-Host "`n[HW1 CHECK: FAIL]" -ForegroundColor Red
Write-Host "Agent exit code: $AgentCode"
Write-Host "See: $AgentLog"
Write-Host "See: $FinalLog"
exit $CheckCode
