program whClone;        {multi-user webapplication using cloned datasets and preinstantiated fields.}
(*
Copyright (c) 1997 HREF Tools Corp.

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

(* See "How to Work with WebHub Demos.rtf" in the webhubdemos\source\docs folder
   for information about "drives" H: and K:. *)

uses
  MultiTypeApp in 'h:\MultiTypeApp.pas',
  tpProj in 'h:\tpProj.pas',
  utPanFrm in 'h:\utPanFrm.pas' {utParentForm},
  utMainFm in 'h:\utMainFm.pas' {fmMainForm},
  utTrayFm in 'h:\utTrayFm.pas' {fmTrayForm},
  whdemo_Initialize in '..\..\Common\whdemo_Initialize.pas',
  whdemo_About in '..\..\Common\whdemo_About.pas' {fmAppAboutPanel},
  whdemo_Extensions in '..\..\Common\whdemo_Extensions.pas' {DemoExtensions: TDataModule},
  whdemo_ViewSource in '..\..\Common\whdemo_ViewSource.pas' {DemoViewSource: TDataModule},
  whpanel_RemotePages in 'h:\whpanel_RemotePages.pas' {fmWhDreamweaver: TfmWhDreamweaver},
  whsample_EvtHandlers in 'H:\whsample_EvtHandlers.pas' {whdmCommonEventHandlers: TDataModule},
  dmwhBDEApp in 'h:\dmwhBDEApp.pas' {dmWebHubBDEApp: TDataModule},
  whMain in 'h:\whMain.pas' {fmWebHubMainForm},
  uAutoDataModules in 'h:\uAutoDataModules.pas',
  uAutoPanels in 'H:\uAutoPanels.pas',
  wdbGrid in 'k:\webhub\lib\whdb\wdbGrid.pas',
  wbdeGrid in 'k:\webhub\lib\whdb\wbdeGrid.pas',
  webLink in 'k:\webhub\lib\webLink.pas',
  wdbScan in 'k:\webhub\lib\whdb\wdbScan.pas',
  wdbSSrc in 'k:\webhub\lib\whdb\wdbSSrc.pas',
  wdbSource in 'k:\webhub\lib\whdb\wdbSource.pas',
  wdbxSource in 'k:\webhub\lib\whdb\wdbxSource.pas',
  wbdeSource in 'k:\webhub\lib\whdb\wbdeSource.pas',
  whdemo_DMDBProjMgr in '..\..\Common\whdemo_DMDBProjMgr.pas' {DMForWHDBDemo: TDataModule},
  fmclone in 'fmclone.pas' {fmBendFields},
  whClone_dmdbProjMgr in 'whClone_dmdbProjMgr.pas' {DMForWHClone: TDataModule},
  whClone_dmwhData in 'whClone_dmwhData.pas' {DMData2Clone: TDataModule},
  whClone_dmwhGridsNScans in 'whClone_dmwhGridsNScans.pas' {DMGridsNScans: TDataModule};

{$R *.RES}
{$R HTDEMOS.RES}     // main icon for WebHub demos
{..$R HTICONS.RES}   // component icons for combo bar, needed if compiling without WH package
{..$R HTGLYPHS.RES}  // icons for WebHub UI features, needed if compiling without WH package

begin
  {M}Application.Initialize;
  {M}Application.CreateForm(TDMForWHClone, DMForWHClone);
  DMForWHClone.SetDemoFacts('htcl', 'DB Examples', True);
  DMForWHClone.ProjMgr.ManageStartup;
  {M}Application.Run;
end.

