; Symfonia Installer Script
; Dieses Skript erzeugt den Installer für den Cutscene Maker.

#define MyAppName "CutsceneMakerInstaller"
#define MyAppVersion "1.0"
#define MyAppPublisher "Siedelwood"
#define MyAppURL "www.siedelwood-neu.de"
#define MyAppExeName "CutsceneMaker.exe"

[Setup]
AppId={{AB2EFE57-6D27-4E9A-96C1-10276873862A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\CutsceneMaker
DefaultGroupName=CutsceneMaker
OutputDir=E:\Repositories\symfonia\cnf\CutsceneMaker
OutputBaseFilename=CutsceneMakerInstaller
SetupIconFile=E:\Repositories\symfonia\bin\CutsceneMaker.ico
Compression=lzma
SolidCompression=yes
ChangesEnvironment=yes
DisableProgramGroupPage=yes

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[CustomMessages]
AppAddPath=Programm zur PATH-Variable hinzufügen (empfohlen)

[Files]
Source: "E:\Repositories\symfonia\bin\CutsceneMaker.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\bin\CutsceneMaker.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\bin\CutsceneMaker.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "CUTSCENE_MAKER_HOME"; ValueData: "{app}"

[Tasks]
Name: modifypath; Description:{cm:AppAddPath};  

[Code]
const
    ModPathName = 'modifypath';
    ModPathType = 'system';

function ModPathDir(): TArrayOfString;
begin
    setArrayLength(Result, 1)
    Result[0] := ExpandConstant('{app}');
end;

#include "modpath.iss"