unit SetupEditPadForWebHub_uDownload;

// Copyright 2014-2017 HREF Tools Corp.

interface

function GetRTFResource(const inResName, SaveAsFilespec: string): Boolean;

function IsWHTekoFileTypeInstalled: Boolean;

function InstallLatestWebHubFiles(const FlagSyntax, FlagFileNav, FlagTools,
  FlagColor: Boolean): Boolean;

function InstallEditPadv7_Original_Ini: Boolean;
function InstallWebHubFileType: Boolean;
function InstallWebHubClipCollections: Boolean;
function InstallWHBridgeTools(WHBridgePath: string): Boolean;

function WGetFileNavigation: UTF8String;
function WGetSyntaxScheme(const JGCSCSIdentifier: string): UTF8String;

function FileTypeID: string;

implementation

uses
  Classes, SysUtils,
  Windows, IniFiles, Math,
  ZM_CodeSiteInterface, ZM_UTF8StringUtils,
  ucPos, ucString,
  SetupEditPadForWebHub_uPaths, uFileIO_Helper;

var
  SaveFileTypeID: string = '';

function FileTypeID: string;
const cFn = 'FileTypeID';
var
  IniFilespec: string;
  Ini: TMemIniFile;
  iFileID: Integer;
  FileTypesStr: string;
begin
  //CSEnterMethod(nil, cFn);
  Ini:= nil;
  Result := '-1';

  if SaveFileTypeID = '' then
  begin
    IniFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
      'EditPadPro7.ini';
    if FileExists(IniFilespec) then
    begin
      try
        Ini := TMemIniFile.Create(IniFilespec, TEncoding.UTF8);
        FileTypesStr := Ini.ReadString('Lite', 'FileTypes', '');
        iFileID := StrToIntDef(FileTypesStr, -1);
        if FileTypesStr = '' then
        begin
          CSSendError(cFn + ': FileTypesStr is not defined yet in ' +
            IniFilespec);
          // do not cache the answer because user might improve things.
        end
        else
        begin
          SaveFileTypeID := IntToStr(iFileID);  // default id -1 count 0
          Result := SaveFileTypeID;
        end;
        {$IFDEF DEBUG}
        CSSend(cFn + ': SaveFileTypeID', SaveFileTypeID);
        {$ENDIF}
      finally
        FreeAndNil(Ini);
      end;
    end
    else
      CSSendWarning(cFn + ': File does not exist: ' + IniFilespec);
  end
  else
    Result := SaveFileTypeID;
  //CSExitMethod(nil, cFn);
end;


function GetUTF8Resource(const inResName: string): UTF8String;
const cFn = 'GetUTF8Resource';
var
  res: TResourceStream;
  pTrg: PByte;
begin
  CSEnterMethod(nil, cFn);
  CSSend('inResName', inResName);
  res := nil;
  try
    res := TResourceStream.Create(HInstance, InResName, RT_RCDATA);
    res.Seek(0, soBeginning);
    CSSend('res.Size', S(res.Size));
    SetLength(Result, res.Size);
    pTrg := Addr(Result[1]);
    res.Read(pTrg^, res.Size);
    StripUTF8BOM(Result);
  finally
    FreeAndNil(res);
  end;
  //LogToCodeSiteKeepCRLF('Result', Copy(Result, 1, 1024));
  CSExitMethod(nil, cFn);
end;

function WGetSyntaxScheme(const JGCSCSIdentifier: string): UTF8String;
const cFn = 'WGetSyntaxScheme';
begin
  CSEnterMethod(nil, cFn);

  Result := GetUTF8Resource(Format('Resource_%s_JGCSCS', [JGCSCSIdentifier]));
  //LogToCodeSiteKeepCRLF('Result', Copy(Result, 1, 1024));
  CSExitMethod(nil, cFn);
end;

function WGetFileNavigation: UTF8String;
const
  cFn = 'WGetFileNavigation';
  cResourceIdentifier = 'Resource_JGFNS';
var
  Result16: string;
  Last2C: string;
  X, Y: Integer;
begin
  CSEnterMethod(nil, cFn);
  Result := GetUTF8Resource(cResourceIdentifier);
  // make sure 2 CRLF pairs at end of file
  Result16 := string(Result);
  X := Length(Result16);
  Y := 2 * Length(sLineBreak); // 4 on Windows, 2 on Linux: reminder.
  Last2C := Copy(Result16, X-Y, Y);
  LogToCodeSiteKeepCRLF('Last2C', Last2C);
  if Last2C <> sLineBreak + sLineBreak then
  begin
    CSSendWarning(cResourceIdentifier + ' lost trailing sLineBreak');
    Result := Result + sLineBreak;
  end
  else
    CSSendNote('confirming: ' + cResourceIdentifier +
      ' kept trailing sLineBreak');
  CSExitMethod(nil, cFn);
end;

function InstallLatestWebHubFiles(const FlagSyntax, FlagFileNav, FlagTools,
  FlagColor: Boolean): Boolean;
const cFn = 'InstallLatestWebHubFiles';
var
  LatestStr8: UTF8String;
  BakFilespec, TargetFilespec: string;
begin
  CSEnterMethod(nil, cFn);
  Result := InstallEditPadv7_Original_Ini;  // installs it if needed.
  if Result then
  begin
    if FlagSyntax then
    begin
      LatestStr8 := WGetSyntaxScheme('Syntax0214');
      TargetFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
        //EditPadPlusProgramInstallRoot) +
        'WebHub_' + 'Syntax0214' + '.jgcscs';
      CSSend('TargetFilespec', TargetFilespec);
      //CSSend('LatestStr8', Copy(string(LatestStr8), 1, 24));
      if FileExists(TargetFilespec) then
      begin
        BakFilespec := ChangeFileExt(TargetFilespec, '.bak');
        SysUtils.DeleteFile(BakFilespec);
        RenameFile(TargetFilespec, BakFilespec);
      end;
      UTF8StringWriteToFile(TargetFilespec, LatestStr8);
      // again for parentils
      LatestStr8 := WGetSyntaxScheme('Parentils');
      TargetFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
        'WebHub_' + 'Parentils' + '.jgcscs';
      CSSend('TargetFilespec', TargetFilespec);
      if FileExists(TargetFilespec) then
      begin
        BakFilespec := ChangeFileExt(TargetFilespec, '.bak');
        SysUtils.DeleteFile(BakFilespec);
        RenameFile(TargetFilespec, BakFilespec);
      end;
      UTF8StringWriteToFile(TargetFilespec, LatestStr8);
    end;

    if FlagFileNav then
    begin
      TargetFilespec := IncludeTrailingPathDelimiter(
        EditPadPlusDataRoot) + 'WebHub-FileNavigation.jgfns';
      CSSend('TargetFilespec', TargetFilespec);
      if FileExists(TargetFilespec) then
      begin
        BakFilespec := ChangeFileExt(TargetFilespec, '.bak');
        SysUtils.DeleteFile(BakFilespec);
        RenameFile(TargetFilespec, BakFilespec);
      end;
      LatestStr8 := WGetFileNavigation;
      UTF8StringWriteToFile(TargetFilespec, LatestStr8);
    end;

    if FlagTools then
    begin
      TargetFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
        cHREFToolsEPPToolsIniFilespec;
      CSSend('TargetFilespec', TargetFilespec);
      if FileExists(TargetFilespec) then
      begin
        BakFilespec := ChangeFileExt(TargetFilespec, '.bak');
        SysUtils.DeleteFile(BakFilespec);
        RenameFile(TargetFilespec, BakFilespec);
      end;
      LatestStr8 := GetUTF8Resource('Resource_Tools_Ini');
      StringWriteToAnsiWinFile(TargetFilespec, string(LatestStr8)); // Ansi
    end;

    if FlagColor then
    begin
      TargetFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
        cHREFToolsColorsIniFilespec;
      CSSend('TargetFilespec', TargetFilespec);
      if FileExists(TargetFilespec) then
      begin
        BakFilespec := ChangeFileExt(TargetFilespec, '.bak');
        SysUtils.DeleteFile(BakFilespec);
        RenameFile(TargetFilespec, BakFilespec);
      end;
      LatestStr8 := GetUTF8Resource('Resource_Colors_Ini');
      StringWriteToAnsiWinFile(TargetFilespec, string(LatestStr8)); // Ansi
    end;
  end;

  CSExitMethod(nil, cFn);
end;

function IsWHTekoFileTypeInstalled: Boolean;
const cFn = 'IsWHTekoFileTypeInstalled';
var
  IniFilespec: string;
  ini: TMemIniFile;
  FileTypeCount: Integer;
  FileMasks: string;
begin
  CSEnterMethod(nil, cFn);
  ini := nil;
  IniFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'EditPadPro7.ini';
  Result := False;
  if FileExists(IniFilespec) then
  begin
    try
      ini := TMemIniFile.Create(IniFilespec, TEncoding.UTF8);
      FileTypeCount := 0;
      while true do
      begin
        FileMasks := ini.ReadString('FT' + IntToStr(FileTypeCount), 'FileMasks',
          '');
        if FileMasks = '' then
          break;
        if PosCI('whteko', FileMasks) > 0 then
        begin
          CSSend('FileTypeCount', S(FileTypeCount));
          CSSend('FileMasks', FileMasks);
          Result := True;
          break;
        end;
        Inc(FileTypeCount);
      end;
    finally
      FreeAndNil(ini);
    end;
  end;

  CSSend('Result', S(Result));
  CSExitMethod(nil, cFn);
end;

function InstallEditPadv7_Original_Ini: Boolean;
const cFn = 'InstallEditPadv7_Original_Ini';
var
  IniFilespec: string;
  IniContent: string;
begin
  CSEnterMethod(nil, cFn);

  IniFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'EditPadPro7.ini';
  Result := FileExists(IniFilespec);
  if NOT Result then
  begin
    IniContent := string(GetUTF8Resource('EditPadPro7_Original_INI'));
    try
      StringWriteToAnsiWinFile(IniFilespec, IniContent);
    except
      on E: Exception do
      begin
        CSSendException(nil, cFn, E);  // e.g. directory does not exist.
        //Raise;
      end;
    end;
    Result := FileExists(IniFilespec);
  end;

  CSExitMethod(nil, cFn);
end;

function InstallWebHubFileType: Boolean;
const cFn = 'InstallWebHubFileType';
var
  Ini: TMemIniFile;
  IniFilespec: string;
  FileType33: string;
  NecessaryFileTypeStr: string;
  iFileTypeCount: Integer;
begin
  CSEnterMethod(nil, cFn);
  ini := nil;

  FileType33 := string(GetUTF8Resource('Resource_FT33')); // fixed FT number 33
  NecessaryFileTypeStr := FileTypeID;
  FileType33 := StringReplaceAll(FileType33, '[FT33]',
    Format('[FT%s]', [FileTypeID]));

  IniFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'EditPadPro7.ini';
  Result := FileExists(IniFilespec);
  if Result then
  begin
    StringAppendToAnsiWinFile(IniFilespec, sLineBreak + FileType33 +
      sLineBreak);

    try
      ini := TMemIniFile.Create(IniFilespec, TEncoding.UTF8);
      iFileTypeCount := StrToIntDef(FileTypeID, 0) + 1;
      ini.WriteInteger('Lite', 'FileTypes', iFileTypeCount);
      ini.UpdateFile;
      CSSend('[Lite] FileTypes', FileTypeID);
    finally
      FreeAndNil(ini);
    end;
  end
  else
    CSSendWarning('File not found: ' + IniFilespec);

  CSSend('Result', S(Result));
  CSExitMethod(nil, cFn);
end;

function InstallWebHubClipCollections: Boolean;
const cFn = 'InstallWebHubClipCollections';
var
  AtcFilespec, AtcFilespecDoubleDelim: string;
  ClipCommands: string;
  Ini: TMemIniFile;
  IniFilespec: string;
begin
  CSEnterMethod(nil, cFn);

  Result := False;
  ClipCommands := string(GetUTF8Resource('Resource_Clip_Commands'));
  AtcFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'WebHub_Commands_ClipCollection.atc';
  StringWriteToAnsiWinFile(AtcFilespec, ClipCommands);

  IniFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'EditPadPro7.ini';
  if FileExists(IniFilespec) then
  try
    AtcFilespecDoubleDelim := StringReplaceAll(AtcFilespec, PathDelim,
      PathDelim + PathDelim);
    ini := TMemIniFile.Create(IniFilespec, TEncoding.UTF8);
    ini.WriteString('FT' + FileTypeID, 'ClipCollection',
      AtcFilespecDoubleDelim);
    ini.UpdateFile;
    Result := True;
  finally
    FreeAndNil(ini);
  end;

  ClipCommands := string(GetUTF8Resource('Resource_Clip_Objects'));
  AtcFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'WebHub_Objects_ClipCollection.atc';
  StringWriteToAnsiWinFile(AtcFilespec, ClipCommands);

  CSExitMethod(nil, cFn);
end;

function InstallWHBridgeTools(WHBridgePath: string): Boolean;
const cFn = 'InstallWHBridgeTools';
var
  IniFilespec: string;
  WHBridgeTools: string;
  iniTrg: TMemIniFile;
  ACommandLine: string;
  bContinue: Boolean;
  iTool: Integer;
  iStartedWithToolCount: Integer;
  iErasedToolsCount: Integer;
const
  nTools = 5;  // 4.Feb.2015
begin
  CSEnterMethod(nil, cFn);

  iniTrg := nil;
  WHBridgeTools := string(GetUTF8Resource('Resource_Tools_Ini'));

  WHBridgePath := StringReplaceAll(WHBridgePath, PathDelim, PathDelim +
    PathDelim);
  CSSend('WHBridgePath', WHBridgePath);

  WHBridgeTools := StringReplaceAll(WHBridgeTools,
    '""C:\\WebHub_v3\\bin\\WHBridge2EditPad.exe"',
    Format('""%sWHBridge2EditPad.exe"', [WHBridgePath]));
  CSSend('WHBridgeTools', WHBridgeTools);

  IniFilespec := IncludeTrailingPathDelimiter(EditPadPlusDataRoot) +
    'EditPadPro7.ini';

  bContinue := FileExists(IniFilespec);
  if bContinue then
  begin
    iErasedToolsCount := 0;
    try
      iniTrg := TMemIniFile.Create(IniFilespec, TEncoding.UTF8);
      iStartedWithToolCount := iniTrg.ReadInteger('Pro', 'ToolCount', 0);
      if iStartedWithToolCount = 0 then
      begin
        iniTrg.WriteInteger('Pro', 'ToolCount', nTools);
        iniTrg.UpdateFile;
      end;
      for iTool := 0 to Pred(Max(iStartedWithToolCount, nTools)) do
      begin
        if bContinue then
        begin
          if iniTrg.SectionExists('Tool' + IntToStr(iTool)) then
          begin
            ACommandLine := Lowercase(iniTrg.ReadString('Tool' + IntToStr(iTool),
              'CommandLine', ''));
            if PosCI('whbridge2editpad.exe', ACommandLine) > 0 then
            begin
              CSSend('Erasing tool ' + S(iTool), ACommandLine);
              iniTrg.EraseSection('Tool' + IntToStr(iTool));
              Inc(iErasedToolsCount);
              iniTrg.UpdateFile;
            end
            else
              bContinue := False;
          end;
        end;
      end;
      if (iErasedToolsCount > 0) and (iStartedWithToolCount > 3) then
      begin
        if (iErasedToolsCount <> 3) then
        begin
          iniTrg.WriteInteger('Pro', 'ToolCount',
            iStartedWithToolCount - iErasedToolsCount + nTools);
          iniTrg.UpdateFile;
          CSSend('ToolCount fixed',
            S(iStartedWithToolCount - iErasedToolsCount + nTools));
        end;
      end;

    finally
      FreeAndNil(iniTrg);
    end;

    if bContinue then
      StringAppendToAnsiWinFile(IniFilespec,
        sLineBreak + WHBridgeTools + sLineBreak)
    else
      CSSendWarning('bContinue went False');
  end
  else
    CSSendWarning('File not found: ' + IniFilespec);
  Result := bContinue;
  CSSend('Result', S(Result));
  CSExitMethod(nil, cFn);
end;

function GetRTFResource(const inResName, SaveAsFilespec: string): Boolean;
const cFn = 'GetRTFResource';
var
  res: TResourceStream;

begin
  CSEnterMethod(nil, cFn);
  CSSend('inResName', inResName);
  res := nil;
  try
    res := TResourceStream.Create(HInstance, InResName, RT_RCDATA);
    res.SaveToFile(SaveAsFilespec);
    Result := FileExists(SaveAsFilespec);
  finally
    FreeAndNil(res);
  end;
  CSExitMethod(nil, cFn);
end;


end.
