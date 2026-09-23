@echo off
chcp 65001 >nul

set "PROJDIR=%~dp0"
set "LOG=%PROJDIR%morning.log"
set "CLAUDE=C:\Users\Peter\.local\bin\claude.exe"
set "PROMPTFILE=%PROJDIR%prompt.txt"

rem determine AM/PM slot so a slot only needs one success per day (saves tokens)
for /f "tokens=1-2 delims=:" %%a in ("%time%") do set "HH=%%a"
set "HH=%HH: =0%"
set "SLOT=AM"
if %HH% GEQ 12 set "SLOT=PM"
set "TODAYKEY=%date:/=-%"
set "FLAG=%PROJDIR%.session_ping_%TODAYKEY%_%SLOT%.flag"

if exist "%FLAG%" goto :skip

set /p PROMPTTEXT=<"%PROMPTFILE%"

set "RETRIES=5"
set "DELAY_SEC=60"
set "ATTEMPT=0"

:retry
set /a ATTEMPT+=1
echo [%date% %time%] [%SLOT%] attempt %ATTEMPT% >> "%LOG%"
"%CLAUDE%" -p "%PROMPTTEXT%" >> "%LOG%" 2>&1
if %errorlevel% EQU 0 goto :success

if %ATTEMPT% GEQ %RETRIES% goto :giveup
echo [%date% %time%] [%SLOT%] attempt %ATTEMPT% failed, retrying in %DELAY_SEC%s >> "%LOG%"
ping -n %DELAY_SEC% 127.0.0.1 >nul
goto :retry

:success
echo. > "%FLAG%"
echo [%date% %time%] [%SLOT%] success >> "%LOG%"
echo. >> "%LOG%"
exit /b 0

:giveup
echo [%date% %time%] [%SLOT%] gave up after %RETRIES% attempts >> "%LOG%"
echo. >> "%LOG%"
exit /b 1

:skip
echo [%date% %time%] [%SLOT%] already succeeded today, skipping >> "%LOG%"
exit /b 0
