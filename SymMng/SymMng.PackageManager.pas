{**********************************************************************}
{                          Менеджер пакетов                            }
{                                                                      }
{   Менеджер пакетов управляет множественной загрузкой и выгрузкой     }
{    одного и того же пакета. При загрузке счетчик загрузок            }
{    увеличивается на единицу, при выгрузке уменьшается.               }
{    Если при выгрузке счетчик равен нулю, то пакет выгружается из     }
{    памяти                                                            }
{                                                                      }
{**********************************************************************}

unit SymMng.PackageManager;

interface

uses WinAPI.Windows, Generics.Collections ;

Type
  TPackageInfo = class
  private
    FFileName: String ;
    FHandle: NativeUInt ;
    FConnectionCount: Integer ;

    function GetName: String;
  public
    constructor Create ;
    destructor Destroy ; override ;

    function  Load(AFileName: String): NativeUInt ;
    procedure UnLoad ;

    property ConnectionCount: Integer read FConnectionCount ;
    property FileName: String read FFileName ;
    property Name: String read GetName;
    property Handle: NativeUInt read FHandle ;
  end;

  TPackageManager = class(TObjectList<TPackageInfo>)
  private
    function GetHandle(Name: String): NativeUInt;
    function GetIsLoad(Name: String): Boolean;
  public
    function  Load(FileName: String): NativeUInt ;
    procedure UnLoad(FileName: String) ; overload ;
    procedure UnLoad(AHandle: NativeUInt) ; overload ;
    function  IndexOf(Name: String): Integer ; overload ;
    function  IndexOf(AHandle: NativeUInt): Integer ; overload ;

    property IsLoad[Name: String]: Boolean read GetIsLoad ;
    property Handle[Name: String]: NativeUInt read GetHandle ;
  end;

Var
  PackageManager: TPackageManager ;

implementation

uses System.SysUtils ;

{ TPackageInfo }
{$REGION 'TPackageInfo'}
constructor TPackageInfo.Create;
begin
  FFileName         := EmptyStr ;
  FHandle           := 0 ;
  FConnectionCount  := 0 ;
end;

destructor TPackageInfo.Destroy;
begin
  FConnectionCount  := 0 ;
//  UnLoad ;
  inherited;
end;

function TPackageInfo.GetName: String;
begin
  Result  := ExtractFileName(FileName) ;
end;

function TPackageInfo.Load(AFileName: String): NativeUInt;
begin
  Result  := 0 ;

  if FileExists(AFileName) then
  begin
    if Handle = 0 then
    begin
      FHandle   := LoadPackage(AFileName) ;
      FFileName := AFileName ;
    end;

    Inc(FConnectionCount) ;
    Result  := Handle ;
  end ;
end;

procedure TPackageInfo.UnLoad;
begin
  if FConnectionCount > 0 then
                              Dec(FConnectionCount) ;

  if (Handle > 0) and (FConnectionCount = 0) then
  begin
    UnloadPackage(Handle);
    FHandle := 0 ;
  end;
end;

{$ENDREGION}

{ TPackageManager }
{$REGION 'TPackageManager'}
function TPackageManager.GetHandle(Name: String): NativeUInt;
Var
  Index: Integer ;
begin
  Result  := 0 ;
  Index   := IndexOf(Name) ;
  if Index >= 0 then
                    Result  := Items[Index].Handle ;
end;

function TPackageManager.GetIsLoad(Name: String): Boolean;
begin
  Result  := Handle[Name] > 0 ;
end;

function TPackageManager.IndexOf(AHandle: NativeUInt): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to Count - 1 do
    if Items[i].Handle = AHandle then
    begin
      Result  := i ;
      Break ;
    end;
end;

function TPackageManager.IndexOf(Name: String): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to Count - 1 do
    if Items[i].Name = Name then
    begin
      Result  := i ;
      Break ;
    end;
end;

function TPackageManager.Load(FileName: String): NativeUInt;
Var
  Name: String ;
  Index: Integer ;
  PkgInfo: TPackageInfo ;
begin
  Result  := 0 ;
  Name    := ExtractFileName(FileName) ;
  Index   := IndexOf(Name) ;
  if Index < 0 then
                    Index  := Add(TPackageInfo.Create) ;
  PkgInfo   := Items[Index] ;
  Result    := PkgInfo.Load(FileName) ;
end;

procedure TPackageManager.UnLoad(FileName: String);
Var
  Name: String ;
  Index: Integer ;
begin
  Name    := ExtractFileName(FileName) ;
  Index   := IndexOf(Name) ;
  if Index >= 0 then
                    Items[Index].UnLoad ;
end;

procedure TPackageManager.UnLoad(AHandle: NativeUInt);
Var
  Index: Integer ;
begin
  Index   := IndexOf(AHandle) ;
  if Index >= 0 then
                    Items[Index].UnLoad ;
end;

{$ENDREGION}

initialization
  PackageManager  := TPackageManager.Create ;
finalization
  PackageManager.Free ;
end.
