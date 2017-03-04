{**********************************************************************}
{           Фрейм с для редактирования параметров системы.             }
{   Фрейм располагается на своей закладке в окне редактирования        }
{   параметров. Любой пллагин может экспортировать аналогичный фрейм   }
{   со своими контролами.                                              }
{**********************************************************************}

unit SymMng.TunerFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections, XML.XMLIntf,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, Vcl.ExtCtrls, cxLabel,
  SymphonyPlugIn.ParamInterface, SymphonyPlugIn.TunerFrame;

type
  TSTBPackageInfo = class
  private
    FName: String         ;
    FCaption: String      ;
    FDescription: String  ;
    FValid: Boolean ;

    procedure LoadPackageInfo(FileName: String) ; overload ;
    procedure LoadPackageInfo(Node: IXMLNode) ; overload ;
  public
    constructor Create(FileName: String) ;

    property Name: String read FName;
    property Caption: String read FCaption;
    property Description: String read FDescription;
    property Valid: Boolean read FValid ;
  end;

  TSTBPackages = class(TObjectList<TSTBPackageInfo>) ;

  TfrmSymMngTuner = class(TfrmSymphonyPlugInTuner)
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    Bevel1: TBevel;
    cxcbTaskListIntf: TcxComboBox;
    cxcbActionListIntf: TcxComboBox;
  private
    { Private declarations }
    FPkg: TSTBPackages ;
    function IndexOfByName(NamePackage: String): Integer ;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy ; override ;

    function  GetCaption: String ; override ;
    function  GetDescription: String ; override ;
    procedure Load(Params: ISymphonyPlugInCFGGroup) ; override ;
    procedure Save(Params: ISymphonyPlugInCFGGroup) ; override ;
  end;

var
  frmSymMngTuner: TfrmSymMngTuner;

implementation

{$R *.dfm}

uses XMLValUtil, SymMng.PackageManager;

Type
  TPackageDescFunc = function: IXMLNode ;

{ TfrmSymMngTuner }
{$REGION 'TfrmSymMngTuner'}
constructor TfrmSymMngTuner.Create(AOwner: TComponent);
Var
  SearchFile: TSearchRec ;
  SearchRes: Integer ;
  PkgInfo: TSTBPackageInfo ;
  Path: String ;
begin
  inherited;
  {Собрать доступные пакеты}
  FPkg  := TSTBPackages.Create ;

  Path  := ExtractFilePath(Application.ExeName) ;
  SearchRes := FindFirst(Path + 'stb*.bpl', faAnyFile, SearchFile) ;
  while SearchRes = 0 do
  begin
    PkgInfo := TSTBPackageInfo.Create(Path + SearchFile.Name);
    if PkgInfo.Valid then
    begin
      FPkg.Add(PkgInfo) ;
      cxcbTaskListIntf.Properties.Items.AddObject(PkgInfo.Caption, PkgInfo) ;
      cxcbActionListIntf.Properties.Items.AddObject(PkgInfo.Caption, PkgInfo) ;
    end
    else PkgInfo.Free ;
    SearchRes := FindNext(SearchFile) ;
  end;

  FindClose(SearchFile);
end;

destructor TfrmSymMngTuner.Destroy;
begin
  {Удалить данные о доступных пакетах}
  FPkg.Free ;
  inherited;
end;

function TfrmSymMngTuner.GetCaption: String;
begin
  Result  := 'Общие' ;
end;

function TfrmSymMngTuner.GetDescription: String;
begin
  Result  := 'Настройки относящиеся к общему поведению системы' ;
end;

function TfrmSymMngTuner.IndexOfByName(NamePackage: String): Integer;
Var
  i: Integer ;
begin
  Result  := -1 ;
  for i := 0 to FPkg.Count - 1 do
    if lowercase(FPkg.Items[i].Name) = lowercase(NamePackage) then
    begin
      Result  := i ;
      Break ;
    end;
end;

procedure TfrmSymMngTuner.Load(Params: ISymphonyPlugInCFGGroup);
Var
  PkgName: String ;
begin
  inherited;
  PkgName                     := Params.PersonalParams.AsString['SYMMNG_UITASK']   ;
  cxcbTaskListIntf.ItemIndex  := IndexOfByName(PkgName)   ;
  PkgName                     := Params.PersonalParams.AsString['SYMMNG_UIACTION']  ;
  cxcbActionListIntf.ItemIndex:= IndexOfByName(PkgName)   ;
end;

procedure TfrmSymMngTuner.Save(Params: ISymphonyPlugInCFGGroup);
begin
  inherited;
  Params.PersonalParams.AsString['SYMMNG_UITASK']    := TSTBPackageInfo(cxcbTaskListIntf.Properties.Items.Objects[cxcbTaskListIntf.ItemIndex]).Name ;
  Params.PersonalParams.AsString['SYMMNG_UIACTION']  := TSTBPackageInfo(cxcbActionListIntf.Properties.Items.Objects[cxcbActionListIntf.ItemIndex]).Name ;
end;

{$ENDREGION}

{ TSTBPackageInfo }
{$REGION 'TSTBPackageInfo'}
constructor TSTBPackageInfo.Create(FileName: String);
begin
  FName         := EmptyStr ;
  FCaption      := EmptyStr ;
  FDescription  := EmptyStr ;
  FValid        := False ;
  if FileExists(FileName) then
                              LoadPackageInfo(FileName) ;
end;

procedure TSTBPackageInfo.LoadPackageInfo(FileName: String);
Var
  XML: IXMLNode ;
  Handle: NativeUInt ;
  Fn: TPackageDescFunc ;
begin
  Handle  := PackageManager.Load(FileName) ;
  Try
    Fn      := GetProcAddress(Handle, 'PackageDesc') ;
    if Assigned(Fn) then
    begin
      LoadPackageInfo(Fn);
      FName := ChangeFileExt(ExtractFileName(FileName), EmptyStr) ;
    end;
  Finally
    PackageManager.UnLoad(Handle);
  End;
end;

procedure TSTBPackageInfo.LoadPackageInfo(Node: IXMLNode);
begin
  FCaption      := AsStr(Node.ChildValues['CAPTION']) ;
  FDescription  := AsStr(Node.ChildValues['HINT']) ;
  FValid        := FCaption <> EmptyStr ;
end;

{$ENDREGION}

end.
