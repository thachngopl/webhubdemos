unit htqry4dm;

(*
Copyright (c) 1999-2017 HREF Tools Corp.

Permission is hereby granted, on 04-Jun-2004, free of charge, to any person
obtaining a copy of this file (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)

// This is the code for the "left" grid which selects by department.

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, 
  Bde.DBTables, DB, MidasLib,
  UpdateOk, tpAction, 
  WebTypes, wbdeSource, wdbForm,
  WebLink, WdbLink, WdbScan, wdbGrid, wbdeGrid{bde}, WebSend, webScan, wdbLstBx, wdbSSrc,
  wdbSource;

type
  TDataModuleHTQ4 = class(TDataModule)
    grid1: TwhbdeGrid;
    WebDataSource1: TwhbdeSource;
    DataSource1: TDataSource;
    Query1: TQuery;
    WebDataForm1: TwhdbForm;
    WebDataSourceEmp: TwhbdeSource;
    DataSourceEmp: TDataSource;
    TableEmp: TTable;
    WebAction1: TwhWebAction;
    DataSourceDept: TDataSource;
    QueryDept: TQuery;
    procedure grid1HotField(Sender: TwhdbGrid; aField: TField;
      var CellValue: string);
    procedure WebAction1Execute(Sender: TObject);
    procedure Query1BeforeOpen(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure WebDataForm1SetCommand(Sender: TObject; var ThisCommand: string);
  private
    { Private declarations }
    FInitFlag: Boolean;
  public
    { Public declarations }
    function Init(out ErrorText: string): Boolean;
    procedure WebAppUpdate(Sender: TObject);
  published
    selectDepartment: TwhdbListBox;
  end;

var
  DataModuleHTQ4: TDataModuleHTQ4;

implementation

uses
  {$IFDEF CodeSite}CodeSiteLogging,{$ENDIF}
  ZM_CodeSiteInterface,
  webApp, htWebApp, whMacroAffixes,
  whdemo_ViewSource, grid2DM;

{$R *.DFM}

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

function TDataModuleHTQ4.Init(out ErrorText: string): Boolean;
const cFn = 'Init';
const cRecylingHtml = '&#x267b;';
begin
  ErrorText := '';
  if NOT FInitFlag then
  begin

    Query1.Databasename := getHtDemoDataRoot + 'whQuery4\';
    Query1.BeforeOpen := Query1BeforeOpen;
    TableEmp.Databasename := getHtDemoDataRoot + 'whQuery4\';

    if NOT Assigned(selectDepartment) then
    begin
      selectDepartment := TwhdbListBox.Create(Self);
      selectDepartment.Name := 'selectDepartment';  // name as used in WHTEKO
      selectDepartment.DataSet := QueryDept;
      selectDepartment.Size := 1;
      selectDepartment.StringVarName := 'Dept';
      selectDepartment.DataField := 'DepartmentFull';
      selectDepartment.ValueField := 'DeptNo';
      selectDepartment.BlankItem := True;
      selectDepartment.BlankText := '--select--';
      selectDepartment.MultiSelect := False;
      QueryDept.Databasename := getHtDemoDataRoot + 'whQuery4\';
      QueryDept.SQL.Text := 'select distinct DeptNo, DepartmentFull ' +
        'from department';
      try
        QueryDept.Prepare; // Delphi TQuery
        QueryDept.Open;
        DataSourceDept.DataSet := QueryDept;
      except
        on E: Exception do
        begin
          LogSendException(E);
          ErrorText := E.Message;
        end;
      end;
    end;
    if ErrorText = '' then
      RefreshWebActions(Self);

    WebDataSource1.MaxOpenDataSets := 20;
    WebDataSource1.BendPointers := False;
    grid1.Border := '';
    grid1.SetCaptions2004;
    grid1.SetButtonSpecs2012;
    grid1.Captions.Values[cCapDraw] := MacroStart + 'mcRedrawSubmit' + MacroEnd;
    WebDataSourceEmp.KeyFieldNames := 'EmpNo';

    if assigned(pWebApp) then
    begin
      AddAppUpdateHandler(WebAppUpdate);
      WebAppUpdate(pWebApp);
    end;

    if grid1.IsUpdated and selectDepartment.IsUpdated and
      WebDataSourceEmp.IsUpdated then
      FInitFlag := True
    else
      ErrorText := ErrorText +
        'grid1 AND selectDepartment AND WebDataSourceEmp must Refresh fully ' +
        'for this demo to work';
  end;
  Result := FInitFlag;
end;

//------------------------------------------------------------------------------

procedure TDataModuleHTQ4.WebAppUpdate(Sender: TObject);
begin
  {Set the list of EventMacros here, rather than loading them from the
   application-level INI file. 31-May-2004}
  with pWebApp.EventMacros do
  begin
    Clear;
    Add('evLocate=x');
  end;
end;

procedure TDataModuleHTQ4.WebDataForm1SetCommand(Sender: TObject;
  var ThisCommand: string);
const cFn = 'WebDataForm1SetCommand';
begin
  CSEnterMethod(Self, cFn);
  CSSend('ThisCommand', ThisCommand);
  CSExitMethod(Self, cFn);
end;

//------------------------------------------------------------------------------

procedure TDataModuleHTQ4.Query1BeforeOpen(DataSet: TDataSet);
begin
  with TQuery(DataSet) do
  begin
    SQL.Text := 'select E.*, D.DepartmentFull as Department ' +
      'from employee E, department D, empdept ed ' +
      'WHERE ' +
      '(ED.DeptNo = ' + pWebApp.StringVar['Dept'] + ') ' +
      'and (ED.EmpNo = E.EmpNo) and (ED.DeptNo = D.DeptNo) ';
  end;
end;

//------------------------------------------------------------------------------

procedure TDataModuleHTQ4.DataModuleCreate(Sender: TObject);
begin
  FInitFlag := False;
  selectDepartment := nil;
end;

procedure TDataModuleHTQ4.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(selectDepartment);
end;

procedure TDataModuleHTQ4.grid1HotField(Sender: TwhdbGrid;
  aField: TField; var CellValue: string);
begin
  if comparetext(aField.fieldname,'empno')=0 then
  begin
    {This just drops a graphic into the 'hot' field for each record.
     We are requesting the macro 'mcPersonIcon' which will get expanded
     based on its definition.  Of course we could also put the HTML
     in here directly, but the idea is to keep as much of the OUTSIDE
     the Delphi project as possible, to cut down on the need to recompile.}
    CellValue := MacroStart + 'mcPersonIcon' + MacroEnd + CellValue;
  end
  else
  if SameText(aField.FieldName, 'lastname') then
  begin
    CellValue := DataModuleGrid2.getLastnameJump(aField);
  end;
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// demonstration of reserved pageid "DO"
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
procedure TDataModuleHTQ4.WebAction1Execute(Sender: TObject);
begin
  { This demonstrates the reserved pageid called 'DO' which runs
    components by name if they are passed as the command.

    TwhWebActionEx.DirectCallOk must be True for this to work. It is False by
    default.

    Test with: http://localhost/scripts/runisa.dll?HTQ4:DO::webaction1.ok}
  with TwhWebAction(Sender) do
    Response.Send( 'DO command demonstration. Hello from ' + name + '.' +
      command);
end;

end.
