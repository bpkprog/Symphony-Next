unit UISPActionManager;

interface

uses System.Generics.Collections, SymphonyPlugIn.ActionInterface ;

Type
  TUISPActionControl = class
  private
    FAction: ISymphonyPlugInAction ;
    FControl: TObject ;
    FImageIndex: Integer;
    procedure SetImageIndex(const Value: Integer);
    procedure SetControl(const Value: TObject);
  public
    constructor Create(AAction: ISymphonyPlugInAction; AControl: TObject) ;

    property Action: ISymphonyPlugInAction read FAction ;
    property Control: TObject read FControl write SetControl;
    property ImageIndex: Integer  read FImageIndex write SetImageIndex;
  end;

  TUISPActionManager = class(TObjectList<TUISPActionControl>)
  private
    function GetAction(AControl: TObject): ISymphonyPlugInAction;
    function GetControl(AAction: ISymphonyPlugInAction): TObject;
  public
    procedure ClearEmptyItems ;
    function  AddControl(AAction: ISymphonyPlugInAction; AControl: TObject): Integer ;
    function  IndexByAction(AAction: ISymphonyPlugInAction): Integer ;
    function  IndexByControl(AControl: TObject): Integer ;

    property Action[AControl: TObject]: ISymphonyPlugInAction read GetAction ;
    property Control[AAction: ISymphonyPlugInAction]: TObject read GetControl ;
  end;

implementation

uses System.SysUtils ;

{ TUISPActionControl }

constructor TUISPActionControl.Create(AAction: ISymphonyPlugInAction; AControl: TObject);
begin
  FAction   := AAction ;
  FControl  := AControl ;
end;

procedure TUISPActionControl.SetControl(const Value: TObject);
begin
  FControl := Value;
end;

procedure TUISPActionControl.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

{ TUISPActionManager }

function TUISPActionManager.AddControl(AAction: ISymphonyPlugInAction; AControl: TObject): Integer ;
begin
  Result := Add(TUISPActionControl.Create(AAction, AControl)) ;
end;

procedure TUISPActionManager.ClearEmptyItems;
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
    if (Items[i].Action.Forms.Count = 0) and (Items[i].Control = nil) then
                                                            Remove(Items[i]) ;
end;

function TUISPActionManager.GetAction(AControl: TObject): ISymphonyPlugInAction;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if Items[i].Control = AControl then
    begin
      Result  := Items[i].Action ;
      Break ;
    end;
end;

function TUISPActionManager.GetControl(AAction: ISymphonyPlugInAction): TObject;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if Items[i].Action = AAction then
    begin
      Result  := Items[i].Control ;
      Break ;
    end;
end;

function TUISPActionManager.IndexByAction(AAction: ISymphonyPlugInAction): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to Count - 1 do
    if Items[i].Action = AAction then
    begin
      Result  := i ;
      Break ;
    end;
end;

function TUISPActionManager.IndexByControl(AControl: TObject): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to Count - 1 do
    if Items[i].Control = AControl then
    begin
      Result  := i ;
      Break ;
    end;
end;

end.
