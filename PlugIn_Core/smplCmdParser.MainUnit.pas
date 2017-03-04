unit smplCmdParser.MainUnit;

interface

uses SymphonyPlugIn.ParamInterface, Generics.Collections ;

Type
  TCMDParserAction = class
  private
    FName: String;
    FParams: ISymphonyPlugInParamList;
    function GetCmdLine: String;
    procedure SetCmdLine(const Value: String);
    procedure SetName(const Value: String);
    procedure SetParams(const Value: ISymphonyPlugInParamList);
  public
    constructor Create ;
    destructor  Destroy ; override ;

    property CmdLine: String read GetCmdLine write SetCmdLine ;
    property Name: String  read FName write SetName;
    property Params: ISymphonyPlugInParamList  read FParams write SetParams;
  end;

  TCMDParserActions = TObjectList<TCMDParserAction> ;

  TCMDPlugIn = class
  private
    FName: String;
    FActions: TCMDParserActions;
    function GetCmdLine: String;
    procedure SetActions(const Value: TCMDParserActions);
    procedure SetCmdLine(const Value: String);
    procedure SetName(const Value: String);
    function GetParams: String;
    procedure SetParams(const Value: String);
  public
    constructor Create ;
    destructor  Destroy ; override ;

    property CmdLine: String read GetCmdLine write SetCmdLine ;
    property Name: String  read FName write SetName;
    property Actions: TCMDParserActions  read FActions write SetActions;
    property Params: String read GetParams write SetParams;
  end;

  TCMDPlugIns = TObjectList<TCMDPlugIn> ;

  TCMDPlugInCommandLine = class(TCMDPlugIns)
  private
    function GetCmdLine: String;
    procedure SetCmdLine(const Value: String);
  public
    property CmdLine: String read GetCmdLine write SetCmdLine ;
  end;

implementation

uses System.SysUtils, System.StrUtils, System.Types, SymphonyPlugIn.ParamImpl ;


{ TCMDParserAction }
{$REGION 'TCMDParserAction'}
constructor TCMDParserAction.Create;
begin
  FName   := EmptyStr ;
  FParams := TSymphonyPlugInParamList.Create ;
end;

destructor TCMDParserAction.Destroy;
begin
  FParams := nil ;
  inherited;
end;

function TCMDParserAction.GetCmdLine: String;
var
  i: Integer;
  Prm: ISymphonyPlugInParam ;
begin
  Result  := Name ;
  for i := 0 to Params.ParamCount - 1 do
  begin
    Prm := Params.Params[i] ;
    Result  := Result + Format('&%s=%s', [Prm.Name, Prm.AsString]) ;
  end;
end;

procedure TCMDParserAction.SetCmdLine(const Value: String);
Var
  phrases: TStringDynArray ;
  prmphr: TStringDynArray ;
  i: Integer;
  Prm: ISymphonyPlugInParam ;
begin
  Name    := EmptyStr ;
  FParams  := nil ;
  FParams := TSymphonyPlugInParamList.Create ;
  if Value = EmptyStr then
                          Exit ;

  phrases := SplitString(Value, '&') ;
  Name    := phrases[Low(phrases)] ;
  for i := Low(phrases) + 1 to High(phrases) do
  begin
     prmphr := SplitString(phrases[i], '=') ;
     Prm    := Params.AddParam(prmphr[Low(prmphr)]) ;
     if Low(prmphr) < High(prmphr) then
                    Prm.Value := prmphr[Low(prmphr) + 1] ;
  end;
end;

procedure TCMDParserAction.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TCMDParserAction.SetParams(const Value: ISymphonyPlugInParamList);
begin
  FParams.Assign(Value) ;
end;

{$ENDREGION}

{ TCMDPlugIn }
{$REGION 'TCMDPlugIn'}
constructor TCMDPlugIn.Create;
begin
  FName := EmptyStr ;
  FActions  := TCMDParserActions.Create ;
end;

destructor TCMDPlugIn.Destroy;
begin
  FActions.Free ;
  inherited;
end;

function TCMDPlugIn.GetCmdLine: String;
begin
  Result  := Name + IfThen(Actions.Count = 0, '', '?') + Params ;
end;

function TCMDPlugIn.GetParams: String;
var
  i: Integer;
begin
  Result  := EmptyStr ;
  for i := 0 to Actions.Count - 1 do
                Result := Result + Format('%s$', [Actions.Items[i].CmdLine]) ;

  if Result <> EmptyStr then
                          Result  := Copy(Result, 1, Length(Result) - 1) ;
end;

procedure TCMDPlugIn.SetActions(const Value: TCMDParserActions);
var
  i: Integer;
  Act: TCMDParserAction ;
begin
  FActions.Clear ;
  for i := 0 to Value.Count - 1 do
  begin
    Act         := TCMDParserAction.Create  ;
    Act.CmdLine := Value.Items[i].CmdLine ;
    FActions.Add(Act) ;
  end;
end;

procedure TCMDPlugIn.SetCmdLine(const Value: String);
Var
  phrases: TStringDynArray ;
begin
  Name  := EmptyStr ;
  FActions.Clear ;
  if Value = EmptyStr then
                          Exit ;

  phrases := SplitString(Value, '?') ;
  Name    := phrases[Low(phrases)] ;
  if Low(phrases) = High(phrases) then
                                      Exit ;
  Params := phrases[Low(phrases) + 1] ;
end;

procedure TCMDPlugIn.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TCMDPlugIn.SetParams(const Value: String);
Var
  phrases: TStringDynArray ;
  Act: TCMDParserAction ;
  i: Integer;
begin
  phrases := SplitString(Value, '$') ;
  for i := Low(phrases) to High(phrases) do
  begin
    Act         := TCMDParserAction.Create  ;
    Act.CmdLine := phrases[i] ;
    FActions.Add(Act) ;
  end;
end;

{$ENDREGION}

{ TCMDPlugInCommandLine }
{$REGION 'TCMDPlugInCommandLine'}
function TCMDPlugInCommandLine.GetCmdLine: String;
var
  i: Integer;
begin
  Result  := EmptyStr ;
  for i := 0 to Count - 1 do
                            Result  := Result + Items[i].CmdLine + ',' ;
  if Result <> EmptyStr then
                            Result  := Copy(Result, 1, Length(Result) - 1) ;
end;

procedure TCMDPlugInCommandLine.SetCmdLine(const Value: String);
Var
  phrases: TStringDynArray ;
  i: Integer ;
  Plg: TCMDPlugIn ;
begin
  Clear ;
  if Value = EmptyStr then
                          Exit ;
  phrases := SplitString(Value, ',') ;
  for i := Low(phrases) to High(phrases) do
  begin
    Plg         := TCMDPlugIn.Create ;
    Plg.CmdLine := phrases[i] ;
    Add(Plg) ;
  end;
end;

{$ENDREGION}

end.
