unit uSeleniumShared;

interface

uses
  uISelenium_1_0_3;

function selenium_Open(url: UTF8String): boolean;
function selenium_Click(locator: UTF8String): boolean;
function selenium_ClickAndWait(locator: UTF8String): boolean;
function selenium_save(title: UTF8String): boolean;
function selenium_Type(const locator, value: UTF8String): boolean;
function selenium_GoBack(): boolean;
function selenium_MouseMove(locator: UTF8String): boolean;
function selenium_WaitForPageToLoad(timeout: UTF8String): boolean;

var
  selenium_server: UTF8String = '';
  selenium_server_port: integer;
  browser: UTF8String = '*chrome'; //'*firefox'; //'*iexplore';
  //browser := '*custom C:\\Program Files\\Mozilla Firefox\\firefox.exe -no-remote -profile d:\\apps\\selenium\\server\\firefoxselenium';
  currentTestID: UTF8String;
  currectBaseUrl: UTF8String;
  currentLogPath: string;
  selenium: ISelenium;
  PageIndex: integer;

implementation

uses
  Forms, SysUtils, Windows,
  ucLogFil,
  ldiRegEx,   // search path use H:\ or K:\WebHub\regex
  uSeleniumIgnoreChanging, uDefaultSelenium_1_0_3;


procedure Log(const S: UTF8String); overload;
begin
  //TestMNH_uMain.Log(s);
  HREFTestLog('info', '', string(S));
end;

procedure Log(const S: string); overload;
begin
  //TestMNH_uMain.Log(s);
  HREFTestLog('info', '', S);
end;


function selenium_Open(url: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Index=%d, Open(%s)', [PageIndex, url]));
    Log(string(cmd));

// Joshua    selenium.start('captureNetworkTraffic=true');
    (*
    To use it, just call
    selenium.start("captureNetworkTraffic=true"),
    and then later on in your script you can call
    selenium.captureNetworkTraffic("...")
    where "..." is "plain", "xml", or "json".
    *)
   //Ann selenium.start('captureNetworkTraffic=true');
    selenium.Open(url);
   //Ann selenium.captureNetworkTraffic('plain');
//Joshua    selenium.captureNetworkTraffic('plain');


    result := selenium_save(cmd);
    // Joshua : turn off capture ?
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      Inc(PageIndex);
      result := false;
    end;
  end;
end;

function selenium_Click(locator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Index=%d, Click(%s)', [PageIndex, locator]));
    Log(cmd);
    selenium.Click(locator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.Click(locator);
    result := selenium_save(cmd);
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      Inc(PageIndex);
      result := false;
    end;
  end;
end;

function selenium_ClickAndWait(locator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Index=%d, ClickAndWait(%s)',
      [PageIndex, locator]));
    Log(cmd);
    selenium.ClickAndWait(locator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.ClickAndWait(locator);
    result := selenium_save(cmd);
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      Inc(PageIndex);
      result := false;
    end;
  end;
end;

function selenium_GoBack(): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Index=%d, GoBack()', [PageIndex]));
    Log(cmd);
    selenium.GoBack();
    selenium.WaitForPageToLoad('30000');
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.GoBack();
    result := selenium_save(cmd);
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      Inc(PageIndex);
      result := false;
    end;
  end;
end;


function selenium_WaitForPageToLoad(timeout: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('WaitForPageToLoad(%s)', [timeout]));
    Log(cmd);
    selenium.WaitForPageToLoad(timeout);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.WaitForPageToLoad(timeout);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;

function selenium_Type(const locator, value: UTF8String): boolean;
var
  cmdinfo: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmdinfo := 'Type(' + locator + ', ' + value + ')';
    Log(cmdinfo);
    selenium.Type_(locator, value);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;


function selenium_Check(locator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Check(%s)', [locator]));
    Log(cmd);
    selenium.Check(locator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.Check(locator);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;

function selenium_Uncheck(locator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Uncheck(%s)', [string(locator)]));
    Log(cmd);
    selenium.Uncheck(locator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.Uncheck(locator);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;

function selenium_Select(selectLocator: UTF8String; optionLocator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('Select(%s, %s)', [string(selectLocator),
      string(optionLocator)]));
    Log(cmd);
    selenium.Select(selectLocator, optionLocator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.Select(selectLocator, optionLocator);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;

function selenium_AddSelection(locator: UTF8String;optionLocator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('AddSelection(%s, %s)', [string(locator),
      string(optionLocator)]));
    Log(cmd);
    selenium.AddSelection(locator, optionLocator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.AddSelection(locator, optionLocator);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;

function selenium_RemoveSelection(locator: UTF8String;optionLocator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('RemoveSelection(%s, %s)',
      [locator, optionLocator]));
    Log(cmd);
    selenium.RemoveSelection(locator, optionLocator);
    //Log(Format('host:(%s) cmd:%s', [selenium2_url, cmd]));
    //selenium2.RemoveSelection(locator, optionLocator);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(UTF8String(Format('Exception: %s', [e.Message])));
      result := false;
    end;
  end;
end;

function selenium_MouseMove(locator: UTF8String): boolean;
var
  cmd: UTF8String;
begin
  Application.ProcessMessages;
  try
    cmd := UTF8String(Format('MouseMove(%s)', [string(locator)]));
    Log(cmd);
    selenium.MouseMove(locator);
    result := true;
  except
    on E: Exception do
    begin
      Log('************* Exception ***********');
      Log(Format('Exception: %s', [e.Message]));
      result := false;
    end;
  end;
end;

function selenium_save(title: UTF8String): boolean;
var
  s_org: UTF8String;
  s: UTF8String;
  filename: string;
begin

  s_org := 'placeholder';

  // Reference http://groups.google.com/group/selenium-users/browse_thread/thread/9d30035cf39676b8/a093cf7fe8c91a8a?lnk=gst&q=gethtmlsource#a093cf7fe8c91a8a

  if false then
  begin
  Selenium.getEval(
    'window.location = ''view-source:'' + window.location;');
  s_org := Selenium.getBodyText();
  // close the view-source window
  Selenium.getEval('this.browserbot.getCurrentWindow().close()');
  //Selenium.getEval('window.location = ''' + s_old_location + '''');
  //Selenium.GoBack();
  Selenium.WaitForPageToLoad('8000');  // 8 seconds?
  //Selenium.SelectFrame('relative=top');
  //Selenium.getEval('window.history.go(-1)');
  end;

  if false then
  begin
    S := StripChanging(s_org);
  end
  else
    s := s_org;

  filename := currentLogPath + IntToStr(PageIndex) + '.txt';
  UTF8StringWriteToFile(filename, Title + sLineBreak + s);

  Inc(PageIndex);
  result := true;
end;



end.
