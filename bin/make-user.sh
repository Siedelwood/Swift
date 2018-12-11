#/bin/bash
cd ..
rm -rf var &>/dev/null
mkdir var &>/dev/null

echo "Building QSB ..."
lua qsb/lua/writer.lua $@ &>/dev/null
echo "Done!"

cd qsb/luaminifyer

echo "Minify QSB ..."
./LuaMinify.sh ../../var/qsb.lua &>/dev/null
echo "Done!"

cd ../../qsb

echo "Generating Documentation ..."
echo "Note: documenting only selected modules does not work yet! You get all!"
# lua ldoc/ldoc.lua -c userconfig.ld ../var/qsb.lua &>/dev/null
# mv doc ../var/doc
# rm userconfig.ld
lua ldoc/ldoc.lua lua -c userconfig.ld -d ../var/doc &>/dev/null
rm userconfig.ld

cd ..
echo "Done!"
