unit CharReplace_uProcess;
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

interface

uses
  SysUtils;

function ProcessFile( const inputFilename, outputFilename: String;
                      const FromChar, ToChar: Char): Boolean;

implementation

uses 
  Classes,
  ucString, ucLogFil;

function ProcessFile( const inputFilename, outputFilename: String;
  const FromChar, ToChar: Char): Boolean;
var
  S: String;
  y: TStringList;
begin
  Result := FileExists(inputFilename);
  if NOT Result then Exit;

  y := nil;
  try
    y := TStringList.Create;
    y.LoadFromFile(inputFilename);  // Unicode Delphi sees a BOM if present
    S := StringReplaceAll(y.Text, FromChar, ToChar);
    y.Text := S;
    y.SaveToFile(outputFilename);
  finally
    FreeAndNil(y);
  end;
end;

end.
