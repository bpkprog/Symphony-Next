unit DBListMakerOra;

interface

uses System.Classes ;

function BuildDBList(DBList: TStrings): Boolean ; export ;

implementation

uses System.SysUtils, TNSNameCore;

function GetTNSNAmesFileName: String ;
Var
  Env: TOraEnvironment ;
begin
  Result  := EmptyStr ;
  Env     := TOraEnvironment.Create ;
  Try
    Result  := Env.tnsnames ;
  Finally
    Env.Free ;
  End;
end;

function BuildDBList(DBList: TStrings): Boolean ;
Var
  tns: TTNSNames ;
  FileName: String ;
  i: Integer;
begin
  FileName  := GetTNSNAmesFileName ;
  Result    := FileExists(FileName) ;
  if not Result then
                    Exit ;

  tns := TTNSNames.Create ;
  Try
    Try
      tns.LoadFromFile(FileName);
      DBList.Clear;
      for i := 0 to tns.ChildCount - 1 do
                                  DBList.Add(tns.ChildNode[i].Name) ;
    Except
      Result  := False ;
    End;
  Finally
    tns.Free ;
  End;
end;

exports BuildDBList ;

end.
