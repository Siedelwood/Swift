; QSB S% Installer Script
; Dieses Skript erzeugt den Installer f�r den Cutscene Maker.

#define MyAppName "QuestSystemBehavior"
#define MyAppVersion "1.0"
#define MyAppPublisher "Siedelwood"
#define MyAppURL "www.siedelwood.de"
#define MyAppExeName "QuestSystemBehavior.exe"

[Setup]
AppId={{AB2EFE57-6D27-4E9A-96C1-10276873862A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={userappdata}\Siedelwood\QuestSystemBehavior
DefaultGroupName=Siedelwood
OutputDir=E:\Repositories\symfonia\cnf\QuestSystemBehavior
OutputBaseFilename=QuestSystemBehaviorInstaller
SetupIconFile=E:\Repositories\symfonia\bin\QuestSystemBehavior.ico
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage=no
DisableDirPage=no

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "E:\Repositories\symfonia\app\mapmakers5\bin\QuestSystemBehavior.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\mapmakers5\bin\QuestSystemBehavior.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\var\updater.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\var\logback-spring.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\src\main\resources\config\icon.png"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\src\main\resources\application.properties"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\src\main\resources\application-s5mapmaker.properties"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "E:\Repositories\symfonia\app\swapplicationupdater\var\jre\*"; DestDir: "{app}\jre"; Flags: ignoreversion recursesubdirs

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\Siedelwood\QuestSystemBehavior"
Type: filesandordirs; Name: "{app}\orthosassistant"

[Icons]
Name: "{group}\QuestSystemBehavior"; Filename: "{app}\QuestSystemBehavior.exe"; WorkingDir: "{app}"
Name: "{group}\QuestSystemBehavior Deinstallieren"; Filename: "{uninstallexe}" 

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent