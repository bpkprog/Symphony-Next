unit SymDBFB.MainUnit;

interface

function Connect(var Server: String; var Database: String; var UserName: String): TObject; export ;
function ReConnect(Session: TObject): Integer ; export ;
function Close(Session: TObject): Integer ; export ;

exports Connect, ReConnect, Close ;

implementation

uses System.SysUtils, VCL.Forms, IBX.IBDatabase, Vcl.DBLogDlg ;

function Connect(var Server: String; var Database: String; var UserName: String): TObject;
Var
  IBDB: TIBDatabase ;
begin
  IBDB  := TIBDatabase.Create(Application);
  IBDB.DatabaseName := Format('%s:%s', [Server, Database]) ;
  IBDB.Params.Text  := Format('user_name=%s', [UserName]) ;
  IBDB.ServerType   := 'IBServer' ;
  IBDB.Open ;
  Result  := IBDB ;
end;

function ReConnect(Session: TObject): Integer ;
Var
  IBDB: TIBDatabase ;
begin
  Result  := -1 ;
  if not (Session is TIBDatabase) then
                                      Exit ;

  Result  := 0 ;
  IBDB       := TIBDatabase(Session) ;
  Try
    IBDB.Close ;
    IBDB.Open ;
  Except on E: Exception do
    Result  := 1 ;
  End;
end;

function Close(Session: TObject): Integer ;
Var
  IBDB: TIBDatabase ;
begin
  Result  := -1 ;
  if not (Session is TIBDatabase) then
                                      Exit ;

  Result  := 0 ;
  IBDB       := TIBDatabase(Session) ;
  Try
    IBDB.Close ;
  Except on E: Exception do
    Result  := 1 ;
  End;
end;

end.
