unit fmIndyEMailSSL;

(*
Copyright (c) 2013 HREF Tools Corp.

Permission is hereby granted, on 29-Dec-2013, free of charge, to any person
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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  tpCompPanel, IdIPMCastBase, IdIPMCastClient, IdIOHandler,
  IdIOHandlerStream, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP,
  IdMessage, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdAttachment, IdAttachmentFile;

type
  TForm3 = class(TForm)
    Panel1: TPanel;
    edTo: TLabeledEdit;
    edFrom: TLabeledEdit;
    edSubject: TLabeledEdit;
    Memo1: TMemo;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    RadioGroup1: TRadioGroup;
    GroupBox1: TGroupBox;
    editSMTP: TLabeledEdit;
    EditUser: TLabeledEdit;
    editPass: TLabeledEdit;
    editFilespec: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
    IdSMTP1: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdMessage1: TIdMessage;
    procedure IndyMailStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
  strict private
    function IntentionalError_SmtpServer: Boolean;
    function IntentionalError_SmtpSenderEmail: Boolean;
    function IntentionalError_SmtpUsername: Boolean;
    function IntentionalError_SmtpPassword: Boolean;
    function IntentionalError_MissingAttachment: Boolean;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses
  CodeSiteLogging,
  IdGlobal,
  ucString, ucDlgs, uCode, ucCodeSiteInterface;

const
  cFromName = 'System Test';

procedure TForm3.BitBtn2Click(Sender: TObject);

  function VERP(const FromAddress, ToAddress: string): string;
  var
    a1, a2: string;
  begin
    SplitString(FromAddress, '@', a1, a2);  // info @ suretreat.com
    Result := a1 + '+' +
      StringReplaceAll(ToAddress, '@', '=') + '@' + a2;
  end;

begin
  BitBtn2.Enabled := False;
  Self.Update;
  with idMessage1 do
  begin
    idMessage1.Recipients.Clear;
    idMessage1.MessageParts.Clear;

    // bounce@simulator.amazonses.com
    // ooto@simulator.amazonses.com
    // complaint@simulator.amazonses.com
    // suppressionlist@simulator.amazonses.com

    (* The mailbox simulator supports labeling, which enables you to test your
    support for Variable Envelope Return Path (VERP). For example, you can send
    an email to bounce+label1@simulator.amazonses.com and
    bounce+label2@simulator.amazonses.com to test how your setup matches a
    bounce message with the undeliverable address that caused the bounce. For
    more information about VERP, see
    http://en.wikipedia.org/wiki/Variable_envelope_return_path.
    *)
    idMessage1.Recipients.EMailAddresses := edTo.Text;
    CSSend('idMessage1.Recipients.EMailAddresses',
      idMessage1.Recipients.EMailAddresses);
    idMessage1.Subject := edSubject.Text;
    //idMessage1.From.Address := VERP(edFrom.Text, edTo.Text);  // see VERP

    idMessage1.From.Address := edFrom.Text;
    if IntentionalError_SmtpSenderEmail then
      idMessage1.From.Address := LeftOf('@', edFrom.Text) +
        '@invalid.microsoft.com';

    idMessage1.From.Name := cFromName;
    CSSend('idMessage1.From.Address', idMessage1.From.Address);
    idMessage1.Body.Text := Memo1.Lines.Text + sLineBreak + 'sent by ' +
      idSMTP1.ClassName + ' compiled with Delphi ' + PascalCompilerCode +
      sLineBreak + ' using ' +
      'Amazon email server ' + editSMTP.Text + sLineBreak;

    idMessage1.CharSet := 'utf-8';
    idMessage1.Encoding := mePlainText;
    idSMTP1.Host := editSMTP.Text;
    if IntentionalError_SmtpServer then
      idSMTP1.Host := 'invalid.' + idSMTP1.Host;
    idSMTP1.Username := editUser.Text;
    if IntentionalError_SmtpUsername then
      idSMTP1.Username := 'bad' + Copy(idSMTP1.Username, 4, MaxInt);

    idSMTP1.Password := editPass.Text;
    if IntentionalError_SmtpPassword then
      idSMTP1.Password := 'bad' + Copy(idSMTP1.Password, 4, MaxInt);

    if Checkbox1.Checked then
    begin
      if NOT IntentionalError_MissingAttachment then
        TIdAttachmentFile.Create(idMessage1.MessageParts, editFilespec.Text)
      else
        TIdAttachmentFile.Create(idMessage1.MessageParts,
          ChangeFileExt(editFilespec.Text, '.bad'));
    end;

    CSSend('idSMTP1.Host', idSMTP1.Host);
  end;

    try
      if NOT idSMTP1.Connected then
        idSMTP1.Connect;
      idSMTP1.Send(idMessage1);
      idMessage1.MessageParts.Clear;
      idSMTP1.Disconnect;
    except
      on E: Exception do
      begin
        CSSendNote('Indy Exception');
        CSSendException(E);
        idSMTP1.Disconnect;
        MsgErrorOk('Exception' + sLineBreak + E.Message + sLineBreak
        {$IFDEF CodeSite} + 'See details in CodeSite log'{$ENDIF}
        );
      end;
    end;

  BitBtn2.Enabled := True;
end;

procedure TForm3.FormCreate(Sender: TObject);
const cFn = 'FormCreate';
begin
  CSEnterMethod(Self, cFn);
  IdSMTP1 := TIdSMTP.Create(nil);
  IdSMTP1.Name := 'IdSMTP1';
  IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  IdSSLIOHandlerSocketOpenSSL1.Name := 'IdSSLIOHandlerSocketOpenSSL1';
  with IdSSLIOHandlerSocketOpenSSL1 do
  begin
    MaxLineAction := TIdMaxLineAction.maException;
    Port := 0;
    DefaultPort := 0;
    SSLOptions.Mode := sslmUnassigned;
    SSLOptions.VerifyMode := []; // [sslvrfFailIfNoPeerCert];
    SSLOptions.VerifyDepth := 0;

    //  let the SSL/TLS handshake determine the highest
    // available SSL/TLS version dynamically.
    SSLOptions.Method := TIdSSLVersion.sslvSSLv23;
  end;

  IdMessage1 := TIdMessage.Create(Self);
  IdMessage1.Name := 'IdMessage1';
  with IdMessage1 do
  begin
    AttachmentEncoding := 'UUE';
    Encoding := meDefault;
    ConvertPreamble := True;
  end;

  with IdSMTP1 do
  begin
    OnStatus := IndyMailStatus;
    IOHandler := IdSSLIOHandlerSocketOpenSSL1;
    Port := 587;
    SASLMechanisms.Clear;
    UseTLS := utUseExplicitTLS;
  end;
  CSExitMethod(Self, cFn);
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  idMessage1.MessageParts.Clear;
  FreeAndNil(idMessage1);
  FreeAndNil(IdSSLIOHandlerSocketOpenSSL1);
  FreeAndNil(idSMTP1);
end;

procedure TForm3.IndyMailStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  CSSend(idSMTP1.Name, AStatusText);
end;

function TForm3.IntentionalError_MissingAttachment: Boolean;
begin
{ leads to exception
Cannot open file "D:\Kynosoura\Projects\book-googledrive\Who Knew - Public Edition\Book Cloud\2013-11-05_Germany_WSJ_ValuableCacheOfNazi-SeizedArt.bad". The system cannot find the file specified
}
  Result := RadioGroup1.ItemIndex = 6;
end;

function TForm3.IntentionalError_SmtpPassword: Boolean;
begin
  Result := RadioGroup1.ItemIndex = 3;
end;

function TForm3.IntentionalError_SmtpSenderEmail: Boolean;
begin
{ leads to exception from Amazon SES through mail dialogue:
Message rejected: Email address is not verified.
}
  Result := RadioGroup1.ItemIndex = 4;
end;

function TForm3.IntentionalError_SmtpServer: Boolean;
begin
{ leads to exception:
Socket Error # 11001
Host not found. }
  Result := RadioGroup1.ItemIndex = 1;
end;

function TForm3.IntentionalError_SmtpUsername: Boolean;
begin
{ leads to exception
Authentication Credentials Invalid
}
  Result := RadioGroup1.ItemIndex = 2;
end;

end.