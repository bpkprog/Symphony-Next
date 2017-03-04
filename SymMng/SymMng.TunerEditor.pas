{**********************************************************************}
{          ќкно редактора параметров системы и плагинов                }
{**********************************************************************}

unit SymMng.TunerEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  Vcl.ButtonGroup, dxBarBuiltInMenu, cxControls, cxPC,
  SymphonyPlugIn.ParamInterface, SymphonyPlugIn.TunerFrame ;

type
  TfrmTunerEditor = class(TForm)
    pnlButtons: TPanel;
    cxbOk: TcxButton;
    cxbCancel: TcxButton;
    cxpcMain: TcxPageControl;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddGroup(Group: ISymphonyPlugInCFGGroup; Frame: TfrmSymphonyPlugInTuner) ;
  end;

var
  frmTunerEditor: TfrmTunerEditor;

implementation

{$R *.dfm}

uses WPS2, SymMng.MainDataModule;

{ TfrmTunerEditor }

procedure TfrmTunerEditor.AddGroup(Group: ISymphonyPlugInCFGGroup; Frame: TfrmSymphonyPlugInTuner);
Var
  tab: TcxTabSheet ;
begin
  tab := TcxTabSheet.Create(Self);
  tab.PageControl := cxpcMain ;
  tab.PageIndex   := cxpcMain.PageCount - 1 ;
  tab.Caption     := Frame.Caption ;
  Frame.Load(Group);
  Frame.Parent    := tab ;
  Frame.Align     := alClient ;
  Frame.Visible   := True ;
end;

procedure TfrmTunerEditor.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  WPS: TWindowPosStorage ;
begin
  WPS := TWindowPosStorage.Create ;
  Try
    WPS.Save(Self);
  Finally
    WPS.Free ;
  End;
end;

procedure TfrmTunerEditor.FormCreate(Sender: TObject);
Var
  WPS: TWindowPosStorage ;
begin
  WPS := TWindowPosStorage.Create ;
  Try
    WPS.Load(Self);
  Finally
    WPS.Free ;
  End;
end;

end.
