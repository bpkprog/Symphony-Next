unit tuiMainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxGallery, dxGalleryControl,
  dxRibbonBackstageViewGalleryControl, cxClasses, Vcl.ButtonGroup,
  Vcl.CategoryButtons, dxBreadcrumbEdit, dxRibbonSkins,
  dxRibbonCustomizationForm, dxRibbon, dxBar, dxBarExtItems, dxBarExtDBItems,
  System.ImageList, Vcl.ImgList, dxBarBuiltInMenu, cxPC;

type
  TForm1 = class(TForm)
    dxBreadcrumbEdit1: TdxBreadcrumbEdit;
    CategoryButtons1: TCategoryButtons;
    ButtonGroup1: TButtonGroup;
    dxRibbon1Tab1: TdxRibbonTab;
    dxRibbon1: TdxRibbon;
    dxRibbon1Tab2: TdxRibbonTab;
    dxRibbon1Tab3: TdxRibbonTab;
    dxBarManager1: TdxBarManager;
    dxBarManager1Bar1: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarStatic1: TdxBarStatic;
    dxBarCombo1: TdxBarCombo;
    dxBarLookupCombo1: TdxBarLookupCombo;
    ButtonGroup2: TButtonGroup;
    cxImageList1: TcxImageList;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    procedure dxBarCombo1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.dxBarCombo1KeyPress(Sender: TObject; var Key: Char);
begin
  dxBarCombo1.DroppedDown := True ;
end;

end.
