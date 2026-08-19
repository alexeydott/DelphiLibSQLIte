@echo off
setlocal EnableExtensions

set "PROJECT_ROOT=%~dp0.."
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"
set "RAD_STUDIO_DEFAULT=D:\Embarcadero RAD Studio\23.0"
set "RAD_STUDIO_FALLBACK=D:\Embarcadero RAD Studio\22.0"
set "PLATFORM=win32"
if /I "%~1"=="win64" set "PLATFORM=win64"
if not defined RAD_STUDIO_ROOT (
  if exist "%RAD_STUDIO_DEFAULT%\bin\dcc32.exe" set "RAD_STUDIO_ROOT=%RAD_STUDIO_DEFAULT%"
  if not defined RAD_STUDIO_ROOT set "RAD_STUDIO_ROOT=%RAD_STUDIO_FALLBACK%"
)

if /I "%PLATFORM%"=="win64" (
  set "DCC=%RAD_STUDIO_ROOT%\bin\dcc64.exe"
) else (
  set "DCC=%RAD_STUDIO_ROOT%\bin\dcc32.exe"
)
set "BIN_DIR=%PROJECT_ROOT%\examples\bin\%PLATFORM%"
set "DCU_DIR=%PROJECT_ROOT%\examples\dcu\%PLATFORM%"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%DCU_DIR%" mkdir "%DCU_DIR%"

call "%RAD_STUDIO_ROOT%\bin\rsvars.bat"
set "LIB_DIR=%RAD_STUDIO_ROOT%\lib\win32\release"
if /I "%~1"=="win64" set "LIB_DIR=%RAD_STUDIO_ROOT%\lib\win64\release"
"%DCC%" -Q -B -DUSER_DEFINES_INC;FireDAC_SQLITE_STATIC;SQLITE_ENABLE_NORMALIZE -I"%PROJECT_ROOT%\tests\defines\cng;%PROJECT_ROOT%;%PROJECT_ROOT%\externals\libopenssl;%RAD_STUDIO_ROOT%\source\data\firedac" -U"%PROJECT_ROOT%\tests\defines\cng;%PROJECT_ROOT%;%PROJECT_ROOT%\externals\libopenssl;%RAD_STUDIO_ROOT%\source\data\firedac;%LIB_DIR%" -E"%BIN_DIR%" -N0"%DCU_DIR%" "%PROJECT_ROOT%\examples\FireDACSQLiteSessionDemo.dpr"
if errorlevel 1 exit /b 1
"%BIN_DIR%\FireDACSQLiteSessionDemo.exe"
exit /b %ERRORLEVEL%
