@echo off
title Nettoyage Rapide Quotidien
color 0B

:: Vérification si le script est exécuté en tant qu'administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Tentative de redemarrage en mode administrateur...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo Nettoyage rapide en cours...
echo.

:: Nettoyage essentiel sans confirmation
echo [1/4] Fichiers temporaires utilisateur...
del /q /f /s "%TEMP%\*.*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1

echo [2/4] Fichiers temporaires systeme...
del /q /f /s "%SystemRoot%\Temp\*.*" >nul 2>&1
for /d %%x in ("%SystemRoot%\Temp\*") do rd /s /q "%%x" >nul 2>&1

echo [3/4] Cache Prefetch...
del /q /f "%SystemRoot%\Prefetch\*.pf" >nul 2>&1

echo [4/4] Corbeille et cache DNS...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

echo.
echo ✓ Nettoyage rapide termine !
echo.
echo Operations executees:
echo   - Fichiers temporaires supprimes
echo   - Cache Prefetch nettoye
echo   - Corbeille videe
echo   - Cache DNS vide
echo.
timeout /t 5 >nul



