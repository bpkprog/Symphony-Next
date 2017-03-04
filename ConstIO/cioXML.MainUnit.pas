unit cioXML.MainUnit;

interface

uses cioIntf.MainUnit, SymphonyPlugIn.ParamInterface, XML.XMLDoc, XML.XMLIntf ;

Type
  TConstXMLIO = class(TInterfacedObject, IConstIO)
    FXML: IXMLDocument ;
    FFileName: String ;

    function IndexNodeByName(GroupNode: IXMLNode; ChildName: String): Integer ;
  public
    constructor Create(AFileName: String) ;

    function LoadCFGGroup(GroupName: String): ISymphonyPlugInCFGGroup ;
    function SaveCFGGroup(Group: ISymphonyPlugInCFGGroup): Boolean ;
    function SaveConst(Group: ISymphonyPlugInCFGGroup; Param: ISymphonyPlugInParam; IsPersonalParam: Boolean): Boolean ;
  end;

function GetConstIO(AFileName: String): IConstIO ; export ;

exports GetConstIO ;

implementation

uses System.SysUtils, SymphonyPlugIn.ParamImpl, XMLValUtil ;

function GetConstIO(AFileName: String): IConstIO ;
begin
  Result  := TConstXMLIO.Create(AFileName);
end;

{ TConstXMLIO }
{$REGION 'TConstXMLIO'}
constructor TConstXMLIO.Create(AFileName: String);
begin
  FXML      := TXMLDocument.Create(nil);
  FFileName := AFileName ;
  if FileExists(FFileName) then
                              FXML.LoadFromFile(FFileName)
  else
  begin
    FXML.Active           := True ;
    FXML.Encoding         := 'UTF-8' ;
    FXML.DocumentElement  := FXML.CreateNode('USERPARAMS') ;
  end;
end;

function TConstXMLIO.IndexNodeByName(GroupNode: IXMLNode; ChildName: String): Integer;
var
  i: Integer;
begin
  Result := -1 ;
  for i := 0 to GroupNode.ChildNodes.Count - 1 do
    if GroupNode.ChildNodes.Nodes[i].Attributes['NAME'] = ChildName then
    begin
      Result  := i ;
      Break ;
    end;
end;

function TConstXMLIO.LoadCFGGroup(GroupName: String): ISymphonyPlugInCFGGroup;
Var
  i: Integer ;
  GroupNode: IXMLNode ;
  ParamNode: IXMLNode ;
  prm: ISymphonyPlugInParam ;
begin
  Result      := TSymphonyPlugInCFGGroup.Create ;
  Result.Name := GroupName ;

  GroupNode := FXML.DocumentElement.ChildNodes.Nodes[GroupName] ;
  for i := 0 to GroupNode.ChildNodes.Count - 1 do
  begin
    ParamNode       := GroupNode.ChildNodes.Nodes[i] ;
    prm             := Result.PersonalParams.AddParam ;
    prm.Name        := AsStr(ParamNode.Attributes['NAME']) ;
    prm.Caption     := AsStr(ParamNode.Attributes['CAPTION']) ;
    prm.Description := AsStr(ParamNode.Attributes['DESCRIPTION']) ;
    prm.Value       := ParamNode.NodeValue ;
  end;
end;

function TConstXMLIO.SaveCFGGroup(Group: ISymphonyPlugInCFGGroup): Boolean;
Var
  i: Integer ;
  Index: Integer ;
  GroupNode: IXMLNode ;
begin
  Index := IndexNodeByName(FXML.DocumentElement, Group.Name) ;
  if Index < 0 then
  begin
    GroupNode := FXML.DocumentElement.AddChild('PARAMGROUP') ;
    GroupNode.Attributes['NAME']        := Group.Name ;
    GroupNode.Attributes['CAPTION']     := Group.Caption ;
    GroupNode.Attributes['DESCRIPTION'] := Group.Description ;
  end
  else GroupNode  := FXML.DocumentElement.ChildNodes.Nodes[Index] ;

  for i := 0 to Group.PersonalParams.ParamCount - 1 do
                        SaveConst(Group, Group.PersonalParams.Params[i], True) ;

  FXML.SaveToFile(FFileName);
end;

function TConstXMLIO.SaveConst(Group: ISymphonyPlugInCFGGroup; Param: ISymphonyPlugInParam; IsPersonalParam: Boolean): Boolean;
Var
  Index: Integer ;
  GroupNode: IXMLNode ;
  ParamNode: IXMLNode ;
begin
  Index     := IndexNodeByName(FXML.DocumentElement, Group.Name) ;
  GroupNode := FXML.DocumentElement.ChildNodes.Nodes[Index] ;

  Index     := IndexNodeByName(GroupNode, Param.Name) ;
  if Index < 0 then
  begin
    ParamNode := GroupNode.AddChild('PARAM') ;
    ParamNode.Attributes['NAME']  := Param.Name ;
    ParamNode.Attributes['CAPTION']  := Param.Caption ;
    ParamNode.Attributes['DESCRIPTION']  := Param.Description ;
  end
  else ParamNode  := GroupNode.ChildNodes.Nodes[Index] ;

  ParamNode.NodeValue  := Param.Value ;
end;

{$ENDREGION}

end.
