@echo off
setlocal
set "YGOFAB_ROOT=D:/Games/EDO-Pro/repositories/triplesix/_fabrica"
set "LUA_PATH=%YGOFAB_ROOT%/?.lua;%YGOFAB_ROOT%/?/init.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?.lua;%YGOFAB_ROOT%/modules/share/lua/5.1/?/init.lua"
set "LUA_CPATH=%YGOFAB_ROOT%/modules/lib/lua/5.1/?.dll"
set "PATH=%YGOFAB_ROOT%/luajit;%YGOFAB_ROOT%/vips/bin;%PATH%"
luajit "%YGOFAB_ROOT%/scripts/ygofab.lua" %*
endlocal
@echo on
