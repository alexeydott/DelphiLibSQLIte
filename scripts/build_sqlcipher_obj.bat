@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Builds suffixed SQLCipher objects for sqlite3.static.pas:
rem   sqlite3_win32_cng.obj / sqlite3_win64_cng.obj
rem   sqlite3_win32_ossl.obj / sqlite3_win64_ossl.obj
rem Defaults: all platforms, SQLCIPHER_CRYPTO_CNG, dynamic bcrypt.dll loading.
rem Usage:
rem   scripts\build_sqlcipher_obj.bat [win32|win64|all] [cng|openssl] [dynamic|static] [--rebuild-amalgamation]
rem   scripts\build_sqlcipher_obj.bat win64 openssl

set "PROJECT_ROOT=%~dp0.."
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"

set "RAD_STUDIO_DEFAULT=D:\Embarcadero RAD Studio\23.0"
set "RAD_STUDIO_FALLBACK=D:\Embarcadero RAD Studio\22.0"
if not defined RAD_STUDIO_ROOT (
  if exist "%RAD_STUDIO_DEFAULT%\bin\bcc32.exe" if exist "%RAD_STUDIO_DEFAULT%\bin\bcc64.exe" (
    set "RAD_STUDIO_ROOT=%RAD_STUDIO_DEFAULT%"
  ) else (
    set "RAD_STUDIO_ROOT=%RAD_STUDIO_FALLBACK%"
  )
)
set "RAD_STUDIO=%RAD_STUDIO_ROOT%"
set "SQLCIPHER_ROOT=%PROJECT_ROOT%\externals\sqlcipher"
set "OPENSSL_ROOT=%PROJECT_ROOT%\externals\libopenssl"
set "OPENSSL_SRC=%OPENSSL_ROOT%\c_src\openssl-openssl-3.6.1"
set "OPENSSL_ZIP=%OPENSSL_ROOT%\c_src\openssl-3.6.1.zip"
set "SQLITE_LINK_SOURCE=%PROJECT_ROOT%\scripts\sqlite3_link.c"

set "ARCH=all"
set "ENGINE=cng"
set "CNG_LINK=dynamic"
set "REBUILD_AMALGAMATION=0"

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
if /I "%~1"=="--rebuild-amalgamation" set "REBUILD_AMALGAMATION=1" & shift & goto parse_args
if /I "%~1"=="--rad-studio" (
  shift
  if "%~1"=="" goto usage
  set "RAD_STUDIO=%~1"
  shift
  goto parse_args
)
echo Unknown argument: %~1
goto usage

:args_done
for %%I in ("%RAD_STUDIO%") do set "RAD_STUDIO_VERSION=%%~nxI"
if not defined RAD_STUDIO_PUBLIC_HPP set "RAD_STUDIO_PUBLIC_HPP=C:\Users\Public\Documents\Embarcadero\Studio\%RAD_STUDIO_VERSION%\hpp\Win32"

if not exist "%SQLCIPHER_ROOT%\.git" (
  echo ERROR: SQLCipher submodule is missing: "%SQLCIPHER_ROOT%"
  echo Run: git submodule update --init --recursive
  exit /b 1
)
if /I "%ENGINE%"=="openssl" if not exist "%OPENSSL_ROOT%\.git" (
  echo ERROR: DelphiLibOpenSSL submodule is missing: "%OPENSSL_ROOT%"
  echo Run: git submodule update --init --recursive
  exit /b 1
)

if /I "%ENGINE%"=="openssl" (
  set "PROFILE=openssl"
  set "OBJ_SUFFIX=ossl"
  set "PROVIDER_DEFINES=-DSQLCIPHER_CRYPTO_OPENSSL"
  set "PROVIDER_DESCRIPTION=OpenSSL 3.6.1 via DelphiLibOpenSSL"
  call :ensure_openssl_headers
  if errorlevel 1 exit /b !errorlevel!
) else (
  set "PROFILE=cng-%CNG_LINK%"
  set "OBJ_SUFFIX=cng"
  set "PROVIDER_DESCRIPTION=CNG %CNG_LINK%"
  if /I "%CNG_LINK%"=="dynamic" (
    set "PROVIDER_DEFINES=-DSQLCIPHER_CRYPTO_CNG -DSQLCIPHER_CRYPTO_CNG_DYNAMIC"
  ) else (
    set "PROVIDER_DEFINES=-DSQLCIPHER_CRYPTO_CNG"
  )
)

set "SQLITE_CORE_DEFINES=-DNDEBUG -DUSEPACKAGES -D__STDC__=1 -D__MT__=1 -DSQLITE_OMIT_AUTOINIT=1 -DSQLITE_ENABLE_API_ARMOR=1 -DSQLITE_THREADSAFE=1 -DSQLITE_THREAD_OVERRIDE_LOCK=-1 -DSQLITE_HAS_CODEC=1 -DSQLITE_TEMP_STORE=2 -DSQLITE_MAX_TRIGGER_DEPTH=100"
set "SQLITE_FEATURE_DEFINES=-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_GEOPOLY=1 -DSQLITE_ENABLE_JSON1=1 -DSQLITE_ENABLE_STMTVTAB=1 -DSQLITE_ENABLE_DBPAGE_VTAB=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_INTROSPECTION_PRAGMAS=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_ENABLE_SESSION=1 -DSQLITE_ENABLE_PREUPDATE_HOOK=1 -DSQLITE_ENABLE_NORMALIZE=1"
set "SQLITE_STATIC_EXT_DEFINES=-DSQLITE_MEMVFS_STATIC=1 -DSQLITE_SQLAR_STATIC=1 -DSQLITE_UNIONVTAB_STATIC=1 -DSQLITE_CSV_STATIC=1 -DSQLITE_VSV_STATIC=1 -DSQLITE_ZIPFILE_STATIC=1 -DSQLITE_FILEIO_STATIC=1 -DSQLITE_COMPRESS_STATIC=1 -DSQLITE_CLOSURE_STATIC=1 -DSQLITE_ENABLE_CARRAY=1 -DSQLITE_CARRAY_STATIC=1 -DSQLITE_EVAL_STATIC=1 -DSQLITE_DB_DUMP_STATIC=1 -DSQLITE_ZORDER_STATIC=1 -DSQLITE_ENABLE_UNICODE=1 -DSQLITE_ENABLE_UNICODE_STATIC=1 -DSQLITE_UUID_STATIC=1 -DSQLITE_OMIT_FILE_IO_EXTENTION=1 -DSQLITE_SOUNDEX=1 -DSQLITE_BASE64_STATIC=1 -DSQLITE_BASE85_STATIC=1"
set "SQLCIPHER_RUNTIME_DEFINES=-DSQLCIPHER_OMIT_LOG=1 -DSQLCIPHER_OMIT_LOG_DEVICE=1 -DSQLCIPHER_OMIT_DEFAULT_LOGGING=1 -DSQLCIPHER_OMIT_DLLMAIN=1"
set "SQLCIPHER_DEFINES=%PROVIDER_DEFINES% %SQLCIPHER_RUNTIME_DEFINES% -DSQLITE_EXTRA_INIT=sqlcipher_extra_init -DSQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown"
set "COMMON_DEFINES=%SQLITE_CORE_DEFINES% %SQLITE_FEATURE_DEFINES% %SQLITE_STATIC_EXT_DEFINES% %SQLCIPHER_DEFINES%"

echo.
echo =========================================================================
echo  DelphiLibSQLite SQLCipher OBJ build
echo    RAD Studio : %RAD_STUDIO%
echo    Engine     : %PROVIDER_DESCRIPTION%
echo    Profile    : %PROFILE%
echo =========================================================================
echo.

if /I "%ARCH%"=="all" (
  call :build_win32
  if errorlevel 1 exit /b !errorlevel!
  call :build_win64
  if errorlevel 1 exit /b !errorlevel!
) else if /I "%ARCH%"=="win32" (
  call :build_win32
  if errorlevel 1 exit /b !errorlevel!
) else if /I "%ARCH%"=="win64" (
  call :build_win64
  if errorlevel 1 exit /b !errorlevel!
) else (
  goto usage
)

echo.
echo DONE: copied current %OBJ_SUFFIX% link objects to "%PROJECT_ROOT%\sqlite3_win32_%OBJ_SUFFIX%.obj" / "sqlite3_win64_%OBJ_SUFFIX%.obj" as applicable.
exit /b 0

:build_win32
set "AMALG_ARCH=x86"
set "PLATFORM=win32"
set "BCC=%RAD_STUDIO%\bin\bcc32.exe"
if not exist "%BCC%" (
  echo ERROR: bcc32.exe not found: "%BCC%"
  exit /b 1
)
call :ensure_amalgamation "%AMALG_ARCH%"
if errorlevel 1 exit /b !errorlevel!

set "AMALG_DIR=%SQLCIPHER_ROOT%\build\%AMALG_ARCH%\amalgamation"
set "SQLITE3_C=%AMALG_DIR%\sqlite3.c"
set "OUT_DIR=%PROJECT_ROOT%\obj\sqlcipher\%PROFILE%\%PLATFORM%"
set "OUT_OBJ=%OUT_DIR%\sqlite3_%PLATFORM%_%OBJ_SUFFIX%.obj"
set "FINAL_OBJ=%PROJECT_ROOT%\sqlite3_%PLATFORM%_%OBJ_SUFFIX%.obj"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
del /Q "%OUT_DIR%\*.obj" "%OUT_DIR%\*.tds" "%OUT_DIR%\*.pch" 2>NUL

set "SYSINCLUDE=-I"%RAD_STUDIO%\include" -I"%RAD_STUDIO%\include\dinkumware" -I"%RAD_STUDIO%\include\windows\crtl" -I"%RAD_STUDIO%\include\windows\sdk" -I"%RAD_STUDIO%\include\windows\rtl" -I"%RAD_STUDIO%\include\windows\vcl" -I"%RAD_STUDIO%\include\windows\fmx" -I"%RAD_STUDIO_PUBLIC_HPP%""
set "CINCLUDE=-I"%ZLIB_INCLUDE%" -I"%AMALG_DIR%" -I"%SQLCIPHER_ROOT%\src" %SYSINCLUDE%"
if /I "%ENGINE%"=="openssl" set "CINCLUDE=-I"%OPENSSL_SRC%\include" %CINCLUDE%"

echo Building %PLATFORM% object from "%SQLITE_LINK_SOURCE%"...
"%BCC%" %COMMON_DEFINES% -n"%OUT_DIR%" %CINCLUDE% -c -tW -C8 -o"%OUT_OBJ%" -w-par -w-pia -w-rvl -O2 -v- -vi -H="%OUT_DIR%\sqlcipher.pch" -H "%SQLITE_LINK_SOURCE%"
if errorlevel 1 exit /b !errorlevel!

copy /Y "%OUT_OBJ%" "%FINAL_OBJ%" >NUL
if errorlevel 1 exit /b !errorlevel!
echo OK: %FINAL_OBJ%
exit /b 0

:build_win64
set "AMALG_ARCH=x64"
set "PLATFORM=win64"
set "BCC=%RAD_STUDIO%\bin\bcc64.exe"
if not exist "%BCC%" (
  echo ERROR: bcc64.exe not found: "%BCC%"
  exit /b 1
)
call :ensure_amalgamation "%AMALG_ARCH%"
if errorlevel 1 exit /b !errorlevel!

set "AMALG_DIR=%SQLCIPHER_ROOT%\build\%AMALG_ARCH%\amalgamation"
set "SQLITE3_C=%AMALG_DIR%\sqlite3.c"
set "OUT_DIR=%PROJECT_ROOT%\obj\sqlcipher\%PROFILE%\%PLATFORM%"
set "OUT_OBJ=%OUT_DIR%\sqlite3_%PLATFORM%_%OBJ_SUFFIX%.obj"
set "FINAL_OBJ=%PROJECT_ROOT%\sqlite3_%PLATFORM%_%OBJ_SUFFIX%.obj"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
del /Q "%OUT_DIR%\*.obj" "%OUT_DIR%\*.o" "%OUT_DIR%\*.d" 2>NUL

set "SYSINCLUDE=-isystem "%RAD_STUDIO%\include" -isystem "%RAD_STUDIO%\include\dinkumware64" -isystem "%RAD_STUDIO%\include\windows\crtl" -isystem "%RAD_STUDIO%\include\windows\sdk" -isystem "%RAD_STUDIO%\include\windows\rtl" -isystem "%RAD_STUDIO%\include\windows\vcl" -isystem "%RAD_STUDIO%\include\windows\fmx""
set "CINCLUDE=-I"%ZLIB_INCLUDE%" -I"%AMALG_DIR%" -I"%SQLCIPHER_ROOT%\src""
if /I "%ENGINE%"=="openssl" set "CINCLUDE=-I"%OPENSSL_SRC%\include" %CINCLUDE%"

echo Building %PLATFORM% object from "%SQLITE_LINK_SOURCE%"...
"%BCC%" -cc1 %COMMON_DEFINES% -output-dir "%OUT_DIR%" %CINCLUDE% %SYSINCLUDE% -dwarf-version=4 -fborland-extensions -nobuiltininc -nostdsysteminc -triple x86_64-pc-win32-elf -emit-obj -fexceptions -fcxx-exceptions -fseh -munwind-tables -fno-common -fno-spell-checking -fno-use-cxa-atexit -x c -std=c99 -O2 -fmath-errno -tR -o"%OUT_OBJ%" -dependency-file "%OUT_DIR%\sqlite3_%PLATFORM%_%OBJ_SUFFIX%.d" -MT "%OUT_OBJ%" -sys-header-deps "%SQLITE_LINK_SOURCE%"
if errorlevel 1 exit /b !errorlevel!

copy /Y "%OUT_OBJ%" "%FINAL_OBJ%" >NUL
if errorlevel 1 exit /b !errorlevel!
echo OK: %FINAL_OBJ%
exit /b 0

:ensure_amalgamation
set "AMALG_ARCH=%~1"
set "AMALG_DIR=%SQLCIPHER_ROOT%\build\%AMALG_ARCH%\amalgamation"
if "%REBUILD_AMALGAMATION%"=="1" (
  echo Regenerating SQLCipher amalgamation for %AMALG_ARCH%...
  pushd "%SQLCIPHER_ROOT%"
  call "%SQLCIPHER_ROOT%\build_amalgamation.bat" %AMALG_ARCH%
  set "AMALG_RC=%errorlevel%"
  popd
  if not "%AMALG_RC%"=="0" exit /b %AMALG_RC%
)
if not exist "%AMALG_DIR%\sqlite3.c" (
  echo ERROR: "%AMALG_DIR%\sqlite3.c" not found.
  echo Generate it with: externals\sqlcipher\build_amalgamation.bat %AMALG_ARCH%
  echo or rerun this script with --rebuild-amalgamation.
  exit /b 1
)
set "ZLIB_INCLUDE=%SQLCIPHER_ROOT%\build\%AMALG_ARCH%\static-lib"
if not exist "%ZLIB_INCLUDE%\zlib.h" (
  echo ERROR: "%ZLIB_INCLUDE%\zlib.h" not found.
  echo Expected the prepared zlib headers from the SQLCipher build artifacts.
  exit /b 1
)
exit /b 0

:ensure_openssl_headers
if not exist "%OPENSSL_SRC%\include\openssl\evp.h" goto openssl_generated_missing
if not exist "%OPENSSL_SRC%\include\openssl\crypto.h" goto openssl_generated_missing
if not exist "%OPENSSL_SRC%\include\openssl\configuration.h" goto openssl_generated_missing
if not exist "%OPENSSL_SRC%\include\openssl\opensslv.h" goto openssl_generated_missing
exit /b 0

:openssl_generated_missing
echo ERROR: OpenSSL 3.6.1 generated headers are missing under:
echo   %OPENSSL_SRC%\include\openssl
echo.
echo The raw OpenSSL zip contains template headers and is not enough for this profile.
echo Run the DelphiLibOpenSSL OpenSSL 3.x preparation/build step first, for example:
echo   pushd "%OPENSSL_ROOT%"
echo   set OPENSSL_BRANCH=3
echo   build_openssl3_cbuilder_classic_win32.bat
echo   build_openssl3_cbuilder_win64.bat
echo   popd
exit /b 1

:usage
echo.
echo Usage:
echo   %~nx0 [win32^|win64^|all] [cng^|openssl] [dynamic^|static] [--rebuild-amalgamation] [--rad-studio PATH]
echo.
echo Defaults: all cng dynamic
echo Examples:
echo   %~nx0
echo   %~nx0 win32 cng dynamic
echo   %~nx0 win64 openssl
exit /b 2
