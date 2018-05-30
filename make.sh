#/bin/bash
lua qsb/lua/writer.lua
cd qsb/luaminifyer
./LuaMinify.sh ../../qsb.lua
cd ../../qsb
lua ldoc/ldoc.lua --dir ../doc lua
cd ..