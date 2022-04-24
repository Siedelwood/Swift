; S6 Tools Installer Script
; Dieses Skript erzeugt den Installer f�r die S6 Tools.

#define MyAppName "SWS6Tools"
#define MyAppVersion "1.0"
#define MyAppPublisher "Siedelwood"
#define MyAppURL "www.siedelwood.de"
#define MyAppExeName "SWS6Tools.exe"

[Setup]
AppId={{AB2EFE57-6D27-4E9A-96C1-10276873862A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={userappdata}\Siedelwood\SWS6Tools
DefaultGroupName=Siedelwood
OutputDir=E:\Repositories\swift\cnf\SWS6Tools
OutputBaseFilename=SWS6ToolsInstaller
SetupIconFile=E:\Repositories\swift\bin\SWS6Tools.ico
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage=no
DisableDirPage=no

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "E:\Repositories\swift\bin\SWS6Tools.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\swift\bin\SWS6Tools.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\swift\app\swapplicationupdater\var\updater.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\swift\app\swapplicationupdater\src\main\resources\logback-spring.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\swift\app\swapplicationupdater\src\main\resources\config\logo_100.png"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\swift\app\swapplicationupdater\src\main\resources\application.properties"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\swift\app\swapplicationupdater\src\main\resources\application-sws6tools.properties"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\swift\app\swapplicationupdater\var\jre\*"; DestDir: "{app}\jre"; Flags: ignoreversion recursesubdirs

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\Siedelwood\SWS6Tools"
Type: filesandordirs; Name: "{app}"

[Icons]
Name: "{group}\SWS6Tools"; Filename: "{app}\SWS6Tools.exe"; WorkingDir: "{app}"
Name: "{group}\SWS6Tools Deinstallieren"; Filename: "{uninstallexe}" 

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent