@echo off
lua qsb/lua/writer.lua
cd qsb
lua ldoc/ldoc.lua --dir ../doc lua