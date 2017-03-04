unit SymphonyPlugIn.GridStyle;

interface

uses System.SysUtils, System.Classes, VCL.Forms, cxStyles, cxGridCustomView,
     cxGridTableView, cxGridDBTableView,
     cxGridBandedTableView, cxGridDBBandedTableView, cxGridCardView, cxTL, cxDBTL  ;

Type
  TSymphonyPluginGridStyle = class(TComponent)
  private
    FStyleRepository: TcxStyleRepository;
    FCardViewStyleSheet: TcxGridCardViewStyleSheet;
    FBandedTableViewStyleSheet: TcxGridBandedTableViewStyleSheet;
    FTableViewStyleSheet: TcxGridTableViewStyleSheet;
    FTreeListStyleSheet: TcxTreeListStyleSheet;
    procedure SetStyleRepository(const Value: TcxStyleRepository);
    procedure SetObjectStyle(AObject: TObject) ;
    procedure SetBandedTableViewStyleSheet(const Value: TcxGridBandedTableViewStyleSheet);
    procedure SetCardViewStyleSheet(const Value: TcxGridCardViewStyleSheet);
    procedure SetTableViewStyleSheet(const Value: TcxGridTableViewStyleSheet);
    procedure SetTreeListStyleSheet(const Value: TcxTreeListStyleSheet);
  public
    procedure SetStyle(Frame: TFrame); overload ;
    procedure SetStyle(Form: TForm); overload ;
  published
    property StyleRepository: TcxStyleRepository read FStyleRepository write SetStyleRepository;
    property TableViewStyleSheet: TcxGridTableViewStyleSheet  read FTableViewStyleSheet write SetTableViewStyleSheet;
    property BandedTableViewStyleSheet: TcxGridBandedTableViewStyleSheet read FBandedTableViewStyleSheet write SetBandedTableViewStyleSheet;
    property CardViewStyleSheet: TcxGridCardViewStyleSheet read FCardViewStyleSheet write SetCardViewStyleSheet;
    property TreeListStyleSheet: TcxTreeListStyleSheet  read FTreeListStyleSheet write SetTreeListStyleSheet;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Symphony', [TSymphonyPluginGridStyle]);
end;

{ TSymphonyPluginGridStyle }

procedure TSymphonyPluginGridStyle.SetStyle(Frame: TFrame);
Var
  i: Integer ;
begin
  for i := 0 to Frame.ComponentCount - 1 do
                                    SetObjectStyle(Frame.Components[i]);
end;

procedure TSymphonyPluginGridStyle.SetBandedTableViewStyleSheet(
  const Value: TcxGridBandedTableViewStyleSheet);
begin
  FBandedTableViewStyleSheet := Value;
end;

procedure TSymphonyPluginGridStyle.SetCardViewStyleSheet(
  const Value: TcxGridCardViewStyleSheet);
begin
  FCardViewStyleSheet := Value;
end;

procedure TSymphonyPluginGridStyle.SetObjectStyle(AObject: TObject);
begin
  if AObject is TcxGridDBTableView then
    TcxGridDBTableView(AObject).Styles.StyleSheet := TableViewStyleSheet ;
  if AObject is TcxGridDBBandedTableView then
        TcxGridDBBandedTableView(AObject).Styles.StyleSheet := BandedTableViewStyleSheet ;
  if AObject is TcxGridDBTableView then
        TcxGridDBTableView(AObject).Styles.StyleSheet := CardViewStyleSheet ;
  if AObject is TcxDBTreeList then
        TcxTreeList(AObject).Styles.StyleSheet  := TreeListStyleSheet ;
end;

procedure TSymphonyPluginGridStyle.SetStyle(Form: TForm);
Var
  i: Integer ;
begin
  for i := 0 to Form.ComponentCount - 1 do
    if Form.Components[i] is TFrame then
        SetStyle(TFrame(Form.Components[i]))
    else
        SetObjectStyle(Form.Components[i]);
end;

procedure TSymphonyPluginGridStyle.SetStyleRepository(const Value: TcxStyleRepository);
begin
  FStyleRepository := Value;
end;

procedure TSymphonyPluginGridStyle.SetTableViewStyleSheet(const Value: TcxGridTableViewStyleSheet);
begin
  FTableViewStyleSheet := Value;
end;

procedure TSymphonyPluginGridStyle.SetTreeListStyleSheet(const Value: TcxTreeListStyleSheet);
begin
  FTreeListStyleSheet := Value;
end;

end.
