#/bin/bash
cd ../qsb

echo "Generating developer documentation ..."

mkdir -p doc/$1
lua ldoc/ldoc.lua lua/$1/$2.lua lua/doc -o bundles/$2

cd ..
echo "Done!"
