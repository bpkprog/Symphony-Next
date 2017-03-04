unit SymphonyPlugIn.ParamImpl;

interface

uses System.Classes, SymphonyPlugIn.ParamInterface;

type
  TSymphonyPlugInNamedIntf = class(TInterfacedObject, ISymphonyPlugInNamedIntf)
  private
    FCaption: String;
    FDescription: String;
    FName: String;
  public
    function GetName: String ;
    function GetCaption: String ;
    function GetDescription: String ;

    procedure SetName(const Value: String);
    procedure SetCaption(const Value: String);
    procedure SetDescription(const Value: String);

    property Caption: String read GetCaption write SetCaption ;
    property Description: String read GetDescription write SetDescription ;
    property Name: String read GetName write SetName ;
  end;

  TSymphonyPlugInParam = class(TSymphonyPlugInNamedIntf, ISymphonyPlugInParam)
  private
    FValue: Variant;
  public
    procedure Assign(Param: ISymphonyPlugInParam) ;

    function  GetValue: Variant;
    function  GetAsInteger: Integer ;
    function  GetAsFloat: Double ;
    function  GetAsDateTime: TDateTime ;
    function  GetAsBoolean: Boolean ;
    function  GetAsString: String ;

    procedure SetValue(const AValue: Variant);
    procedure SetAsInteger(const AValue: Integer);
    procedure SetAsFloat(const AValue: Double);
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsBoolean(const AValue: Boolean);
    procedure SetAsString(const AValue: String);

    property AsInteger: Integer read GetAsInteger write SetAsInteger ;
    property AsFloat: Double read GetAsFloat write SetAsFloat ;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime ;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean ;
    property AsString: String read GetAsString write SetAsString ;
    property Value: Variant read GetValue write SetValue;
  end;

  TSymphonyPlugInParamList = class(TSymphonyPlugInNamedIntf, ISymphonyPlugInParamList)
  private
    FParams: TInterfaceList ;
    procedure ParseParam(ParamLine: String) ;
  protected
    procedure AssignParamList(ParamList: ISymphonyPlugInParamList) ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure Assign(ParamList: ISymphonyPlugInParamList) ;
    procedure Merge(ParamList: ISymphonyPlugInParamList) ;
    procedure ParseParams(CmdLine: String) ;
    function  IndexOf(ParamName: String): Integer ;

    function GetParamCount: Integer ;
    function GetParams(Index: Integer): ISymphonyPlugInParam ;
    function GetParamValue(ParamName: String): Variant ;
    function GetAsInteger(ParamName: String): Integer ;
    function GetAsFloat(ParamName: String): Double ;
    function GetAsDateTime(ParamName: String): TDateTime ;
    function GetAsBoolean(ParamName: String): Boolean ;
    function GetAsString(ParamName: String): String ;

    procedure SetParamValue(ParamName: String; Value: Variant) ;
    procedure SetAsInteger(ParamName: String; const AValue: Integer);
    procedure SetAsFloat(ParamName: String; const AValue: Double);
    procedure SetAsDateTime(ParamName: String; const AValue: TDateTime);
    procedure SetAsBoolean(ParamName: String; const AValue: Boolean);
    procedure SetAsString(ParamName: String; const AValue: String);

    function AddParam: ISymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String): ISymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String; ParamValue: Variant): ISymphonyPlugInParam ; overload ;

    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: ISymphonyPlugInParam read GetParams ;
    property ParamValue[ParamName: String]: Variant read GetParamValue write SetParamValue;
    property AsInteger[ParamName: String]: Integer read GetAsInteger write SetAsInteger ;
    property AsFloat[ParamName: String]: Double read GetAsFloat write SetAsFloat ;
    property AsDateTime[ParamName: String]: TDateTime read GetAsDateTime write SetAsDateTime ;
    property AsBoolean[ParamName: String]: Boolean read GetAsBoolean write SetAsBoolean ;
    property AsString[ParamName: String]: String read GetAsString write SetAsString ;
  end;

  TSymphonyPlugInCommand = class(TSymphonyPlugInParamList, ISymphonyPlugInCommand)
  private
    FCommand: String ;
  public
    procedure Assign(ACommand: ISymphonyPlugInCommand) ;

    function GetCommand: String ;
    procedure SetCommand(Value: String) ;

    property Command: String read GetCommand write SetCommand ;
  end;

  TSymphonyPlugInCFGGroup = class(TSymphonyPlugInNamedIntf, ISymphonyPlugInCFGGroup)
  private
    FCommonParams: ISymphonyPlugInParamList   ;
    FPersonalParams: ISymphonyPlugInParamList ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure Assign(CFGGroup: ISymphonyPlugInCFGGroup) ;
    procedure Merge(CFGGroup: ISymphonyPlugInCFGGroup) ;

    function GetCommonParams: ISymphonyPlugInParamList ;
    function GetPersonalParams: ISymphonyPlugInParamList ;

    property CommonParams: ISymphonyPlugInParamList   read GetCommonParams ;
    property PersonalParams: ISymphonyPlugInParamList read GetPersonalParams ;
  end ;

implementation

uses System.SysUtils, System.StrUtils, System.Types, System.Variants, XMLValUtil ;

{ TSymphonyPlugInParam }
{$REGION 'TSymphonyPlugInParam'}
procedure TSymphonyPlugInParam.Assign(Param: ISymphonyPlugInParam);
begin
  Name        := Param.Name ;
  Caption     := Param.Caption ;
  Description := Param.Description ;
  Value       := Param.Value ;
end;

function TSymphonyPlugInParam.GetAsBoolean: Boolean;
begin
  Result  := AsBool(Value) ;
end;

function TSymphonyPlugInParam.GetAsDateTime: TDateTime;
begin
  Result  := XMLValUtil.AsDateTime(Value) ;
end;

function TSymphonyPlugInParam.GetAsFloat: Double;
begin
  Result  := XMLValUtil.AsFloat(Value) ;
end;

function TSymphonyPlugInParam.GetAsInteger: Integer;
begin
  Result  := AsInt(Value) ;
end;

function TSymphonyPlugInParam.GetAsString: String;
begin
  Result  := AsStr(Value) ;
end;

function TSymphonyPlugInParam.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TSymphonyPlugInParam.SetAsBoolean(const AValue: Boolean);
begin
  Value := AValue ;
end;

procedure TSymphonyPlugInParam.SetAsDateTime(const AValue: TDateTime);
begin
  Value := AValue ;
end;

procedure TSymphonyPlugInParam.SetAsFloat(const AValue: Double);
begin
  Value := AValue ;
end;

procedure TSymphonyPlugInParam.SetAsInteger(const AValue: Integer);
begin
  Value := AValue ;
end;

procedure TSymphonyPlugInParam.SetAsString(const AValue: String);
begin
  Value := AValue ;
end;

procedure TSymphonyPlugInParam.SetValue(const AValue: Variant);
begin
  FValue := AValue;
end;

{$ENDREGION}

{ TSymphonyPlugInParamList }
{$REGION 'TSymphonyPlugInParamList'}
function TSymphonyPlugInParamList.AddParam(ParamName: String; ParamValue: Variant): ISymphonyPlugInParam;
begin
  Result        := AddParam(ParamName) ;
  Result.Value  := ParamValue ;
end;

procedure TSymphonyPlugInParamList.Assign(ParamList: ISymphonyPlugInParamList);
begin
  AssignParamList(ParamList);
end;

procedure TSymphonyPlugInParamList.AssignParamList(ParamList: ISymphonyPlugInParamList);
var
  i: Integer;
begin
  Name        := ParamList.Name ;
  Caption     := ParamList.Caption ;
  Description := ParamList.Description ;

  FParams.Clear ;
  for i := 0 to ParamList.ParamCount - 1 do
                                            AddParam.Assign(ParamList.Params[i]);
end;

function TSymphonyPlugInParamList.AddParam(ParamName: String): ISymphonyPlugInParam;
begin
  Result      := AddParam ;
  Result.Name := ParamName ;
end;

function TSymphonyPlugInParamList.AddParam: ISymphonyPlugInParam;
begin
  Result  := TSymphonyPlugInParam.Create ;
  FParams.Add(Result) ;
end;

constructor TSymphonyPlugInParamList.Create;
begin
  FParams := TInterfaceList.Create ;
end;

destructor TSymphonyPlugInParamList.Destroy;
begin
  FParams.Free ;
  inherited;
end;

function TSymphonyPlugInParamList.GetAsBoolean(ParamName: String): Boolean;
begin
  Result  := AsBool(ParamValue[ParamName]) ;
end;

function TSymphonyPlugInParamList.GetAsDateTime(ParamName: String): TDateTime;
begin
  Result  := XMLValUtil.AsDateTime(ParamValue[ParamName]) ;
end;

function TSymphonyPlugInParamList.GetAsFloat(ParamName: String): Double;
begin
  Result  := XMLValUtil.AsFloat(ParamValue[ParamName]) ;
end;

function TSymphonyPlugInParamList.GetAsInteger(ParamName: String): Integer;
begin
  Result  := AsInt(ParamValue[ParamName]) ;
end;

function TSymphonyPlugInParamList.GetAsString(ParamName: String): String;
begin
  Result  := AsStr(ParamValue[ParamName]) ;
end;

function TSymphonyPlugInParamList.GetParamCount: Integer;
begin
  Result  := FParams.Count ;
end;

function TSymphonyPlugInParamList.GetParams(Index: Integer): ISymphonyPlugInParam;
begin
  Result  := FParams.Items[Index] as ISymphonyPlugInParam;
end;

function TSymphonyPlugInParamList.GetParamValue(ParamName: String): Variant;
var
  i: Integer;
begin
  Result:= null ;
  i := IndexOf(ParamName) ;
  if i >= 0 then
                Result  := Params[i].Value ;
end;

function TSymphonyPlugInParamList.IndexOf(ParamName: String): Integer;
var
  i: Integer;
begin
  Result  := - 1 ;
  for i := 0 to ParamCount - 1 do
    if LowerCase(Params[i].Name) = LowerCase(ParamName) then
    begin
      Result := i ;
      Break ;
    end;
end;

procedure TSymphonyPlugInParamList.Merge(ParamList: ISymphonyPlugInParamList);
var
  i: Integer;
  Index: Integer ;
  src: ISymphonyPlugInParam ;
begin
  for i := 0 to ParamList.ParamCount - 1 do
  begin
    src   := ParamList.Params[i] ;
    Index := IndexOf(src.Name) ;
    if Index < 0 then
                      AddParam.Assign(src)
                 else
                      Params[Index].Value := src.Value ;
  end;
end;

procedure TSymphonyPlugInParamList.ParseParam(ParamLine: String);
Var
  Prm: TStringDynArray ;
  PrmName: String ;
  PrmVal: String ;
begin
  Prm := SplitString(ParamLine, '=') ;
  PrmName := Prm[Low(Prm)] ;
  PrmVal  := '' ;
  if Low(Prm) < High(Prm) then
                PrmVal  := Prm[High(Prm)] ;
  if IndexOf(PrmName) < 0 then
                                AddParam(PrmName, PrmVal)
                          else
                                ParamValue[PrmName] := PrmVal ;
end;

procedure TSymphonyPlugInParamList.ParseParams(CmdLine: String);
Var
  i: Integer ;
  Prms: TStringDynArray ;
begin
  Prms  := SplitString(CmdLine, '&') ;
  for i := Low(Prms) to High(Prms) do
                                    ParseParam(Prms[i]);
end;

procedure TSymphonyPlugInParamList.SetAsBoolean(ParamName: String; const AValue: Boolean);
begin
  ParamValue[ParamName] := AValue ;
end;

procedure TSymphonyPlugInParamList.SetAsDateTime(ParamName: String; const AValue: TDateTime);
begin
  ParamValue[ParamName] := AValue ;
end;

procedure TSymphonyPlugInParamList.SetAsFloat(ParamName: String; const AValue: Double);
begin
  ParamValue[ParamName] := AValue ;
end;

procedure TSymphonyPlugInParamList.SetAsInteger(ParamName: String; const AValue: Integer);
begin
  ParamValue[ParamName] := AValue ;
end;

procedure TSymphonyPlugInParamList.SetAsString(ParamName: String; const AValue: String);
begin
  ParamValue[ParamName] := AValue ;
end;

procedure TSymphonyPlugInParamList.SetParamValue(ParamName: String; Value: Variant);
Var
  Index: Integer ;
begin
  Index := IndexOf(ParamName) ;
  if Index < 0 then AddParam(ParamName, Value)
               else Params[Index].Value  := Value ;
end;

{$ENDREGION}

{ TSymphonyPlugInCommand }
{$REGION 'TSymphonyPlugInCommand'}
procedure TSymphonyPlugInCommand.Assign(ACommand: ISymphonyPlugInCommand);
begin
  AssignParamList(ACommand) ;
  Command := ACommand.Command ;
end;

function TSymphonyPlugInCommand.GetCommand: String;
begin
  Result  := FCommand ;
end;

procedure TSymphonyPlugInCommand.SetCommand(Value: String);
begin
  FCommand  := Value ;
end;

{$ENDREGION}

{ TSymphonyPlugInNamedIntf }
{$REGION 'TSymphonyPlugInNamedIntf'}
function TSymphonyPlugInNamedIntf.GetCaption: String;
begin
  Result  := FCaption ;
end;

function TSymphonyPlugInNamedIntf.GetDescription: String;
begin
  Result  := FDescription ;
end;

function TSymphonyPlugInNamedIntf.GetName: String;
begin
  Result  := FName ;
end;

procedure TSymphonyPlugInNamedIntf.SetCaption(const Value: String);
begin
  FCaption  := Value ;
end;

procedure TSymphonyPlugInNamedIntf.SetDescription(const Value: String);
begin
  FDescription  := Value ;
end;

procedure TSymphonyPlugInNamedIntf.SetName(const Value: String);
begin
  FName := Value ;
end;

{$ENDREGION}

{ TSymphonyPlugInCFGGroup }
{$REGION 'TSymphonyPlugInCFGGroup'}
procedure TSymphonyPlugInCFGGroup.Assign(CFGGroup: ISymphonyPlugInCFGGroup);
begin
  CommonParams.Assign(CFGGroup.CommonParams);
  PersonalParams.Assign(CFGGroup.PersonalParams);
end;

constructor TSymphonyPlugInCFGGroup.Create;
begin
  FCommonParams   := TSymphonyPlugInParamList.Create ;
  FPersonalParams := TSymphonyPlugInParamList.Create ;
end;

destructor TSymphonyPlugInCFGGroup.Destroy;
begin
  FCommonParams   := nil ;
  FPersonalParams := nil ;
  inherited;
end;

function TSymphonyPlugInCFGGroup.GetCommonParams: ISymphonyPlugInParamList;
begin
  Result  := FCommonParams ;
end;

function TSymphonyPlugInCFGGroup.GetPersonalParams: ISymphonyPlugInParamList;
begin
  Result  := FPersonalParams ;
end;

procedure TSymphonyPlugInCFGGroup.Merge(CFGGroup: ISymphonyPlugInCFGGroup);
begin
  CommonParams.Merge(CFGGroup.CommonParams);
  PersonalParams.Merge(CFGGroup.PersonalParams);
end;

{$ENDREGION}

end.
