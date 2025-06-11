@echo off
title CleanTemp
color 0B

:: Check if the script is running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Attempting to reboot in administrator mode...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo Quick cleaning in progress...
echo.

:: Essential cleaning without confirmation
echo [1/4] User temporary files...
del /q /f /s "%TEMP%\*.*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1

echo [2/4] Temporary system files...
del /q /f /s "%SystemRoot%\Temp\*.*" >nul 2>&1
for /d %%x in ("%SystemRoot%\Temp\*") do rd /s /q "%%x" >nul 2>&1

echo [3/4] Cache Prefetch...
del /q /f "%SystemRoot%\Prefetch\*.pf" >nul 2>&1

echo [4/4] Recycle Bin and DNS Cache...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

echo.
echo ✓ Quick cleaning complete!
echo.
echo Operations executed:
echo   - Temporary files deleted
echo   - Prefetch cache cleaned
echo   -  empty trash
echo   - empty DNS cache
echo.
timeout /t 5 >nul



