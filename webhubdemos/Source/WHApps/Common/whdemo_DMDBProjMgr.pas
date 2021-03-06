unit whdemo_DMDBProjMgr;

// for use with demos that use the database layer

{$I hrefdefines.inc}

interface

uses
  SysUtils, Classes, tpProj;

type
  TDMForWHDBDemo = class(TDataModule)
    ProjMgr: TtpProject;
    procedure ProjMgrBeforeFirstCreate(Sender: TtpProject;
      var ErrorText: String; var Continue: Boolean);
    procedure ProjMgrDataModulesCreate1(Sender: TtpProject;
      var ErrorText: String; var Continue: Boolean);
    procedure ProjMgrDataModulesCreate2(Sender: TtpProject;
      const SuggestedAppID: String; var ErrorText: String;
      var Continue: Boolean);
    procedure ProjMgrDataModulesCreate3(Sender: TtpProject;
      var ErrorText: String; var Continue: Boolean);
    procedure ProjMgrDataModulesInit(Sender: TtpProject;
      var ErrorText: String; var Continue: Boolean);
    procedure ProjMgrGUICreate(Sender: TtpProject;
      const ShouldEnableGUI: Boolean; var ErrorText: String;
      var Continue: Boolean);
    procedure ProjMgrGUIInit(Sender: TtpProject;
      const ShouldEnableGUI: Boolean; var ErrorText: String;
      var Continue: Boolean);
    procedure ProjMgrStartupError(Sender: TtpProject;
      const ErrorText: String);
    procedure ProjMgrStop(Sender: TtpProject; var ErrorText: String;
      var Continue: Boolean);
    procedure DataModuleCreate(Sender: TObject);
    procedure ProjMgrStartupComplete(Sender: TtpProject);
  private
    { Private declarations }
    FFixedAppID: string;
    FSourceSubDir: string;
    FIsRelativePath: Boolean;
  public
    { Public declarations }
    procedure SetDemoFacts(const DemoAppID, SourceSubdir: string;
      const IsRelativePath: Boolean);
    procedure WHDBAppException(Sender: TObject; E: Exception; var Handled,
      ReDoPage: Boolean);
  end;

var
  DMForWHDBDemo: TDMForWHDBDemo;

implementation

{$R *.dfm}

uses
  {$IFDEF CodeSite}CodeSiteLogging,{$ENDIF}
  {$IFDEF EUREKALOG}
  ExceptionLog7, EExceptionManager,
  {$ENDIF}
  MultiTypeApp, ucDlgs, ucLogFil, ZM_CodeSiteInterface,
  whSharedLog,
  whutil_ZaphodsMap,
  webApp, webBase, webSplat, dmWHApp, webCall,
  whdemo_Extensions, whdemo_Initialize, whdemo_ViewSource,
  whMain, htWebApp, whpanel_RemotePages,
  whpanel_Mail, uAutoPanels;

{ TDMForWHDemo }

procedure TDMForWHDBDemo.DataModuleCreate(Sender: TObject);
begin
  FFixedAppID := '';
end;

procedure TDMForWHDBDemo.SetDemoFacts(const DemoAppID, SourceSubdir: string;
  const IsRelativePath: Boolean);
begin
  FFixedAppID := DemoAppID;
  FSourceSubDir := SourceSubDir;
  FIsRelativePath := IsRelativePath;
end;

procedure TDMForWHDBDemo.ProjMgrBeforeFirstCreate(
  Sender: TtpProject; var ErrorText: String; var Continue: Boolean);
begin
  SetCodeSiteLoggingState([]); // none initially
end;

procedure TDMForWHDBDemo.ProjMgrDataModulesCreate1(
  Sender: TtpProject; var ErrorText: String; var Continue: Boolean);
begin
  CreateCoreWebHubDataModule;
end;

procedure TDMForWHDBDemo.ProjMgrDataModulesCreate2(
  Sender: TtpProject; const SuggestedAppID: String; var ErrorText: String;
  var Continue: Boolean);
var
  UsedAppID: string;
begin
  UsedAppID := FFixedAppID;
  if UsedAppID = '' then
  begin
    UsedAppID := SuggestedAppID;
    if UsedAppID = '' then
      UsedAppID := 'appvers';
  end;

  Continue := whDemoSetAppId(UsedAppID);  // this refreshes the app
  if Continue then
  begin
    ResetLogFileSpec;
    SetCodeSiteLoggingStateFromText(pWebApp.AppSetting['CodeSiteLogging']);
    whDemoCreateSharedDataModules;
  end
  else
  begin
    CSSendError('unable to set AppID');
  end;
 
end;

procedure TDMForWHDBDemo.ProjMgrDataModulesCreate3(
  Sender: TtpProject; var ErrorText: String; var Continue: Boolean);
begin
//
end;

procedure TDMForWHDBDemo.ProjMgrDataModulesInit(Sender: TtpProject;
  var ErrorText: String; var Continue: Boolean);
const
  cFn = 'ProjMgrDataModulesInit';
begin
  ErrorText := '';
  try
    InitCoreWebHubDataModule;
    whDemoInit;
    whDemoSetDelphiSourceLocation(FSourceSubDir, FIsRelativePath);
  except
    on E: Exception do
    begin
       ErrorText := cFn + Chr(183) + E.Message;
       Continue := False;
    end;
  end;
end;

procedure TDMForWHDBDemo.ProjMgrGUICreate(Sender: TtpProject;
  const ShouldEnableGUI: Boolean; var ErrorText: String;
  var Continue: Boolean);
const
  cFn = 'ProjMgrGUICreate';
var
  SplashMessage: string;
begin
  ErrorText := '';
  if ShouldEnableGUI then
  begin
    try
      SplashMessage := 'Creating panels';
      WebMessage(SplashMessage);

      {M}Application.CreateForm(TfmWebHubMainForm, fmWebHubMainForm);

      if Assigned(fmWebHubMainForm.Restorer) then
      begin
        { avoid Restorer feature on production server
          with multiple instances -- too much conflict on the
          WHAppRestorer.xml file during shutdown }
        CSSend(csmLevel5, 'Restorer.Forget on ZMContext',
          pWebApp.ZMDefaultMapContext);
        fmWebHubMainForm.Restorer.Forget;  // cleanup pointers on nested panels
        FreeAndNil(fmWebHubMainForm.Restorer);
      end
      else
        CSSend('fmWebHubMainForm.Restorer already nil');

      fmWebHubMainForm.Caption := pWebApp.AppID;

      whDemoCreateSharedPanels;
 
      WebMessage('-' + SplashMessage);
    except
      on E: Exception do
      begin
         ErrorText := cFn + Chr(183) + E.Message;
         Continue := False;
      end;
    end;
  end;
end;

procedure TDMForWHDBDemo.ProjMgrGUIInit(Sender: TtpProject;
  const ShouldEnableGUI: Boolean; var ErrorText: String;
  var Continue: Boolean);
begin
  Assert(Assigned(pWebApp));
  Assert(pWebApp.IsUpdated);
  if ShouldEnableGUI then
  begin
    pWebApp.DoUpdateGUI;

    InitCoreWebHubDataModuleGUI;
    InitStandardWHModulesGUI;

    WebMessage('0');         // required to close splash screen
  end;

end;

procedure TDMForWHDBDemo.ProjMgrStartupComplete(Sender: TtpProject);
begin
  UncoverAppOnStartup(pWebApp.AppID);
  pConnection.MarkReadyToWork;  // required in v3.190+
end;

procedure TDMForWHDBDemo.ProjMgrStartupError(Sender: TtpProject;
  const ErrorText: String);
begin
  LogSendError(ErrorText, 'during startup');
{$IFNDEF PREVENTGUI}
  MsgErrorOk(ErrorText);
{$ENDIF}
end;

procedure TDMForWHDBDemo.ProjMgrStop(Sender: TtpProject;
  var ErrorText: String; var Continue: Boolean);
begin
  whDemoDestroySharedPanels;
  DestroyCoreWebHubDataModuleGUI;
  whDemoDestroySharedDataModules;
end;

procedure TDMForWHDBDemo.WHDBAppException(Sender: TObject; E: Exception;
  var Handled, ReDoPage: Boolean);
begin
  { some database demos connect pWebApp.OnError to this event handler }
  Handled := True;
  CSSendError(E.StackTrace);
  LogSendException(E);  // uses ZM_CodeSiteInterface and ucLogFil

  {$IFDEF CodeSite}
  HREFTestLog('exception', E.Message, '');
  {$ENDIF}

  {$IFDEF EUREKALOG}
  // uses ExceptionLog7, EExceptionManager
  LogSendWarning('EurekaLog provides the following CallStack');
  LogSendError(ExceptionManager.LastThreadException.CallStack.ToString);
  {$ENDIF}

  if E is EAccessViolation then
    pConnection.MarkTerminateASAP;
  pWebApp.Response.SendBounceToPage('pgWelcome', '');
end;

initialization
  {$IFDEF Log2CSL}UseWebHubSharedLog;{$ENDIF}

end.
