setlocal

:: set zmcontext variable
call %ZaphodsMap%zmset.bat zmcontext AsDefaultContext
set compilerdigits=24

::change to folder containing this bat file
cd /D %~dp0

::start the WebHub advertising demo
if     "%zmcontext%"=="NYX"		goto %zmcontext%
if     "%zmcontext%"=="ultraann"	goto %zmcontext%
goto others

:NYX
start DServer_x_d%compilerdigits%_win64.exe /ID=adv
goto end

:ultraann
start whlite_x_d%compilerdigits%_win64_src.exe /ID=adv
goto end

:others
start whLite /ID=adv

:end
