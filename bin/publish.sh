#/bin/bash

echo "==== Building QSB ===="
./make.sh -d

echo "==== Creating Release ===="

echo "Creating release folder..."
cd ..
rm -rf Release &>/dev/null
mkdir Release
echo "Done!"

echo "Copy qsb files..."
cp var/qsb.lua Release/questsystembehavior.lua &>/dev/null
cp var/qsb_min.lua Release/questsystembehavior_min.lua &>/dev/null
cp qsb/default/globalscript.lua Release/mapscript.lua &>/dev/null
cp qsb/default/localscript.lua Release/localmapscript.lua &>/dev/null
echo "Done!"

echo "Copy documentation..."
cp -r qsb/doc Release/doc &>/dev/null
mkdir Release/guide &>/dev/null
cp hlp/*.pdf Release/guide &>/dev/null
cp hlp/readme.txt Release/start.txt &>/dev/null
echo "Done!"

echo "Creating archive..."
zip -r Release/doc Release/guide Release/* &>/dev/null
mv Release/doc.zip Release.zip &>/dev/null
echo "Done!"

echo "Cleanup mess..."
rm -rf Release
echo "Done!"

echo "Publishing finished!"
