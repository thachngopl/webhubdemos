:: webhubdemos\Live\_Control

setlocal

:: call D:\projects\WebHubDemos\_ControlSVN\svn-update-webhubdemos.bat

cd /d %~dp0\..

start taskmgr
rem make sure WHDPrefix.exe is out of memory
pause

del webhub\apps\whdprefix.exe

cd /d %~dp0..\WebHub\Apps

d:\Apps\Utilities\7Zip\7z.exe x whdprefix-bin.7z 
if errorlevel 1 pause

start %~dp0..\WebHub\Apps\whdprefix.exe
if errorlevel 1 pause

