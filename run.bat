@echo off
set PATH=%CD%\lib;%PATH%
set PROJECT_NAME=tiny-player
set ODIN_FILE=src

odin run src

:: Clean up generated executable
del /f /q src.exe >nul 2>&1
