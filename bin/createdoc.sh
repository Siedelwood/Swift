#/bin/bash
cd ../qsb

echo "Generating developer documentation ..."

mkdir -p doc/html
lua ldoc/ldoc.lua lua$1$2.lua -d doc/html -o $2.lua

cd ..
echo "Done!"
