@echo off
setlocal EnableDelayedExpansion

echo Checking for updates...
echo.

REM Check for uncommitted changes
git diff-index --quiet HEAD -- 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] You have uncommitted changes:
    echo.
    git status --short
    echo.
    echo Recommendation: Run commit.bat first to save your work
    echo.
    set /p CONTINUE="Pull anyway? (y/n): "
    if /i not "!CONTINUE!"=="y" (
        echo Cancelled.
        pause
        exit /b 0
    )
    echo.
)

REM Pull with fast-forward only
git pull --ff-only

if %errorlevel% equ 0 (
    echo.
    echo [OK] Repository updated successfully!
    echo.
) else (
    echo.
    echo [ERROR] Pull failed
    echo.
    echo Common reasons:
    echo   - No internet connection
    echo   - Your branch has diverged from remote
    echo   - Merge conflicts detected
    echo.
    echo To resolve diverged branches:
    echo   git pull --rebase
    echo.
    echo To see what's wrong:
    echo   git status
    echo.
)

pause
exit /b %errorlevel%
