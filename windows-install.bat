@echo off
echo Installing Sneednet.
echo Please don't close this window, it will close automatically.
echo Downloading bash environment (msys2)
echo:
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set execution_time=%mydate%_%mytime%
set new_filename=msys64_%execution_time%
move msys64 %new_filename% >NUL 2>&1
del /F /Q msys2-base-x86_64-20221216.sfx.exe
curl "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20221216.sfx.exe" -o "msys2-base-x86_64-20221216.sfx.exe"

msys2-base-x86_64-20221216.sfx.exe

echo Running msys2_shell
timeout 10 > Nul

:run
timeout 3 > Nul
call msys64\msys2_shell.cmd -c "mypath=`cygpath -u '%cd%'`; ""$mypath/windows-create-finished-msys2-install-indicator.sh"" ""$mypath""; sleep 10"

SET LookForFile=finished-msys2-install

:CheckForFile
IF EXIST %LookForFile% GOTO FoundIt

rem echo Checking for file %LookForFile%
TIMEOUT /t 5 > Nul

GOTO CheckForFile

:FoundIt
rem ECHO Found: %LookForFile%
timeout /t 10 > Nul
del %LookForFile%
msys64\msys2_shell.cmd -c "mypath=`cygpath -u '%cd%'`; ""$mypath/windows-install.sh"" ""$mypath"";"
