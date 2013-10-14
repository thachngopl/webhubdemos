// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://demos.href.com/scripts/runisa.dll/HTUN/wsdl/waSlowSpam
// Encoding : utf-8
// Version  : 1.0
// (07/04/2005 5:54:40 PM - 1.33.2.5)
// ************************************************************************ //

unit soap_waSlowSpam;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:unsignedInt     - "http://www.w3.org/2001/XMLSchema"
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"


  // ************************************************************************ //
  // Namespace : urn:whStopSpam_fmWh-waSlowSpam
  // soapAction: urn:whStopSpam_fmWh-waSlowSpam#MailtoStrObfuscate
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // binding   : waSlowSpamBinding
  // service   : waSlowSpamService
  // port      : waSlowSpamPort
  // URL       : http://demos.href.com/scripts/runisa.dll/HTUN/soap/waSlowSpam
  // ************************************************************************ //
  IwaSlowSpam = interface(IInvokable)
  ['{B50CBDD7-C839-6817-0DA5-FE8C213BD54B}']
    function  MailtoStrObfuscate(var InstanceID: Cardinal; var SessionID: Cardinal; const input: WideString; const MakeResultReadyToCopyFromWeb: Boolean): WideString; stdcall;
  end;

function GetIwaSlowSpam(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IwaSlowSpam;


implementation

function GetIwaSlowSpam(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IwaSlowSpam;
const
  defWSDL = 'http://demos.href.com/scripts/runisa.dll/HTUN/wsdl/waSlowSpam';
  defURL  = 'http://demos.href.com/scripts/runisa.dll/HTUN/soap/waSlowSpam';
  defSvc  = 'waSlowSpamService';
  defPrt  = 'waSlowSpamPort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IwaSlowSpam);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(IwaSlowSpam), 'urn:whStopSpam_fmWh-waSlowSpam', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IwaSlowSpam), 'urn:whStopSpam_fmWh-waSlowSpam#MailtoStrObfuscate');

end.