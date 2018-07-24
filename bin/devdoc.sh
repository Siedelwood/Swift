#/bin/bash
cd ../qsb

echo "Generating developer documentation ..."
lua ldoc/ldoc.lua -a lua -d ../doc &>/dev/null

cd ..
echo "Done!"
