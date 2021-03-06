program whConverter;
(*
Copyright (c) 2003 HREF Tools Corp.
Author: Ann Lynnworth

Permission is hereby granted, on 22-Aug-2003, free of charge, to any person
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
  utpanfrm in 'h:\utpanfrm.pas' {utParentForm},
  utmainfm in 'h:\utMainFm.pas' {fmMainForm},
  uttrayfm in 'H:\utTrayFm.pas' {fmTrayForm},
  whdemo_Initialize in '..\..\Common\whdemo_Initialize.pas',
  whdemo_About in '..\..\Common\whdemo_About.pas' {fmAppAboutPanel},
  whdemo_Extensions in '..\..\Common\whdemo_Extensions.pas' {DemoExtensions: TDataModule},
  whdemo_CodeSite in '..\..\Common\whdemo_CodeSite.pas',
  whdemo_UIHelpers in '..\..\Common\whdemo_UIHelpers.pas',
  whdemo_ViewSource in '..\..\Common\whdemo_ViewSource.pas' {DemoViewSource: TDataModule},
  whpanel_RemotePages in 'h:\whpanel_RemotePages.pas' {fmWhDreamweaver: TfmWhDreamweaver},
  whsample_EvtHandlers in 'h:\whsample_EvtHandlers.pas' {whdmCommonEventHandlers: TDataModule},
  whMain in 'H:\whMain.pas' {fmWebHubMainForm},
  dmWHApp in 'H:\dmWHApp.pas' {dmWebHubApp: TDataModule},
  whhtml in 'H:\whhtml.pas' {fmAppHTML},
  whConverter_fmWhProcess in 'whConverter_fmWhProcess.pas' {fmWhProcess},
  tpProj in 'h:\tpProj.pas',
  whdemo_DMProjMgr in '..\..\Common\whdemo_DMProjMgr.pas' {DMForWHDemo: TDataModule},
  whConverter_dmProjMgr in 'whConverter_dmProjMgr.pas' {DMForWHConverter: TDataModule};

{$R *.RES}
{$R HTDEMOS.RES}     // main icon for WebHub demos
{..$R HTICONS.RES}   // component icons for combo bar, needed if compiling without WH package
{..$R HTGLYPHS.RES}  // icons for WebHub UI features, needed if compiling without WH package

begin
  {M}Application.Initialize;
  {M}Application.CreateForm(TDMForWHConverter, DMForWHConverter);
  DMForWHConverter.SetDemoFacts('htcv', 'More Examples',True);
  DMForWHConverter.ProjMgr.ManageStartup;
  {M}Application.Run;
end.

