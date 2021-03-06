unit whdemo_ViewSource;        { Display .dfm and .pas files over the web for use on http://lite.demos.href.com }

{ ---------------------------------------------------------------------------- }
{ * Copyright (c) 1998-2017 HREF Tools Corp.                                 * }
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


{ To configure the "View Source" feature to use a root folder other than
  c:\Projects\webhubdemos\

  add

  <Product name="WebHubDemos" folder="d:\YourPath\Projects\WebHubDemos" />

  to your WebHubInstallationConfig.xml file which can be found using ZMAdmin,
  ZM Configuration, go into branch HREFTools\Install. View the ZMKeybox.
  On the right side, look for

    KeyGroup = WebHub
    Keys = Install

  There you can EDIT the WebHubInstallationConfig.xml file.
}

interface

uses
  Windows, Messages, SysUtils, Classes,
  tpaction, updateok,
  webTypes, webLink;

type
  TDemoViewSource = class(TDataModule)
    waDemoViewSource: TwhWebActionEx;
    waDemoViewSourcePascalFile: TwhWebActionEx;
    waDemoViewSourceWHTMLFile: TwhWebActionEx;
    waDemoViewSourceWHTMLFileList: TwhWebActionEx;
    waDemoViewSourceProjectLink: TwhWebActionEx;
    procedure waDemoViewSourceExecute(Sender: TObject);
    procedure waDemoViewSourcePascalFileExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure waDemoViewSourceWHTMLFileExecute(Sender: TObject);
    procedure waDemoViewSourceWHTMLFileListExecute(Sender: TObject);
    procedure waDemoViewSourceProjectLinkExecute(Sender: TObject);
    procedure waDemoViewSourceSetCommand(Sender: TObject;
      var ThisCommand: string);
  private
    { Private declarations }
    fpaslist: TStringlist;
    fformlist: Tstringlist;
    foutputlist: TStringlist;
    ftemplist: TStringlist;
    fProjectFilename: String;
    fDelphiSourcePath: String;
    function GetWHTMLFilename(const i: Integer): string;
    function isEndOfUses(a1: string): Boolean;
    //function isInCurrentForm(aClassname: string): Boolean;
  public
    { Public declarations }
    property DelphiSourcePath: string read fDelphiSourcePath
      write fDelphiSourcePath;
  end;

var
  DemoViewSource: TDemoViewSource = nil;
  IsDemoRootKnown: Boolean;

function getWebHubDemoInstallRoot: string;
function getHtDemoCodeRoot: string;     // default is c:\projects\WebHubDemos\Source\WhApps\
function getHtDemoDataRoot: string;     // default is c:\projects\WebHubDemos\Live\Database\
function getHtDemoWWWRoot: string;      // default is c:\projects\WebHubDemos\Live\WebRoot\

procedure whDemoSetDelphiSourceLocation(const Path: String;
  const isRelativePath: Boolean);

implementation

{$R *.DFM}

uses
  Forms,
  ZaphodsMap,
  ZM_CodeSiteInterface,
  whutil_ZaphodsMap, webApp, whMacroAffixes, htStream,
  htmlBase,      // PrologueMode property
  ucDlgs, ucLogFil, ucString;

//----------------------------------------------------------------------

procedure whDemoSetDelphiSourceLocation(const Path: String;
  const isRelativePath: Boolean);
const cFn = 'whDemoSetDelphiSourceLocation';
begin
  CSEnterMethod(nil, cFn);
  if Assigned(DemoViewSource) then
  begin
    if isRelativePath then
      DemoViewSource.DelphiSourcePath := getHtDemoCodeRoot + Path + PathDelim +
        ChangeFileExt(ExtractFileName(ParamStr(0)),'') + PathDelim
    else
      { Make it relatively easy for projects other than the WebHub demos to use
        the view-source capability... they just set their own absolute path to
        source here. }
      DemoViewSource.DelphiSourcePath := Path;
  end;
  CSExitMethod(nil, cFn);
end;

function getWebHubDemoInstallRoot: string;
const cFn = 'getWebHubDemoInstallRoot';
var
  HREFInstallBranch: string;
  Warning: string;
begin
  Result := '';

  HREFInstallBranch := 'HREFTools' + PathDelim + 'Install';

  Result := ZaphodKeyedFileZNodeAttr(HREFInstallBranch, cWebHubKeyGroupName,
    cWebHubInstallKeyName, cWebHubInstallConfigRootName,
    ['InstallFolders/Product[@name="WebHubDemos"]'], cxOptional, usrNone,
    'folder', 'D:\projects\WebHubDemos\', Warning);
  if Warning = '' then
  begin
    IsDemoRootKnown := True;
    Result := IncludeTrailingPathDelimiter(Result);
  end
  else
    LogSendWarning(cFn + ': ' + Warning);
end;

function getHtDemoCodeRoot: String;
begin
  Result := getWebHubDemoInstallRoot + 'Source\WhApps\';
end;

//----------------------------------------------------------------------

function getHtDemoDataRoot: String;
begin
  Result := getWebHubDemoInstallRoot + 'Live\Database\';
end;

//----------------------------------------------------------------------

function getHtDemoWWWRoot: String;
begin
  Result := getWebHubDemoInstallRoot + 'Live\WebRoot\';
end;

//----------------------------------------------------------------------

procedure TDemoViewSource.DataModuleCreate(Sender: TObject);
const cFn = 'DataModuleCreate';
begin
  CSEnterMethod(Self, cFn);
  IsDemoRootKnown := False;
  fProjectFilename := ChangeFileExt(ExtractFilename(Paramstr(0)), '.dpr');
  fpaslist := TStringList.Create;
  fformlist := TStringList.Create;
  foutputlist := TStringList.Create;
  ftemplist := TStringList.Create;
  CSExitMethod(Self, cFn);
end;

//------------------------------------------------------------------------------

procedure TDemoViewSource.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(ftemplist);
  FreeAndNil(fpaslist);
  FreeAndNil(foutputlist);
  FreeAndNil(fFormlist);
  DemoViewSource := nil;
end;

// -----------------------------------------------------------------------------

procedure TDemoViewSource.waDemoViewSourceExecute(Sender: TObject);
const cFn = 'waDemoViewSourceExecute';
var
  aUnitName: string;
  a1, a2, a3, a4 : string;
  aTemp, aCurrentLine, aHyperLine: string;
  i: Integer;
  bOk: Boolean;
begin
  CSEnterMethod(Self, cFn);

  begin

    if NOT IsDemoRootKnown then
    begin
      TwhWebActionEx(Sender).WebApp.SendStringImm(
        'Error: the root folder for webhubdemos has not been configured.');
    end
    else
    begin

      // calculate every time so this works multi-surfer.
      foutputlist.clear;
      with ftemplist do
      begin
        Clear;
        if FileExists(DelphiSourcePath+fProjectFilename) then
          LoadFromFile(DelphiSourcePath+fProjectFilename);
        bOK:=True;
        for i:=0 to pred(Count) do
        begin
          if NOT bOK then break;
          aCurrentLine:=strings[i];
          aHyperLine:=aCurrentLine;   // might not need any changes.
          bOK:=(i=0) or NOT isEndOfUses(aCurrentLine);
          //
          if i=0 then
          begin
            // link project filename to display of self
            SplitThree(aCurrentLine,' ',a1,a2,a3);  // program aunit; //comment
            aHyperLine :=
              Format('%s %sJUMP|%sPageID%s,waDemoViewSource.%s|%s%s; %s',
                [a1, MacroStart, MacroStart, MacroEnd, fProjectFilename,
                 fProjectFilename, MacroEnd, a3]);
          end;
          if copy(aCurrentLine,1,2)='//' then
          begin
            aHyperLine:='';
            continue;  // skip over comment lines when displaying the uses clause.
          end;
          if splitstring(aCurrentLine,' in ''',a1,a2) then
          begin
            a1 := Trimboth(a1);
            if (splitstring(a2,'},',a3,a4)) or (splitstring(a2,'};',a3,a4)) then
            begin
              aTemp:=leftof('''',a2);         // e.g. c:\ht\lib32\utPanForm.pas
              aTemp:=a1 + cEq + aTemp;
              fPaslist.Add(aTemp);
              aTemp:=rightof('{',a3);         // e.g. utParentForm
                fformlist.Add(a1 + cEq + aTemp);
              aHyperLine := '  ' + a1 + ' in ' + MacroStart+'Jump|' + MacroStart +
                'PageID' + MacroEnd + ',waDemoViewSource.'
                 + TwhWebActionEx(Sender).Command
                 + ',waDemoViewSourcePascalFile.' + a1 + '|' + leftof('{', a3)
                 + MacroEnd + '  ';
              aHyperLine:=aHyperLine+'{' + MacroStart + 'Jump|' + MacroStart +
                 'PageID' + MacroEnd + ',waDemoViewSource.'
                 + TwhWebActionEx(Sender).Command +
                 ',waDemoViewSourcePascalFile.form!' + a1 + '|'
                 + rightof('{',a3) + MacroEnd + '}'
                ;
              if bOK then
                aHyperLine:=aHyperLine+','
              else
                aHyperLine:=aHyperLine+';';
            end
            else
            begin
              aUnitName:=a1;
              aTemp:=aUnitName + cEq + leftof('''',a2);
              fPaslist.Add(aTemp);
              fformlist.Add(aUnitName + cEq);
              aHyperLine := '  ' + aUnitName + ' in ' + MacroStart + 'Jump|' +
                MacroStart + 'PageID' + MacroEnd + ',waDemoViewSource.'
                 + TwhWebActionEx(Sender).Command +
                 ',waDemoViewSourcePascalFile.' + aUnitName + '|'
                 + a2 + MacroEnd;
            end;
          end;
          if aHyperLine<>'' then
            foutputlist.add(aHyperLine);  // hypertext version
          end;
        end;
        TwhWebActionEx(Sender).WebApp.Response.SendStringListNoBR(foutputlist);
      end;
    end;
  CSExitMethod(Self, cFn);
end;

function fixFilename(const aProjectPath,aFilespec:string):string;
begin
  Result:=aFilespec;
  if copy(aFilespec,2,1)=':' then
    // do not add in the path
  else if copy(aFilespec,1,2)='\\' then
    // do not add in the path
  else if copy(aFilespec,1,1)='\' then
    // just add in the drive letter
    Result:=Copy(aProjectPath,1,1)+':'+aFilespec
  else
    Result:=aProjectPath+aFilespec;
end;

procedure TDemoViewSource.waDemoViewSourcePascalFileExecute(Sender: TObject);
const cFn = 'waDemoViewSourcePascalFileExecute';
var
  a1,a2: string;
  aFilename, aShowName: string;
  aFileContents: string;
  InfoMsg: string;
begin
  CSEnterMethod(Self, cFn);
  inherited;
  with TwhWebActionEx(Sender) do
  begin
    a1 := DelphiSourcePath;
    if a1='' then
    begin
      with Response do
      begin
        SendHdr('2','Error');
        Send('Full source viewing has not been configured. Required property, '+
        '"DelphiSourcePath", is blank.');
      end;
    end
    else
    begin
      a1:=command;
      if a1 = '' then
      begin
        aFilename:=rightof('.',webapp.command);
        aShowname:=aFilename;
        aFilename:=fixFilename(DelphiSourcePath,aFilename);
        if NOT FileExists(aFilename) then
        begin
          Response.SendHdr('2','Error');
          InfoMsg := 'File does not exist: ' + aFilename;
          Response.Send(InfoMsg);
          CSSendError(InfoMsg + #183 +
            ' or garbage command');
          Response.Send('; DelphiSourcePath is ' + DelphiSourcePath);
          Exit;
        end
        else
        begin
          aFileContents := StringLoadFromFile(aFilename);
          if aFileContents = '' then
          begin
            CSSendWarning('Empty source? ' + aFilename);
            pWebApp.Debug.AddPageError('Empty source? ' + aFilename);
          end;
        end;
      end
      else
      if not splitstring(command,'form!',a1,a2) then
      begin
        // This is a .pas or .dcu file.
        aFilename:=fpaslist.values[command];
        aFilename:=fixFilename(DelphiSourcePath,aFilename);
        //aShowName:=command;
        aShowName := ExtractFilename(aFilename);
        if not fileExists(aFilename) then
          aFileContents:='Source is not available here for ' + aFilename + '.'
        else
        begin
          aFileContents := StringLoadFromFile(aFilename);
          if aFileContents = '' then
          begin
            CSSendWarning('Empty source? ' + aFilename);
            pWebApp.Debug.AddPageError('Empty source? ' + aFilename);
          end;
        end;
      end
      else
      begin
        aShowName:=a2+'.dfm';
        SplitString(uppercase(fPasList.values[a2]),'.PAS',a1,a2);
        aFilename:=a1+'.dfm';
        aFilename:=fixFilename(DelphiSourcePath,aFilename);
        if NOT FileExists(aFilename) then
        begin
          Response.SendHdr('2','Error');
          InfoMsg := 'DFM File does not exists: ' + aFilename;
          Response.Send(InfoMsg);
          CSSendError(InfoMsg + #183 +
            ' or garbage command');
          Response.Send('; DelphiSourcePath is ' + DelphiSourcePath);
          Exit;
        end
        else
        begin
          try
            aFileContents := htFormFileToString(aFilename);
          except
            on E: Exception do
            begin
              // modern DFM files are no longer binary so this is expected....
              if (E.Message <> 'Invalid stream format') then
              begin
                CSSendException(Self, cFn, E);
                CSSendError('when loading ' + aFilename);
                pWebApp.Debug.AddPageError(E.Message);
              end;
              aFileContents:= StringLoadfromfileDef(aFilename, '');
            end;
          end;
        end;
      end;
      with Response do
      begin
        SendLine('<h1>Full Source to '+aShowname+'</h1>');
        SendLine('<form>');
        SendLine('<textarea name="" cols="80" rows="30">');
        pWebApp.SendStringImm(aFileContents);
        SendLine('</textarea>');
        SendLine('</form>');
      end;
    end;
  end;
  CSExitMethod(Self, cFn);
end;

function TDemoViewSource.isEndOfUses(a1: String): boolean;
var
  iSemi,iComm :integer;
begin
  result:=false;
  iSemi := pos(';',a1);
  iComm := pos('//',a1);
  if (iSemi>0) and
     ((iComm=0) or (iComm>iSemi)) then
     result:=true;
end;

(*function TDemoViewSource.isInCurrentForm(aClassname:string):boolean;
var
  i,n:integer;
begin
  result:=False;
  n := Screen.FormCount;
  if aClassname[1] <> 'T' then
    aClassname := 'T' + aClassname;
  for i:=0 to pred(n) do
    if lowercase(Screen.Forms[i].ClassName)=lowercase(aClassname) then
    begin
      result:=True;
      break;
    end;
end;*)

function TDemoViewSource.GetWHTMLFilename(const i: Integer): String;
var
  w: Word;
  FileExt: String;
begin
  Result := RightOfEqual(pWebApp.TekoFiles[i]);
  w := pos(',',Result);  // possible data after filename, e.g. f1=file1.wh,reset=x
  if (w > 0) then
    Result := Copy(Result,1,w-1);
  {W-HTML files with no stated extension are considered to have .HTM extension.}
  FileExt := ExtractFileExt(Result);
  if FileExt = '' then
    Result := Result + '.htm';
end;

{ Generate the list of W-HTML Files; first the INI file, then the others }
procedure TDemoViewSource.waDemoViewSourceWHTMLFileListExecute(
  Sender: TObject);
var
  i: Integer;

  procedure SendDottedFileLink(const idx: Integer; const VisPhrase: String);
  begin
    with pWebApp do
    begin
      SendMacro('mcGlobalDot');
      SendStringImm(' ');
      SendMacro('JUMP|ViewWHTMLFile,' + IntToStr(idx) + '|' + VisPhrase);
      SendStringImm('<br />');
    end;
  end;

begin
  with TwhWebActionEx(Sender) do
  begin
    { display a link to the application-level config file}
    SendDottedFileLink(-1, ExtractFilename(WebApp.WebAppKey.KeyedFileName));

    { display links for all files in the TwhAppBase.Files list}
    for i:= 0 to pred(WebApp.TekoFiles.Count) do
      SendDottedFileLink(i,GetWHTMLFileName(i));
  end;
end;

{ Display a given W-HTML file inside a TEXTAREA so that macros do not expand,
  and code can be copied+pasted easily }
procedure TDemoViewSource.waDemoViewSourceWHTMLFileExecute(Sender: TObject);
var
  i, n: Integer;
  S: string;
  S8: System.UTF8String;
  InfoMsg: string;

  procedure SendFileIntro(const fileDescription: String);
  begin
    with pWebApp do
    begin
      SendMacro('mcHdrOn');
      SendString(Format('Contents of %s', [fileDescription]));
      SendMacro('mcHdrOff');
    end;
  end;

begin
  with TwhWebActionEx(Sender) do
  begin
    i := StrToIntDef(WebApp.Command,-99);
    if i = -1 then
    begin
      S := WebApp.WebAppKey.KeyedFileName;
      SendFileIntro('application-level config file');
      CSSend('WebApp.WebAppKey.KeyedFileName', S);
    end
    else
    begin
      n := pred(WebApp.TekoFiles.Count);
      if (i < 0) or (i>n) then
      begin
        Response.Send('Invalid request for W-HTML File #'+WebApp.Command);
        exit;
      end;
      {$IFNDEF CONFIGZAPHOD}
      S := ExtractFilePath(WebApp.ConfigFilespec) + GetWHTMLFilename(i);
      {$ELSE}
      S := WebApp.WebAppKey.KeyedFilePath + GetWHTMLFilename(i);
      {$ENDIF}
      SendFileIntro(GetWHTMLFilename(i));
    end;
    if FileExists(S) then
    begin
      with Response do
      begin
        SendLine('<form>');
        SendLine('<textarea name="" cols=80 rows=30>');
        S8 := UTF8StringLoadFromFile(S);
        Response.Stream.WriteS(UTF8ToString(S8));
        SendLine('</textarea>');
        SendLine('</form>');
      end;
    end
    else
    begin
      InfoMsg := 'File #' + WebApp.Command + ' not found.';
      CSSendWarning(InfoMsg);
      Response.Send(InfoMsg);
      Response.SendComment(S);
    end;
  end;
end;

procedure TDemoViewSource.waDemoViewSourceProjectLinkExecute(
  Sender: TObject);
var
  S: string;
begin
  with TwhWebActionEx(Sender) do
  begin
    S := Format('JUMP|viewDelphiFile,waDemoViewSource.%s|%s',
      [fProjectFilename, fProjectFilename]);
    WebApp.SendMacro(S);
  end;
end;

procedure TDemoViewSource.waDemoViewSourceSetCommand(Sender: TObject;
  var ThisCommand: string);
const cFn = 'waDemoViewSourceSetCommand';
var
  InfoMsg: string;
begin
  if (ThisCommand = '') or IsEqual(ThisCommand, FProjectFilename) then
  begin
    // all is well - normal
  end
  else
  begin
    LogSendWarning(cFn + #183 + Self.ClassName+' bot overload');
    LogSendInfo(pWebApp.Request.QueryString);
    LogSendError('ThisCommand' + #183 + ThisCommand);
    ThisCommand := '';
    InfoMsg := 'Invalid URL';
    CSSendError(InfoMsg);
    raise Exception.Create(InfoMsg);
  end;
end;

end.
