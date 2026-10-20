#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs
python3 scripts/preflight.py | tee logs/preflight.log
ai4science doctor | tee logs/doctor.log
ai4science run "Выполни полностью TASK_ONE_SHOT.md, строго следуя AGENT.md. Не заканчивай, пока python checks/check_hw1.py --strict не вернёт код 0." | tee logs/agent_run.log
python3 checks/check_hw1.py --strict | tee logs/final_check.log
