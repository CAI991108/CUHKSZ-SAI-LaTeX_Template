@echo off
REM ---------------------------------------------------------------------------
REM  Windows wrapper around setup-miktex.ps1.
REM  Bypass is scoped to this single invocation only.
REM
REM  Usage:  scripts\setup.cmd
REM ---------------------------------------------------------------------------
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-miktex.ps1" %*
exit /b %ERRORLEVEL%
