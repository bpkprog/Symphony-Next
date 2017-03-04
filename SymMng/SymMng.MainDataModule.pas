{**********************************************************************}
{       Модуль данных для размещения не визуальных компонентов         }
{**********************************************************************}
unit SymMng.MainDataModule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls,
  cxGraphics, cxTL, cxGridBandedTableView, cxStyles, cxGridTableView, cxClasses,
  cxGridCardView, SymphonyPlugIn.GridStyle, cxLocalization;

type
  TdmMain = class(TDataModule)
    cxilSmall: TcxImageList;
    cxStyleRepository1: TcxStyleRepository;
    cxsContentEven: TcxStyle;
    cxsContentOdd: TcxStyle;
    cxsHead: TcxStyle;
    cxsBandHead: TcxStyle;
    cxsFooter: TcxStyle;
    cxsNav: TcxStyle;
    cxsGroupBox: TcxStyle;
    cxGridTableViewStyleSheet1: TcxGridTableViewStyleSheet;
    cxGridBandedTableViewStyleSheet1: TcxGridBandedTableViewStyleSheet;
    cxTreeListStyleSheet1: TcxTreeListStyleSheet;
    SymphonyPluginGridStyle1: TSymphonyPluginGridStyle;
    cxGridCardViewStyleSheet1: TcxGridCardViewStyleSheet;
    cxLocalizer1: TcxLocalizer;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetLang ;
  public
    { Public declarations }
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses SpecFoldersObj ;

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  SetLang ;
end;

procedure TdmMain.SetLang;
Var
  FileName: String ;
begin
  FileName  := SpecFolders.AppPath + 'russian.lng' ;
  if FileExists(FileName) then
  begin
    cxLocalizer1.LoadFromFile(FileName);
    cxLocalizer1.Locale := 1049 ;
    if not cxLocalizer1.Active then
                            cxLocalizer1.Active := True ;
  end;
end;

end.
