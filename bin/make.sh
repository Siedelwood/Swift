#/bin/bash
cd ..
rm -rf var &>/dev/null
mkdir var &>/dev/null

echo "Building QSB ..."

if [ $# -gt 0 ]; then
    for var in "$@"
    do
        if [[ $var == -* ]]; then
            echo "Param: $var"
        else
            echo "Including: $var"
        fi
    done
else
    echo "Vanilla mode!"
fi

lua qsb/lua/writer.lua $@ #&>/dev/null
echo "Done!"

cd qsb/luaminifyer

echo "Minify QSB ..."
./LuaMinify.sh ../../var/qsb.lua &>/dev/null
echo "Done!"

cd ../../qsb

#echo "Generating Documentation ..."
#echo "Note: documenting only selected modules does not work yet! You get all!"
#rm -r ../doc
#lua ldoc/ldoc.lua -d ../doc -c userconfig.ld ../var/qsb.lua &>/dev/null
#cp -r ../doc ../var/doc
#lua ldoc/ldoc.lua lua -a -c userconfig.ld -d ../doc &>/dev/null
#cp -r ../doc ../var/doc
#rm userconfig.ld

cd ..
echo "Done!"
