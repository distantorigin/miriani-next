@echo off
setlocal EnableDelayedExpansion

git diff-index --quiet HEAD --
if %errorlevel% neq 0 (
    echo [ERROR] Uncommitted changes exist
    pause
    exit /b 1
)

for /f "delims=" %%i in ('git describe --tags --abbrev^=0 2^>nul') do set LATEST_TAG=%%i

if "!LATEST_TAG!"=="" (
    echo Starting from v1.0.0
    set MAJOR=1
    set MINOR=0
    set PATCH=0
) else (
    echo Current version: !LATEST_TAG!
    set VERSION=!LATEST_TAG:~1!

    for /f "tokens=1,2,3 delims=." %%a in ("!VERSION!") do (
        set MAJOR=%%a
        set MINOR=%%b
        set PATCH=%%c
        set MAJOR_STR=%%a
        set MINOR_STR=%%b
        set PATCH_STR=%%c
        call :strlen MAJOR_STR MAJOR_LEN
        call :strlen MINOR_STR MINOR_LEN
        call :strlen PATCH_STR PATCH_LEN
    )
)

echo.
echo Current version: v!MAJOR!.!MINOR!.!PATCH!
echo.
echo Select version bump type:
echo   1. Major (v!MAJOR!.!MINOR!.!PATCH! -^> v!MAJOR!+1.0.0)
echo   2. Minor (v!MAJOR!.!MINOR!.!PATCH! -^> v!MAJOR!.!MINOR!+1.0)
echo   3. Patch (v!MAJOR!.!MINOR!.!PATCH! -^> v!MAJOR!.!MINOR!.!PATCH!+1)
echo   4. Custom version
echo   5. Cancel
echo.
set /p CHOICE="Enter your choice (1-5): "

if "!CHOICE!"=="1" (
    set /a MAJOR=!MAJOR!+1
    call :pad_version !MAJOR! !MAJOR_LEN! MAJOR
    call :pad_version 0 !MINOR_LEN! MINOR
    call :pad_version 0 !PATCH_LEN! PATCH
) else if "!CHOICE!"=="2" (
    set /a MINOR=!MINOR!+1
    call :pad_version !MAJOR! !MAJOR_LEN! MAJOR
    call :pad_version !MINOR! !MINOR_LEN! MINOR
    call :pad_version 0 !PATCH_LEN! PATCH
) else if "!CHOICE!"=="3" (
    set /a PATCH=!PATCH!+1
    call :pad_version !MAJOR! !MAJOR_LEN! MAJOR
    call :pad_version !MINOR! !MINOR_LEN! MINOR
    call :pad_version !PATCH! !PATCH_LEN! PATCH
) else if "!CHOICE!"=="4" (
    set /p CUSTOM_VERSION="Enter custom version (e.g., 2.4.5): "
    set MAJOR=
    set MINOR=
    set PATCH=
    set VERSION=!CUSTOM_VERSION!
    goto create_tag
) else (
    echo Cancelled.
    pause
    exit /b 0
)

set VERSION=!MAJOR!.!MINOR!.!PATCH!

:create_tag
set NEW_TAG=v!VERSION!

echo.
echo Creating new version: !NEW_TAG!
echo.
set /p CONFIRM="Are you sure you want to create and publish this version? (y/n): "

if /i not "!CONFIRM!"=="y" (
    echo Cancelled.
    pause
    exit /b 0
)

REM Create the tag
echo.
echo Creating tag !NEW_TAG!...
git tag !NEW_TAG!
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create tag!
    pause
    exit /b 1
)

echo [OK] Tag created

echo.
git push origin !NEW_TAG!
if %errorlevel% neq 0 (
    echo [ERROR] Failed to push tag
    pause
    exit /b 1
)

echo [OK] Tag published
pause
exit /b 0

:strlen
setlocal enabledelayedexpansion
set "str=!%~1!"
set len=0
:strlen_loop
if defined str (
    set "str=!str:~1!"
    set /a len+=1
    goto :strlen_loop
)
endlocal & set "%~2=%len%"
exit /b

:pad_version
setlocal enabledelayedexpansion
set "num=%~1"
set "target_len=%~2"
set "result=%num%"
set len=0
set "temp=!result!"
:pad_version_len_loop
if defined temp (
    set "temp=!temp:~1!"
    set /a len+=1
    goto :pad_version_len_loop
)
:pad_version_loop
if !len! lss %target_len% (
    set "result=0!result!"
    set /a len+=1
    goto :pad_version_loop
)
endlocal & set "%~3=%result%"
exit /b
