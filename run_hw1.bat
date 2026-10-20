@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0run_hw1.ps1"
exit /b %ERRORLEVEL%
