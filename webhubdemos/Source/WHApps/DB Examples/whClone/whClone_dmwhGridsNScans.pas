unit whClone_dmwhGridsNScans;

interface

uses
  SysUtils, Classes, MidasLib,
  updateOK, tpAction, 
  webLink, wdbGrid, wbdeGrid, webTypes, wdbScan, wdbSource, wdbSSrc;

type
  TDMGridsNScans = class(TDataModule)
    Scan1: TwhdbScan;
    Scan2: TwhdbScan;
    WebDataGrid1: TwhbdeGrid;
    ScanXML: TwhdbScan;
    ScanXMLCloned: TwhdbScan;
    ScanDBxDBf: TwhdbScan;
    procedure DataModuleCreate(Sender: TObject);
    procedure ScanOnExecutePageHeader(Sender: TObject);
    procedure ScanInit(Sender: TObject);
    procedure ScanFinish(Sender: TObject);
    procedure ScanRowStart(Sender: TwhdbScanBase;
      aWebDataSource: TwhdbSourceBase; var ok: Boolean);
    procedure ScanAfterExecute(Sender: TObject);
    procedure WebDataGrid1AfterExecute(Sender: TObject);
    procedure WebDataGrid1Execute(Sender: TObject);
    procedure ScanXMLEmptyDataSet(Sender: TObject);
  private
    { Private declarations }
    FlagInitDone: Boolean;
    procedure PageHeader;
    procedure PageFooter;
    procedure TableHeader(Sender: TObject);
    procedure TableFooter;
    procedure WebAppUpdate(Sender: TObject);
  public
    { Public declarations }
    function Init(out ErrorText: string): Boolean;
  end;

var
  DMGridsNScans: TDMGridsNScans;

implementation

{$R *.dfm}

uses
  {$IFDEF CodeSite}CodeSiteLogging,{$ENDIF}
  Data.DB, TypInfo,
  ZM_CodeSiteInterface,
  webApp, htWebApp, wbdeSource, webScan,
  whClone_dmwhData;

{ TDMGridsNScans }

procedure TDMGridsNScans.DataModuleCreate(Sender: TObject);
const cFn = 'DataModuleCreate';
begin
  CSEnterMethod(Self, cFn);
  FlagInitDone := False;
  CSExitMethod(Self, cFn);
end;

function TDMGridsNScans.Init(out ErrorText: string): Boolean;
const cFn = 'Init';
begin
  CSEnterMethod(Self, cFn);
  ErrorText := '';
  // reserved for code that should run once, after AppID set
  if NOT FlagInitDone then
  begin

    if Assigned(pWebApp) and pWebApp.IsUpdated then
    begin
      Scan1.OnExecute := nil; // when controlled from the form
      Scan1.OnExecute := ScanOnExecutePageHeader;
      scan1.WebDataSource := DMData2Clone.WebDataSource1;
      scan1.OnRowStart := ScanRowStart;

      Scan2.OnExecute := nil; // when controlled from the form
      Scan2.OnExecute := ScanOnExecutePageHeader;
      scan2.WebDataSource := DMData2Clone.WebDataSource2;
      scan2.OnRowStart := ScanRowStart;
      Scan2.ControlsWhere := dsBelow;

      WebDataGrid1.WebDataSource := DMData2Clone.WebDataSource1;
      WebDataGrid1.ShowRecno := False;

      ScanXML.WebDataSource := DMData2Clone.whdbxSourceXML;

      ScanXmlCloned.WebDataSource := DMData2Clone.whdbxSourceXMLCloned;

      // Call RefreshWebActions here only if it is not called within a TtpProject event
      RefreshWebActions(Self);

      if NOT ScanXML.IsUpdated then
        ErrorText := 'ScanXML would not update';

      if (ErrorText = '') then
      begin
        // allow all web actions to be called via DO page
        // appid:DO::webactionname
        DirectCallOk(Self, True);
        AddAppUpdateHandler(WebAppUpdate);
        FlagInitDone := True;
      end;
    end;
  end;
  Result := FlagInitDone;
  CSSend(cFn + ': Result', S(Result));
  CSExitMethod(Self, cFn);
end;
//------------------------------------------------------------------------------
//both datascan components deliver roughly the same look and here's the code
//shared by both:

procedure TDMGridsNScans.PageFooter;
begin
  pWebApp.SendMacro('drPageFooterHTCL');
end;

procedure TDMGridsNScans.PageHeader;
begin
  pWebApp.SendMacro('drPageHeaderHTCL');
end;

procedure TDMGridsNScans.ScanAfterExecute(Sender: TObject);
begin
  PageFooter;
end;

procedure TDMGridsNScans.ScanFinish(Sender: TObject);
begin
  TableFooter;
end;

procedure TDMGridsNScans.ScanInit(Sender: TObject);
var
  i: Integer;
  S1: string;
begin
  TableHeader(Sender);
  writeln('<tr><th>DataSet Name</th>');
  with TwhbdeSource(TwhdbScan(Sender).WebDataSource) do
  for i := 0 to Pred(DataSet.FieldCount) do
  begin

    S1 := GetEnumName(TypeInfo(TFieldType), Ord(DataSet.Fields[i].DataType));

    if (DataSet.Fields[i].DataType in
      [ftDate, ftDateTime, ftSmallint, ftInteger, ftFloat, ftString]) then
      WriteLn('<th>' + DataSet.Fields[i].FieldName + '<br/>' + S1 + '</th>')
    else
      pWebApp.Response.SendComment(DataSet.Fields[i].FieldName + ' is ' + S1);
  end;
  WriteLn('</tr>');
end;

procedure TDMGridsNScans.ScanRowStart(Sender: TwhdbScanBase;
  aWebDataSource: TwhdbSourceBase; var ok: Boolean);
var
  i: Integer;
begin
  writeln(
   '<tr>'
  +'  <td>'
  //  <- notice reference to table2
  +TwhbdeSource(aWebDataSource).DataSet.Name +
  //DMData2Clone.Table2.Name+
  '</td>');
  //      when this runs, that pointer (Table2.RecNo)
  //      and all the field pointers (such as Table2SpeciesNo
  //      will point to the clones!
  with TwhbdeSource(aWebDataSource) do
  for i := 0 to Pred(DataSet.FieldCount) do
  begin
    if (DataSet.Fields[i].DataType in
      [ftDate, ftDateTime, ftSmallint, ftInteger, ftFloat, ftString]) then
      WriteLn('  <td>' + DataSet.Fields[i].AsString + '</td>');
  end;
  WriteLn('</tr>');
end;

procedure TDMGridsNScans.ScanXMLEmptyDataSet(Sender: TObject);
begin
  pWebApp.Response.Send('empty dataset');
end;

procedure TDMGridsNScans.ScanOnExecutePageHeader(Sender: TObject);
begin
  PageHeader;
end;

procedure TDMGridsNScans.TableFooter;
begin
  writeln('</table>');
end;

procedure TDMGridsNScans.TableHeader(Sender: TObject);
const cCSSSuffix = '-table';
var
  s1: string;
begin
  if Sender is TwhWebAction then
  begin
    pWebApp.SendStringImm('<h1>' + TwhWebAction(Sender).Name + '</h1>');
    s1 := TwhWebAction(Sender).Family;
  end;

  if Sender is TwhdbScan then
  begin
    pWebApp.SendStringImm('<h2>DataSet.Owner is ' +
      TwhdbSource(TwhdbScan(Sender).WebDataSource).DataSource.DataSet.Owner.Name
      + '</h2>');
    pWebApp.SendStringImm('<p>MaxOpenDataSets is ' +
      IntToStr(TwhdbScan(Sender).WebDataSource.MaxOpenDataSets) +
      '. KeyFields = ' + TwhdbScan(Sender).WebDataSource.KeyFields + '.</p>');
  end;

  pWebApp.SendStringImm('<table id="' + Self.Name + cCSSSuffix + '" class="' +
    S1 + cCSSSuffix + '">');
end;

procedure TDMGridsNScans.WebAppUpdate(Sender: TObject);
const cFn = 'WebAppUpdate';
begin
  CSEnterMethod(Self, cFn);
  // reserved for when the WebHub application object refreshes
  // e.g. to make adjustments because the config changed.
  CSExitMethod(Self, cFn);
end;

procedure TDMGridsNScans.WebDataGrid1AfterExecute(Sender: TObject);
begin
  PageFooter;
end;

//------------------------------------------------------------------------------
//this code is used by both webdatasources as they both demonstrate using
//pre-instantiated fields:

procedure TDMGridsNScans.WebDataGrid1Execute(Sender: TObject);
begin
  PageHeader;
end;

end.
