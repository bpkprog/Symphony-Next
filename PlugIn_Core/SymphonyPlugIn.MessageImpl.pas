unit SymphonyPlugIn.MessageImpl;

interface

uses System.Classes,
     SymphonyPlugIn.MessageInterface, SymphonyPlugIn.ParamInterface;

Type
  TSymphonyPlugInMessage = class(TInterfacedObject, ISymphonyPlugInMessage)
  private
    FParams: TInterfaceList ;
    FDomain: String ;
    FEvent: String ;
    FResult: Variant ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    function  AddParam: ISymphonyPlugInParam ; overload ;
    function  AddParam(ParamName: String): ISymphonyPlugInParam ; overload ;
    function  AddParam(ParamName: String; ParamValue: Variant): ISymphonyPlugInParam ; overload ;
    function  IndexOf(ParamName: String): Integer ;

    function  GetDomain: String ;
    function  GetEvent: String ;
    function  GetParamCount: Integer ;
    function  GetParams(Index: Integer): ISymphonyPlugInParam ;
    function  GetParamValue(ParamName: String): Variant ;
    function  GetResult: Variant ;

    procedure SetResult(Value: Variant) ;
    procedure SetParamValue(ParamName: String; Value: Variant) ;
    procedure SetDomain(Value: String) ;
    procedure SetEvent(Value: String) ;

    property Domain: String read GetDomain write SetDomain ;
    property Event: String read GetEvent write SetEvent ;
    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: ISymphonyPlugInParam read GetParams ;
    property ParamValue[ParamName: String]: Variant read GetParamValue write SetParamValue;
    property Result: Variant read GetResult write SetResult ;
  end;

implementation

uses Variants, SymphonyPlugIn.ParamImpl ;

{ TSymphonyPlugInMessage }
{$REGION 'TSymphonyPlugInMessage'}
function TSymphonyPlugInMessage.AddParam(ParamName: String; ParamValue: Variant): ISymphonyPlugInParam;
begin
  Result        := AddParam(ParamName) ;
  Result.Value  := ParamValue ;
end;

function TSymphonyPlugInMessage.AddParam(ParamName: String): ISymphonyPlugInParam;
begin
  Result      := AddParam ;
  Result.Name := ParamName ;
end;

function TSymphonyPlugInMessage.AddParam: ISymphonyPlugInParam;
begin
  Result  := TSymphonyPlugInParam.Create ;
  FParams.Add(Result) ;
end;

constructor TSymphonyPlugInMessage.Create;
begin
  FParams   := TInterfaceList.Create ;
end;

destructor TSymphonyPlugInMessage.Destroy;
begin
  FParams.Free ;
  inherited;
end;

function TSymphonyPlugInMessage.GetDomain: String;
begin
  Result  := FDomain ;
end;

function TSymphonyPlugInMessage.GetEvent: String;
begin
  Result  := FEvent ;
end;

function TSymphonyPlugInMessage.GetParamCount: Integer;
begin
  Result  := FParams.Count ;
end;

function TSymphonyPlugInMessage.GetParams(Index: Integer): ISymphonyPlugInParam;
begin
  Result  := FParams.Items[Index] as ISymphonyPlugInParam;
end;

function TSymphonyPlugInMessage.GetParamValue(ParamName: String): Variant;
var
  i: Integer;
begin
  Result:= null ;
  i := IndexOf(ParamName) ;
  if i >= 0 then
                Result  := Params[i].Value ;
end;

function TSymphonyPlugInMessage.GetResult: Variant;
begin
  Result  := FResult ;
end;

function TSymphonyPlugInMessage.IndexOf(ParamName: String): Integer;
var
  i: Integer;
begin
  Result  := - 1 ;
  for i := 0 to ParamCount - 1 do
    if Params[i].Name = ParamName then
    begin
      Result := i ;
      Break ;
    end;
end;

procedure TSymphonyPlugInMessage.SetDomain(Value: String);
begin
  FDomain := Value ;
end;

procedure TSymphonyPlugInMessage.SetEvent(Value: String);
begin
  FEvent  := Value ;
end;

procedure TSymphonyPlugInMessage.SetParamValue(ParamName: String; Value: Variant);
Var
  Index: Integer ;
begin
  Index := IndexOf(ParamName) ;
  if Index < 0 then AddParam(ParamName, Value)
               else Params[Index].Value  := Value ;
end;

procedure TSymphonyPlugInMessage.SetResult(Value: Variant);
begin
  FResult := Value ;
end;

{$ENDREGION}

end.
