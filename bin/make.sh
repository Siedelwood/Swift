#/bin/bash
cd ..
rm -rf var &>/dev/null
mkdir var &>/dev/null

echo "Building QSB ..."

if [ $# -gt 0 ]; then
    for var in "$@"
    do
        echo "Including: $var"
    done
else
    echo "Vanilla mode!"
fi

lua qsb/lua/writer.lua $@ &>/dev/null
echo "Done!"

cd qsb/luaminifyer

echo "Minify QSB ..."
./LuaMinify.sh ../../var/qsb.lua &>/dev/null
echo "Done!"

cd ../../qsb

echo "Generating Documentation ..."
lua ldoc/ldoc.lua ../var/qsb.lua &>/dev/null
mv doc ../var/doc
rm config.ld

cd ..
echo "Done!"
