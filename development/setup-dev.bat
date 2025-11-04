@echo off
REM This script configures Git to skip tracking changes to local development files

echo Developer Setup
echo.
echo This script will configure Git to ignore changes to:
echo   - mushclient.sqlite
echo   - mushclient.ini
echo.
echo These files will remain in your working directory but Git
echo will not show them as modified in git status.
echo.
pause

echo.
echo Configuring Git to skip mushclient.sqlite...
git update-index --skip-worktree mushclient.sqlite 2>nul
if %errorlevel% equ 0 (
    echo [OK] mushclient.sqlite configured
) else (
    echo [WARNING] Could not configure mushclient.sqlite (file may not exist yet)
)

echo.
echo Configuring Git to skip mushclient.ini...
git update-index --skip-worktree mushclient.ini 2>nul
if %errorlevel% equ 0 (
    echo [OK] mushclient.ini configured
) else (
    echo [WARNING] Could not configure mushclient.ini (file may not exist yet)
)

echo.
echo Setup Complete!
echo.
echo Your local development files are now configured.
echo Git will ignore changes to these files.
echo.
echo To undo this later, run:
echo   git update-index --no-skip-worktree mushclient.sqlite
echo   git update-index --no-skip-worktree mushclient.ini
echo.
pause
