; Symfonia Installer Script
; Dieses Skript erzeugt den Installer für den Cutscene Maker.

#define MyAppName "QSBSBuilder"
#define MyAppVersion "1.0"
#define MyAppPublisher "Siedelwood"
#define MyAppURL "www.siedelwood-neu.de"
#define MyAppExeName "QSBSBuilder.exe"

[Setup]
AppId={{AB2EFE57-6D27-4E9A-96C1-10276873862A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\Siedelwood\QSBSBuilder
DefaultGroupName=Siedelwood
OutputDir=E:\Repositories\symfonia\cnf\QSBSBuilder
OutputBaseFilename=QSBSBuilderInstaller
SetupIconFile=E:\Repositories\symfonia\bin\QSBSBuilder.ico
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage=no
DisableDirPage=no

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "E:\Repositories\symfonia\bin\QSBSBuilder.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\bin\qsb-s-builder.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\bin\QSBSBuilder.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\qsb-s-builder\config\bundles.json"; DestDir: "{app}\config"; Flags: ignoreversion   
Source: "E:\Repositories\symfonia\app\qsb-s-builder\config\version.json"; DestDir: "{app}\config"; Flags: ignoreversion

[UninstallDelete]
Type: filesandordirs; Name: "{app}\sources"
Type: filesandordirs; Name: "{app}\var"

[Icons]
Name: "{group}\QSBSBuilder"; Filename: "{app}\QSBSBuilder.exe"; WorkingDir: "{app}"
Name: "{group}\QSBSBuilder Deinstallieren"; Filename: "{uninstallexe}"

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}" 

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent