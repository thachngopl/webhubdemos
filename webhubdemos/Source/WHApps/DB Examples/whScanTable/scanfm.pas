unit scanfm;
(*
Copyright (c) 1997 HREF Tools Corp.
Author: Ann Lynnworth

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

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, DB, DBTables, DBClient, Buttons, Grids,
  DBGrids, DBCtrls, MidasLib, Provider, SimpleDS, 
  Toolbar, {}tpCompPanel, ucstring, UTPANFRM, tpTable, updateOk,
  tpAction, tpStatus, TxtGrid,
  wbdeForm, wbdeSource, webTypes, webLink, wdbLink, wdbScan, wbdeGrid, webMemo,
  webPage, webPHub, wdbSSrc, webScan, wdbxSource;

type
  TfmDBPanel = class(TutParentForm)
    tpStatusBar1: TtpStatusBar;
    tpComponentPanel2: TtpComponentPanel;
    Panel1: TPanel;
    DBGrid2: TDBGrid;
    DBNavigator2: TDBNavigator;
    DataSource1: TDataSource;
    BrowseScan: TwhdbScan;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    tpToolBar: TtpToolBar;
    tpToolButton1: TtpToolButton;
    sdsScanDemo: TSimpleDataSet;
    disabledDBX: TwhdbxSource;
    disabledBDE: TwhbdeSource;
    GroupBox3: TGroupBox;
    cbUseBDE: TCheckBox;
    Table1: TtpTable;
    DataSource2: TDataSource;
    procedure tpToolButton1Click(Sender: TObject);
    procedure BrowseScanRowStart(Sender: TwhdbScanBase;
      aWebDataSource: TwhdbSourceBase; var ok: Boolean);
    procedure BrowseScanInit(Sender: TObject);
    procedure BrowseScanFinish(Sender: TObject);
    procedure BrowseScanUpdate(Sender: TObject);
    procedure cbUseBDEClick(Sender: TObject);
  private
    { Private declarations }
    procedure ToggleUseBDE(const DesiredState: Boolean);
  public
    { Public declarations }
    function Init: Boolean; override;
  end;

var
  fmDBPanel: TfmDBPanel;

implementation

{$R *.DFM}

uses
  MultiTypeApp,
  webApp,    // global pointer pWebApp is in this unit
  webSend,   // declaration of drBeforeTag
  whdemo_ViewSource,  // getHtDemoDataRoot is in this unit.
  ucDlgs;    // ucDlgs is part of TPack. msgErrorOk is in this unit.

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

var
  FlagDone: Boolean = False;

function TfmDBPanel.Init: Boolean;
var
  Flex: TwhdbSourceBase;
begin
  Result:= inherited Init;
  if not Result then
    Exit;
  if FlagDone then Exit;

  (* There is a lot of code here purely for testing for differences between
     BDE and dbExpress.  Please excuse the mess.  11-Dec-2008 *)
  try
    with Table1 do
    begin
      DatabaseName := getHtDemoDataRoot + 'whScanTable\';
      TableName := 'graphics.db';
      open;
    end;
  except on e: Exception do
    begin
      MsgErrorOk('TableFullName='+Table1.TableFullName+'. '+e.Message);
      Result := False;
    end;
  end;

  sdsScanDemo.Close;  // in case it was left open in the DFM

  Flex := disabledBDE;
  with TwhbdeSource(Flex) do
  begin
    DataSource := DataSource2;  // TTable
    UsingIndexFieldNames := True;
    Name := 'Browse';
    KeyFieldNames := 'FileID';
    Refresh;
    Name := 'disabledBDE';
  end;

  Flex := disabledDBX;
  with TwhdbxSource(Flex) do
  begin
    DataSource := DataSource1;
    UsingIndexFieldNames := True;
    KeyFieldNames := 'FileID';
    Name := 'Browse';
    Refresh;
    if Flex.KeyFields <> 'FileID' then
      MsgWarningOk('Invalid KeyFields on DBX web data source');
    Name := 'disabledDBX';
  end;

  ToggleUseBDE(True);

  { Note. The PageHeight is set to 3 initially, just so that the grid is not
    too large/slow for downloaders on overseas connections. 7-Jun-1998. }
  BrowseScan.PageHeight := 3;
  BrowseScan.ControlsWhere := dsNone;
  BrowseScan.ButtonsWhere := dsNone;

  RefreshWebActions(Self);
  FlagDone := True;
end;

//------------------------------------------------------------------------------

procedure TfmDBPanel.BrowseScanInit(Sender: TObject);
var
  aDropletName: String;
begin
  inherited;
  { This technique of sending droplets is webmaster-friendly.
    The parameter to the BrowseScan component (e.g. browsescan.execute|drTest)
    provides the name of the droplet whose contents are to be used for
    formatting. }
  with TwhdbScan(Sender) do
  begin
    aDropletName := HtmlParam;
    WebApp.SendDroplet(aDropletName, drBeforeWhrow);
  end;
end;


//------------------------------------------------------------------------------

procedure TfmDBPanel.BrowseScanRowStart(Sender: TwhdbScanBase;
  aWebDataSource: TwhdbSourceBase; var ok: Boolean);
var
  aDropletName: String;
begin
  inherited;
  with TwhdbScan(Sender) do
  begin
    // This literal flows into a DYNCHUNK in the HTML. It is used to color code
    // the rows based on file type (PNG, JPG, etc.)
    if TwhbdeSource(aWebDataSource).DataSet is TDataSet then
      with TwhbdeSource(aWebDataSource).DataSet do
        WebApp.StringVar['litExt'] := FieldByName('FileExt').asString;

    aDropletName := HtmlParam;
    WebApp.SendDroplet(aDropletName, drWithinWhrow);
  end;
end;

//------------------------------------------------------------------------------

procedure TfmDBPanel.BrowseScanFinish(Sender: TObject);
var
  aDropletName: String;
begin
  inherited;
  with TwhdbScan(Sender) do
  begin
    aDropletName := HtmlParam;
    WebApp.SendDroplet(aDropletName, drAfterWhrow);
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure TfmDBPanel.tpToolButton1Click(Sender: TObject);
begin
  inherited;
  // This procedure makes the grid display within the running app, so you
  // can see the data.  It does not impact the web pages at all.
  // You can run this app without ever activating the visible
  // controls.
  if NOT Assigned(dbNavigator2.DataSource) then
  begin
    dbNavigator2.DataSource:=DataSource1;
    dbGrid2.DataSource:=DataSource1;
    if Assigned(dbGrid2.DataSource.DataSet) then
    begin
      if dbGrid2.DataSource.DataSet is TSimpleDataSet then
      begin
        MsgInfoOk(Format('Filename: %s',
          [TSimpleDataSet(dbGrid2.DataSource.DataSet).FileName]));
      end
      else
        MsgWarningOk(Format('DataSet.ClassName is %s',
          [dbGrid2.DataSource.DataSet.ClassName]));
    end
    else
      MsgWarningOk('dbGrid2.DataSource.DataSet is nil');
  end
  else
  begin
    dbNavigator2.DataSource:=nil;
    dbGrid2.DataSource:=nil;
  end;
end;

procedure TfmDBPanel.BrowseScanUpdate(Sender: TObject);
begin
  inherited;
  (* testing in May 2006 -- not generally important
  with TwhdbScan(Sender) do
  begin
    SetButtonSpecs2012;     // stopped working in v2.055
    SetCaptions2004;
  end; *)
end;

(* out 03-Dec-2008
object Table1: TtpTable
  TableMode = tmData
  PostBeforeClose = False
  HideLinkingKeys = False
  LeaveOpen = False
  Left = 136
  Top = 24
end
*)
procedure TfmDBPanel.ToggleUseBDE(const DesiredState: Boolean);
var
  CompBDE: TComponent;
  CompDBX: TComponent;
begin
  BrowseScan.WebDataSource.HouseClean;

  if NOT (cbUseBDE.Checked = DesiredState) then
    cbUseBDE.Checked := DesiredState;

  sdsScanDemo.Close;  // in case it was left open in the DFM

  CompBDE := FindComponentByClass(Self, TwhbdeSource);
  CompDBX := FindComponentByClass(Self, TwhdbxSource);

  Assert(Assigned(CompBDE));
  Assert(Assigned(CompDBX));

  if DesiredState = True then
  begin
    //use BDE
    CompDBX.Name := 'disabledDBX';
    CompBDE.Name := 'Browse';
    if Assigned(disabledBDE) then
      disabledBDE := nil;
    BrowseScan.WebDataSource := TwhbdeSource(CompBDE);
  end
  else
  begin
    CompBDE.Name := 'disabledBDE';
    CompDBX.Name := 'Browse';
    if Assigned(disabledDBX) then
      disabledDBX := nil;
    BrowseScan.WebDataSource := TwhdbxSource(CompDBX);
  end;
  BrowseScan.WebDataSource.HouseClean;

end;

procedure TfmDBPanel.cbUseBDEClick(Sender: TObject);
begin
  inherited;
  ToggleUseBDE(cbUseBDE.Checked);
end;

end.
