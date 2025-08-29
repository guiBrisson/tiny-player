@echo off
setlocal

:: === Settings ===
set PROJECT_NAME=tiny-player
set ODIN_FILE=src
set BUILD_DIR=build
set LIB_DIR=lib
set DATA_DIR=data
set RELEASE_NAME=%PROJECT_NAME%.zip

:: === Parse argument ===
set RELEASE=false
if /I "%1"=="release" set RELEASE=true

:: === Cleanup ===
echo Cleaning up previous build...
if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
if exist %RELEASE_NAME% del %RELEASE_NAME%

:: === Build ===
echo Building executable...
mkdir %BUILD_DIR%
if %RELEASE%==true (
    odin build %ODIN_FILE% -subsystem:windows -vet -out:%BUILD_DIR%\%PROJECT_NAME%.exe    
) else (
    odin build %ODIN_FILE% -out:%BUILD_DIR%\%PROJECT_NAME%.exe
)

:: === Copy DLLs ===
echo Copying DLLs...
copy %LIB_DIR%\*.dll %BUILD_DIR% >nul

:: === Copy data folder ===
echo Copying Lua scripts...
xcopy %DATA_DIR% %BUILD_DIR%\%DATA_DIR% /E /I /Y >nul

:: === Zip if requested ===
if %RELEASE%==true (
    echo Creating release archive...
    powershell -Command "Compress-Archive -Path '%BUILD_DIR%\*' -DestinationPath '%RELEASE_NAME%'"
    echo Done. Release archive created: %RELEASE_NAME%
) else (
    echo Build complete. No archive created.
)

endlocal
