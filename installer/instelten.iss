[Setup]
AppId={{9FE2B24B-49F4-4D0B-A36B-31F267F9B114}
AppName=ELTEN
AppVersion=2.4
AppVerName=Elten 2.4
AppPublisher=Dawid Pieper
AppPublisherURL=https://elten-net.eu
AppSupportURL=https://elten-net.eu/
AppUpdatesURL=https://elten-net.eu/download
AppCopyright=Copyright (C) 2014-2021 Dawid Pieper
DefaultDirName={pf}\ELTEN
DefaultGroupName=ELTEN
AllowNoIcons=yes
OutputDir=.
OutputBaseFilename=elten_setup
Compression=Lzma2/ultra
SolidCompression=yes
RestartIfNeededByRun=no
PrivilegesRequiredOverridesAllowed=commandline dialog
LicenseFile=elten/gpl-3.0.txt
WizardStyle=modern

#define Use_UninsHs_Default_CustomMessages

[InstallDelete]
Type: filesandordirs; Name: "{app}\*"

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "pl"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "tr"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
//Name: "ext_update"; Description: "{cm:EltenUpdate}"; GroupDescription: "{cm:EltenUpdate}";

[Files]
Source: "elten\eltenc\*"; DestDir: "{app}"; Flags: "ignoreversion createallsubdirs recursesubdirs"
//Source: "{tmp}\elten.7z"; DestDir: "{app}"; Tasks: ext_update; \
//  Flags: external; Check: DwinsHs_Check(ExpandConstant('{tmp}\elten.7z'), \
//    'http://elten-net.eu/bin/download/elten.7z', 'INSTELTEN', 'get', 0, 0) 

[Icons]
Name: "{group}\ELTEN"; Filename: "{app}\elten.exe"
Name: "{group}\{cm:ProgramOnTheWeb,ELTEN}"; Filename: "https://elten-net.eu"
Name: "{group}\{cm:UninstallProgram,ELTEN}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\ELTEN"; Filename: "{app}\elten.exe"; Tasks: desktopicon

[Run]
//Filename: "{app}\bin\7z.exe"; Parameters: "x {userappdata}\elten\bin\elten.7z -oelten -y"; WorkingDir: "{userappdata}\elten\bin"; StatusMsg: "{cm:extractingelten}"; Flags: runhidden; tasks: ext_update
Filename: "{app}\elten.exe"; Description: "{cm:LaunchProgram,{#StringChange("ELTEN", '&', '&&')}}"; Flags: nowait postinstall

[INI]
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "de-DE"; Languages: de
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "pl-PL"; Languages: pl
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "fr-FR"; Languages: fr
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "ru-RU"; Languages: ru
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "es-PA"; Languages: es
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "tr-TR"; Languages: tr

[Code]

#define DwinsHs_Use_Predefined_Downloading_WizardPage
#define DwinsHs_Auto_Continue
#include "dwinshs.iss"

procedure InitializeWizard();
begin
  DwinsHs_InitializeWizard(wpPreparing);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  DwinsHs_CurPageChanged(CurPageID, nil, nil);
end;

function ShouldSkipPage(CurPageId: Integer): Boolean;
begin
  Result := False;
  DwinsHs_ShouldSkipPage(CurPageId, Result);
end;

function BackButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  DwinsHs_BackButtonClick(CurPageID);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  DwinsHs_NextButtonClick(CurPageID, Result);
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  DwinsHs_CancelButtonClick(CurPageID, Cancel, Confirm);
end;

[CustomMessages]
pl.DwinsHs_PageCaption =Pobieranie aktualizacji
en.DwinsHs_PageCaption =Downloading the update
de.DwinsHs_PageCaption =Das Update herunterladen
pl.DwinsHs_PageDescription =Prosz� czeka�, trwa konfigurowanie programu Elten...  Instalator pobiera dodatkowe pliki...
en.DwinsHs_PageDescription =Please wait while Elten is being preconfigured ... The installer is downloading additional files ...
de.DwinsHs_PageDescription =Bitte warten Sie, w�hrend der Elten vorkonfiguriert ist ... Der Installer l�dt weitere Dateien ...
pl.DwinsHs_TotalProgress =Post�p:
pl.DwinsHs_CurrentFile =Bierz�cy plik:
pl.DwinsHs_File =Plik:
pl.DwinsHs_Speed =Szybko��:
pl.DwinsHs_Status =Status:
pl.DwinsHs_ElapsedTime =Min�o:
pl.DwinsHs_RemainingTime =Pozosta�o:
pl.DwinsHs_Status_ButtonRetry =Spr�buj &ponownie
pl.DwinsHs_Status_ButtonNext =&Dalej >
pl.DwinsHs_SizeInBytes =%d B
pl.DwinsHs_SizeInKB =%.2f KB
pl.DwinsHs_SizeInMB =%.2f MB
pl.DwinsHs_ProgressValue = %s z %s (%d%%%)
pl.DwinsHs_SpeedInBytes =%d B/s
pl.DwinsHs_SpeedInKB =%.2f KB/s
pl.DwinsHs_SpeedInMB =%.2f MB/s
pl.DwinsHs_TimeInHour =%d godzin, %d minut, %d sekund
pl.DwinsHs_TimeInMinute =%d minut, %d sekund
pl.DwinsHs_TimeInSecond =%d sekund
pl.DwinsHs_Status_GetFileInformation =Okre�lam rozmiar pliku
pl.DwinsHs_Status_StartingDownload =Rozpoczynam pobieranie
pl.DwinsHs_Status_Downloading =Pobieranie
pl.DwinsHs_Status_DownlaodComplete =Pobieranie zako�czone
pl.DwinsHs_Error_Network =Brak po��czenia z Internetem
pl.DwinsHs_Error_Offline =Komputer znajduje si� w trybie offline
pl.DwinsHs_Error_Initialize =B��d inicjalizacji konfiguracji
pl.DwinsHs_Error_OpenSession =Nie uda�o si� otworzy� sesji HTTP
pl.DwinsHs_Error_CreateRequest =B��d http
pl.DwinsHs_Error_SendRequest =Nie uda�o si� wys�a� rz�dania do serwera HTTP
pl.DwinsHs_Error_DeleteFile =Stary plik nie mo�e by� usuni�ty
pl.DwinsHs_Error_SaveFile =Nie mo�na zapisa� danych
pl.DwinsHs_Error_Canceled =Pobieranie anulowane
pl.DwinsHs_Error_ReadData =Nie mo�na odczyta� danych
pl.DwinsHs_Status_HTTPError =B��d HTTP %d: %s
pl.DwinsHs_Status_HTTP400 =B��dne zapytanie
pl.DwinsHs_Status_HTTP401 =Odmowa dost�pu
pl.DwinsHs_Status_HTTP404 =Plik nie istnieje
pl.DwinsHs_Status_HTTP407 =Wymagane jest uwierzytelnianie serwera proxy
pl.DwinsHs_Status_HTTP500 =B��d wewn�trzny
pl.DwinsHs_Status_HTTP502 =Bad gateway
pl.DwinsHs_Status_HTTP503 =Us�uga nie jest dost�pna
pl.DwinsHs_Status_HTTPxxx =Nieznany b��d
pl.EltenUpdate =Pobierz najnowsz� wersj� programu z serwera
en.EltenUpdate =Download the newest Elten version from the server
de.EltenUpdate =Neueste Elten-Version vom Server laden
pl.extractingelten =Prosz� czeka�, trwa przygotowywanie programu Elten do pierwszego uruchomienia
en.extractingelten =Please wait, preparing Elten for the first run
de.extractingelten =Bitte warten Sie, der Installateur bereitet Elten auf den ersten Lauf vor