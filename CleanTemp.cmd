@echo off
setlocal enabledelayedexpansion

:: Vérification si le script est exécuté en tant qu'administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b

)
:: ============================================================================
::                            SÉLECTION DE LA LANGUE
:: ============================================================================
:language_selection
cls
echo.
echo ================================================================================
echo                    LANGUAGE SELECTION / SELECTION DE LANGUE
echo ================================================================================
echo.
echo 1. Francais
echo 2. English
echo.
set /p lang_choice="Choisissez votre langue / Choose your language (1-2): "

if "%lang_choice%"=="1" (
    set "LANG=FR"
    call :load_french_messages
) else if "%lang_choice%"=="2" (
    set "LANG=EN"
    call :load_english_messages
) else (
    echo Choix invalide / Invalid choice
    timeout /t 2 >nul
    goto language_selection
)

title %MSG_TITLE%
color 0B

:: ============================================================================
::                                MENU PRINCIPAL
:: ============================================================================
:main_menu
cls
echo.
echo ================================================================================
echo                           %MSG_TITLE%
echo ================================================================================
echo.
echo %MSG_WELCOME%
echo %MSG_IMPORTANT%
echo.
set /p continue_choice="%MSG_CONTINUE%"

if "%LANG%"=="FR" (
    if /i "%continue_choice%" neq "O" goto cancel_operation
) else (
    if /i "%continue_choice%" neq "Y" goto cancel_operation
)

:: ============================================================================
::                            CHOIX DE LA PORTÉE
:: ============================================================================
:scope_selection
cls
echo.
echo %MSG_SCOPE_QUESTION%
echo.
echo %MSG_SCOPE_CURRENT%
echo %MSG_SCOPE_EXTENDED%
echo.
set /p user_scope="%MSG_SCOPE_CHOICE%"

if "%user_scope%"=="1" (
    set "CLEAN_SCOPE=CURRENT"
    set "SCOPE_DESC=%MSG_SCOPE_CURRENT%"
) else if "%user_scope%"=="2" (
    set "CLEAN_SCOPE=EXTENDED"
    set "SCOPE_DESC=%MSG_SCOPE_EXTENDED%"
) else (
    echo %MSG_INVALID_CHOICE%
    timeout /t 2 >nul
    goto scope_selection
)

:: ============================================================================
::                            CHOIX CORBEILLE
:: ============================================================================
:recycle_selection
cls
echo.
echo %MSG_RECYCLE_QUESTION%
echo.
set /p recycle_choice="%MSG_RECYCLE_PROMPT%"

if "%LANG%"=="FR" (
    if /i "%recycle_choice%"=="O" (
        set "EMPTY_RECYCLE=YES"
        set "RECYCLE_DESC=%MSG_YES%"
    ) else if /i "%recycle_choice%"=="N" (
        set "EMPTY_RECYCLE=NO"
        set "RECYCLE_DESC=%MSG_NO%"
    ) else (
        echo %MSG_INVALID_CHOICE%
        timeout /t 2 >nul
        goto recycle_selection
    )
) else (
    if /i "%recycle_choice%"=="Y" (
        set "EMPTY_RECYCLE=YES"
        set "RECYCLE_DESC=%MSG_YES%"
    ) else if /i "%recycle_choice%"=="N" (
        set "EMPTY_RECYCLE=NO"
        set "RECYCLE_DESC=%MSG_NO%"
    ) else (
        echo %MSG_INVALID_CHOICE%
        timeout /t 2 >nul
        goto recycle_selection
    )
)

:: ============================================================================
::                            CONFIRMATION
:: ============================================================================
:confirmation
cls
echo.
echo %MSG_CONFIRM_TITLE%
echo.
echo   %MSG_CONFIRM_SCOPE% %SCOPE_DESC%
echo   %MSG_CONFIRM_RECYCLE% %RECYCLE_DESC%
echo.
set /p final_confirm="%MSG_CONFIRM_PROCEED%"

if "%LANG%"=="FR" (
    if /i "%final_confirm%" neq "O" goto cancel_operation
) else (
    if /i "%final_confirm%" neq "Y" goto cancel_operation
)

:: ============================================================================
::                            EXECUTION DU NETTOYAGE
:: ============================================================================
cls
echo.
echo ================================================================================
echo                           %MSG_CLEANING_PROGRESS%
echo ================================================================================
echo.

:: Nettoyage des fichiers temporaires utilisateur actuel
echo [1/6] %MSG_CLEANING_USER_TEMP%
if exist "%TEMP%" (
    del /q /f /s "%TEMP%\*.*" >nul 2>&1
    for /d %%x in ("%TEMP%\*") do rd /s /q "%%x" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Temp" (
    del /q /f /s "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
    for /d %%x in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%x" >nul 2>&1
)
echo      [✓] %MSG_DONE%

:: Nettoyage étendu si sélectionné
if "%CLEAN_SCOPE%"=="EXTENDED" (
    echo [2/6] %MSG_CLEANING_SYSTEM_TEMP%
    if exist "%SystemRoot%\Temp" (
        del /q /f /s "%SystemRoot%\Temp\*.*" >nul 2>&1
        for /d %%x in ("%SystemRoot%\Temp\*") do rd /s /q "%%x" >nul 2>&1
    )
    
    echo [3/6] %MSG_CLEANING_ALL_USERS%
    for /d %%u in ("C:\Users\*") do (
        if exist "%%u\AppData\Local\Temp" (
            del /q /f /s "%%u\AppData\Local\Temp\*.*" >nul 2>&1
            for /d %%x in ("%%u\AppData\Local\Temp\*") do rd /s /q "%%x" >nul 2>&1
        )
    )
    echo      [✓] %MSG_DONE%
) else (
    echo [2/6] %MSG_CLEANING_SYSTEM_TEMP% (%MSG_SKIPPED%)
    echo [3/6] %MSG_CLEANING_ALL_USERS% (%MSG_SKIPPED%)
)

:: Nettoyage du cache Prefetch
echo [4/6] %MSG_CLEANING_PREFETCH%
if exist "%SystemRoot%\Prefetch" (
    del /q /f "%SystemRoot%\Prefetch\*.pf" >nul 2>&1
)
echo      [✓] %MSG_DONE%

:: Vidage de la corbeille si demandé
echo [5/6] %MSG_CLEANING_RECYCLE%
if "%EMPTY_RECYCLE%"=="YES" (
    PowerShell.exe -NoProfile -Command "try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
    echo      [✓] %MSG_DONE%
) else (
    echo      [✓] %MSG_SKIPPED%
)

:: Vidage du cache DNS
echo [6/6] %MSG_CLEANING_DNS%
ipconfig /flushdns >nul 2>&1
echo      [✓] %MSG_DONE%

:: ============================================================================
::                            RÉSULTATS FINAUX
:: ============================================================================
echo.
echo ================================================================================
echo                           %MSG_CLEANING_COMPLETE%
echo ================================================================================
echo.
echo %MSG_OPERATIONS_SUMMARY%
echo.
echo   [✓] %MSG_SUMMARY_USER_TEMP%
if "%CLEAN_SCOPE%"=="EXTENDED" (
    echo   [✓] %MSG_SUMMARY_SYSTEM_TEMP%
    echo   [✓] %MSG_SUMMARY_ALL_USERS%
)
echo   [✓] %MSG_SUMMARY_PREFETCH%
if "%EMPTY_RECYCLE%"=="YES" (
    echo   [✓] %MSG_SUMMARY_RECYCLE%
)
echo   [✓] %MSG_SUMMARY_DNS%
echo.
pause
goto :eof

:cancel_operation
echo %MSG_CANCELLED%
pause
exit /b 0

:: ============================================================================
::                            MESSAGES FRANÇAIS
:: ============================================================================
:load_french_messages
set "MSG_TITLE=Nettoyage Rapide Personnalise"
set "MSG_ADMIN_ERROR=[ERREUR] Ce script necessite des privileges administrateur."
set "MSG_ADMIN_INSTRUCTION=Clic droit sur le fichier et selectionner 'Executer en tant qu'administrateur'"
set "MSG_WELCOME=Ce script va effectuer un nettoyage rapide et personnalise des fichiers temporaires."
set "MSG_IMPORTANT=IMPORTANT: Il est recommande de creer un point de restauration avant utilisation."
set "MSG_CONTINUE=Voulez-vous continuer ? (O/N): "
set "MSG_SCOPE_QUESTION=Choisissez la portee du nettoyage :"
set "MSG_SCOPE_CURRENT=1. Mon utilisateur seulement (fichiers temporaires de ma session)"
set "MSG_SCOPE_EXTENDED=2. Nettoyage etendu (ma session + fichiers systeme + autres utilisateurs)"
set "MSG_SCOPE_CHOICE=Entrez 1 ou 2: "
set "MSG_RECYCLE_QUESTION=Voulez-vous vider la corbeille ?"
set "MSG_RECYCLE_PROMPT=Vider la corbeille ? (O/N): "
set "MSG_CONFIRM_TITLE=Veuillez confirmer vos choix :"
set "MSG_CONFIRM_SCOPE=Portee selectionnee:"
set "MSG_CONFIRM_RECYCLE=Vider corbeille:"
set "MSG_CONFIRM_PROCEED=Proceder au nettoyage avec ces parametres ? (O/N): "
set "MSG_CLEANING_PROGRESS=NETTOYAGE EN COURS"
set "MSG_CLEANING_USER_TEMP=Nettoyage des fichiers temporaires utilisateur..."
set "MSG_CLEANING_SYSTEM_TEMP=Nettoyage des fichiers temporaires systeme..."
set "MSG_CLEANING_ALL_USERS=Nettoyage des fichiers temporaires autres utilisateurs..."
set "MSG_CLEANING_PREFETCH=Nettoyage du cache Prefetch..."
set "MSG_CLEANING_RECYCLE=Vidage de la corbeille..."
set "MSG_CLEANING_DNS=Vidage du cache DNS..."
set "MSG_CLEANING_COMPLETE=NETTOYAGE TERMINE AVEC SUCCES"
set "MSG_OPERATIONS_SUMMARY=Resume des operations executees :"
set "MSG_SUMMARY_USER_TEMP=Fichiers temporaires utilisateur supprimes"
set "MSG_SUMMARY_SYSTEM_TEMP=Fichiers temporaires systeme supprimes"
set "MSG_SUMMARY_ALL_USERS=Fichiers temporaires autres utilisateurs supprimes"
set "MSG_SUMMARY_PREFETCH=Cache Prefetch nettoye"
set "MSG_SUMMARY_RECYCLE=Corbeille videe"
set "MSG_SUMMARY_DNS=Cache DNS vide"
set "MSG_YES=Oui"
set "MSG_NO=Non"
set "MSG_DONE=Termine"
set "MSG_SKIPPED=Ignore"
set "MSG_INVALID_CHOICE=Choix invalide. Veuillez reessayer."
set "MSG_CANCELLED=Operation annulee par l'utilisateur."
goto :eof

:: ============================================================================
::                            MESSAGES ANGLAIS
:: ============================================================================
:load_english_messages
set "MSG_TITLE=Personalized Quick Cleanup"
set "MSG_ADMIN_ERROR=[ERROR] This script requires administrator privileges."
set "MSG_ADMIN_INSTRUCTION=Right-click the file and select 'Run as administrator'"
set "MSG_WELCOME=This script will perform a quick and personalized cleanup of temporary files."
set "MSG_IMPORTANT=IMPORTANT: It is recommended to create a restore point before use."
set "MSG_CONTINUE=Do you want to continue? (Y/N): "
set "MSG_SCOPE_QUESTION=Choose the cleanup scope:"
set "MSG_SCOPE_CURRENT=1. My user only (temporary files from my session)"
set "MSG_SCOPE_EXTENDED=2. Extended cleanup (my session + system files + other users)"
set "MSG_SCOPE_CHOICE=Enter 1 or 2: "
set "MSG_RECYCLE_QUESTION=Do you want to empty the recycle bin?"
set "MSG_RECYCLE_PROMPT=Empty recycle bin? (Y/N): "
set "MSG_CONFIRM_TITLE=Please confirm your choices:"
set "MSG_CONFIRM_SCOPE=Selected scope:"
set "MSG_CONFIRM_RECYCLE=Empty recycle bin:"
set "MSG_CONFIRM_PROCEED=Proceed with cleanup using these settings? (Y/N): "
set "MSG_CLEANING_PROGRESS=CLEANING IN PROGRESS"
set "MSG_CLEANING_USER_TEMP=Cleaning user temporary files..."
set "MSG_CLEANING_SYSTEM_TEMP=Cleaning system temporary files..."
set "MSG_CLEANING_ALL_USERS=Cleaning other users temporary files..."
set "MSG_CLEANING_PREFETCH=Cleaning Prefetch cache..."
set "MSG_CLEANING_RECYCLE=Emptying recycle bin..."
set "MSG_CLEANING_DNS=Flushing DNS cache..."
set "MSG_CLEANING_COMPLETE=CLEANUP COMPLETED SUCCESSFULLY"
set "MSG_OPERATIONS_SUMMARY=Summary of operations performed:"
set "MSG_SUMMARY_USER_TEMP=User temporary files deleted"
set "MSG_SUMMARY_SYSTEM_TEMP=System temporary files deleted"
set "MSG_SUMMARY_ALL_USERS=Other users temporary files deleted"
set "MSG_SUMMARY_PREFETCH=Prefetch cache cleaned"
set "MSG_SUMMARY_RECYCLE=Recycle bin emptied"
set "MSG_SUMMARY_DNS=DNS cache flushed"
set "MSG_YES=Yes"
set "MSG_NO=No"
set "MSG_DONE=Done"
set "MSG_SKIPPED=Skipped"
set "MSG_INVALID_CHOICE=Invalid choice. Please try again."
set "MSG_CANCELLED=Operation cancelled by user."
goto :eof

