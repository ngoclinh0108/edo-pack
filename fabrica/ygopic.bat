@echo off
set ygofab_home="C:\Users\tripl\AppData\Local\YGOFabrica"
set back="%cd%"
cd "%ygofab_home%"
luajit -l modules.set-paths scripts/ygopic.lua %back% %*
cd %back%
@echo on
