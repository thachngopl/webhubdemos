unit ucAWS_CloudFront_PrivateURLs;

{$I hrefdefines.inc}
{$DEFINE LOGAWSSign}

interface

uses
  SysUtils;

type TCloudFrontSecurityProvider = class(TObject)
  strict private
    FKeyPairID: string;
    FPrivateKeyPEM: string;
    FPolicy: string;
    FDiskFolder: string;
    function getUrlSafeString(const unsafeURLStr: string): string;
  protected
    procedure SetPolicy(const Value: string);
  public
    function GetCustomUrl(const url: string): string; overload;
    function GetCustomUrl(const url: string; const expirationUTC: TDateTime;
      const allowedCidr: string): string; overload;

/// <param name="policyPlain">Be sure that whitespace has already been stripped.
/// </param>
    function GetCustomUrl(const url, policyPlain: string): string;
      overload;

/// <param name="url">Absolute url starting from http and ending with the file
/// to be retrieved.  If you start with http://, the policy will be signed for
/// http*// so that both http and https will work for the same file.
/// </param>
/// <param name="expirationUTC">Expiration TDateTime for the policy. Required.
/// </param>
/// <param name="allowedCidr">allow access when client matches this Cidr;
/// example '192.168.0.0/24'; leave blank for no condition based on ip.
/// </param>
    function GetPolicyAsStr(const url: string; const expirationUTC: TDateTime;
      const allowedCidr: string): string;

    function Sign(const StringToSign: string): string;

    property DiskFolder: string read FDiskFolder write FDiskFolder;
    property Policy: string read FPolicy write SetPolicy;
    property KeyPairID: string read FKeyPairID write FKeyPairID;
    property PrivateKeyPEM: string read FPrivateKeyPEM write FPrivateKeyPEM;

end;

implementation

uses
  DateUtils, Classes,
  ucMsTime, ucString, ucAWS_Security, ucCodeSiteInterface,
  uChilkatInterface;

function TCloudFrontSecurityProvider.GetPolicyAsStr(const url: string;
  const expirationUTC: TDateTime; const allowedCidr: string): string;
const cFn = 'GetPolicyAsStr';
var
  sb: TStringBuilder;
  epoch: Int64;
  flexURL: string;
  dt: TDateTime;
begin
  sb := nil;
  flexURL := url.Replace('http:', 'http*:'); // allow https if asking for http
  
  try
    sb := TStringBuilder.Create;  // without any whitespace
    sb.Append('{');
    sb.Append('"Statement":[');
    sb.Append('{');
    sb.Append('"Resource":"');
      sb.Append(flexURL);
      sb.Append('",');
    sb.Append('"Condition":{');
    if allowedCidr <> '' then
    begin
      sb.AppendFormat('"IpAddress":{"AWS:SourceIp":"%s"}',
        [allowedCidr]);
    end;
    if expirationUTC < NowUTC then
      LogProgrammerErrorToCodeSite(Format('%s: %s utc expires in the PAST', [cFn,
        FormatDateTime('yyyy-mm-dd hh:nn:ss', expirationUTC)]));

    if false then
    begin
    epoch := DateTimeToUnix(IncMinute(NowUTC, -15), True);
    sb.Append(',');
    sb.AppendFormat('"DateGreaterThan":{"AWS:EpochTime":%d}',
      [epoch]); // allow for some slow clocks
    end;

    if expirationUTC <> 0 then
    begin
      dt := EncodeDateTime(2016,6,23,1,2,3,0);
      epoch := DateTimeToUnix(dt, True);
      sb.AppendFormat(',"DateLessThan":{"AWS:EpochTime":%d}', [ epoch ]);
    end;

    sb.Append('}');
    sb.Append('}');
    sb.Append(']');
    sb.Append('}');

    // test in http://jsonlint.com/
    Result := sb.ToString;
  finally
    FreeAndNil(sb);
  end;
end;

function TCloudFrontSecurityProvider.getUrlSafeString(
  const unsafeURLStr: string): string;
begin
  result := unsafeURLStr;
  Result := Result.Replace('+', '-').Replace('=', '_').Replace('/', '~');
end;

procedure TCloudFrontSecurityProvider.SetPolicy(const Value: string);
begin
  FPolicy := StripWhitespace(Value);
end;

function TCloudFrontSecurityProvider.Sign(const StringToSign: string): string;
const cFn = 'Sign';
var
  IndyAnswer, ChilkatAnswer: string;
begin
  {$IFDEF LOGAWSSign}CSEnterMethod(Self, cFn);{$ENDIF}

  LogToCodeSiteKeepCRLF('PrivateKeyPEM', PrivateKeyPEM);

  IndyAnswer := Indy_OpenSSL_Sign_SHA1(StringToSign, PrivateKeyPEM);
  ChilkatAnswer := Chilkat_OpenSSL_Sign_SHA1(StringToSign, PrivateKeyPEM);

  if IndyAnswer <> ChilkatAnswer then
  begin
    CSSendError('Indy answer does NOT equal Chilkat answer');
    LogToCodeSiteKeepCRLF('IndyAnswer', IndyAnswer);
    LogToCodeSiteKeepCRLF('ChilkatAnswer', ChilkatAnswer);
  end
  else
    CSSendNote('Indy answer matches Chilkat');

  Result := IndyAnswer;

  {$IFDEF LOGAWSSign}CSExitMethod(Self, cFn);{$ENDIF}
end;

function TCloudFrontSecurityProvider.GetCustomUrl(
  const url, policyPlain: string): string;
const cFn = 'GetCustomUrl';
var
  PolicyBase64: string;
  signatureFromOpenSSL: string;
begin
  {$IFDEF LOGAWSSign}CSEnterMethod(Self, cFn);{$ENDIF}

  { Excellent guide to building the url string:
  http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-custom-policy.html#private-content-custom-policy-statement-examples
  }

  { Your policy statement in JSON format, with white space removed, then base64
    encoded. }
  policyBase64 := StringToBase64NoCRLF(UTF8String(policyPlain));

  {$IFDEF LOGAWSSign}
  CSSend(cFn + ': policyPlain', policyPlain);
  LogToCodeSiteKeepCRLF(cFn + ': should have NoCRLF: policyBase64', policyBase64);
  {$ENDIF}

  { A hashed, signed, and base64-encoded version of the JSON policy statement.
    For more information, see Creating a Signature for a Signed URL That Uses a
    Custom Policy.
  }
  signatureFromOpenSSL := sign(policyPlain);
  {$IFDEF LOGAWSSign}
  LogToCodeSiteKeepCRLF('signatureFromOpenSSL, BEFORE', signatureFromOpenSSL);
  CSSend('Length of signatureFromOpenSSL', S(Length(signatureFromOpenSSL)));
  {$ENDIF}

  signatureFromOpenSSL := signatureFromOpenSSL
       //.Replace(#13, '',  [rfReplaceAll])
       //.Replace(#10, '',  [rfReplaceAll])
       .Replace('+', '-', [rfReplaceAll])
       .Replace('=', '_', [rfReplaceAll])
       .Replace('/', '~', [rfReplaceAll]);

  {$IFDEF LOGAWSSign}
  LogToCodeSiteKeepCRLF('signatureFromOpenSSL, AFTER', signatureFromOpenSSL);
  CSSend('FPrivateKeyID', FKeyPairID);
  {$ENDIF}

  // return url + string.Format("?Policy={0}&Signature={1}&Key-Pair-Id={2}",
  // getUrlSafeString(Encoding.ASCII.GetBytes(policy)),
  // signature, privateKeyId);
  Result := url + '?' + Format(
    'Policy=%s&Signature=%s&Key-Pair-Id=%s',
    [getUrlSafeString(policyBase64), signatureFromOpenSSL, FKeyPairID]);

  {$IFDEF LOGAWSSign}
  LogToCodeSiteKeepCRLF(cFn + ': Result', Result);
  CSExitMethod(Self, cFn);
  {$ENDIF}
end;

function TCloudFrontSecurityProvider.GetCustomUrl(const url: string;
  const expirationUTC: TDateTime;
  const allowedCidr: string): string;
var
  policyPlain: string;
begin
  policyPlain := GetPolicyAsStr(url, expirationUTC, allowedCidr);
  Result := GetCustomUrl(url, policyPlain);
end;

function TCloudFrontSecurityProvider.GetCustomUrl(const url: string): string;
begin
  Result := GetCustomUrl(url, Self.FPolicy);
end;

end.
