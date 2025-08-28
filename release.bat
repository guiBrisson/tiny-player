@echo off
setlocal

:: === Settings ===
set PROJECT_NAME=tiny-player
set ODIN_FILE=src
set BUILD_DIR=build
set LIB_DIR=lib
set RELEASE_NAME=%PROJECT_NAME%-release.zip

:: === Cleanup ===
echo Cleaning up previous build...
if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
if exist %RELEASE_NAME% del %RELEASE_NAME%

:: === Build ===
echo Building release executable...
mkdir %BUILD_DIR%
odin build %ODIN_FILE% -o:speed -subsystem:windows -show-timings -vet -out:%BUILD_DIR%\%PROJECT_NAME%.exe

:: === Copy DLLs ===
echo Copying DLLs...
copy %LIB_DIR%\*.dll %BUILD_DIR% >nul

:: === Zip ===
echo Creating release archive...
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\*' -DestinationPath '%RELEASE_NAME%'"

echo Done. Release archive created: %RELEASE_NAME%

endlocal
pause
