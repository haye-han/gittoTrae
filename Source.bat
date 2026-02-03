::[Bat To Exe Converter]
::
::fBE1pAF6MU+EWHreyHcjLQlHcAuMAE+/Fb4I5/jHZTp7LrDF2CLK81wP5oarAcQ+zwvwbYJN
::fBE1pAF6MU+EWHreyHcjLQlHcAuMAE+/Fb4I5/jHZTp7LrDF2CLK81wP5rOGbuUL7yU=
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+IeA==
::cxY6rQJ7JhzQF1fEqQJhSA==
::ZQ05rAF9IBncCkqN+0xwdVsFLA==
::ZQ05rAF9IAHYFVzEqQI3IQ9AQzCQPW7a
::eg0/rx1wNQPfEVWB+kM9LVsJDAOLKH+1Mqcd7Yg=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQI3IQ9AQzCQPW7a
::dhA7uBVwLU+EWHGF7UcjaDNVQmQ=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATE3EMpLQgUZAWMXA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBRacCCHL2CuCaUgYjgHYxdfLo3o3zHrRIjSzqCBFPIS7wvhbZNN
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
setlocal EnableDelayedExpansion

:: ========================================================
:: GitHub Codespace SSH Setup Tool (v1.4)
:: [Note] Using English to prevent character encoding issues.
:: ========================================================

title GitHub Codespace SSH Configurator

set "EXIT_CODE=0"
echo ========================================================
echo   GitHub Codespace SSH Setup Tool
echo ========================================================
echo.

:: [Step 1] Search for gh.exe
echo [1/5] Searching for 'gh.exe'...
set "GH_CMD="

:: 1. Bat To Exe Converter temp directory
if defined MYFILES (
    if exist "!MYFILES!\gh.exe" (
        set "GH_CMD=!MYFILES!\gh.exe"
        echo    - Found: Embedded (!GH_CMD!)
    )
)

:: 2. Current directory
if not defined GH_CMD (
    if exist "%~dp0gh.exe" (
        set "GH_CMD=%~dp0gh.exe"
        echo    - Found: Current Dir (!GH_CMD!)
    )
)

:: 3. System PATH
if not defined GH_CMD (
    where gh >nul 2>&1
    if !errorlevel! equ 0 (
        set "GH_CMD=gh"
        echo    - Found: System PATH
    )
)

if not defined GH_CMD (
    echo.
    echo [ERROR] 'gh.exe' not found.
    echo Please make sure gh.exe is in the same folder or included in the EXE.
    set "EXIT_CODE=1"
    goto :FINAL_STEP
)

:: [Step 2] Test gh.exe
"!GH_CMD!" --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] "!GH_CMD!" is invalid or corrupted.
    set "EXIT_CODE=1"
    goto :FINAL_STEP
)
echo    - Executable check passed.

:: [Step 3] GitHub Authentication
echo.
echo [2/5] Checking GitHub login status...
"!GH_CMD!" auth status >nul 2>&1
if !errorlevel! neq 0 (
    echo    - Not logged in. Starting authentication...
    echo.
    echo [Notice] A browser will open. Verify the code and authorize.
    echo.
    "!GH_CMD!" auth login --hostname github.com --git-protocol ssh --web
    "!GH_CMD!" auth status >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] Authentication failed.
        set "EXIT_CODE=1"
        goto :FINAL_STEP
    )
)
echo    - Auth Success.

:: [Step 4] Prepare SSH Config
echo.
echo [3/5] Preparing SSH configuration...
set "SSH_DIR=%USERPROFILE%\.ssh"
set "SSH_CONFIG=!SSH_DIR!\config"

if not exist "!SSH_DIR!" (
    mkdir "!SSH_DIR!" >nul 2>&1
)

if exist "!SSH_CONFIG!" (
    set "BAK_NAME=!SSH_CONFIG!.bak_!RANDOM!"
    copy /y "!SSH_CONFIG!" "!BAK_NAME!" >nul 2>&1
    echo    - Existing config backed up to: !BAK_NAME!
)

:: [Step 5] Apply Codespace Config
echo.
echo [4/5] Fetching available Codespaces...
echo ---------------------------------------------------------------------
"!GH_CMD!" codespace list
if !errorlevel! neq 0 (
    echo [ERROR] Failed to fetch Codespace list.
    set "EXIT_CODE=1"
    goto :FINAL_STEP
)
echo ---------------------------------------------------------------------
echo.
echo [Input] Enter the 'Name' of the Codespace you want to connect to:
set /p TARGET_NAME="> "

if "!TARGET_NAME!"=="" (
    echo [ERROR] No name entered. Operation canceled.
    set "EXIT_CODE=1"
    goto :FINAL_STEP
)

echo.
echo [5/5] Applying SSH configuration for "!TARGET_NAME!"...
"!GH_CMD!" codespace ssh --config -c "!TARGET_NAME!" > "!SSH_CONFIG!" 2>nul

if !errorlevel! neq 0 (
    echo [ERROR] Failed to generate SSH config. 
    echo Please check if the Codespace name is correct and it is active.
    set "EXIT_CODE=1"
    goto :FINAL_STEP
)

echo.
echo ========================================================
echo   [SUCCESS] Setup complete!
echo   You can now connect to "!TARGET_NAME!" via SSH.
echo ========================================================

:FINAL_STEP
echo.
if "!EXIT_CODE!"=="0" (
    echo [Status] Success
) else (
    echo [Status] Failed (Code: !EXIT_CODE!)
)
echo.
echo Press any key to exit...
pause >nul
exit /b %EXIT_CODE%
