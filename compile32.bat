@echo off
setlocal

call "%~dp0scripts\build_sqlcipher_obj.bat" win32 %*
exit /b %errorlevel%
