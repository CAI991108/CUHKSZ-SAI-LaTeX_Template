@echo off
REM ---------------------------------------------------------------------------
REM  Windows wrapper around build.ps1.
REM  Needed because PowerShell may refuse to run unsigned .ps1 files that sit
REM  inside this folder (execution policy / zone handling), even under
REM  RemoteSigned.  Bypass is scoped to this single invocation only.
REM
REM  Usage:  scripts\build.cmd            (Chinese document)
REM          scripts\build.cmd -All       (both documents)
REM          scripts\build.cmd -Clean     (empty tmp\ first)
REM ---------------------------------------------------------------------------
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*
exit /b %ERRORLEVEL%
