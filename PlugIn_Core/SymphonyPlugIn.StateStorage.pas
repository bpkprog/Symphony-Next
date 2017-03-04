unit SymphonyPlugIn.StateStorage;

interface

uses System.Classes, VCL.Controls, VCL.Forms, Generics.Collections, XML.XMLIntf,
     SymphonyPlugIn.ParamImpl ;

Type
  TSaveControlPart  = (scpLeft, scpTop, scpWidth, scpHeight, scpVisible) ;
  TSaveControlParts = set of TSaveControlPart ;

  TSaveControlInfo  = class
  private
    FControl: TControl ;
    FSaveParts: TSaveControlParts;
    procedure SetControl(const Value: TControl);
    procedure SetSaveParts(const Value: TSaveControlParts);
  published
    constructor Create(AControl: TControl; ASaveParts: TSaveControlParts)  ;
    property Control: TControl  read FControl write SetControl;
    property SaveParts: TSaveControlParts  read FSaveParts write SetSaveParts;
  end;

  TControlsList = TObjectList<TSaveControlInfo> ;

  TStateStorage = class
  private
    FFrame:   TFrame ;
    FParams:  TObjectList<TSymphonyPlugInParam> ;
    FComps:   TControlsList ;
    function  GetParamCount: Integer;
    function  GetParams(Index: Integer): TSymphonyPlugInParam;
    function  GetParamValue(ParamName: String): Variant;
    function  FindControlByName(AName: String): TSaveControlInfo ;
    procedure SaveControlInfo(ANode: IXMLNode; AControlInfo: TSaveControlInfo) ;
    procedure LoadControlInfo(ANode: IXMLNode; AComponentInfo: TSaveControlInfo) ;
    procedure LoadParams(ANode: IXMLNode) ;
    procedure SaveParams(ANode: IXMLNode) ;
    procedure LoadControls(ANode: IXMLNode) ;
    procedure SaveControls(ANode: IXMLNode) ;
    procedure SaveParam(ANode: IXMLNode; AParam: TSymphonyPlugInParam) ;
    procedure LoadParam(ANode: IXMLNode; AParam: TSymphonyPlugInParam) ;
  public
    constructor Create(AFrame: TFrame) ;
    destructor  Destroy ; override ;

    function AddParam: TSymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String): TSymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String; ParamValue: Variant): TSymphonyPlugInParam ; overload ;
    function IndexOfParam(ParamName: String): Integer ;

    procedure AddControl(AControl: TControl;  ASaveParts: TSaveControlParts)  ;

    function  FileName: String ;
    function  Load: Boolean ;
    function  Save: Boolean ;

    property ParamCount: Integer read GetParamCount ;
    property Params[Index: Integer]: TSymphonyPlugInParam read GetParams ;
    property ParamValue[ParamName: String]: Variant read GetParamValue ;
  end;

implementation

uses System.SysUtils, XML.XMLDoc, SpecFoldersObj, XMLValUtil ;

{ TStateStorage }
{$REGION 'TStateStorage'}
function TStateStorage.AddParam: TSymphonyPlugInParam;
begin
  Result  := TSymphonyPlugInParam.Create ;
  FParams.Add(Result) ;
end;

procedure TStateStorage.AddControl(AControl: TControl;  ASaveParts: TSaveControlParts);
Var
  sci: TSaveControlInfo ;
begin
  sci := FindControlByName(AControl.Name) ;
  if sci = nil then FComps.Add(TSaveControlInfo.Create(AControl, ASaveParts))
               else sci.SaveParts := sci.SaveParts + ASaveParts ;
end;

function TStateStorage.AddParam(ParamName: String; ParamValue: Variant): TSymphonyPlugInParam;
begin
  Result        := AddParam(ParamName) ;
  Result.Value  := ParamValue ;
end;

function TStateStorage.AddParam(ParamName: String): TSymphonyPlugInParam;
begin
  Result      := AddParam ;
  Result.Name := ParamName ;
end;

constructor TStateStorage.Create(AFrame: TFrame);
begin
  FFrame    := AFrame ;
  FParams   := TObjectList<TSymphonyPlugInParam>.Create ;
  FComps    := TControlsList.Create ;
end;

destructor TStateStorage.Destroy;
begin
  FParams.Free ;
  FComps.Free ;
  inherited;
end;

function TStateStorage.FileName: String;
begin
  Result  := Format('%s%s.spssf', [SpecFolders.AppDataPath, lowerCase(FFrame.Name)]) ;
end;

function TStateStorage.FindControlByName(AName: String): TSaveControlInfo;
Var
  i: Integer ;
begin
  Result:= nil ;
  for i := 0 to FComps.Count - 1 do
    if UpperCase(FComps.Items[i].Control.Name) = UpperCase(AName) then
    begin
      Result  := FComps.Items[i] ;
      Break ;
    end;
end;

function TStateStorage.GetParamCount: Integer;
begin
  Result  := FParams.Count ;
end;

function TStateStorage.GetParams(Index: Integer): TSymphonyPlugInParam;
begin
  Result  := FParams.Items[Index] ;
end;

function TStateStorage.GetParamValue(ParamName: String): Variant;
Var
  Index: Integer ;
begin
  Index := IndexOfParam(ParamName) ;
  if Index >= 0 then
                    Result := Params[Index].Value ;
end;

function TStateStorage.IndexOfParam(ParamName: String): Integer;
Var
  i: Integer ;
begin
  Result  := -1 ;
  for i := 0 to ParamCount - 1 do
    if Uppercase(Params[i].Name) = Uppercase(ParamName) then
    begin
      Result:= i ;
      Break ;
    end;
end;

function TStateStorage.Load: Boolean;
Var
  Doc: IXMLDocument ;
begin
  Result  := False ;
  if not FileExists(FileName) then
                                  Exit ;
  Doc := TXMLDocument.Create(nil) ;
  Doc.LoadFromFile(FileName);
  LoadParams(Doc.DocumentElement.ChildNodes.Nodes['PARAMS']) ;
  LoadControls(Doc.DocumentElement.ChildNodes.Nodes['CONTROLS']) ;
end;

procedure TStateStorage.LoadControlInfo(ANode: IXMLNode; AComponentInfo: TSaveControlInfo);
begin
  if scpLeft in AComponentInfo.SaveParts then
      AComponentInfo.Control.Left     := AsInt(ANode.Attributes['LEFT'], 0) ;
  if scpTop in AComponentInfo.SaveParts then
      AComponentInfo.Control.Top      := AsInt(ANode.Attributes['TOP'], 0) ;
  if scpWidth in AComponentInfo.SaveParts then
      AComponentInfo.Control.Width    := AsInt(ANode.Attributes['WIDTH'], 100) ;
  if scpHeight in AComponentInfo.SaveParts then
      AComponentInfo.Control.Height   := AsInt(ANode.Attributes['HEIGHT'], 100) ;
  if scpVisible in AComponentInfo.SaveParts then
      AComponentInfo.Control.Visible  := AsBool(ANode.Attributes['VISIBLE'], True) ;
end;

procedure TStateStorage.LoadControls(ANode: IXMLNode);
Var
  i: Integer ;
  sci: TSaveControlInfo ;
  CompNode: IXMLNode ;
  CompName: String ;
begin
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    CompNode  := ANode.ChildNodes.Nodes[i] ;
    CompName  := CompNode.Attributes['NAME'] ;
    sci       := FindControlByName(CompName) ;
    if sci <> nil then
                      LoadControlInfo(CompNode, sci);
  end;
end;

procedure TStateStorage.LoadParam(ANode: IXMLNode; AParam: TSymphonyPlugInParam);
begin
  AParam.Name     := ANode.Attributes['NAME'] ;
  AParam.Value    := ANode.NodeValue ;
end;

procedure TStateStorage.LoadParams(ANode: IXMLNode);
Var
  i: Integer ;
  Index: Integer ;
  prm: TSymphonyPlugInParam ;
  PrmNode: IXMLNode ;
  PrmName: String ;
begin
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    PrmNode   := ANode.ChildNodes.Nodes[i] ;
    PrmName   := PrmNode.Attributes['NAME'] ;
    if PrmName = EmptyStr then
                              Continue ;
    Index     := IndexOfParam(PrmName) ;
    if Index < 0 then AddParam(PrmName, PrmNode.NodeValue)
                 else Params[Index].Value := PrmNode.NodeValue ;
  end;
end;

function TStateStorage.Save: Boolean;
Var
  Doc: IXMLDocument ;
begin
  Doc                 := TXMLDocument.Create(nil) ;
  Doc.Active          := True ;
  Doc.DocumentElement := Doc.CreateNode('SYMPHONYPLUGINFRAME_PARAMS') ;
  SaveParams(Doc.DocumentElement.ChildNodes.Nodes['PARAMS']);
  SaveControls(Doc.DocumentElement.ChildNodes.Nodes['CONTROLS']);
  Doc.SaveToFile(FileName);
end;

procedure TStateStorage.SaveControlInfo(ANode: IXMLNode; AControlInfo: TSaveControlInfo);
begin
  ANode.Attributes['NAME']      := AControlInfo.Control.Name ;
  if scpLeft in AControlInfo.SaveParts then
      ANode.Attributes['LEFT']  := AControlInfo.Control.Left ;
  if scpTop in AControlInfo.SaveParts then
      ANode.Attributes['TOP']   := AControlInfo.Control.Top  ;
  if scpWidth in AControlInfo.SaveParts then
      ANode.Attributes['WIDTH'] := AControlInfo.Control.Width ;
  if scpHeight in AControlInfo.SaveParts then
      ANode.Attributes['HEIGHT']  := AControlInfo.Control.Height ;
  if scpVisible in AControlInfo.SaveParts then
      ANode.Attributes['VISIBLE'] := AControlInfo.Control.Visible ;
end;

procedure TStateStorage.SaveControls(ANode: IXMLNode);
var
  i: Integer;
begin
  for i := 0 to FComps.Count - 1 do
      SaveControlInfo(ANode.AddChild('CONTROL'), FComps.Items[i]);
end;

procedure TStateStorage.SaveParam(ANode: IXMLNode; AParam: TSymphonyPlugInParam);
begin
  ANode.Attributes['NAME']  := AParam.Name  ;
  ANode.NodeValue           := AParam.Value ;
end;

procedure TStateStorage.SaveParams(ANode: IXMLNode);
var
  i: Integer;
begin
  for i := 0 to ParamCount - 1 do
                                SaveParam(ANode.AddChild('PARAM'), Params[i]);
end;

{$ENDREGION}

{ TSaveComponentInfo }
{$REGION 'TSaveComponentInfo'}
constructor TSaveControlInfo.Create(AControl: TControl; ASaveParts: TSaveControlParts);
begin
  Control   := AControl ;
  SaveParts := ASaveParts ;
end;

procedure TSaveControlInfo.SetControl(const Value: TControl);
begin
  FControl := Value;
end;

procedure TSaveControlInfo.SetSaveParts(const Value: TSaveControlParts);
begin
  FSaveParts := Value;
end;

{$ENDREGION}

end.
