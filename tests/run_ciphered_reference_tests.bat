@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Builds and runs the separate reference-database ciphering application.
rem Usage:
rem   tests\run_ciphered_reference_tests.bat [win32|win64|all] [cng|openssl] [dynamic|static] [--no-build]

set "PROJECT_ROOT=%~dp0.."
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"

set "RAD_STUDIO_DEFAULT=D:\Embarcadero RAD Studio\23.0"
set "RAD_STUDIO_FALLBACK=D:\Embarcadero RAD Studio\22.0"
if not defined RAD_STUDIO_ROOT (
  if exist "%RAD_STUDIO_DEFAULT%\bin\dcc32.exe" if exist "%RAD_STUDIO_DEFAULT%\source\DUnit\src" (
    set "RAD_STUDIO_ROOT=%RAD_STUDIO_DEFAULT%"
  ) else (
    set "RAD_STUDIO_ROOT=%RAD_STUDIO_FALLBACK%"
  )
)
set "RAD_STUDIO=%RAD_STUDIO_ROOT%"
set "DUNIT_PATH=%RAD_STUDIO%\source\DUnit\src"
set "ARCH=all"
set "ENGINE=cng"
set "CNG_LINK=dynamic"
set "BUILD_FIRST=1"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="win32" set "ARCH=win32" & shift & goto parse_args
if /I "%~1"=="x86" set "ARCH=win32" & shift & goto parse_args
if /I "%~1"=="win64" set "ARCH=win64" & shift & goto parse_args
if /I "%~1"=="x64" set "ARCH=win64" & shift & goto parse_args
if /I "%~1"=="all" set "ARCH=all" & shift & goto parse_args
if /I "%~1"=="cng" set "ENGINE=cng" & shift & goto parse_args
if /I "%~1"=="openssl" set "ENGINE=openssl" & shift & goto parse_args
if /I "%~1"=="dynamic" set "CNG_LINK=dynamic" & shift & goto parse_args
if /I "%~1"=="static" set "CNG_LINK=static" & shift & goto parse_args
if /I "%~1"=="--no-build" set "BUILD_FIRST=0" & shift & goto parse_args
echo Unknown argument: %~1
goto usage

:args_done
if /I "%ENGINE%"=="openssl" (
  set "PROFILE=openssl"
  set "DEFINE_FLAGS=-DUSER_DEFINES_INC;OPENSSL_3X;SQLITE_ENABLE_NORMALIZE"
  set "INCLUDE_PATH=%PROJECT_ROOT%\tests\defines\openssl3;%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%PROJECT_ROOT%\externals\libopenssl;%DUNIT_PATH%"
  set "UNIT_PATH=%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%PROJECT_ROOT%\externals\libopenssl;%DUNIT_PATH%"
) else (
  set "PROFILE=cng-%CNG_LINK%"
  set "DEFINE_FLAGS=-DUSER_DEFINES_INC;SQLITE_ENABLE_NORMALIZE"
  set "INCLUDE_PATH=%PROJECT_ROOT%\tests\defines\cng;%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%DUNIT_PATH%"
  set "UNIT_PATH=%PROJECT_ROOT%\tests;%PROJECT_ROOT%;%DUNIT_PATH%"
)

if "%BUILD_FIRST%"=="1" (
  call "%PROJECT_ROOT%\scripts\build_sqlcipher_obj.bat" %ARCH% %ENGINE% %CNG_LINK%
  if errorlevel 1 exit /b 1
)

if /I "%ARCH%"=="all" (
  call :compile_and_run win32
  if errorlevel 1 exit /b 1
  call :compile_and_run win64
  if errorlevel 1 exit /b 1
) else if /I "%ARCH%"=="win32" (
  call :compile_and_run win32
  if errorlevel 1 exit /b 1
) else if /I "%ARCH%"=="win64" (
  call :compile_and_run win64
  if errorlevel 1 exit /b 1
) else (
  goto usage
)
exit /b 0

:compile_and_run
set "PLATFORM=%~1"
if /I "%PLATFORM%"=="win32" (
  set "DCC=%RAD_STUDIO%\bin\dcc32.exe"
) else (
  set "DCC=%RAD_STUDIO%\bin\dcc64.exe"
)
if not exist "%DCC%" (
  echo ERROR: Delphi compiler not found: "%DCC%"
  exit /b 1
)

set "BIN_DIR=%PROJECT_ROOT%\tests\bin\%PLATFORM%\%PROFILE%"
set "DCU_DIR=%PROJECT_ROOT%\tests\dcu\%PLATFORM%\%PROFILE%-reference"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%DCU_DIR%" mkdir "%DCU_DIR%"
set "PLATFORM_DEFINE_FLAGS=%DEFINE_FLAGS%"
set "TEST_EXE=%BIN_DIR%\Sqlite3CipheredReferenceTests.exe"
set "DCC_LOG=%TEMP%\Sqlite3CipheredReferenceTests_%PLATFORM%_%PROFILE%.dcc.log"
if exist "%TEST_EXE%" del /q "%TEST_EXE%" >nul 2>&1

echo.
echo =========================================================================
echo  Compile reference cipher tests: %PLATFORM% / %PROFILE%
echo =========================================================================
"%DCC%" -Q -B -NSSystem;System.Win;Winapi %PLATFORM_DEFINE_FLAGS% -I"%INCLUDE_PATH%" -U"%UNIT_PATH%" -E"%BIN_DIR%" -N0"%DCU_DIR%" "%PROJECT_ROOT%\tests\Sqlite3CipheredReferenceTests.dpr" > "%DCC_LOG%" 2>&1
set "DCC_FAILED=0"
if errorlevel 1 set "DCC_FAILED=1"
type "%DCC_LOG%"
if "%DCC_FAILED%"=="1" exit /b 1
findstr /R /C:" Error: " /C:" Fatal: " "%DCC_LOG%" >nul
if not errorlevel 1 exit /b 1
findstr /C:" W1028 " /C:"W1028 Bad global symbol definition" "%DCC_LOG%" >nul
if not errorlevel 1 (
  echo ERROR: Delphi linker reported W1028 bad global symbol definitions.
  exit /b 1
)
if not exist "%TEST_EXE%" (
  echo ERROR: Delphi compiler did not produce "%TEST_EXE%".
  exit /b 1
)

echo.
echo =========================================================================
echo  Run reference cipher tests: %PLATFORM% / %PROFILE%
echo =========================================================================
"%TEST_EXE%"
set "TEST_EXIT=%ERRORLEVEL%"
if not "%TEST_EXIT%"=="0" exit /b %TEST_EXIT%
exit /b 0

:usage
echo.
echo Usage:
echo   %~nx0 [win32^|win64^|all] [cng^|openssl] [dynamic^|static] [--no-build]
exit /b 2
