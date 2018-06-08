#/bin/bash
cd ..
mkdir var &>/dev/null

echo "Building QSB ..."
lua qsb/lua/writer.lua &>/dev/null
echo "Done!"

cd qsb/luaminifyer

echo "Minify QSB ..."
./LuaMinify.sh ../../var/qsb.lua &>/dev/null
echo "Done!"

cd ../../qsb

echo "Generating Documentation ..."
lua ldoc/ldoc.lua --dir ../var/doc lua &>/dev/null
cd ..
echo "Done!"