unit whSchedule_uImport;

interface

function ImportProductAbout: Boolean;

implementation

uses
  SysUtils, Classes,
  ucString, ucLogFil, ucDlgs,
  IB_Components,
{$IFDEF IBO_49_OR_GREATER} 
  IB_Access,  // part of IBObjects 4.9.5 and 4.9.9 but not part of v4.8.6
{$ENDIF}
  //CodeRage_dmCommon;
  uFirebird_Connect_CodeRageSchedule;

function ImportProductAbout: Boolean;
var
  S: string;
  ProductName: array[1..5] of string;
  ProductNo: array[1..5] of integer;
  EventTitle: string;
  FileContents: string;
  y: TStringList;
  i: Integer;
  j: Integer;
  findprod: TIB_Cursor;
  findevent: TIB_Cursor;
  EventID: Integer;
const
  cFilespec = 'D:\Projects\WebHubDemos\Source\' +
    'WHApps\DB Examples\whSchedule\DBDesign\' +
    'CodeRageScheduleProducts.txt';
begin
  Result := True;
  y := nil;
  findprod := nil;
  findevent := nil;
  FileContents := StringLoadFromFile(cFilespec);
  bufferFor_About.SetPrimaryKeyOnInsert := True;
  try
    try
      dmCommon.tr1.StartTransaction;

      y := TStringList.Create;
      findprod := TIB_Cursor.Create(nil);
      findprod.IB_Connection := dmCommon.cn1;
      findprod.SQL.Text := 'select * ' +
        'from xproduct where ' +
        '(ProductName = :ProdName) ';
      IbObj_PrepareEx(findprod, dmCommon.cn1, dmCommon.tr1, dmCommon.sess1);

      findevent := TIB_Cursor.Create(nil);
      findevent.IB_Connection := dmCommon.cn1;
      findevent.SQL.Text := 'select * from schedule ' +
        'where ' +
        '(SchTitle starting with :Something)';
      IbObj_PrepareEx(findevent, dmCommon.cn1, dmCommon.tr1, dmCommon.sess1);

      y.Text := FileContents;
      for i := 0 to pred(y.Count) do
      begin
        S := y[i];
        if SplitFour(S, #9, ProductName[1], ProductName[2],
          ProductName[3], S) then
        begin
          if SplitThree(S, #9, ProductName[4], ProductName[5],
            EventTitle) then
          begin
            EventTitle := StringReplaceAll(EventTitle, '*', '');
            EventTitle := Trim(EventTitle);

            for j := 1 to 5 do
            begin
              ProductName[j] := Trim(ProductName[j]);
              if ProductName[j] = '' then
                ProductNo[j] := -1
              else
              begin
                findprod.Close;
                findprod.Params[0].AsString := ProductName[j];
                findprod.Open;
                ProductNo[j] := findprod.Fields[0].asInteger; //key
                findprod.Close;
              end;
            end;

            findevent.Close;
            findevent.Params[0].AsString := EventTitle;
            findevent.Open;
            if findevent.RecordCount = 0 then
            begin
              Result := False;
              LogSendError(IntToStr(findevent.RecordCount), EventTitle);
              MsgErrorOk('not found' + sLineBreak +
                EventTitle + sLineBreak +
                IntToStr(findevent.RecordCount));
              Exit;
            end;
            while NOT findevent.eof do
            begin
              EventID := findevent.Fields[0].AsInteger;
              for j := 1 to 5 do
              begin
                if ProductNo[j] <> -1 then
                begin
                  dmCommon.SetDefaultsFor_About;
                  bufferFor_About.SchNo := EventID;
                  bufferFor_About.ProductNo := ProductNo[j];
                  dmCommon.InsertRecordInto_About;
                end;
              end;
              findevent.Next;
            end;

            findevent.Close;

            {msgInfoOk(ProductName[1] + sLineBreak +
              ProductName[2] + sLineBreak +
              ProductName[3] + sLineBreak +
              ProductName[4] + sLineBreak +
              ProductName[5] + sLineBreak +
              '#' + IntToStr(EventID) + #9 + EventTitle +
                sLineBreak +
              Format('%d %d %d %d %d',
               [ProductNo[1], ProductNo[2], ProductNo[3],
               ProductNo[4], ProductNo[5]])
              );}

          end;

        end;

      end;
      dmCommon.tr1.Commit;
    except
      on E: Exception do
      begin
        dmCommon.tr1.Rollback;
      end;
    end;
  finally
    FreeAndNil(y);
    FreeAndNil(findprod);
    FreeAndNil(findevent);
  end;
end;

end.
