:: use the ncftp utility to post the files to the server using ftp
:: ncftp is freely available yet its author would appreciate a donation

:: use zmset.bat to pull credentials from a local config file
:: zmset and ZMLookup are freely available from HREF Tools
:: Pascal source is included with ZaphodsMap 
:: www.zaphodsmap.com

setlocal

:: switch to the location of this BAT file
cd %~dp0
:: switch to the location of the 7z files
cd ..\..\Live\WebHub\Apps

set h=db.demos.href.com
call %ZaphodsMap%zmset.bat u UsingKey2Value "HREFTools\FileTransfer FTP webhubdemos-database-user"
call %ZaphodsMap%zmset.bat p UsingKey2Value "HREFTools\FileTransfer FTP webhubdemos-database-pass"

D:\Apps\Utilities\NcFTP\ncftpput.exe -u %u% -p %p% %h% /Live/WebHub/Apps Database-bin.7z
if errorlevel 1 pause
D:\Apps\Utilities\NcFTP\ncftpput.exe -u %u% -p %p% %h% /Library32 Database-Library32-bin.7z
if errorlevel 1 pause

:: 64bit for the DEMOS demo
D:\Apps\Utilities\NcFTP\ncftpput.exe -u %u% -p %p% %h% /Library64 Database-Library64-bin.7z
if errorlevel 1 pause

endlocal