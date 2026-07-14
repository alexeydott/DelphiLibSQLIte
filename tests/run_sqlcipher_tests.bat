@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Builds the selected SQLCipher OBJ profile, compiles Sqlite3StaticTests.dpr,
rem and runs the resulting executable.
rem Usage:
rem   tests\run_sqlcipher_tests.bat [win32|win64|all] [cng|openssl] [dynamic|static] [--no-build]

set "PROJECT_ROOT=%~dp0.."
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"

if not defined RAD_STUDIO_ROOT set "RAD_STUDIO_ROOT=D:\Embarcadero RAD Studio\22.0"
set "RAD_STUDIO=%RAD_STUDIO_ROOT%"
set "DUNIT_PATH=%RAD_STUDIO%\source\DUnit\src"
set "ARCH=all"
set "ENGINE=cng"
set "CNG_LINK=dynamic"
set "BUILD_FIRST=1"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="win32"  set "ARCH=win32"  & shift & goto parse_args
if /I "%~1"=="x86"    set "ARCH=win32"  & shift & goto parse_args
if /I "%~1"=="win64"  set "ARCH=win64"  & shift & goto parse_args
if /I "%~1"=="x64"    set "ARCH=win64"  & shift & goto parse_args
if /I "%~1"=="all"    set "ARCH=all"    & shift & goto parse_args
if /I "%~1"=="cng"    set "ENGINE=cng"  & shift & goto parse_args
if /I "%~1"=="openssl" set "ENGINE=openssl" & shift & goto parse_args
if /I "%~1"=="dynamic" set "CNG_LINK=dynamic" & shift & goto parse_args
if /I "%~1"=="static"  set "CNG_LINK=static"  & shift & goto parse_args
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
set "DCU_DIR=%PROJECT_ROOT%\tests\dcu\%PLATFORM%\%PROFILE%"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%DCU_DIR%" mkdir "%DCU_DIR%"
set "PLATFORM_DEFINE_FLAGS=%DEFINE_FLAGS%"
if /I "%ENGINE%"=="openssl" if /I "%PLATFORM%"=="win64" set "PLATFORM_DEFINE_FLAGS=%DEFINE_FLAGS%;C_COMPILER_BORLAND_64"
set "TEST_EXE=%BIN_DIR%\Sqlite3StaticTests.exe"
set "DCC_LOG=%TEMP%\Sqlite3StaticTests_%PLATFORM%_%PROFILE%.dcc.log"
if exist "%TEST_EXE%" del /q "%TEST_EXE%" >nul 2>&1

echo.
echo =========================================================================
echo  Compile tests: %PLATFORM% / %PROFILE%
echo =========================================================================
"%DCC%" -Q -B -NSSystem;System.Win;Winapi %PLATFORM_DEFINE_FLAGS% -I"%INCLUDE_PATH%" -U"%UNIT_PATH%" -E"%BIN_DIR%" -N0"%DCU_DIR%" "%PROJECT_ROOT%\tests\Sqlite3StaticTests.dpr" > "%DCC_LOG%" 2>&1
set "DCC_FAILED=0"
if errorlevel 1 set "DCC_FAILED=1"
type "%DCC_LOG%"
if "%DCC_FAILED%"=="1" (
  echo ERROR: Delphi compiler failed for %PLATFORM% / %PROFILE%.
  exit /b 1
)
findstr /R /C:" Error: " /C:" Fatal: " "%DCC_LOG%" >nul
if not errorlevel 1 (
  echo ERROR: Delphi compiler reported errors for %PLATFORM% / %PROFILE%.
  exit /b 1
)
findstr /C:" W1028 " /C:"W1028 Bad global symbol definition" "%DCC_LOG%" >nul
if not errorlevel 1 (
  echo ERROR: Delphi linker reported W1028 bad global symbol definitions for %PLATFORM% / %PROFILE%.
  exit /b 1
)
if not exist "%TEST_EXE%" (
  echo ERROR: Delphi compiler did not produce "%TEST_EXE%".
  exit /b 1
)

echo.
echo =========================================================================
echo  Run tests: %PLATFORM% / %PROFILE%
echo =========================================================================
"%TEST_EXE%"
set "TEST_EXIT=%ERRORLEVEL%"
if not "%TEST_EXIT%"=="0" exit /b %TEST_EXIT%
exit /b 0

:usage
echo.
echo Usage:
echo   %~nx0 [win32^|win64^|all] [cng^|openssl] [dynamic^|static] [--no-build]
echo.
echo Defaults: all cng dynamic
exit /b 2
