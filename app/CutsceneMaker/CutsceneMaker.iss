; -- UnicodeExample1.iss --
; Demonstrates some Unicode functionality. Requires Unicode Inno Setup.
;
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

[Setup]
AppName=Cutscene Maker
AppVerName=Version 1.0
DefaultDirName={pf}\CutsceneMaker
DefaultGroupName=CutsceneMaker
UninstallDisplayIcon={app}\CutsceneMaker.png
Compression=lzma2
SolidCompression=yes
OutputDir=E:/Repositories/symfonia/app/CutsceneMaker
OutputBaseFilename=CutsceneMakerInstaller

[Files]
Source: "CutsceneMaker.jar"; DestDir: "{app}";     DestName: "CutsceneMaker.jar"
Source: "CutsceneMaker.bat"; DestDir: "{app}";     DestName: "CutsceneMaker.bat"
Source: "CutsceneMaker";     DestDir: "{app}";     DestName: "CutsceneMaker"
Source: "tpl/*";             DestDir: "{app}/tpl"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\CutsceneMaker"; Filename: "{app}\CutsceneMaker.png"

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"