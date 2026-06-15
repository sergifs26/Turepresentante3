@echo off
REM Doble clic para abrir el panel grafico de skills.
powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0Panel-Skills.ps1"
