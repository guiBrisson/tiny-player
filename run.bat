@echo off
set PATH=%CD%\lib;%PATH%

odin run src

:: Clean up generated executable
del /f /q src.exe >nul 2>&1
