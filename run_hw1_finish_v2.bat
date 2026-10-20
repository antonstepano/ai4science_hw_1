@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_hw1_yandex_finish_v2.ps1" %*
set ERR=%ERRORLEVEL%
echo.
echo Script exit code: %ERR%
endlocal & exit /b %ERR%
