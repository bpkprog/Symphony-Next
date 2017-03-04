unit SymphonyPlugIn.GridStateStorage;

interface

uses cxGridCustomTableView, cxGridTableView, cxGridDBBandedTableView,
     cxGridDBTableView, cxTL, cxDBTL, SymphonyPlugIn.StateStorage;

Type
  TColIndex = record
    Column: TObject ;
    TunedIndex: Integer ;
  end;

  TColIndexArray = array of TColIndex ;

  TGridStateStorage = class
  private
    FColIndex: TColIndexArray ;

    procedure InitColIndexArray(ColumnCount: Integer) ;
    procedure ApplyColIndexArray ;
    procedure SortColIndexArray ;
    procedure SetColumnIndex(Index: Integer; Column: TcxGridColumn ; TunedIndex: Integer) ; overload ;
    procedure SetColumnIndex(Index: Integer; Column: TcxTreeListColumn ; TunedIndex: Integer) ; overload ;
    function  GetColumnName(AColumn: TcxCustomGridColumn): String ; overload ;
    function  GetColumnName(AColumn: TcxTreeListColumn): String ; overload ;
    procedure LoadBand(AStateStorage: TStateStorage; AColumn: TcxGridDBBandedColumn) ;
    procedure Load(AStateStorage: TStateStorage; AColumn: TcxTreeListColumn) ;  overload ;
    procedure Save(AStateStorage: TStateStorage; AColumn: TcxTreeListColumn) ;  overload ;
    procedure Load(AStateStorage: TStateStorage; AColumn: TcxGridDBBandedColumn) ;  overload ;
    procedure Save(AStateStorage: TStateStorage; AColumn: TcxGridDBBandedColumn) ;  overload ;
    procedure Load(AStateStorage: TStateStorage; AColumn: TcxGridDBColumn) ;  overload ;
    procedure Save(AStateStorage: TStateStorage; AColumn: TcxGridDBColumn) ;  overload ;
    procedure Load(AStateStorage: TStateStorage; ATableView: TcxGridDBTableView) ;  overload ;
    procedure Save(AStateStorage: TStateStorage; ATableView: TcxGridDBTableView) ;  overload ;
    procedure Load(AStateStorage: TStateStorage; ATableView: TcxGridDBBandedTableView) ; overload ;
    procedure Save(AStateStorage: TStateStorage; ATableView: TcxGridDBBandedTableView) ; overload ;
  public
    procedure Load(AStateStorage: TStateStorage; ATableView: TcxCustomGridTableView) ; overload ;
    procedure Save(AStateStorage: TStateStorage; ATableView: TcxCustomGridTableView) ; overload ;
    procedure Load(AStateStorage: TStateStorage; ATreeList:  TcxDBTreeList) ; overload ;
    procedure Save(AStateStorage: TStateStorage; ATreeList:  TcxDBTreeList) ; overload ;
  end;

implementation

uses System.SysUtils, XMLValUtil ;

{ TGridStateStorage }
{$REGION TGridStateStorage}
procedure TGridStateStorage.Load(AStateStorage: TStateStorage; ATableView: TcxGridDBTableView);
Var
  i: Integer ;
begin
  InitColIndexArray(ATableView.ColumnCount);
  for i := 0 to ATableView.ColumnCount - 1 do
                                Load(AStateStorage, ATableView.Columns[i]);
  SortColIndexArray ;
  ApplyColIndexArray;
end;

procedure TGridStateStorage.Load(AStateStorage: TStateStorage; ATableView: TcxGridDBBandedTableView);
Var
  i: Integer ;
begin
  InitColIndexArray(ATableView.ColumnCount);
  for i := 0 to ATableView.ColumnCount - 1 do
                                      Load(AStateStorage, ATableView.Columns[i]);
  SortColIndexArray ;
  ApplyColIndexArray;
end;

procedure TGridStateStorage.ApplyColIndexArray ;
Var
  i: Integer ;
begin
  for i := Low(FColIndex) to High(FColIndex) do
    if FColIndex[i].Column is TcxGridDBBandedColumn then
        TcxGridDBBandedColumn(FColIndex[i].Column).Position.ColIndex  := FColIndex[i].TunedIndex
    else if FColIndex[i].Column is TcxGridDBColumn then
        TcxGridDBColumn(FColIndex[i].Column).Index  := FColIndex[i].TunedIndex
    else if FColIndex[i].Column is TcxTreeListColumn then
        TcxTreeListColumn(FColIndex[i].Column).Position.ColIndex  := FColIndex[i].TunedIndex ;
end;

function TGridStateStorage.GetColumnName(AColumn: TcxCustomGridColumn): String;
begin
  Result  := AnsiUpperCase(AColumn.GridView.Name + '.' + AColumn.Name + '.') ;
end;

function TGridStateStorage.GetColumnName(AColumn: TcxTreeListColumn): String;
begin
  Result  := AnsiUpperCase(AColumn.TreeList.Name + '.' + AColumn.Name + '.') ;
end;

procedure TGridStateStorage.InitColIndexArray(ColumnCount: Integer);
Var
  i: Integer ;
begin
  SetLength(FColIndex, ColumnCount);
  for i := Low(FColIndex) to High(FColIndex) do
  begin
    FColIndex[i].Column     := nil ;
    FColIndex[i].TunedIndex := 0 ;
  end;
end;

procedure TGridStateStorage.Load(AStateStorage: TStateStorage; ATableView: TcxCustomGridTableView);
begin
  if ATableView is TcxGridDBBandedTableView then
      Load(AStateStorage, ATableView as TcxGridDBBandedTableView)
  else if ATableView is TcxGridDBTableView then
      Load(AStateStorage, ATableView as TcxGridDBTableView) ;
end;

procedure TGridStateStorage.LoadBand(AStateStorage: TStateStorage; AColumn: TcxGridDBBandedColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AColumn.Position.BandIndex  := AsInt(AStateStorage.ParamValue[ColumnName + 'BANDINDEX'], AColumn.Position.BandIndex) ;
end;

procedure TGridStateStorage.Load(AStateStorage: TStateStorage; AColumn: TcxGridDBBandedColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AColumn.Position.BandIndex  := AsInt(AStateStorage.ParamValue[ColumnName + 'BANDINDEX'], AColumn.Position.BandIndex) ;
  AColumn.Width := AsInt(AStateStorage.ParamValue[ColumnName + 'WIDTH'], AColumn.Width) ;
  SetColumnIndex(AColumn.Index, AColumn, AsInt(AStateStorage.ParamValue[ColumnName + 'INDEX'], AColumn.Index));
end;

procedure TGridStateStorage.Load(AStateStorage: TStateStorage; AColumn: TcxGridDBColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AColumn.Width := AsInt(AStateStorage.ParamValue[ColumnName + 'WIDTH'], AColumn.Width) ;
  SetColumnIndex(AColumn.Index, AColumn, AsInt(AStateStorage.ParamValue[ColumnName + 'INDEX'], AColumn.Index));
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; ATableView: TcxGridDBTableView);
Var
  i: Integer ;
begin
  for i := 0 to ATableView.ColumnCount - 1 do
                                      Save(AStateStorage, ATableView.Columns[i]);
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; ATableView: TcxGridDBBandedTableView);
Var
  i: Integer ;
begin
  for i := 0 to ATableView.ColumnCount - 1 do
                                      Save(AStateStorage, ATableView.Columns[i]);
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; ATableView: TcxCustomGridTableView);
begin
  if ATableView is TcxGridDBBandedTableView then
      Save(AStateStorage, ATableView as TcxGridDBBandedTableView)
  else if ATableView is TcxGridDBTableView then
      Save(AStateStorage, ATableView as TcxGridDBTableView) ;
end;

procedure TGridStateStorage.SetColumnIndex(Index: Integer; Column: TcxGridColumn ; TunedIndex: Integer);
begin
  FColIndex[Index].Column     := Column     ;
  FColIndex[Index].TunedIndex := TunedIndex ;
end;

procedure TGridStateStorage.SortColIndexArray;
Var
  i, j: Integer ;
  MinTuned: Integer ;
  Dummy: TColIndex ;
begin
  for i := Low(FColIndex) to High(FColIndex) - 1 do
  begin
    MinTuned  := FColIndex[i].TunedIndex ;
    for j := i + 1 to High(FColIndex) do
      if FColIndex[j].TunedIndex < MinTuned then
      begin
        Dummy         := FColIndex[i] ;
        FColIndex[i]  := FColIndex[j] ;
        FColIndex[j]  := Dummy ;
        MinTuned  := FColIndex[i].TunedIndex ;
      end;
  end;
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; AColumn: TcxGridDBBandedColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AStateStorage.AddParam(ColumnName + 'BANDINDEX', AColumn.Position.BandIndex) ;
  AStateStorage.AddParam(ColumnName + 'INDEX', AColumn.Position.ColIndex) ;
  AStateStorage.AddParam(ColumnName + 'WIDTH', AColumn.Width) ;
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; AColumn: TcxGridDBColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AStateStorage.AddParam(ColumnName + 'INDEX', AColumn.VisibleIndex) ;
  AStateStorage.AddParam(ColumnName + 'WIDTH', AColumn.Width) ;
end;

{$ENDREGION}

procedure TGridStateStorage.Load(AStateStorage: TStateStorage; AColumn: TcxTreeListColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AColumn.Position.BandIndex  := AsInt(AStateStorage.ParamValue[ColumnName + 'BANDINDEX'], AColumn.Position.BandIndex) ;
  AColumn.Width := AsInt(AStateStorage.ParamValue[ColumnName + 'WIDTH'], AColumn.Width) ;
  SetColumnIndex(AColumn.ItemIndex, AColumn, AsInt(AStateStorage.ParamValue[ColumnName + 'INDEX'], AColumn.ItemIndex));
end;

procedure TGridStateStorage.Load(AStateStorage: TStateStorage; ATreeList: TcxDBTreeList);
Var
  i: Integer ;
begin
  InitColIndexArray(ATreeList.ColumnCount);
  for i := 0 to ATreeList.ColumnCount - 1 do
                                      Load(AStateStorage, ATreeList.Columns[i]);
  SortColIndexArray ;
  ApplyColIndexArray;
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; AColumn: TcxTreeListColumn);
Var
  ColumnName: String ;
begin
  ColumnName  := GetColumnName(AColumn) ;
  AStateStorage.AddParam(ColumnName + 'BANDINDEX', AColumn.Position.BandIndex) ;
  AStateStorage.AddParam(ColumnName + 'INDEX', AColumn.Position.ColIndex) ;
  AStateStorage.AddParam(ColumnName + 'WIDTH', AColumn.Width) ;
end;

procedure TGridStateStorage.Save(AStateStorage: TStateStorage; ATreeList: TcxDBTreeList);
Var
  i: Integer ;
begin
  for i := 0 to ATreeList.ColumnCount - 1 do
                                      Save(AStateStorage, ATreeList.Columns[i]);
end;

procedure TGridStateStorage.SetColumnIndex(Index: Integer; Column: TcxTreeListColumn; TunedIndex: Integer);
begin
  FColIndex[Index].Column     := Column     ;
  FColIndex[Index].TunedIndex := TunedIndex ;
end;

end.
