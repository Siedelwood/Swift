#define MyAppName "MapIconator"
#define MyAppVersion "1.0"
#define MyAppPublisher "Siedelwood"
#define MyAppURL "http://www.siedelwood-neu.de/"
#define MyAppExeName "MapIconator.exe"

[Setup]
AppId={{C258E9FE-88D4-44E6-B04E-9EFEA7DD4F60}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\Siedelwood\MapIconator
DefaultGroupName=Siedelwood
OutputDir=E:\Repositories\symfonia\cnf\MapIconator
OutputBaseFilename=MapIconatorInstaller
SetupIconFile=E:\Repositories\symfonia\bin\MapIconator.ico
Compression=lzma
SolidCompression=yes
ChangesEnvironment=yes

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "E:\Repositories\symfonia\bin\MapIconator.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\bin\MapIconator.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\bin\MapIconator.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent