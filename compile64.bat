@echo off
setlocal

call "%~dp0scripts\build_sqlcipher_obj.bat" win64 %*
exit /b %errorlevel%
