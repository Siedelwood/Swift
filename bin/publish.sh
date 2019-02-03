#/bin/bash

echo "==== Building QSB ===="
./make.sh -d

echo "==== Creating Release ===="

echo "Creating release folder..."
cd ..
rm -rf Release &>/dev/null
mkdir -p Release/src/advanced
mkdir -p Release/src/beginner
mkdir -p Release/bin
echo "Done!"

echo "Copy qsb files..."
cp var/qsb.lua Release/src/questsystembehavior.lua &>/dev/null
cp var/qsb_min.lua Release/src/questsystembehavior_min.lua &>/dev/null
cp qsb/default/globalscript.lua Release/src/beginner/mapscript.lua &>/dev/null
cp qsb/default/localscript.lua Release/src/beginner/localmapscript.lua &>/dev/null
cp qsb/default/globalscript2.lua Release/src/advanced/mapscript.lua &>/dev/null
cp qsb/default/localscript2.lua Release/src/advanced/localmapscript.lua &>/dev/null
cp qsb/default/internglobalscript.lua Release/src/advanced/internmapscript.lua &>/dev/null
cp qsb/default/internlocalscript.lua Release/src/advanced/internlocalmapscript.lua &>/dev/null
echo "Done!"

echo "Copy documentation..."
cp -r qsb/doc Release/doc &>/dev/null
mkdir Release/guide &>/dev/null
cp hlp/*.pdf Release/guide &>/dev/null
cp hlp/readme.txt Release/start.txt &>/dev/null
echo "Done!"

echo "Copy examples..."
cp -r qsb/example Release/example &>/dev/null
echo "Done"

echo "Copy Map Iconator..."
cp -r bin/MapIconator.jar Release/bin/MapIconator.jar &>/dev/null
echo "Done"

echo "Copy Siedelwood Cutscene Assistant..."
cp -r "bin/Siedelwood Cutscene Assistant.jar" Release/bin/SiedelwoodCutsceneAssistant.jar &>/dev/null
echo "Done"

echo "Copy Cutscene Maker..."
cp -r "bin/CutsceneMaker.jar" Release/bin/CutsceneMaker.jar &>/dev/null
echo "Done"

echo "Creating archive..."
zip -r Release/doc Release/guide Release/* &>/dev/null
mv Release/doc.zip Release.zip &>/dev/null
echo "Done!"

echo "Cleanup mess..."
rm -rf Release
echo "Done!"

echo "Publishing finished!"
