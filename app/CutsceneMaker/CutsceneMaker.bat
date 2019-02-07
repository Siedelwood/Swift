echo off
for /f %%i in ('where /r CutsceneMaker.jar') do set location=%%i
java -jar %location%