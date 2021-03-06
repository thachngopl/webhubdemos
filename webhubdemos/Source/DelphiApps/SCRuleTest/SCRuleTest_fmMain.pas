unit SCRuleTest_fmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ldi.RegEx.RegularExpressions, Vcl.Menus;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    MemoMacros: TMemo;
    GroupBox2: TGroupBox;
    MemoRegex: TMemo;
    GroupBox3: TGroupBox;
    MemoURLs: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    GroupBox4: TGroupBox;
    MemoMatched: TMemo;
    GroupBox5: TGroupBox;
    MemoExpandedRegex: TMemo;
    Splitter1: TSplitter;
    MemoMatchCount: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    Splitter2: TSplitter;
    iming1: TMenuItem;
    mi1000x: TMenuItem;
    mi10000x: TMenuItem;
    m1x: TMenuItem;
    m1000000x: TMenuItem;
    m100000x: TMenuItem;
    FileOpenDialog1: TFileOpenDialog;
    Open2: TMenuItem;
    FileSaveDialog1: TFileSaveDialog;
    Exit1: TMenuItem;
    LoadDefaults1: TMenuItem;
    Splitter3: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure mi10000xClick(Sender: TObject);
    procedure mi1000xClick(Sender: TObject);
    procedure m1xClick(Sender: TObject);
    procedure m1000000xClick(Sender: TObject);
    procedure m100000xClick(Sender: TObject);
    procedure Open2Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure LoadDefaults1Click(Sender: TObject);
  strict private
    { Private declarations }
    FRegEx: TldiRegExMulti;
    FIterationHigh: Integer;
    FAbbrev: string;
    function TestDataRegexFilespec: string;
    function TestDataURLsFilespec: string;
    function LoadDefaultMacros: Boolean;
    function LoadDefaultRegex: Boolean;
    function LoadDefaultURLs: Boolean;
    function LoadDefaults: Boolean;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses
  ucDlgs, ucString, ucLogFil, ucMsTime;

const
  cAppTitle = 'StreamCatcher / WebHub Rule Tester';

procedure TForm3.Button1Click(Sender: TObject);
var
  bContinue: Boolean;
  S1: string;
  APattern8: UTF8String;
  i: Integer;
  MacroName, MacroValue: string;
  iPattern: Integer;
  PatternStatus: TPatternStatus;
  MatchResult: TMatchResult;
  S8: UTF8String;
  b2: Boolean;
  j: Integer;
  iteration: Integer;
  StartOnAt: Cardinal;
  StopOnAt: Cardinal;
  ElapsedMS: Cardinal;
  MsPerEach: Extended;
begin
  MemoMatched.Clear;
  MemoExpandedRegex.Clear;
  MemoMatchCount.Clear;
  MatchResult := nil;
  StartOnAt := 0;
  StopOnAt := 0;
  bContinue := MemoRegex.Lines.Count > 0;

  if bContinue then
  begin
    if FIterationHigh > 1 then
    begin
      bContinue := AskQuestionYesNo(Format(
        'Test %d iterations against %d URLs?', [FIterationHigh,
          MemoURLs.Lines.Count]));
      if bContinue then
      begin
        MemoUrls.Visible := False;  // avoid screen painting while timing
        Self.Update;
      end;
    end
  end;

  if bContinue then
  for i := Pred(MemoURLs.Lines.Count) downto 1 do
  begin
    MemoURLs.Lines[i] := Trim(MemoURLs.Lines[i]);
    if MemoURLs.Lines[i] = '' then
      MemoURLs.Lines.Delete(i);
  end;

  if bContinue then
  try
    S1 := Trim(MemoRegex.Lines.Text);
    for i := 0 to Pred(MemoMacros.Lines.Count) do
    begin
      if SplitString(MemoMacros.Lines[i], '=', MacroName, MacroValue) then
        S1 := StringReplaceAll(S1, MacroName, MacroValue);
    end;
    MemoExpandedRegex.Lines.Text := S1;
    APattern8 := UTF8String(S1);

    bContinue := FRegEx.AddPattern8(APattern8, iPattern, PatternStatus,
        [poDotMatchesAll] {i.e. NOT poIgnoreCase});
  except
    on E: Exception do
    begin
      MemoMatched.Lines.Text := E.Message;
      bContinue := False;
    end;
  end;

  if bContinue then
  begin
    try
      MatchResult := TMatchResult.Create;
      StartOnAt := GetTickCount;
      for iteration := 1 to FIterationHigh do
      begin
        for i := 0 to Pred(MemoURLs.Lines.Count) do
        begin
          s8 := UTF8String(MemoURLs.Lines[i]);
          b2 := FRegEx.Match8(iPattern, MatchResult, S8);
          if (FIterationHigh = 1) then
            MemoMatchCount.Lines.Add(
              Format('GroupCount =%4d', //BoolToStr(b2, True),
                [MatchResult.GroupCount]));
          if (FIterationHigh = 1) and (i=0) and b2 then
          begin
            for j := 0 to Pred(MatchResult.GroupCount) do
            begin
              MemoMatched.Lines.Add(Format('Group%4d%s%s',
                [j, #9#9, MatchResult.GroupValue8(j)]));
            end;
          end;
        end;
      end;
      StopOnAt := GetTickCount;
    finally
      FreeAndNil(MatchResult);
    end;
  end
  else
    MemoMatched.Lines.Add('bContinue False');

  if bContinue then
  begin
    if FIterationHigh > 1 then
    begin
      ElapsedMS := ucMsTime.ElapsedMilliSecondsBetween(StartOnAt, StopOnAt);
      MsPerEach := ((ElapsedMS / FIterationHigh) / MemoURLs.Lines.Count);
      MemoMatched.Lines.Add(Format(
      '%d Iterations through %d URLs took %d milliseconds, thus %10.6f ms each.',
        [FIterationHigh, MemoUrls.Lines.Count, ElapsedMS, MsPerEach]));
    end;
  end;
  MemoUrls.Visible := True;
  Self.Update;
end;

procedure TForm3.Exit1Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  FRegEx := TldiRegExMulti.Create(Self);
  FIterationHigh := 1;
  FAbbrev := '(default)';
  Self.Height := Screen.WorkAreaHeight - 100;
  Self.Width := Screen.WorkAreaWidth - 100;
  Self.Caption := cAppTitle + ' ' + FAbbrev;
  Position := poDesktopCenter;
  FileOpenDialog1.DefaultFolder := ExtractFilePath(ParamStr(0));
  FileOpenDialog1.DefaultExtension := '*.swrt';
  FileSaveDialog1.DefaultFolder := ExtractFilePath(ParamStr(0));
  FileSaveDialog1.DefaultExtension := '*.swrt';
  LoadDefaults;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FRegex);
end;

function TForm3.LoadDefaultMacros: Boolean;
begin
  MemoMacros.Clear;
  MemoMacros.Lines.Add('�lingvo�=([a-z]{2,3}(-[a-z]{2})?)');
  MemoMacros.Lines.Add('�lingvow�=(([a-z]{2,3}(-[a-z]{2})?)/)');
  MemoMacros.Lines.Add('�appid�=(adv|demos|htun)');
  MemoMacros.Lines.Add('�pageid�=([a-zA-Z][^:/?-]{0,34})');
  MemoMacros.Lines.Add('�sessionid�=([0-9]+(\.[0-9]+)?)');
  MemoMacros.Lines.Add('�command�=([^?]*)');
  MemoMacros.Lines.Add('�seotail�=(.*)');
  Result := True;
end;

function TForm3.LoadDefaultRegex: Boolean;
begin
  MemoRegex.Lines.Text :=
    '^(/)?�lingvow�?�appid�?[:/]{0,1}�pageid�?([:/]�sessionid�?([:/]�command�)?)?(\?�seotail�)?$';
  Result := True;
end;

function TForm3.LoadDefaults: Boolean;
begin
  MemoMatched.Clear;
  MemoExpandedRegex.Clear;
  MemoMatchCount.Clear;
  MemoRegex.Clear;
  MemoURLs.Clear;
  Result := LoadDefaultMacros and LoadDefaultRegex and LoadDefaultURLs;
end;

procedure TForm3.LoadDefaults1Click(Sender: TObject);
begin
  LoadDefaults;
end;

function TForm3.LoadDefaultURLs: Boolean;
begin
  MemoURLs.Clear;
  MemoURLs.Lines.Add('/demos:pgwelcome');
  MemoURLs.Lines.Add('/adv:pgwelcome');
  MemoURLs.Lines.Add('/adv:pgenteradv:2000');
  MemoURLs.Lines.Add('/adv:pgenteradv:2000:grid1.next');
  MemoURLs.Lines.Add('/adv:pgwelcome?gclid=34');
  MemoURLs.Lines.Add('/eng/demos:pgwelcome');
  Result := True;
end;

procedure TForm3.m1000000xClick(Sender: TObject);
begin
  FIterationHigh := 1000 * 1000;
  if Sender is TMenuItem then
    TMenuItem(Sender).Checked := True;
  MsgWarningOk('Expect a LONG delay to test a million iterations');
end;

procedure TForm3.m100000xClick(Sender: TObject);
begin
  FIterationHigh := 100 * 1000;
  if Sender is TMenuItem then
    TMenuItem(Sender).Checked := True;
end;

procedure TForm3.m1xClick(Sender: TObject);
begin
  FIterationHigh := 1;
  if Sender is TMenuItem then
    TMenuItem(Sender).Checked := True;
end;

procedure TForm3.mi10000xClick(Sender: TObject);
begin
  FIterationHigh := 10 * 1000;
  if Sender is TMenuItem then
    TMenuItem(Sender).Checked := True;
end;

procedure TForm3.mi1000xClick(Sender: TObject);
begin
  FIterationHigh := 1000;
  if Sender is TMenuItem then
    TMenuItem(Sender).Checked := True;
end;

function TForm3.TestDataRegexFilespec: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + FAbbrev + '.swrt';
end;

function TForm3.TestDataURLsFilespec: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + FAbbrev + '_urls.ini';
end;

function RegexMacrosFilespec: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'SCRuleTest_Macros.ini';
end;

procedure TForm3.Open2Click(Sender: TObject);
var
  ChosenFilespec: string;
begin
  MemoMatched.Clear;
  MemoExpandedRegex.Clear;
  MemoMatchCount.Clear;

  if FileOpenDialog1.Execute then
  begin
    ChosenFilespec := FileOpenDialog1.FileName;
    FAbbrev := ExtractFileNameNoExt(ChosenFilespec);
    if FileExists(RegexMacrosFilespec) then
      MemoMacros.Lines.Text := StringLoadFromFile(RegexMacrosFilespec)
    else
    begin
      Beep;
      LoadDefaultMacros;
    end;
    if FileExists(ChosenFilespec) then
      MemoRegex.Lines.Text := StringLoadFromFile(ChosenFilespec)
    else
    begin
      Beep;
      LoadDefaultRegex;
    end;
    if FileExists(TestDataURLsFilespec) then
      MemoURLs.Lines.Text := StringLoadFromFile(TestDataURLsFilespec)
    else
    begin
      Beep;
      LoadDefaultURLs;
    end;
  end;
end;

procedure TForm3.Save1Click(Sender: TObject);
var
  ChosenFilespec: string;
begin
  FileSaveDialog1.Filename := FAbbrev + '.swrt';
  if FileSaveDialog1.Execute then
  begin
    ChosenFilespec := FileSaveDialog1.FileName;
    FAbbrev := ExtractFileNameNoExt(ChosenFilespec);
    StringWriteToFile(RegexMacrosFilespec,   MemoMacros.Lines.Text);
    StringWriteToFile(TestDataRegexFilespec, MemoRegex.Lines.Text);
    StringWriteToFile(TestDataURLsFilespec,  MemoURLs.Lines.Text);
  end;
end;

end.
