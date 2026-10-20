$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path logs | Out-Null
python scripts/preflight.py | Tee-Object -FilePath logs/preflight.log
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
ai4science doctor | Tee-Object -FilePath logs/doctor.log
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
ai4science run "Выполни полностью TASK_ONE_SHOT.md, строго следуя AGENT.md. Не заканчивай, пока python checks/check_hw1.py --strict не вернёт код 0." | Tee-Object -FilePath logs/agent_run.log
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
python checks/check_hw1.py --strict | Tee-Object -FilePath logs/final_check.log
exit $LASTEXITCODE
