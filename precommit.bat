@echo off
REM Improved development workflow automation for Toastush. Probablky better as a git hook, let's be honest.
echo Starting pre-commit workflow...

REM Step 1: Clean up problematic files
echo Step 1: Cleaning up problematic files...
git checkout -- mushclient_prefs.sqlite 2>nul
echo Files cleaned up.

REM Step 2: Generate index manifest automatically
echo Step 2: Generating index manifest...
python generate_index.py
if %errorlevel% neq 0 (
    echo Error: Python script failed. Make sure Python is installed and accessible.
    pause
    exit /b 1
)

REM Step 3: Stage all changes for commit
echo Step 3: Staging changes for git...
git add -A

REM Step 4: Show status
echo Step 4: Current git status...
git status

echo.
echo Pre-commit workflow complete!
echo You can now commit your changes with: git commit -m "your message"
echo.
pause