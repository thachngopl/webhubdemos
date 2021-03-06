program whLite;  {A fairly generic WebHub application.}
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

// Usage: whLite.exe /ID:AppID
// Check Run|Parameters if you are running this from within the Delphi IDE!

// Full paths are required on utpanfrm, utmainfm, uttrayfm so that WebHub Panels
// will open inside the Delphi IDE.

// Either map h: to your WebHub "lib" directory or change the paths as needed.
// e.g. h: would be mapped to c:\Program Files\HREFTools\WebHub\lib

(* See "How to Work with WebHub Demos.rtf" in the webhubdemos\source\docs folder
   for information about "drives" H: and K:. *)

{$I hrefdefines.inc}

uses
  MultiTypeApp in 'h:\MultiTypeApp.pas',
  tpProj in 'h:\tpProj.pas',
  uCode,
  utPanFrm in 'h:\utPanFrm.pas' {utParentForm},
  utMainFm in 'h:\utMainFm.pas' {fmMainForm},
  utTrayFm in 'h:\utTrayFm.pas' {fmTrayForm},
  webLink in 'h:\webLink.pas',
  whutil_ZaphodsMap in 'k:\webhub\lib\whutil_ZaphodsMap.pas',
  whdemo_DMProjMgr in '..\..\..\Common\whdemo_DMProjMgr.pas' {DMForWHDemo: TDataModule},
  whdemo_CodeSite in '..\..\..\Common\whdemo_CodeSite.pas' {dmwhUIHelpers: TDataModule},
  whdemo_UIHelpers in '..\..\..\Common\whdemo_UIHelpers.pas',
  whdemo_Initialize in '..\..\..\Common\whdemo_Initialize.pas',
  whdemo_ViewSource in '..\..\..\Common\whdemo_ViewSource.pas' {DemoViewSource: TDemoViewSource},
  whdemo_Extensions in '..\..\..\Common\whdemo_Extensions.pas' {DemoExtensions: TDataModule},
  whdemo_About in '..\..\..\Common\whdemo_About.pas' {fmAppAboutPanel},
  whpanel_Mail in 'h:\whpanel_Mail.pas' {fmWebMail},
  dmWHApp in 'h:\dmWHApp.pas' {dmWebHubApp: TDataModule},
  whMain in 'h:\whMain.pas' {fmWebHubMainForm},
  htWebApp in 'H:\htWebApp.pas',
  whMail in 'h:\whMail.pas' {DataModuleWhMail: TDataModule},
  whAppOut in 'h:\whAppOut.pas',
  webTypes in 'h:\webTypes.pas',
  whHTML in 'h:\whHTML.pas' {fmAppHTML},
  whSample_GoogleSitemap in 'k:\webhub\lib\whSample_GoogleSitemap.pas',
  whSample_DMGoogleSitemap in 'k:\webhub\lib\whSample_DMGoogleSitemap.pas',
  whcfg_App in 'k:\webhub\lib\whcfg_App.pas',
  ucAWS_Security in 'H:\ucAWS_Security.pas',
  ucAWS_S3_Upload in 'H:\ucAWS_S3_Upload.pas',
  ucAWS_CloudFront_PrivateURLs in 'H:\ucAWS_CloudFront_PrivateURLs.pas',
  uAutoDataModules in 'k:\webhub\lib\uAutoDataModules.pas',
  uAutoPanels in 'k:\webhub\lib\uAutoPanels.pas'
  ;

(* only if you want to compile with Chilkat RSA for comparison,
  uChilkatInterface in '..\..\..\Common\uChilkatInterface.pas',
  PrivateKey in '..\..\..\Externals\chilkat-9.5.0-delphi\PrivateKey.pas',
  Rsa in '..\..\..\Externals\chilkat-9.5.0-delphi\Rsa.pas'
*)

{$R *.RES}
{$R h:\HTDEMOS.RES}  // main icon for WebHub demos

{$IFDEF DEBUG}
{$R HTICONS.RES}   // component icons for combo bar, needed if compiling without WH package
{$R HTGLYPHS.RES}  // icons for WebHub UI features, needed if compiling without WH package
{$ENDIF}

begin
  {M}Application.Initialize;
  {M}Application.CreateForm(TDMForWHDemo, DMForWHDemo);
  DMForWHDemo.SetDemoFacts('', 'Lite Examples\whAppServer', True);
  DMForWHDemo.ProjMgr.ManageStartup;

  if Assigned(DemoExtensions) then

    DemoExtensions.Init;  // make extra sure that these event handlers go LAST.

  {M}Application.Run;
end.

