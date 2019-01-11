#/bin/bash

echo "==== Building QSB ===="
./make.sh -d

echo "==== Creating Release ===="

echo "Creating release folder..."
cd ..
rm -rf Release &>/dev/null
mkdir -p Release/src/prof
mkdir -p Release/src/assi
echo "Done!"

echo "Copy qsb files..."
cp var/qsb.lua Release/src/questsystembehavior.lua &>/dev/null
cp var/qsb_min.lua Release/src/questsystembehavior_min.lua &>/dev/null
cp qsb/default/globalscript.lua Release/src/assi/mapscript.lua &>/dev/null
cp qsb/default/localscript.lua Release/src/assi/localmapscript.lua &>/dev/null
cp qsb/default/globalscript2.lua Release/src/prof/mapscript.lua &>/dev/null
cp qsb/default/localscript2.lua Release/src/prof/localmapscript.lua &>/dev/null
cp qsb/default/internglobalscript.lua Release/src/prof/internmapscript.lua &>/dev/null
cp qsb/default/internlocalscript.lua Release/src/prof/internlocalmapscript.lua &>/dev/null
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
