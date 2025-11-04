@echo off
REM Helps you commit changes with an intuitive interface

setlocal EnableDelayedExpansion

REM Show current status
echo Current changes:
echo.
git status --short

echo.
echo What would you like to do?
echo   1. Commit all changes
echo   2. Commit specific files
echo   3. Show detailed changes (git diff)
echo   4. Cancel
echo.
set /p CHOICE="Enter your choice (1-4): "

if "!CHOICE!"=="1" goto commit_all
if "!CHOICE!"=="2" goto commit_specific
if "!CHOICE!"=="3" goto show_diff
if "!CHOICE!"=="4" goto cancel

echo Invalid choice. Please run the script again.
pause
exit /b 1

:show_diff
echo.
git diff
echo.
pause
goto :eof

:commit_all
echo.
echo Staging all changes...
git add -A
if %errorlevel% neq 0 (
    echo [ERROR] Failed to stage changes!
    pause
    exit /b 1
)
goto enter_message

:commit_specific
echo.
echo Enter the files you want to commit (space-separated, or * for pattern):
set /p FILES="Files: "

if "!FILES!"=="" (
    echo No files specified. Cancelled.
    pause
    exit /b 0
)

echo.
echo Staging files: !FILES!
git add !FILES!
if %errorlevel% neq 0 (
    echo [ERROR] Failed to stage files!
    pause
    exit /b 1
)
goto enter_message

:enter_message
echo.
echo Staged changes:
git status --short
echo.
set /p MESSAGE="Enter commit message: "

if "!MESSAGE!"=="" (
    echo Commit message cannot be empty. Cancelled.
    git reset >nul
    pause
    exit /b 0
)

echo.
echo Committing with message: "!MESSAGE!"
git commit -m "!MESSAGE!"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to commit!
    pause
    exit /b 1
)

echo [OK] Changes committed successfully

echo.
echo Would you like to push to remote? (y/n):
set /p PUSH=""

if /i "!PUSH!"=="y" (
    echo.
    echo Pushing to remote...
    git push
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to push!
        echo Your changes are committed locally but not pushed.
        echo You can push later with: git push
        pause
        exit /b 1
    )
    echo [OK] Changes pushed successfully
)

echo.
echo Done!
pause
exit /b 0

:cancel
echo Cancelled.
pause
exit /b 0
