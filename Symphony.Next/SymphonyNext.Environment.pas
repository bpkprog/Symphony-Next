unit SymphonyNext.Environment;

interface

Type
  TSCFEnvironment = class
  private
    FFileName: String;
    function  GetConfig: Boolean;
    function  GetUpdate: Boolean;
    procedure SetFileName(const Value: String);
    function  ParamInList(AList: array of String): Boolean ;
    function  ReadFileName: String ;
    function  GetOSName: String;
    function  GetOSBit: Integer;
    function  GetSCFFileExists: Boolean;
    function GetLogged: Boolean;
  public
    constructor Create ;

    function ToString: string; override ;

    property FileName: String  read FFileName write SetFileName;
    property SCFFileExists: Boolean read GetSCFFileExists ;
    property Config: Boolean read GetConfig ;
    property Update: Boolean read GetUpdate ;
    property Logged: Boolean read GetLogged ;
    property OSName: String read GetOSName ;
    property OSBit: Integer read GetOSBit ;
  end;

Var
  Environment: TSCFEnvironment ;

implementation

Uses {$IFDEF MSWINDOWS}Windows,{$ENDIF}
     System.SysUtils, System.StrUtils, System.Classes, SymphonyNext.Logger ;

{ TSCFModeEnv }
{$REGION 'TSCFModeEnv'}
constructor TSCFEnvironment.Create;
begin
  Log.EnterMethod('TSCFEnvironment.Create', [], []);
  FFileName := ReadFileName ;
  Log.ExitMethod('TSCFEnvironment.Create');
end;

function TSCFEnvironment.GetConfig: Boolean;
begin
  Result  := ParamInList(['-CONFIG', '-C', '/CONFIG', '/C']) ;
end;

function TSCFEnvironment.GetLogged: Boolean;
begin
  Result  := True or ParamInList(['-LOG', '-L', '/LOG', '/L']) ;
end;

function TSCFEnvironment.GetOSBit: Integer;
{$IFDEF MSWINDOWS}
  function IsWow64: BOOL;
  type
    TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall;
  var
    IsWow64Process: TIsWow64Process;
  begin
    Result := False;
    @IsWow64Process := GetProcAddress(GetModuleHandle(kernel32), 'IsWow64Process');
    if Assigned(@IsWow64Process) then
            IsWow64Process(GetCurrentProcess, Result);
  end;
{$ELSE}
  function IsWow64: Boolean;
  begin
    Result := False ;
  end ;
{$ENDIF}
begin
  Result := 32 ;

  if IsWow64 then
                Result := 64 ;
end;

function TSCFEnvironment.GetOSName: String;
begin
  {$IFDEF MSWINDOWS}Result  := 'WINDOWS'{$ENDIF}
  {$IFDEF ANDROID}  Result  := 'ANDROID'{$ENDIF}
end;

function TSCFEnvironment.GetSCFFileExists: Boolean;
begin
  Result  := FileExists(FileName) ;
end;

function TSCFEnvironment.GetUpdate: Boolean;
begin
  Result  := ParamInList(['-UPDATE', '-U', '/UPDATE', '/U']) ;
end;

function TSCFEnvironment.ParamInList(AList: array of String): Boolean;
Var
  i, j: Integer ;
begin
  Result  := False ;
  for j := 1 to ParamCount do
    for i := Low(AList) to High(AList) do
    begin
      Result  := UpperCase(ParamStr(j)) = UpperCase(AList[i]) ;
      if Result then
                    Exit ;
    end ;
end;

function TSCFEnvironment.ReadFileName: String;
Var
  i: Integer ;
  Ch: Char ;
  Buffer: String ;
  NameWithExt: String ;
  NameWithOutExt: String ;
begin
  NameWithExt     := EmptyStr ;
  NameWithOutExt  := EmptyStr ;
  for i := 1 to ParamCount do
  begin
    Buffer  := ParamStr(i) ;
    Ch      := Buffer[1] ;

    if (Length(Buffer) > 4) and (UpperCase(Copy(Buffer, Length(Buffer) - 3, 4)) = '.SCF') then
                  NameWithExt     := Buffer
    else if not ((Ch = '-') or (Ch = '/')) then
                  NameWithOutExt  := Buffer ;
  end;

  if NameWithExt = EmptyStr then Result  := NameWithOutExt
                            else Result  := NameWithExt ;

end;

procedure TSCFEnvironment.SetFileName(const Value: String);
begin
  FFileName := Value;
end;

function TSCFEnvironment.ToString: string;
Var
  sl: TStringList ;

  function PrmStr(const AName, AValue: String): String ;
  begin
    Result  := DupeString(' ', 24) + AName + ' = ' + AValue ;
  end;
begin
  sl  := TStringList.Create ;
  Try
    sl.Add('Среда выполнения: ') ;
    sl.Add(PrmStr('FileName', FileName)) ;
    sl.Add(PrmStr('SCFFileExists', BoolToStr(SCFFileExists))) ;
    sl.Add(PrmStr('Config', BoolToStr(Config))) ;
    sl.Add(PrmStr('Update', BoolToStr(Update))) ;
    sl.Add(PrmStr('Logged', BoolToStr(Logged))) ;
    sl.Add(PrmStr('OSName', OSName)) ;
    sl.Add(PrmStr('OSBit', IntToStr(OSBit))) ;

    Result  := sl.Text ;
  Finally
    sl.Free ;
  End;
end;

{$ENDREGION}
initialization
  Log.Write('Инициализация окружения в модуле SymphonyNext.Environment');
  Environment := TSCFEnvironment.Create ;
  Log.Write('Инициализация окружения в модуле SymphonyNext.Environment закончено');
finalization
  Environment.Free ;
end.
