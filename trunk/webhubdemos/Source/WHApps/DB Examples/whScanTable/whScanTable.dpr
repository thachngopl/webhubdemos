program whScanTable;    {Free-form dynamic table display}
(*
Copyright (c) 1997 HREF Tools Corp.

Original Author: Ann Lynnworth, HREF Tools Corp.
Based on the work of Robert Martin and Michael S. Davis at www.seacom.net
and Suzanne Aldrich, HREF Tools Corp.

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


uses
  ExceptionLog,
  MultiTypeApp in 'h:\MultiTypeApp.pas',
  tpProj in 'h:\tpProj.pas',
  utpanfrm in 'h:\utPanFrm.pas' {utParentForm},
  utmainfm in 'h:\utMainFm.pas' {fmMainForm},
  uttrayfm in 'h:\utTrayFm.pas' {fmTrayForm},
  whdemo_Initialize in '..\..\Common\whdemo_Initialize.pas',
  whdemo_About in '..\..\Common\whdemo_About.pas' {fmAppAboutPanel},
  whdemo_Extensions in '..\..\Common\whdemo_Extensions.pas' {DemoExtensions: TDataModule},
  whdemo_ViewSource in '..\..\Common\whdemo_ViewSource.pas' {DemoViewSource: TDataModule},
  whdemo_Refresh in '..\..\Common\whdemo_Refresh.pas' {dmWhRefresh: TDataModule},
  whdemo_DMProjMgr in '..\..\Common\whdemo_DMProjMgr.pas' {DMForWHDemo: TDataModule},
  whpanel_RemotePages in 'h:\whpanel_RemotePages.pas' {fmWhDreamweaver: TfmWhDreamweaver},
  whsample_EvtHandlers in 'H:\whsample_EvtHandlers.pas' {whdmCommonEventHandlers: TDataModule},
  whMain in 'k:\webhub\lib\whMain.pas' {fmWebHubMainForm},
  scanfm in 'scanfm.pas' {fmDBPanel},
  importfm in 'importfm.pas' {FormImport},
  ucScnDir in 'ucScnDir.pas',
  wdbScan in 'k:\webhub\lib\whdb\wdbScan.pas',
  wdbSSrc in 'K:\WebHub\lib\whdb\wdbSSrc.pas',
  wdbxSource in 'K:\WebHub\lib\whdb\wdbxSource.pas',
  webScan in 'K:\WebHub\lib\whplus\webScan.pas',
  htWebApp in 'K:\WebHub\lib\htWebApp.pas',
  whScanTable_dmProjMgr in 'whScanTable_dmProjMgr.pas' {DMForWHScanTable: TDataModule},
  webLink in 'k:\webhub\lib\webLink.pas',
  htmlBase in 'K:\WebHub\lib\whvcl\htmlBase.pas';

{$R *.RES}
{$R HTDEMOS.RES}     // main icon for WebHub demos
{..$R HTICONS.RES}   // component icons for combo bar, needed if compiling without WH package
{..$R HTGLYPHS.RES}  // icons for WebHub UI features, needed if compiling without WH package

begin
  {M}Application.Initialize;
  {M}Application.CreateForm(TDMForWHScanTable, DMForWHScanTable);
  DMForWHScanTable.SetDemoFacts('scan', 'DB Examples', True);
  DMForWHScanTable.ProjMgr.ManageStartup;
  {M}Application.Run;
end.
