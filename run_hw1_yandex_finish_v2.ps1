param(
    [int]$WaitMinutes = 0,
    [switch]$Force,
    [switch]$AllowDifferentModel
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

# This script is intentionally ASCII-only so that Windows PowerShell 5.1
# cannot corrupt its source code when the file has no UTF-8 BOM.

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

New-Item -ItemType Directory -Force -Path "logs" | Out-Null
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "=== AI4Science HW1 focused finish via Yandex AI Studio ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"

if ($WaitMinutes -gt 0) {
    Write-Host "Waiting $WaitMinutes minute(s) before launch..." -ForegroundColor Yellow
    Start-Sleep -Seconds ($WaitMinutes * 60)
}

$Ai4ScienceCmd = Get-Command ai4science -ErrorAction SilentlyContinue
if ($null -eq $Ai4ScienceCmd) {
    throw "ai4science command was not found in PATH. Activate the AI4Science environment or open the terminal where ai4science works."
}

$PythonCmd = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $PythonCmd) {
    throw "python command was not found in PATH. Activate the Python environment used by AI4Science."
}

function Run-NativeAndLog {
    param(
        [Parameter(Mandatory=$true)][string]$LogFile,
        [Parameter(Mandatory=$true)][scriptblock]$Command
    )

    $global:LASTEXITCODE = 0
    & $Command 2>&1 | Tee-Object -FilePath $LogFile | Out-Host
    return $LASTEXITCODE
}

# 1) Project preflight
Write-Host "`n[1/5] Project preflight" -ForegroundColor Cyan
$PreflightLog = "logs/yandex_finish_preflight_$Stamp.log"
$PreflightCode = Run-NativeAndLog -LogFile $PreflightLog -Command { python scripts/preflight.py }
if ($PreflightCode -ne 0) {
    throw "Preflight failed. See $PreflightLog"
}

# 2) AI4Science / Yandex configuration check
Write-Host "`n[2/5] AI4Science doctor" -ForegroundColor Cyan
$DoctorLog = "logs/yandex_finish_doctor_$Stamp.log"
$DoctorCode = Run-NativeAndLog -LogFile $DoctorLog -Command { ai4science doctor }
if ($DoctorCode -ne 0) {
    throw "ai4science doctor failed. See $DoctorLog"
}

$DoctorText = Get-Content -LiteralPath $DoctorLog -Raw
$ExpectedModel = "deepseek-v4-flash"
if ($DoctorText -notmatch [regex]::Escape($ExpectedModel)) {
    $msg = "AI4Science doctor does not show '$ExpectedModel'. This script is intended to continue with the previous Yandex AI Studio DeepSeek model."
    if (-not $AllowDifferentModel) {
        throw "$msg If the different model is intentional, rerun with -AllowDifferentModel."
    }
    Write-Warning $msg
}

# Optional daily-budget guard. This regex is ASCII-only and looks for a line
# containing two large integers separated by '/'. It does not depend on Russian text.
$BudgetMatch = [regex]::Match($DoctorText, '(?m)^.*?([0-9][0-9, ]*)\s*/\s*([0-9][0-9, ]*).*$')
if ($BudgetMatch.Success) {
    $UsedText = $BudgetMatch.Groups[1].Value.Replace(",", "").Replace(" ", "")
    $LimitText = $BudgetMatch.Groups[2].Value.Replace(",", "").Replace(" ", "")
    $Used = 0L
    $Limit = 0L
    if ([int64]::TryParse($UsedText, [ref]$Used) -and [int64]::TryParse($LimitText, [ref]$Limit)) {
        if ($Limit -ge 100000) {
            Write-Host "Detected daily token budget: $Used / $Limit"
            if ($Used -ge $Limit) {
                Write-Host "Daily token budget is still exhausted. Wait for the reset and run again." -ForegroundColor Yellow
                exit 88
            }
        }
    }
}

# 3) Strict check before model call
Write-Host "`n[3/5] Strict check before agent" -ForegroundColor Cyan
$BeforeLog = "logs/yandex_finish_check_before_$Stamp.log"
$BeforeCode = Run-NativeAndLog -LogFile $BeforeLog -Command { python checks/check_hw1.py --strict }
if (($BeforeCode -eq 0) -and (-not $Force)) {
    Write-Host "HW1 is already complete. No model call is needed." -ForegroundColor Green
    exit 0
}

# 4) Focused continuation. Keep the prompt compact because the expensive
# literature verification and parameter extraction are already on disk.
$Prompt = @'
Continue HW1 "Environment and Context" from the CURRENT on-disk project state.

First read only these project-control files:
1. AGENT.md
2. INDEX.md
3. STATUS.md
4. results/README.md
5. report/HW1_REPORT_TEMPLATE.md

Then immediately run:
python checks/check_hw1.py --strict

Do NOT redo artifacts that the checker already accepts.
The previous run already completed and validated the large literature pass,
source registry, ontology/graph, concept notes, and parameter_evidence.csv.

Your task is to fix ONLY the FAIL items reported by the current strict checker.
The last known unfinished items were:

1) results/local_context_examples.md
   - create at least 6 examples based on questions/local_context_queries.md;
   - run local retrieval with:
     python scripts/local_search.py "<query>" --top 8
   - for every example record: query, command, concise answer, SRC-Lxxx,
     page/locator, an independent verification step, and limitations or conflicts;
   - do not perform a new large external literature search unless a specific FAIL requires it.

2) report/HW1_environment_context.md
   - follow report/HW1_REPORT_TEMPLATE.md and AGENT.md;
   - include environment description, project map, local library, external-search summary,
     ontology/graph, local-context examples, generation-to-verification cycle,
     parameter evidence, DATA GAPs, and limitations;
   - Appendix A must contain the FULL current contents of AGENT.md.

3) diary.md
   - append only; do not rewrite previous entries;
   - add the date, task, completed actions, a verification checkpoint,
     the exact command 'python checks/check_hw1.py --strict', and the actual final result;
   - make the generation -> verification cycle explicit enough for the checker.

4) STATUS.md
   - update it after all work is complete.

After writing the files, run again:
python checks/check_hw1.py --strict

If it fails, fix only the remaining concrete FAIL items and rerun the checker.
The task is finished only when the actual checker output says:
HW1 CHECK: PASS

Do not modify:
- library/local/
- data/input/
- project_context/
- checks/

Do not invent sources, DOI values, page numbers, numerical values, or verification results.
Do not repeat the expensive verification of all external sources or reread all PDFs
unless the current checker specifically makes that necessary.
'@

Write-Host "`n[4/5] Focused AI4Science continuation" -ForegroundColor Cyan
$AgentLog = "logs/yandex_finish_agent_$Stamp.log"

# Important: use the same AI4Science default Yandex model configured in doctor.
# We intentionally do not pass an unverified model-selection CLI flag here.
$AgentCode = Run-NativeAndLog -LogFile $AgentLog -Command { ai4science run $Prompt }
if ($AgentCode -ne 0) {
    Write-Warning "The agent returned exit code $AgentCode. The final deterministic checker will still run because the needed files may already have been written."
}

# 5) Deterministic acceptance check
Write-Host "`n[5/5] Final strict check" -ForegroundColor Cyan
$FinalLog = "logs/yandex_finish_final_check_$Stamp.log"
$FinalCode = Run-NativeAndLog -LogFile $FinalLog -Command { python checks/check_hw1.py --strict }

if ($FinalCode -eq 0) {
    Write-Host "`n[HW1 CHECK: PASS]" -ForegroundColor Green
    Write-Host "Agent log: $AgentLog"
    Write-Host "Check log: $FinalLog"
    exit 0
}

Write-Host "`n[HW1 CHECK: FAIL]" -ForegroundColor Red
Write-Host "Agent exit code: $AgentCode"
Write-Host "See: $AgentLog"
Write-Host "See: $FinalLog"
exit $FinalCode
