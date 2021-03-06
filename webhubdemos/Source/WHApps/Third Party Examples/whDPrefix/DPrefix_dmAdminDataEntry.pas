unit DPrefix_dmAdminDataEntry;

{ ---------------------------------------------------------------------------- }
{ * Copyright (c) 1999-2017 HREF Tools Corp.  All Rights Reserved Worldwide. * }
{ *                                                                          * }
{ * This source code file is part of the Delphi Prefix Registry.             * }
{ *                                                                          * }
{ * This file is licensed under a Creative Commons Attribution 2.5 License.  * }
{ * http://creativecommons.org/licenses/by/2.5/                              * }
{ * If you use this file, please keep this notice intact.                    * }
{ *                                                                          * }
{ * Author: Ann Lynnworth                                                    * }
{ *                                                                          * }
{ * Refer friends and colleagues to www.href.com/whvcl. Thanks!              * }
{ ---------------------------------------------------------------------------- }

{$I hrefdefines.inc}

interface

uses
  SysUtils, Classes, Data.DB,
  System.Actions, // requires D17 XE3
  Vcl.ActnList,   // requires D17 XE3
  updateOK, tpAction,
  webLink, webCall, webTypes, wdbSSrc, wdbSource, wdbScan;

type
  TDMAdminDataEntry = class(TDataModule)
    ActionList1: TActionList;
    ActCleanURL: TAction;
    Act1stLetter: TAction;
    ActUpcaseStatus: TAction;
    ActDeleteStatusD: TAction;
    ActCreateIndices: TAction;
    ActCountPending: TAction;
    ActCheckURLs: TAction;
    ActAssignPasswords: TAction;
    ActExportToCSV: TAction;
    ActionPurpose: TAction;
    ActLowercaseEMail: TAction;
    ActNoAmpersand: TAction;
    DataSource1: TDataSource;
    ManPref: TwhdbScan;
    procedure ManPrefExecute(Sender: TObject);
    procedure ManPrefInit(Sender: TObject);
    procedure ManPrefRowStart(Sender: TwhdbScanBase;
      aWebDataSource: TwhdbSourceBase; var ok: Boolean);
    procedure ManPrefFinish(Sender: TObject);
    procedure Act1stLetterExecute(Sender: TObject);
    procedure ActCleanURLExecute(Sender: TObject);
    procedure ActUpcaseStatusExecute(Sender: TObject);
    procedure ActDeleteStatusDExecute(Sender: TObject);
    procedure ActCreateIndicesExecute(Sender: TObject);
    procedure ActCountPendingExecute(Sender: TObject);
    procedure ActCheckURLsExecute(Sender: TObject);
    procedure ActAssignPasswordsExecute(Sender: TObject);
    procedure ActExportToCSVExecute(Sender: TObject);
    procedure ActionPurposeExecute(Sender: TObject);
    procedure ActLowercaseEMailExecute(Sender: TObject);
    procedure ActNoAmpersandExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FlagInitDone: Boolean;
    procedure WebAppUpdate(Sender: TObject);
  public
    { Public declarations }
    wdsManPref: TwhdbSource;
    function Init(out ErrorText: string): Boolean;
    procedure WebAppOutputClose(Sender: TObject);
    procedure WebCommandLineFrontDoorTriggered(Sender: TwhConnection;
      const ADesiredPageID: string; var bDoFrontDoorBounce: Boolean);
  end;

var
  DMAdminDataEntry: TDMAdminDataEntry;

implementation

{$R *.dfm}

uses
  System.Character, // IsDigit
  DateUtils,
  ZM_CodeSiteInterface,
  MultiTypeApp,
  ucMsTime,
  ucLogFil,
  ucDlgs,   //admin/non-web confirmation questions
  whutil_ValidEmail, webApp, htWebApp, webScan, webSend,
  DPrefix_dmNexus, DPrefix_dmwhActions;

procedure TDMAdminDataEntry.DataModuleCreate(Sender: TObject);
begin
  FlagInitDone := False;
  wdsManPref := TwhdbSource.Create(Self);
  with wdsmanPref do
  begin
    Name := 'wdsmanPref';  // required for all webactions
    ComponentOptions := [];
    GotoMode := wgGotoKey;
    MaxOpenDataSets := 1;
    OpenDataSets := 0;
    OpenDataSetRetain := 600;
    SaveTableName := False;
    DataSource := DataSource1;
  end;
  ManPref.WebDataSource := wdsmanPref;
end;

procedure TDMAdminDataEntry.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(wdsManPref);
end;

function TDMAdminDataEntry.Init(out ErrorText: string): Boolean;
const cFn = 'Init';
begin
  CSEnterMethod(Self, cFn);
  ErrorText := '';
  // reserved for code that should run once, after AppID set
  if NOT FlagInitDone then
  begin

    ManPref.WebDataSource := wdsManPref;
    ManPref.ButtonsWhere := dsNone;
    ManPref.PageHeight := 200;
    ManPref.ControlsWhere := dsNone;
    wdsManPref.KeyFieldNames := 'MpfID';
    TwhdbSource(ManPref.WebDataSource).DataSource := DataSource1;
    DataSource1.DataSet := DMNexus.Table1;
    DataSource1.DataSet.Open; // readonly, all records

    RefreshWebActions(Self);
    Result := ManPref.WebDataSource.IsUpdated;
    if NOT Result then
      LogSendError('ManPref.WebDataSource.IsUpdated=' +
        S(ManPref.WebDataSource.IsUpdated));

    if Assigned(pWebApp) and pWebApp.IsUpdated then
    begin
      // Call RefreshWebActions here only if it is not called within a TtpProject event
      // RefreshWebActions(Self);

      // helpful to know that WebAppUpdate will be called whenever the
      // WebHub app is refreshed.
      AddAppUpdateHandler(WebAppUpdate);
      FlagInitDone := True;
    end;
  end;
  Result := FlagInitDone;
  CSSend('Result', S(Result));
  CSExitMethod(Self, cFn);
end;

procedure TDMAdminDataEntry.WebAppOutputClose(Sender: TObject);
begin
  // reminder
  // be careful not to add something to ALL pages that is only suitable for SOME pages
end;

procedure TDMAdminDataEntry.WebAppUpdate(Sender: TObject);
const cFn = 'WebAppUpdate';
begin
  CSEnterMethod(Self, cFn);
  // reserved for when the WebHub application object refreshes
  // e.g. to make adjustments because the config changed.
  CSExitMethod(Self, cFn);
end;

procedure TDMAdminDataEntry.Act1stLetterExecute(Sender: TObject);
var
  ACap: string;
begin
  inherited;
  with DMNexus.TableAdmin do
  begin
    if NOT Filtered then
    begin
      First;
      while not EOF do
      begin
        ACap := Uppercase(Copy(FieldByName('Mpf Prefix').AsString, 1, 1));
        {$IFDEF Delphi18UP}
        if ACap[1].IsDigit then
        {$ELSE}
        if IsDigit(ACap[1]) then
        {$ENDIF}
          ACap := '1';
        if FieldByName('MpfFirstLetter').asString <> ACap then
        begin
          Edit;
          FieldByName('MpfFirstLetter').asString := ACap;
          DMNexus.Stamp(DMNexus.TableAdmin, 'upc');
          Post;
        end;
        Next;
      end;
      if {M}Application.ApplicationMode = mtamApp then
        MsgInfoOk('all records reviewed');
    end
    else
    begin
      if {M}Application.ApplicationMode = mtamApp then
        MsgErrorOk('table filtered; not reviewed');
    end;
  end;
end;

procedure TDMAdminDataEntry.ActAssignPasswordsExecute(Sender: TObject);
var
  LastEMail, AEMail: string;
  bGrant: Boolean;
const
  cLettersDigits = 'zqLvXuX8hZhJlYGq0wcsYUZn2jVKKrQs1AozWqsc3weKnJdA4itkexzcmFBAP94';

  function RandomPasswordString: string;
  var
    i, j, n: Integer;
  begin
    Result := '';
    n := 12; // length of password
    for i := 1 to n do
    begin
      j := Random(61);
      Result := Result + cLettersDigits[Succ(j)];
    end;
  end;
begin
  inherited;
  Randomize;
  LastEMail := '';
  with DMNexus.TableAdmin do
  begin
    Close;
    IndexName := 'EMail';
    Open;
    First;
    while not EOF do
    begin
      bGrant := False;
      AEMail := FieldByName('Mpf EMail').AsString;
      if Aemail <> LastEMail then
        bGrant := StrIsEMail(AEMail);

      if bGrant then
      begin
        Edit;
        FieldByName('MpfPassToken').asString := RandomPasswordString;
        FieldByName('MpfPassUntil').AsDateTime := IncDay(Now, 14);
        DMNexus.Stamp(DMNexus.TableAdmin, 'htc');
        Post;
      end
      else
      begin
        Edit;
        FieldByName('MpfPassToken').asString := '';
        FieldByName('MpfPassUntil').AsDateTime := IncDay(Now, -365);
        DMNexus.Stamp(DMNexus.TableAdmin, 'htc');
        Post;
      end;
      Next;
    end;
  end;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Passwords assigned ' + FormatDateTime('dddd dd-MMM hh:nn',
      NowUTC));
end;

procedure TDMAdminDataEntry.ActCheckURLsExecute(Sender: TObject);
var
  AURL: string;
  iStatusCode: Integer;
  Count: Integer;

begin
  inherited;
  Count := 0;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while (not EOF) do // and (Count < 5) do
    begin
      Application.ProcessMessages;
      (*if CheckBox1.Checked then
      begin
        CSSendWarning('break');
        break;
      end;*)
      if (NOT FieldByName('MpfURLStatus').IsNull) then
      begin
        AURL := FieldByName('Mpf WebPage').AsString;
        if AURL <> '' then
        begin
          Inc(Count);
          CSSend('Count', S(Count));
          AURL := 'http://' + AURL;
          DMDPRWebAct.TestURL(AURL, iStatusCode);
          if iStatusCode > 0 then
          begin
            Edit;
            FieldByName('MpfURLStatus').AsInteger := iStatusCode;
            FieldByName('MpfURLTestOnAt').AsDateTime := NowUTC;
            DMNexus.Stamp(DMNexus.TableAdmin, 'htc');
            Post;
          end;
        end
        else
        begin
          if (NOT FieldByName('MpfURLStatus').IsNull) and
            (FieldByName('MpfURLStatus').AsInteger <> -1) then
          begin
            Edit;
            FieldByName('MpfURLStatus').AsInteger := -1;
            FieldByName('MpfURLTestOnAt').AsDateTime := NowUTC;
            DMNexus.Stamp(DMNexus.TableAdmin, 'htc');
            Post;
          end;
        end;
      end;
      Next;
    end;
  end;

end;

procedure TDMAdminDataEntry.ActCleanURLExecute(Sender: TObject);
var
  AURL: string;
begin
  inherited;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while not EOF do
    begin
      AURL := FieldByName('Mpf WebPage').AsString;
      if Copy(AURL, 1, 7) = 'http://' then
      begin
        Edit;
        FieldByName('Mpf WebPage').asString := Copy(AURL, 8, MaxInt);
        Post;
      end;
      Next;
    end;
  end;
end;

procedure TDMAdminDataEntry.ActCountPendingExecute(Sender: TObject);
begin
  inherited;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Number Pending = ' + IntToStr(DMNexus.CountPending));
end;

procedure TDMAdminDataEntry.ActCreateIndicesExecute(Sender: TObject);
begin
  inherited;
  DMNexus.TableAdmin.Close;
  DMNexus.Table1.Close;
  try
    DMNexus.Table1.DeleteIndex('Prefix');
  except
    on E: Exception do
    begin
      LogSendException(E);
    end;
  end;
  DMNexus.Table1.AddIndex('Prefix', 'Mpf Prefix', [], 'Mpf Prefix');
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Prefix index has been created');
  (*try
    DMNexus.Table1.DeleteIndex('MpfID');
  except
    on E: Exception do
    begin
      LogSendException(E);
    end;
  end;*)
  // NexusDB does not allow deletion when there is a primary key ??!!
  //DMNexus.Table1.AddIndex('MpfID', 'MpfID', [ixPrimary, ixUnique], '', '', True);
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Indexing complete.');
  DMNexus.TableAdmin.Open;
  DMNexus.Table1.Open;
end;

procedure TDMAdminDataEntry.ActDeleteStatusDExecute(Sender: TObject);
var
  AStatus: string;
  n: Integer;
begin
  inherited;
  n := 0;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while not EOF do
    begin
      AStatus := FieldByName('Mpf Status').AsString;
      if AStatus = 'D' then
      begin
        Delete;
        Inc(n);
      end
      else
        Next;
    end;
  end;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Deleted ' + IntToStr(n) + ' records');
end;

type TMarketingRec = record
  Contact: string;
  Company: string;
  Purpose: string;
  Prefix: string;
  FirstLetter: string;
  Webpage: string;
  email: string;
  RegisteredOn: TDateTime;
  URLStatus: Integer;
  URLTestOnAt: TDateTime;
  PassToken: string;
  PassUntil: TDateTime;
  Beneficiary: string;
  ListRadio: string;
end;

procedure TDMAdminDataEntry.ActExportToCSVExecute(Sender: TObject);
var
  Data: TMarketingRec;
  Filespec8: string;
  CSVContents: string;
  LastEMail: string;

  function DateTimeNot1899(const D1: TDateTime): string;
  begin
    //30-Dec-1899
    Result := FormatDateTime('dd-MMM-yyyy hh:nn', D1);
    if Pos('30-Dec-1899', Result) = 1 then
      Result := ''
    else
      Result := Result + ' gmt';
  end;

  function DateNot1899(const D1: TDateTime): string;
  begin
    //30-Dec-1899
    Result := FormatDateTime('dd-MMM-yyyy', D1);
    if Result = '30-Dec-1899' then
      Result := '';
  end;

  function QthenTab(const S1: string): string;
  begin
    Result := //'"' +
      S1 +
      //'"' +
      #9;
  end;

begin
  inherited;
  ActAssignPasswordsExecute(ActAssignPasswords);
  Filespec8 := 'd:\DelphiPrefixRegistry_Marketing.' +
    FormatDateTime('yyyy-mm-dd', NowUTC) + '.utf8.csv';
  CSVContents := '';
  Data.ListRadio := 'yes';
  with DMNexus.TableAdmin do
  begin
    Close;
    IndexName := 'EMail';
    Open;
    First;
    LastEMail := '';
    while not EOF do
    begin
      Data.EMail := FieldByName('Mpf EMail').AsString;
      Data.PassToken := FieldByName('MpfPassToken').asString;
      Data.PassUntil := FieldByName('MpfPassUntil').AsDateTime;
      if (Data.email <> LastEMail) and (Data.PassToken <> '') and
        (Now < Data.PassUntil) then
      begin
        if StrIsEMail(Data.EMail) then
        begin
          Data.Contact := FieldByName('Mpf Contact').asString;
          Data.Purpose := FieldByName('MpfPurpose').AsString;
          Data.Prefix := FieldByName('Mpf Prefix').AsString;
          Data.FirstLetter := FieldByName('MpfFirstLetter').AsString;
          Data.Webpage := FieldByName('Mpf Webpage').AsString;
          Data.RegisteredOn :=
            FieldByName('Mpf Date Registered').AsDateTime;
          //Data.RegisteredOn := StrToDateDef(
          //  FieldByName('Mpf Date Registered').AsString, IncDay(Now, -(113*365)));
          Data.URLStatus := FieldByName('MpfURLStatus').AsInteger;
          Data.URLTestOnAt := FieldByName('MpfURLTestOnAt').AsDateTime;
          if Data.Purpose <> '' then
            Data.Beneficiary := Data.Purpose
          else
          if Data.Company <> '' then
            Data.Beneficiary := Data.Company
          else
            Data.Beneficiary := Data.Contact;
          CSVContents := CSVContents +
            QthenTab(Data.Email) +
            QthenTab(Data.ListRadio) +
            QthenTab(DateNot1899(data.RegisteredOn)) +
            QthenTab(Data.Contact) +
            QthenTab(Data.Company) +
            QthenTab(Data.Purpose) +
            QthenTab(Data.Prefix) +
            QthenTab(Data.FirstLetter) +
            QthenTab(Data.WebPage) +
            QthenTab(Data.Beneficiary) +
            QthenTab(IntToStr(data.URLStatus)) +
            QthenTab(DateTimeNot1899(data.URLTestOnAt)) +
            QthenTab(Data.PassToken) +
            DateTimeNot1899(data.PassUntil) +
            sLineBreak;
        end;
        LastEMail := Data.email;
      end;
      Next;
    end;
    Close;
    IndexName := '';
  end;
  // www.streamsend.com needs UTF-8 tab delimited, *no* quotes around text.
  UTF8StringWriteToFile(Filespec8, UTF8String(CSVContents));
  if {M}Application.ApplicationMode = mtamApp then
  begin
    MsgInfoOk(Filespec8 + sLineBreak +
      'Done at ' + FormatDateTime('dddd dd-MMM hh:nn', NowUTC));
  end;
end;

procedure TDMAdminDataEntry.ActionPurposeExecute(Sender: TObject);
var
  s2, s3: string;
  Purpose: string;
begin
  inherited;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while not EOF do
    begin
      Purpose := FieldByName('Mpf Package Name').AsString;
      s2 := FieldByName('MpfApplication').AsString;
      s3 := FieldByName('MpfType').AsString;
      if s2 <> '' then
      begin
        if Purpose <> '' then
          Purpose := Purpose + '; ';
        Purpose := Purpose + s2;
      end;
      if s3 <> '' then
      begin
        if Purpose <> '' then
          Purpose := Purpose + '; ';
        Purpose := Purpose + s3;
      end;

      Edit;
      FieldByName('MpfPurpose').asString := Purpose;
      DMNexus.Stamp(DMNexus.TableAdmin, 'pur');
      Post;
      Next;
    end;
  end;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Purpose field is ready for use.');
end;

procedure TDMAdminDataEntry.ActLowercaseEMailExecute(Sender: TObject);
var
  ale: string;
  n: Integer;
begin
  inherited;
  n := 0;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while not EOF do
    begin
      ale := (FieldByName('Mpf EMail').AsString);
      if ale <> Lowercase(ale) then
      begin
        Edit;
        FieldByName('Mpf EMail').asString := Lowercase(ale);
        DMNexus.Stamp(DMNexus.TableAdmin, 'low');
        Post;
        Inc(n);
      end;
      Next;
    end;
  end;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Cleaned ' + IntToStr(n) + ' records');
end;

procedure TDMAdminDataEntry.ActNoAmpersandExecute(Sender: TObject);
var
  n: Integer;
  b: Boolean;
begin
  inherited;
  n := 0;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while not EOF do
    begin
      b := DMNexus.RecordNoAmpersand(DMNexus.TableAdmin);
      if b then
      begin
        DMNexus.Stamp(DMNexus.TableAdmin, 'amp');
        Post;
        Inc(n);
      end;
      Next;
    end;
  end;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Cleaned ampersands from ' + IntToStr(n) + ' records');
end;

procedure TDMAdminDataEntry.ActUpcaseStatusExecute(Sender: TObject);
var
  AStatus: string;
  n: Integer;
begin
  inherited;
  n := 0;
  with DMNexus.TableAdmin do
  begin
    Assert(NOT Filtered);
    First;
    while not EOF do
    begin
      AStatus := FieldByName('Mpf Status').AsString;
      if AStatus <> Uppercase(AStatus) then
      begin
        Edit;
        FieldByName('Mpf Status').asString := Uppercase(AStatus);
        Post;
        Inc(n);
      end;
      Next;
    end;
  end;
  if {M}Application.ApplicationMode = mtamApp then
    MsgInfoOk('Cleaned ' + IntToStr(n) + ' records');
end;

procedure TDMAdminDataEntry.WebCommandLineFrontDoorTriggered(
  Sender: TwhConnection; const ADesiredPageID: string;
  var bDoFrontDoorBounce: Boolean);
begin
  bDoFrontDoorBounce := (NOT pWebApp.IsWebRobotRequest) or
    (NOT SameText(aDesiredPageID, 'pgWebEye'));
end;

procedure TDMAdminDataEntry.ManPrefInit(Sender: TObject);
const cFn = 'ManPrefInit';
var
  dropletName: string;
begin
  CSEnterMethod(Self, cFn);
  inherited;
  with TwhdbScan(Sender) do
  begin
    // HtmlParam is used to differentiate one grid from another.
    // e.g. %=manPref.execute|Approved=%
    dropletName := 'Scan' + HtmlParam;
    WebApp.SendDroplet(dropletName, drBeforeWhrow);
  end;
  CSExitMethod(Self, cFn);
end;

procedure TDMAdminDataEntry.ManPrefRowStart(Sender:TwhdbScanBase;
  aWebDataSource:TwhdbSourceBase; var ok:Boolean);
begin
  inherited;
  with Sender do
    WebApp.SendDroplet('Scan'+HtmlParam, drWithinWhrow);
end;

procedure TDMAdminDataEntry.ManPrefExecute(Sender: TObject);
const cFn = 'ManPrefExecute';
var
  DropletKeyword: string;
begin
  CSEnterMethod(Self, cFn);
  inherited;
  CSSend('PageID', pWebApp.PageID);
  DropletKeyword := ManPref.HtmlParam;
  CSSend('DropletKeyword', DropletKeyword);
  if DropletKeyword = 'Maintain' then
    DMNexus.Table1OnlyMaintain
  else
    DMNexus.Table1OnlyApproved;
  //WebDBAlphabet.Execute;  // repeat the GotoNearest step after filter change!
  if Assigned(ManPref) and Assigned(ManPref.WebDataSource) then
    CSSend('DataSetIsActive', S(ManPref.WebDataSource.DataSetIsActive));
  CSExitMethod(Self, cFn);
end;

procedure TDMAdminDataEntry.ManPrefFinish(Sender: TObject);
begin
  inherited;
  with TwhdbScan(Sender) do
    WebApp.SendDroplet('Scan'+HtmlParam, drAfterWhrow);
end;

end.
