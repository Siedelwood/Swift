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
DisableProgramGroupPage=no
DisableDirPage=no

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "E:\Repositories\symfonia\bin\MapIconator.exe"; DestDir: "{app}"; Flags: ignoreversion
; Source: "E:\Repositories\symfonia\bin\MapIconator.jar"; DestDir: "{app}"; Flags: ignoreversion
; Source: "E:\Repositories\symfonia\bin\MapIconator.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\var\updater.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\var\logback-spring.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\src\main\resources\config\icon.png"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\src\main\resources\application.properties"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\src\main\resources\application-mapicon.properties"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\var\jre\*"; DestDir: "{app}\jre"; Flags: ignoreversion recursesubdirs

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\Siedelwood\MapIconator"
Type: filesandordirs; Name: "{app}\mapiconatordeployment"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent