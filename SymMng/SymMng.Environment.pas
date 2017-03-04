{********************************************************************}
{             ќбъект с параметрами запуска приложени€                }
{                                                                    }
{   ќбъект создаетс€ автоматически при запуске системы, анализирует  }
{   параметры командной строки и возвращает их в виде своих свойств  }
{   “ип базы данных, имена сервера и базы данных и список плагинов   }
{   в автозагрузке. јвтоматически определ€ет поддержку переданного   }
{   типа базы данных? по наличию об€зательных пакетов                }
{                                                                    }
{********************************************************************}

unit SymMng.Environment;

interface

Uses System.Classes, Generics.Collections ;

Type
  TSymMngEnviroment = class
  private
    FDBType: String ;
    FServer: String ;
    FDatabase: String ;
    FUserName: String ;
    FPassword: String ;
    FAutoRunCmd: String ;
    FTaskUI: Boolean ;
    FHideMainForm: Boolean ;
    FAutoClose: Boolean ;
    FShowHelp: Boolean ;

    function  GetValidDBType: Boolean;
    function  GetCommandLine: String;
    function  GetHelp: String;
    procedure Parse ;
    function  GetParamName(CmdLine: String): String ;
    function  GetParamValue(CmdLine: String): String ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    property DBType: String   read FDBType ;
    property Server: String   read FServer ;
    property Database: String read FDatabase ;
    property TaskUI: Boolean  read FTaskUI  ;
    property HideMainForm: Boolean read FHideMainForm ;
    property AutoClose: Boolean read FAutoClose ;
    property UserName: String read FUserName ;
    property Password: String read FPassword ;
    property ShowHelp: Boolean read FShowHelp ;
    property AutoRunCmd: String read FAutoRunCmd ;
    property ValidDBType: Boolean read GetValidDBType ;
    property CommandLine: String read GetCommandLine ;
    property Help: String read GetHelp ;
  end;

Var
  SymMngEnviroment: TSymMngEnviroment ;

implementation

uses Types, SysUtils, StrUtils, Forms ;

{ TSymMngEnviroment }
{$REGION 'TSymMngEnviroment'}
constructor TSymMngEnviroment.Create;
begin
  FTaskUI       := True ;
  FDBType       := EmptyStr ;
  FServer       := EmptyStr ;
  FDatabase     := EmptyStr ;
  FUserName     := EmptyStr ;
  FPassword     := EmptyStr ;
  FHideMainForm := False ;
  FAutoClose    := False ;
  FShowHelp     := False ;

  Parse ;
end;

destructor TSymMngEnviroment.Destroy;
begin

  inherited;
end;

function TSymMngEnviroment.GetCommandLine: String;
var
  i: Integer;
begin
  Result  := EmptyStr ;
  for i := 1 to ParamCount do
    Result  := Result + ' ' + ParamStr(i) ;
  Result  := Trim(Result) ;
end;

function TSymMngEnviroment.GetHelp: String;
begin
  Result  := 'ѕараметры командной строки:' + #13 +
              '-dbt:TYPE - тип используемой базы данных. ќб€зательный параметр.' + #13 +
              '-s:SERVER - сервер базы данных. ƒл€ Oracle передаетс€ SID. ќб€зательный параметр.' + #13 +
              '-db:DATABASE - им€ базы данных. ƒл€ Oracle не об€зательный параметр.' + #13 +
              '-u:USERNAME - им€ пользовател€' + #13 +
              '-p:PASSWORD - пароль пользовател€' + #13 +
              '-ht - скрыть список задач' + #13 +
              '-hw - скрыть главное окно приложени€' + #13 +
              '-ac - после выполнени€ всех плагинов закрыть приложение' + #13 +
              '-e:AUTORUN - при старте выполнить список AUTORUN.' + #13 + #13 +
              '—труктура списка AUTORUN:  AutoRunItem,[AutoRunItem]' + #13 +
              '—труктура AutoRunItem:  PlugInName?PlugInParam' + #13 +
              '   PlugInName - им€ файла плагина' + #13 +
              '   PlugInParam: ACTION$[ACTION]' + #13 +
              '—труктура ACTION: NAME&PARAM=VALUE&[PARAM=VALUE]' + #13 +
              '   NAME - им€ акции в плагине PlugInName' + #13 +
              '   PARAM - им€ параметра передаваемого плагину' + #13 +
              '   VALUE - значение параметра передаваемого плагину' ;
end;

function TSymMngEnviroment.GetParamName(CmdLine: String): String;
Var
  Buffer: String ;
  Parts: TStringDynArray ;
begin
  // убираем первый символ "-" или "/"
  Buffer  := lowercase(Copy(CmdLine, 2, Length(CmdLine) - 1)) ;
  // делим строку на до двоеточи€, и после
  Parts   := SplitString(Buffer, ':') ;
  // ƒо двоеточи€ им€ параметра
  Result  := Parts[Low(Parts)] ;
end;

function TSymMngEnviroment.GetParamValue(CmdLine: String): String;
Var
  Buffer: String ;
  PrmName: String ;
begin
  Result  := EmptyStr ;
  // убираем первый символ "-" или "/"
  Buffer  := lowercase(Copy(CmdLine, 2, Length(CmdLine) - 1)) ;
  // »щем им€ параметра
  PrmName := GetParamName(CmdLine) ;
  // ≈сли в строке есть что то кроме имени, то остальное - это значение
  if Buffer <> PrmName then
        Result  := Copy(Buffer, Length(PrmName) + 2, Length(Buffer) - Length(PrmName)) ;
end;

function TSymMngEnviroment.GetValidDBType: Boolean;
Var
  FileName: String ;
begin
  FileName  := Format('%sSymDB%s.bpl', [ExtractFilePath(Application.ExeName), FDBType]) ;
  Result    := FileExists(FileName) ;
end;

procedure TSymMngEnviroment.Parse;
Var
  i, j: Integer ;
  Plg: TStringDynArray ;
  Index: Integer ;
  Buffer: String ;
  PrmName: String ;
begin
  for i := 1 to ParamCount do
  begin
    Buffer  := LowerCase(ParamStr(i)) ;
    PrmName := GetParamName(Buffer) ;

    if PrmName = 'dbt' then
                            FDBType := GetParamValue(Buffer)
    else if PrmName = 's' then
                            FServer := GetParamValue(Buffer)
    else if PrmName = 'db' then
                            FDatabase := GetParamValue(Buffer)
    else if PrmName = 'u' then
                            FUserName := GetParamValue(Buffer)
    else if PrmName = 'p' then
                            FPassword := GetParamValue(Buffer)
    else if PrmName = 'ht' then
                            FTaskUI := False
    else if PrmName = 'hw' then
                            FHideMainForm := True
    else if PrmName = 'ac' then
                            FAutoClose := True
    else if PrmName = '?' then
                            FShowHelp := True
    else if PrmName = 'h' then
                            FShowHelp := True
    else if PrmName = 'help' then
                            FShowHelp := True
    else if PrmName = 'e' then
                            FAutoRunCmd := GetParamValue(Buffer) ;
  end;
end;

{$ENDREGION}

initialization
  SymMngEnviroment  := TSymMngEnviroment.Create ;
finalization
  SymMngEnviroment.Free ;
end.
