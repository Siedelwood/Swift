@echo off
cd ..
mkdir var
lua qsb/lua/writer.lua > nul 2>&1
cd qsb/luaminifyer
LuaMinify.bat ../../var/qsb.lua > nul 2>&1
cd ../../qsb
lua ldoc/ldoc.lua --dir ../var/doc lua > nul 2>&1
cd ..
