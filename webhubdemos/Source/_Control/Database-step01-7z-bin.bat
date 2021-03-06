:: use 7z utility to compress executable files
:: 7z is free with open source

setlocal

set bits=32

cd %~dp0
cd ..\..\Live\WebHub\Apps

del Database-bin.7z
del Database-Library??-bin.7z

:: off Apr 2017 del DriveH-source.7z
:: off Apr 2017 set t=DriveH-source.7z
:: off Apr 2017 d:\Apps\Utilities\7Zip\7z.exe a %t% h:\*.pas h:\*.dfm
:: off Apr 2017 if errorlevel 1 pause

set t=Database-dpr.7z
d:\Apps\Utilities\7Zip\7z.exe a %t% whDPrefix.exe
if errorlevel 1 pause

set t=Database-bin.7z

d:\Apps\Utilities\7Zip\7z.exe a %t% whLite.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whClone.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whQuery*.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whInstantForm.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whLoadFromDB.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whRubicon.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whSchedule.exe
if errorlevel 1 pause
d:\Apps\Utilities\7Zip\7z.exe a %t% whShopping.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whText2Table.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whDynamicJPEG.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whFirebird.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whFishStore.exe
d:\Apps\Utilities\7Zip\7z.exe a %t% whScanTable.exe
if errorlevel 1 pause

:: DynHelp for webhub.com, running on same server as db.demos.href.com
:: April 2017
if EXIST "D:\HREF\semele\drived\projects\dynhelp\Live\WebHub\WHApps\DynHelp.exe" d:\Apps\Utilities\7Zip\7z.exe a %t% "D:\HREF\semele\drived\projects\dynhelp\Live\WebHub\WHApps\DynHelp.exe"
if errorlevel 1 pause

set bits=32
call %~dp0\set-compilerdigits.bat
set t=Database-Library%bits%-bin.7z

:: D25 compiler has bde support, win32
set sdir=h:\pkg_d%compilerdigits%_win%bits%

d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\ldiRegExLib_d??_win32.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\WebHub_d??_win32.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\WebHubDB_d??_win32.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\WebHubBDE_d??_win32.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\ZaphodsMapLib_d??_win32.bpl

:: latest win64 is good for the rest of the non-BDE projects
set bits=64
call %~dp0set_compilerdigits.bat
set sdir=h:\pkg_d%compilerdigits%_win%bits%
set t=Database-Library%bits%-bin.7z

d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\ldiRegExLib_d%compilerdigits%_win??.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\WebHub_d%compilerdigits%_win??.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\WebHubDB_d??_win??.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\WebHubBDE_d??_win32.bpl
d:\Apps\Utilities\7Zip\7z.exe a %t% %sdir%\ZaphodsMapLib_d%compilerdigits%_win??.bpl

pause

