unit SymphonyNext.Logger;

interface

uses System.SysUtils, Logger ;

Type
  TSNLog = class
  private
    FLog: TLog ;
  public
    constructor Create  ;
    destructor  Destroy ; override ;

    procedure InitLog ;
    procedure Open(FileName: String) ;

    procedure EnterMethod(const MethodName: String; const ParamNames: array of String; const ParamValues: array of String) ;
    procedure ExitMethod(const MethodName: String) ;

    procedure WriteException(E: Exception) ;
    procedure Write(const Message: String) ; overload ;
    procedure Write(const Message: string; const Args: array of const) ; overload ;
  end;

Var
  Log: TSNLog ;

implementation

uses FMX.SpecFoldersObj ;

{ TSNLog }

constructor TSNLog.Create;
begin
  FLog  := nil ;
end;

destructor TSNLog.Destroy;
begin
  if FLog <> nil then
                    FLog.Free ;
  inherited;
end;

procedure TSNLog.EnterMethod(const MethodName: String; const ParamNames,
                                                ParamValues: array of String);
begin
  if FLog <> nil then
                    FLog.EnterMethod(MethodName, ParamNames, ParamValues);
end;

procedure TSNLog.ExitMethod(const MethodName: String);
begin
  if FLog <> nil then
                    FLog.ExitMethod(MethodName);
end;

procedure TSNLog.InitLog;
Var
  LogFileName: String ;
begin
  LogFileName  := SpecFolders.AppDataPath + 'log\' ;
  if not DirectoryExists(LogFileName) then
                                          ForceDirectories(LogFileName) ;
  LogFileName := LogFileName + {IntToStr(Trunc(10000000 * Now)) +} 'start.log';
  Log.Open(LogFileName);
end;

procedure TSNLog.Open(FileName: String);
begin
  if FLog <> nil then
                      FLog.Free ;
  FLog  := TLog.Create(FileName);
end;

procedure TSNLog.Write(const Message: String);
begin
  if FLog <> nil then
                    FLog.Write(Message);
end;

procedure TSNLog.Write(const Message: string; const Args: array of const);
begin
  if FLog <> nil then
                    FLog.Write(Message, Args);
end;

procedure TSNLog.WriteException(E: Exception);
begin
  FLog.WriteExceptionInfo(E);
end;

initialization
  Log := TSNLog.Create ;
finalization
  Log.Free ;
end.
