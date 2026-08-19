@echo off
setlocal
set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
set "RAD_STUDIO_ROOT=D:\Embarcadero RAD Studio\23.0"
set "BIN=%ROOT%\examples\bin"
set "DCU=%ROOT%\examples\dcu"
if not exist "%BIN%" mkdir "%BIN%"
if not exist "%DCU%" mkdir "%DCU%"
call "%RAD_STUDIO_ROOT%\bin\rsvars.bat"
"%RAD_STUDIO_ROOT%\bin\dcc32.exe" -Q -B -NSSystem;System.Win;Winapi -DUSER_DEFINES_INC;SQLITE_ENABLE_NORMALIZE -I"%ROOT%\tests\defines\cng;%ROOT%\tests;%ROOT%;%ROOT%\externals\libopenssl" -U"%ROOT%;%ROOT%\externals\libopenssl" -E"%BIN%" -N0"%DCU%" "%ROOT%\examples\SqliteSessionDemo.dpr"
if errorlevel 1 exit /b 1
"%BIN%\SqliteSessionDemo.exe"
exit /b %ERRORLEVEL%
