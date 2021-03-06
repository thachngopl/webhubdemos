setlocal

set thisdate=2016-12-02

:: use ZaphodsMap to find credentials
call %ZaphodsMap%zmset.bat dbname UsingKey2Value "FirebirdSQL Credentials-CodeRageSchedule database"
call %ZaphodsMap%zmset.bat u UsingKey2Value "FirebirdSQL Credentials-CodeRageSchedule user"
call %ZaphodsMap%zmset.bat p UsingKey2Value "FirebirdSQL Credentials-CodeRageSchedule pass"

cls
echo RESTORE backup dated %thisdate% to the following
echo dbname %dbname%
echo user %u%
pause

cd /d %~dp0

D:\Apps\FirebirdSQL\2.5\bin\gbak -v -z -recreate_database overwrite -user %u% -password %p% backup\coderage_%thisdate%.fbk %dbname%

pause
