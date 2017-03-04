unit UITaskContolManager;

interface

uses System.Generics.Collections, XML.XMLIntf ;

Type
  TUITaskControl = class
  private
    FControl: TObject ;
    FTask: IXMLNode ;
  public
    constructor Create(ATask: IXMLNode; AControl: TObject) ;
    property Control: TObject read FControl ;
    property Task: IXMLNode read FTask ;
  end;

  TUITaskControlManager = class(TObjectList<TUITaskControl>)
  private
    function GetControl(ATask: IXMLNode): TObject;
    function GetTask(AControl: TObject): IXMLNode;
  public
    procedure AddControl(ATask: IXMLNode; AControl: TObject) ;
    property Task[AControl: TObject]: IXMLNode read GetTask ;
    property Control[ATask: IXMLNode]: TObject read GetControl ;
  end ;

implementation

{ TUITaskControl }
{$REGION 'TUITaskControl'}
constructor TUITaskControl.Create(ATask: IXMLNode; AControl: TObject);
begin
  FControl  := AControl ;
  FTask     := ATask ;
end;

{$ENDREGION}

{ TUITaskControlManager }
{$REGION 'TUITaskControlManager'}
procedure TUITaskControlManager.AddControl(ATask: IXMLNode; AControl: TObject);
begin
  Add(TUITaskControl.Create(ATask, AControl)) ;
end;

function TUITaskControlManager.GetControl(ATask: IXMLNode): TObject;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if Items[i].Task = ATask then
    begin
      Result  := Items[i].Control ;
      Break ;
    end;
end;

function TUITaskControlManager.GetTask(AControl: TObject): IXMLNode;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if Items[i].Control = AControl then
    begin
      Result  := Items[i].Task ;
      Break ;
    end;
end;

{$ENDREGION}

end.
