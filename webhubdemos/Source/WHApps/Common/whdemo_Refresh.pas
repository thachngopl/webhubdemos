unit whdemo_Refresh;

{ ---------------------------------------------------------------------------- }
{ * Copyright (c) 2002-2017 HREF Tools Corp.  All Rights Reserved Worldwide. * }
{ *                                                                          * }
{ * This source code file is part of WebHub v3.1x.  Please obtain a WebHub   * }
{ * development license from HREF Tools Corp. before using this file, and    * }
{ * refer friends and colleagues to http://www.href.com/webhub. Thanks!      * }
{ ---------------------------------------------------------------------------- }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  tpshareb, updateok, tpAction, 
  webTypes, webLink;

type
  TdmWhRefresh = class(TDataModule)
    waDemoRefresh: TwhWebActionEx;
    procedure DataModuleCreate(Sender: TObject);
    procedure tpSharedLongintChange(Sender: TObject);
    procedure waDemoRefreshExecute(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    tpSharedLongint: TSharedInt;
    { Public declarations }
  end;

var
  dmWhRefresh: TdmWhRefresh = nil;

implementation

{$R *.DFM}

uses webapp;

procedure TdmWhRefresh.DataModuleCreate(Sender: TObject);
begin
  (* Set the name equal to something that is easily available to all instances
     which need to respond to the commands.  In this case, we want to refresh
     all running demos in unison. *)
  tpSharedLongint := TSharedInt.CreateNamed(Self, 'WebHubDemo', cReadWriteSharedMem);
  tpSharedLongint.Name := 'tpSharedLongint';
  tpSharedLongint.OnChange := tpSharedLongintChange;

  (* If IgnoreOwnChanges is true, then "global" actions will not occur in
     this instance, only in the other instances.  If IgnoreOwnChanges is
     false, then "global" actions will occur in ALL instances including
     this one. *)
  tpSharedLongint.IgnoreOwnChanges := False;
end;

procedure TdmWhRefresh.tpSharedLongintChange(Sender: TObject);
var
  newValue: Integer;
begin
  inherited;
  newValue := TSharedInt(Sender).GlobalInteger;
  { These are the same values (1,3) as used in whShared.pas. Nonetheless you
    may define any values to lead to any actions. }
  case newValue of
    1:begin
      // Close application
      Application.MainForm.Close;
      // By the way, the app will exit; no response will come back to surfer.
      end;
    3:begin
      pWebApp.Refresh;
      end;
    end;
end;

procedure TdmWhRefresh.waDemoRefreshExecute(Sender: TObject);
var
  WebResponse: String;
begin
  WebResponse := 'No action taken';
  with TwhWebActionEx(Sender) do
  begin
    {security check -- only allow this when used locally or within HREF's LAN}
    if (WebApp.Request.RemoteAddress = '127.0.0.1') or
      (copy(WebApp.Request.RemoteAddress,1,11) = '208.201.252') then
    begin
      if HtmlParam = '3' then
        WebResponse := 'Refreshing all apps';
      tpSharedLongInt.GlobalInteger := StrToIntDef(HtmlParam, 0);
    end;
    Response.Send(WebResponse);
  end;
end;

procedure TdmWhRefresh.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(tpSharedLongint);
  dmWhRefresh := nil;
end;

end.
