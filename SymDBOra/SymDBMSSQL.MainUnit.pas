unit SymDBMSSQL.MainUnit;

interface

function Connect(var Server: String; var Database: String; var UserName: String; Password: String): TObject; export ;
function ReConnect(Session: TObject): Integer ; export ;
function Close(Session: TObject): Integer ; export ;

exports Connect, ReConnect, Close ;

implementation

uses System.SysUtils, System.StrUtils, System.Types,
     VCL.Dialogs, VCL.Forms, Data.Win.ADODB ;

function GetConnValue(ConnStr, ParamName: String): String ;
Var
  Params: TStringDynArray ;
  Param: TStringDynArray ;
  i: Integer;
begin
  Params  := SplitString(ConnStr, ';') ;
  for i := Low(Params) to High(Params) do
    if Pos(ParamName, Params[i]) = 1 then
    begin
      Param  := SplitString(Params[i], '=') ;
      Result  := Param[Low(Param) + 1] ;
      Break ;
    end;
end;

function Connect(var Server: String; var Database: String; var UserName: String; Password: String): TObject;
Var
  Session: TADOConnection ;
begin
  Result                  := nil ;
  Session                   := TADOConnection.Create(Application);
  Session.ConnectionString  := Format('Provider=SQLOLEDB.1;Password=%s;Persist Security Info=True;User ID=%s;Initial Catalog=%s;Data Source=%s',
                                            [Password, UserName, Database, Server]) ;
  Session.LoginPrompt       := Password = EmptyStr ;
  Try
    Session.Open ;
    if Session.Connected then
    begin
      Server                  := GetConnValue(Session.ConnectionString, 'Data Source') ;
      UserName                := GetConnValue(Session.ConnectionString, 'User ID') ;
      Result                  := Session ;
    end;
  except on E: Exception do
        begin
          if E is EAbort then
              raise EABort.Create(E.Message)
          else
            MessageDlg(E.Message, mtError, [mbOK], 0) ;
        end;
  end;
end;

function ReConnect(Session: TObject): Integer ;
Var
  S: TADOConnection ;
begin
  Result  := -1 ;
  if not (Session is TADOConnection) then
                                      Exit ;

  Result  := 0 ;
  S       := TADOConnection(Session) ;
  Try
    S.Open ;
  Except on E: Exception do
    Result  := 1 ;
  End;
end;

function Close(Session: TObject): Integer ;
Var
  S: TADOConnection ;
begin
  Result  := -1 ;
  if not (Session is TADOConnection) then
                                      Exit ;

  Result  := 0 ;
  S       := TADOConnection(Session) ;
  Try
    S.Close ;
  Except on E: Exception do
    Result  := 1 ;
  End;
end;

end.
