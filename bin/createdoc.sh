#/bin/bash
cd ../qsb

echo "Generating developer documentation ..."

mkdir -p doc
lua ldoc/ldoc.lua lua$1$2.lua lua/doc -o $2.lua

cd ..
echo "Done!"
