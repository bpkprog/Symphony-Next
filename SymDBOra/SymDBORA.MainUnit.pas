unit SymDBORA.MainUnit;

interface

function Connect(var Server: String; var Database: String; var UserName: String; Password: String): TObject; export ;
function ReConnect(Session: TObject): Integer ; export ;
function Close(Session: TObject): Integer ; export ;

exports Connect, ReConnect, Close ;

implementation

uses System.SysUtils, VCL.Dialogs, VCL.Forms, Ora, OdacVcl, DBAccess ;

function Connect(var Server: String; var Database: String; var UserName: String; Password: String): TObject;
Var
  Session: TOraSession ;
  ConnectDialog: TConnectDialog ;
//  TryCount: Integer ;
begin
  Result                  := nil ;
  ConnectDialog           := TConnectDialog.Create(Application);
  ConnectDialog.LabelSet  := lsRussian ;

  Session                 := TOraSession.Create(Application);
  Session.Server          := Server ;
  Session.Username        := UserName ;
  Session.Password        := Password ;
  Session.ConnectPrompt   := Password = EmptyStr ;
  Session.ConnectDialog   := ConnectDialog ;
//  TryCount                := 0 ;
//  while TryCount < 4 do
//  begin
//    Try
      Try
        Session.Connect ;
        if Session.Connected then
        begin
          Server                  := Session.Server   ;
          UserName                := Session.Username ;
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
//    Finally
//      Inc(TryCount) ;
//    End;
//  end;



end;

function ReConnect(Session: TObject): Integer ;
Var
  S: TOraSession ;
begin
  Result  := -1 ;
  if not (Session is TOraSession) then
                                      Exit ;

  Result  := 0 ;
  S       := TOraSession(Session) ;
  Try
    S.Connect ;
  Except on E: Exception do
    Result  := 1 ;
  End;
end;

function Close(Session: TObject): Integer ;
Var
  S: TOraSession ;
begin
  Result  := -1 ;
  if not (Session is TOraSession) then
                                      Exit ;

  Result  := 0 ;
  S       := TOraSession(Session) ;
  Try
    S.Disconnect ;
  Except on E: Exception do
    Result  := 1 ;
  End;
end;

end.
