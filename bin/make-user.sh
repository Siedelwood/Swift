#/bin/bash
cd ..
rm -rf var &>/dev/null
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
lua ldoc/ldoc.lua ../var/qsb.lua &>/dev/null
mv doc ../var/doc
rm ../qsb/config.ld

cd ..
echo "Done!"
