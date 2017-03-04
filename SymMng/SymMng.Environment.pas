{********************************************************************}
{             ������ � ����������� ������� ����������                }
{                                                                    }
{   ������ ��������� ������������� ��� ������� �������, �����������  }
{   ��������� ��������� ������ � ���������� �� � ���� ����� �������  }
{   ��� ���� ������, ����� ������� � ���� ������ � ������ ��������   }
{   � ������������. ������������� ���������� ��������� �����������   }
{   ���� ���� ������? �� ������� ������������ �������                }
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
  Result  := '��������� ��������� ������:' + #13 +
              '-dbt:TYPE - ��� ������������ ���� ������. ������������ ��������.' + #13 +
              '-s:SERVER - ������ ���� ������. ��� Oracle ���������� SID. ������������ ��������.' + #13 +
              '-db:DATABASE - ��� ���� ������. ��� Oracle �� ������������ ��������.' + #13 +
              '-u:USERNAME - ��� ������������' + #13 +
              '-p:PASSWORD - ������ ������������' + #13 +
              '-ht - ������ ������ �����' + #13 +
              '-hw - ������ ������� ���� ����������' + #13 +
              '-ac - ����� ���������� ���� �������� ������� ����������' + #13 +
              '-e:AUTORUN - ��� ������ ��������� ������ AUTORUN.' + #13 + #13 +
              '��������� ������ AUTORUN:  AutoRunItem,[AutoRunItem]' + #13 +
              '��������� AutoRunItem:  PlugInName?PlugInParam' + #13 +
              '   PlugInName - ��� ����� �������' + #13 +
              '   PlugInParam: ACTION$[ACTION]' + #13 +
              '��������� ACTION: NAME&PARAM=VALUE&[PARAM=VALUE]' + #13 +
              '   NAME - ��� ����� � ������� PlugInName' + #13 +
              '   PARAM - ��� ��������� ������������� �������' + #13 +
              '   VALUE - �������� ��������� ������������� �������' ;
end;

function TSymMngEnviroment.GetParamName(CmdLine: String): String;
Var
  Buffer: String ;
  Parts: TStringDynArray ;
begin
  // ������� ������ ������ "-" ��� "/"
  Buffer  := lowercase(Copy(CmdLine, 2, Length(CmdLine) - 1)) ;
  // ����� ������ �� �� ���������, � �����
  Parts   := SplitString(Buffer, ':') ;
  // �� ��������� ��� ���������
  Result  := Parts[Low(Parts)] ;
end;

function TSymMngEnviroment.GetParamValue(CmdLine: String): String;
Var
  Buffer: String ;
  PrmName: String ;
begin
  Result  := EmptyStr ;
  // ������� ������ ������ "-" ��� "/"
  Buffer  := lowercase(Copy(CmdLine, 2, Length(CmdLine) - 1)) ;
  // ���� ��� ���������
  PrmName := GetParamName(CmdLine) ;
  // ���� � ������ ���� ��� �� ����� �����, �� ��������� - ��� ��������
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
