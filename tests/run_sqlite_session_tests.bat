@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Compile and run the SQLite Session API fixture.
rem Usage: tests\run_sqlite_session_tests.bat [win32|win64|all] [cng|openssl] [dynamic|static] [--no-build]

set "PROJECT_ROOT=%~dp0.."
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"
set "RAD_STUDIO_DEFAULT=D:\Embarcadero RAD Studio\23.0"
set "RAD_STUDIO_FALLBACK=D:\Embarcadero RAD Studio\22.0"
if not defined RAD_STUDIO_ROOT (
  if exist "%RAD_STUDIO_DEFAULT%\bin\dcc32.exe" set "RAD_STUDIO_ROOT=%RAD_STUDIO_DEFAULT%"
  if not defined RAD_STUDIO_ROOT set "RAD_STUDIO_ROOT=%RAD_STUDIO_FALLBACK%"
)
set "ARCH=all"
set "ENGINE=cng"
set "CNG_LINK=dynamic"
set "BUILD_FIRST=1"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="win32" set "ARCH=win32"&shift&goto parse_args
if /I "%~1"=="win64" set "ARCH=win64"&shift&goto parse_args
if /I "%~1"=="all" set "ARCH=all"&shift&goto parse_args
if /I "%~1"=="cng" set "ENGINE=cng"&shift&goto parse_args
if /I "%~1"=="openssl" set "ENGINE=openssl"&shift&goto parse_args
if /I "%~1"=="dynamic" set "CNG_LINK=dynamic"&shift&goto parse_args
if /I "%~1"=="static" set "CNG_LINK=static"&shift&goto parse_args
if /I "%~1"=="--no-build" set "BUILD_FIRST=0"&shift&goto parse_args
echo Unknown argument: %~1
exit /b 2

:args_done
if /I "%ENGINE%"=="openssl" (
  set "PROFILE=openssl"
  set "DEFINE_FLAGS=-DUSER_DEFINES_INC;OPENSSL_3X;SQLITE_ENABLE_NORMALIZE"
  set "INCLUDE_PATH=%PROJECT_ROOT%\tests\defines\openssl3;%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%PROJECT_ROOT%\externals\libopenssl;%RAD_STUDIO_ROOT%\source\DUnit\src"
  set "UNIT_PATH=%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%PROJECT_ROOT%\externals\libopenssl;%RAD_STUDIO_ROOT%\source\DUnit\src"
) else (
  set "PROFILE=cng-%CNG_LINK%"
  set "DEFINE_FLAGS=-DUSER_DEFINES_INC;SQLITE_ENABLE_NORMALIZE"
  set "INCLUDE_PATH=%PROJECT_ROOT%\tests\defines\cng;%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%RAD_STUDIO_ROOT%\source\DUnit\src"
  set "UNIT_PATH=%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%RAD_STUDIO_ROOT%\source\DUnit\src"
)
if "%BUILD_FIRST%"=="1" (
  call "%PROJECT_ROOT%\scripts\build_sqlcipher_obj.bat" %ARCH% %ENGINE% %CNG_LINK%
  if errorlevel 1 exit /b 1
)
if /I "%ARCH%"=="all" (
  call :run_one win32
  if errorlevel 1 exit /b 1
  call :run_one win64
  if errorlevel 1 exit /b 1
) else (
  call :run_one %ARCH%
  if errorlevel 1 exit /b 1
)
exit /b 0

:run_one
set "PLATFORM=%~1"
if /I "%PLATFORM%"=="win32" (set "DCC=%RAD_STUDIO_ROOT%\bin\dcc32.exe") else (set "DCC=%RAD_STUDIO_ROOT%\bin\dcc64.exe")
set "BIN_DIR=%PROJECT_ROOT%\tests\bin\%PLATFORM%\%PROFILE%"
set "DCU_DIR=%PROJECT_ROOT%\tests\dcu\%PLATFORM%\%PROFILE%"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%DCU_DIR%" mkdir "%DCU_DIR%"
set "EXE=%BIN_DIR%\SqliteSessionTests.exe"
set "LOG=%TEMP%\SqliteSessionTests_%PLATFORM%_%PROFILE%.log"
if exist "%EXE%" del /q "%EXE%" >nul 2>&1
set "PLATFORM_FLAGS=%DEFINE_FLAGS%"
if /I "%ENGINE%"=="openssl" if /I "%PLATFORM%"=="win64" set "PLATFORM_FLAGS=%DEFINE_FLAGS%;C_COMPILER_BORLAND_64"
echo ========================================================================
echo  Compile SQLite Session tests: %PLATFORM% / %PROFILE%
echo ========================================================================
"%DCC%" -Q -B -NSSystem;System.Win;Winapi %PLATFORM_FLAGS% -I"%INCLUDE_PATH%" -U"%UNIT_PATH%" -E"%BIN_DIR%" -N0"%DCU_DIR%" "%PROJECT_ROOT%\tests\SqliteSessionTests.dpr" > "%LOG%" 2>&1
type "%LOG%"
if errorlevel 1 exit /b 1
findstr /R /C:" Error: " /C:" Fatal: " "%LOG%" >nul && exit /b 1
findstr /C:"W1028 Bad global symbol definition" "%LOG%" >nul && exit /b 1
echo ========================================================================
echo  Run SQLite Session tests: %PLATFORM% / %PROFILE%
echo ========================================================================
"%EXE%"
exit /b %ERRORLEVEL%
