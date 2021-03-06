unit whdemo_About;  {panel to help self-document all WebHub demos}

{ ---------------------------------------------------------------------------- }
{ * Copyright (c) 1996-2018 HREF Tools Corp.                                 * }
{ *                                                                          * }
{ * This source code file is part of the WebHub Demos.                       * }
{ *                                                                          * }
{ * This file is licensed under a Creative Commons Attribution 2.5 License.  * }
{ * http://creativecommons.org/licenses/by/2.5/                              * }
{ * If you use this file, please keep this notice intact.                    * }
{ *                                                                          * }
{ * Author: Ann Lynnworth                                                    * }
{ *                                                                          * }
{ * Refer friends and colleagues to www.href.com/whvcl. Thanks!              * }
{ ---------------------------------------------------------------------------- }

interface

{$I hrefdefines.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Buttons,  System.Actions, Vcl.ActnList,
  utPanFrm, tpMemo, tpStatus, updateOk, tpAction, toolbar, tpCompPanel, 
  webTypes, webLink;

type
  TfmAppAboutPanel = class(TutParentForm)
    Panel1: TPanel;
    Panel: TPanel;
    LabelShortDesc: TLabel;
    LabelQueryString: TLabel;
    Panel3: TPanel;
    LabelCopyright: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelAbout: TLabel;
    Panel2: TPanel;
    Panel4: TPanel;
    ActionList1: TActionList;
    ActionToggleConnection: TAction;
    GroupBoxWHXP: TGroupBox;
    ActionShowConnectionDetail: TAction;
    Splitter1: TSplitter;
    Panel5: TPanel;
    Panel6: TPanel;
    LabelIdentification: TLabel;
    LabelDllCalls: TLabel;
    LabelAboutCPU: TLabel;
    LabelAboutHarry: TLabel;
    LabelAboutInstance: TLabel;
    Timer1: TTimer;
    LabelAboutCompiler: TLabel;
    procedure LabelURLClick(Sender: TObject);
    procedure ActionToggleConnectionExecute(Sender: TObject);
    procedure ActionShowConnectionDetailExecute(Sender: TObject);
    procedure LabelAboutHarryClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    destructor Destroy; override;
    function Init: Boolean; override;
    procedure SetAboutLabels(Sender: TObject);
  end;

var
  fmAppAboutPanel: TfmAppAboutPanel = nil;

implementation

{$R *.DFM}

uses
  ucShell, ucVers, ucString, uCode,
  whxpUtils,
  webApp, whConst, htWebApp, webCall;

//------------------------------------------------------------------------------

function TfmAppAboutPanel.Init: Boolean;
begin
  Result := inherited Init;
  if not Result then
    Exit;
  AddAppUpdateHandler(SetAboutLabels);
  GroupBoxWHXP.Visible := True;
  Result := assigned(pWebApp) and pWebApp.IsUpdated;
  if Result then
  begin
    SetAboutLabels(pWebApp);
    RefreshWebActions(Self);
  end;
end;

procedure TfmAppAboutPanel.SetAboutLabels(Sender: TObject);
var
  S: String;
begin
  S := GetVersionString(vsLegalCopyright);
  LabelCopyright.Caption := 'Copyright ';
  if (S = '') or (S = 'Unknown') then
    LabelCopyRight.Caption := LabelCopyright.Caption + '(c) 1997-' +
      FormatDateTime('yyyy', Now) + ' HREF Tools Corp.'
  else
    LabelCopyRight.Caption := S;

  with pWebApp do
  begin
    LabelShortDesc.Caption :=
      Macros.Values['mcWhDemoOneLiner' + AppID]; // e.g. 'Ad Rotation'
    if LabelShortDesc.Caption = '' then
      LabelShortDesc.Caption := AppID;
    S := ExtractFilePath(pWebApp.ConfigFilespec);
    with LabelQueryString do
    begin
      Caption := '?' + AppID + ':' + Situations.HomePageID;
    end;
    with LabelAbout do
    begin
      Caption := '?' + AppID + ':pgAbout::' + AppID;
    end;
  end;
  ActionShowConnectionDetailExecute(Self);
end;

procedure TfmAppAboutPanel.Timer1Timer(Sender: TObject);
begin
  inherited;
  Timer1.Enabled := False;
  FreeAndNil(pConnection);   // for testing WebHubGuardian
end;

procedure TfmAppAboutPanel.LabelAboutHarryClick(Sender: TObject);
begin
  inherited;
  ActionToggleConnectionExecute(LabelAboutHarry);
end;

procedure TfmAppAboutPanel.LabelURLClick(Sender: TObject);
begin
  inherited;
  with TLabel(Sender) do
    WinShellOpen('http://localhost/scripts/runisa.dll' + Caption);
end;

procedure TfmAppAboutPanel.ActionToggleConnectionExecute(Sender: TObject);
begin
  inherited;

    if IsEqual(Caption, 'suspend') then
    begin
      //pConnection.Active := False;  // off, WebHub v2.132, 24-Nov-2010
      FreeAndNil(pConnection);        // alternative
      Caption := 'Resume';
      LabelAboutHarry.Caption := 'Connect to Hub = False';
    end
    else
    begin
      //pConnection.Active := True;  // off, WebHub v2.132, 24-Nov-2010
      pWebApp.Refresh;               // alternative
      Caption := 'Suspend';
    end;

end;

procedure TfmAppAboutPanel.ActionShowConnectionDetailExecute(
  Sender: TObject);
var
  Port: Integer;
  pid: Cardinal;
  S: string;
begin
  inherited;
  if Assigned(pConnection) then
  begin
    LabelDllCalls.Caption := 'Calls: ' + IntToStr(pConnection.DllCalls);
    LabelIdentification.Caption := 'AppID=' + pConnection.AppID +
      ' and PID=' + IntToStr(getCurrentProcessID) +
      ' Slot#' + IntToStr(pConnection.SlotNo); {17-Dec-2004}
  end;
  if GetHarryListenPortAndPID(Port, pid) then
  begin
    LabelAboutHarry.Caption := 'Hub is running with PID ' + IntToStr(pid);
  end
  else
    LabelAboutHarry.Caption := 'Hub not running';
  S := 'Native Code: ';
{$IFDEF CPUX64}
  S := S + '64-bit';
{$ELSE}
  S := S + '32-bit';
{$ENDIF}
  LabelAboutCPU.Caption := S;
  LabelAboutCompiler.Caption := 'Compiler: ' + uCode.PascalCompilerCode;
  LabelAboutInstance.Caption := pWebApp.AppID + ' instance #' +
    IntToStr(pWebApp.AppInstanceCounter.InstanceSequence);
end;

destructor TfmAppAboutPanel.Destroy;
begin
  inherited;
  fmAppAboutPanel := nil;
end;

procedure TfmAppAboutPanel.FormCreate(Sender: TObject);
begin
  inherited;
  // Timer1 is a placeholder for testing WebHubGuardian with services
  // It is not ordinarily required at all.
  FreeAndNil(Timer1);
end;

end.
