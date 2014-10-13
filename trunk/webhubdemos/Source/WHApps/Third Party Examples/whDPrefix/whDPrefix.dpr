program whDPrefix;  { Delphi Prefix Registry WebHub App }

{ ---------------------------------------------------------------------------- }
{ * Copyright (c) 2013-2014 HREF Tools Corp.  All Rights Reserved Worldwide. * }
{ *                                                                          * }
{ * This source code file is part of the Delphi Prefix Registry.             * }
{ *                                                                          * }
{ * This file is licensed under a Creative Commons Attribution 2.5 License.  * }
{ * http://creativecommons.org/licenses/by/2.5/                              * }
{ * If you use this file, please keep this notice intact.                    * }
{ *                                                                          * }
{ * Author: Ann Lynnworth                                                    * }
{ *                                                                          * }
{ * Refer friends and colleagues to www.href.com/whvcl. Thanks!              * }
{ ---------------------------------------------------------------------------- }

uses
  MultiTypeApp in 'h:\MultiTypeApp.pas',
  tpProj in 'h:\tpProj.pas',
  utmainfm in 'h:\utmainfm.pas' {fmMainForm},
  utTrayFm in 'h:\utTrayFm.pas' {fmTrayForm},
  utPanFrm in 'h:\utPanFrm.pas' {utParentForm},
  whhtml in 'h:\whhtml.pas' {fmAppHTML},
  whmail in 'h:\whmail.pas' {DataModuleWhMail: TDataModuleWhMail},
  whappin in 'h:\whappin.pas' {fmAppIn},
  whappout in 'h:\whappout.pas' {fmAppOut},
  whMain in 'h:\whMain.pas' {fmWebHubMainForm},
  whdm_Lingvo in 'h:\whdm_Lingvo.pas',
  whcfg_App in 'k:\webhub\lib\whcfg_App.pas',
  htWebApp in 'k:\webhub\lib\htWebApp.pas',
  whdemo_ViewSource in '..\..\Common\whdemo_ViewSource.pas' {DemoViewSource: TDataModule},
  whdemo_About in '..\..\Common\whdemo_About.pas' {fmAppAboutPanel: TDataModule},
  whdemo_Extensions in '..\..\Common\whdemo_Extensions.pas' {DemoExtensions: TDataModule},
  whsample_EvtHandlers in 'h:\whsample_EvtHandlers.pas' {whdmCommonEventHandlers: TDataModule},
  whsample_GoogleSitemap in 'h:\whsample_GoogleSitemap.pas' {fmwhGoogleSitemap},
  whdemo_CodeSite in '..\..\Common\whdemo_CodeSite.pas',
  wnxdbAlpha in 'wnxdbAlpha.pas',
  whutil_ZaphodsMap in 'h:\whutil_ZaphodsMap.pas',
  whutil_ValidEmail in 'h:\whutil_ValidEmail.pas',
  whOpenID_dmwhAction in '..\..\More Examples\whOpenID\whOpenID_dmwhAction.pas',
  DPrefix_fmWhActions in 'DPrefix_fmWhActions.pas' {fmWhActions},
  DPrefix_DMProjMgr in 'DPrefix_DMProjMgr.pas' {DMDPrefixProjMgr: TDataModule},
  DPrefix_dmNexus in 'DPrefix_dmNexus.pas' {DMNexus: TDataModule},
  DPrefix_dmWhActions in 'DPrefix_dmWhActions.pas' {DMDPRWebAct: TDataModule},
  webLink in 'h:\webLink.pas',
  wdbForm in 'h:\wdbForm.pas',
  uBigMacIndex in 'uBigMacIndex.pas',
  DPrefix_dmWhNexus in 'DPrefix_dmWhNexus.pas' {DMWHNexus: TDataModule},
  DPrefix_dmwhApi in 'DPrefix_dmwhApi.pas' {DMWHAPI: TDataModule};

(* search path for debugging with WebHub source
k:\webhub\lib;k:\webhub\lib\whvcl;k:\webhub\lib\wheditors;k:\webhub\lib\whrun;k:\webhub\lib\whplus;k:\webhub\tpack
*)

{$R *.RES}
{$R DPRICON.RES}
{$R HTICONS.RES}
{$R HTGLYPHS.RES}

begin
  {M}Application.Initialize;
  {M}Application.CreateForm(TDMDPrefixProjMgr, DMDPrefixProjMgr);
  DMDPrefixProjMgr.ProjMgr.ManageStartup;
  {M}Application.Run;
end.

