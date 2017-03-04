{*****************************************************************}
{            Менеджер соединений с базами данных                  }
{                                                                 }
{   Менеджер соединений является коллекцией объектов-соединений   }
{   Каждый объект-соединение управляет загрузкой пакета,          }
{   реализующего соединение с базой данных, возвращает компонент  }
{   соединения, а также ведет список плагинов, использующих это   }
{   соединение. Если соединение не используется плагинами, значит }
{  его можно закрывать, если это не базовое соединение            }
{*****************************************************************}

unit SymMng.ConnectionMng;

interface

Uses System.Classes, System.Generics.Collections ;

Type
  TConnection = class
  private
    FDBType: String   ;
    FServer: String   ;
    FDataBase: String ;
    FUserName: String ;
    FPassword: String ;
    FSession: TObject ;
    FHandle: NativeUInt ;
    FPlugins: TStrings ;
    procedure CloseSession ; overload ;
  public
    constructor Create(ADBType, AServer, ADatabase, AUserName, APassword: String) ;
    destructor  Destroy ; override ;

    function  Connect(PlugIn: String): TObject ;
    function  ReConnect: Integer ;
    procedure CloseSession(PlugIn: String) ;  overload ;

    function Equal(ADBType, AServer, ADatabase: String): Boolean ; overload ;
    function Equal(ADBType: String): Boolean ; overload ;
    function Equal(AConnection: TConnection): Boolean ; overload ;

    property DBType: String   read FDBType   ;
    property Server: String   read FServer   ;
    property DataBase: String read FDataBase ;
    property UserName: String read FUserName ;

    property Session: TObject read FSession ;
    property Handle: NativeUInt read FHandle ;
    property Plugins: TStrings read FPlugins ;
  end;

  TConnectionMng = class(TObjectList<TConnection>)
  private
    function GetBaseConnection: TConnection;
    function GetEqualConnection(ADBType, AServer, ADatabase: String): TConnection ;
    function GetDBTypeConnection(ADBType, AServer, ADatabase, AUserName, APassword: String): TConnection ;
    function CreateNewConnection(ADBType, AServer, ADatabase, AUserName, APassword: String): TConnection ;
    function ConnectionCountByHandle(AHandle: NativeUInt): Integer ;
    procedure UnloadConnectionPackage(AHandle: NativeUInt) ;
  public
    destructor Destroy ; override ;

    function  GetConnection(PlugIn, ADBType, AServer, ADatabase, AUserName, APassword: String): TConnection ;
    procedure CloseSession(PlugIn: String) ;

    property BaseConnection: TConnection read GetBaseConnection ;
  end ;

implementation

uses System.SysUtils, WinAPI.Windows, VCL.Forms , SymMng.PackageManager;

Type
  TConnectFunc    = function (var Server: String; var Database: String; var UserName: String; Password: String): TObject;
  TReConnectFunc  = function (Session: TObject): Integer ;
  TCloseFunc      = function (Session: TObject): Integer ;

{ TConnection }
{$REGION 'TConnection'}
procedure TConnection.CloseSession(PlugIn: String);
Var
  Index: Integer ;
begin
  Index := FPlugins.IndexOf(PlugIn) ;
  if Index >= 0 then
                    FPlugins.Delete(Index);
end;

procedure TConnection.CloseSession;
Var
  Fn: TCloseFunc ;
begin
  if (FSession = nil) or (FHandle = 0) then
                                            Exit ;
  Fn  := GetProcAddress(FHandle, 'Close') ;
  if Assigned(Fn) then
                      Fn(FSession) ;
end;

function TConnection.Connect(PlugIn: String): TObject;
Var
  FileName: String ;
  Fn: TConnectFunc ;
begin
  Result  := nil ;
  if FHandle = 0 then
  begin
    FileName  := Format('%sSymDB%s.bpl', [ExtractFilePath(Application.ExeName), FDBType]) ;
    FHandle   := PackageManager.Load(FileName) ;
    if FHandle = 0 then
      raise Exception.CreateFmt('Ошибка загрузки библиотеки "%s"', [FileName]);
  end;

  if FSession = nil then
  begin
    Fn  := GetProcAddress(FHandle, 'Connect') ;
    if Assigned(Fn) then
                        FSession  := Fn(FServer, FDataBase, FUserName, FPassword) ;
  end;

  if FSession = nil then
                        Exit ;
  FPlugins.Add(PlugIn) ;
  Result  := FSession ;
end;

constructor TConnection.Create(ADBType, AServer, ADatabase, AUserName, APassword: String);
begin
  FPlugins  := TStringList.Create ;
  FDBType   := UpperCase(ADBType) ;
  FServer   := UpperCase(AServer) ;
  FDataBase := UpperCase(ADatabase) ;
  FUserName := AUserName ;
  FPassword := APassword ;
  FSession  := nil ;
  FHandle   := 0 ;
end;

destructor TConnection.Destroy;
begin
  if FSession <> nil then
                        CloseSession ;
{ Нельзя выгружать пакет,
  ибо могут быть загружены другие базы данных того же типа
  if FHandle > 0 then
                    UnloadPackage(FHandle) ;  }
  FPlugins.Free ;
  inherited;
end;

function TConnection.Equal(ADBType, AServer, ADatabase: String): Boolean;
begin
  Result  := (FDBType = UpperCase(ADBType)) and (FServer = UpperCase(AServer))
                                    and (FDataBase = UpperCase(ADatabase)) ;
end;

function TConnection.Equal(ADBType: String): Boolean;
begin
  Result  := FDBType = UpperCase(ADBType) ;
end;

function TConnection.Equal(AConnection: TConnection): Boolean;
begin
  Result  := Equal(AConnection.DBType, AConnection.Server, AConnection.DataBase) ;
end;

function TConnection.ReConnect: Integer;
Var
  Fn: TReConnectFunc ;
begin
  if (FSession = nil) or (FHandle = 0) then
                                            Exit ;
  Fn  := GetProcAddress(FHandle, 'ReConnect') ;
  if Assigned(Fn) then
                      Fn(FSession) ;
end;

{$ENDREGION}

{ TConnectionMng }
{$REGION 'TConnectionMng'}
procedure TConnectionMng.CloseSession(PlugIn: String);
Var
  i: Integer ;
begin
  for i := 0 to Count - 1 do
                            Items[i].CloseSession(PlugIn);
end;

function TConnectionMng.ConnectionCountByHandle(AHandle: NativeUInt): Integer;
Var
  i: Integer ;
begin
  Result  := 0 ;
  for i := 0 to Count - 1 do
    if Items[i].Handle = AHandle then
                                  Inc(Result) ;
end;

function TConnectionMng.CreateNewConnection(ADBType, AServer, ADatabase, AUserName, APassword: String): TConnection;
begin
  Result  := TConnection.Create(ADBType, AServer, ADatabase, AUserName, APassword);
  Add(Result) ;
end;

destructor TConnectionMng.Destroy;
begin
  While Count > 0 do
                  UnloadConnectionPackage(Items[Count - 1].Handle);
  inherited;
end;

function TConnectionMng.GetBaseConnection: TConnection;
begin
  Result  := nil ;
  if Count > 0 then
                  Result  := Items[0] ;
end;

function TConnectionMng.GetConnection(PlugIn, ADBType, AServer, ADatabase, AUserName, APassword: String): TConnection;
Var
  FullEqualConn: TConnection ;
  DBTypeEqualConn: TConnection ;
  i: Integer;
begin
  Result  := GetEqualConnection(ADBType, AServer, ADatabase) ;
  if Result = nil then
                    Result  := GetDBTypeConnection(ADBType, AServer, ADatabase, AUserName, APassword) ;
  if Result = nil then
                    Result  := CreateNewConnection(ADBType, AServer, ADatabase, AUserName, APassword) ;

  if Result = nil then
    raise Exception.CreateFmt('Ошибка создания соединения с базой данных %s (%s) на сервере %s для плагина %s', [ADatabase, ADBType, AServer, PlugIn]);

  Result.Connect(PlugIn) ;
end;

function TConnectionMng.GetDBTypeConnection(ADBType, AServer, ADatabase, AUserName, APassword: String): TConnection;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if Items[i].Equal(ADBType) then
    begin
      Result  := CreateNewConnection(ADBType, AServer, ADatabase, AUserName, APassword) ;
      Result.FHandle  := Items[i].Handle ;
      Break ;
    end;
end;

function TConnectionMng.GetEqualConnection(ADBType, AServer, ADatabase: String): TConnection;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if Items[i].Equal(ADBType, AServer, ADatabase) then
    begin
      Result  := Items[i] ;
      Break ;
    end;
end;

procedure TConnectionMng.UnloadConnectionPackage(AHandle: NativeUInt);
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
    if Items[i].Handle = AHandle then
        Remove(Items[i]) ;

  PackageManager.UnLoad(AHandle);
end;

{$ENDREGION}

end.
