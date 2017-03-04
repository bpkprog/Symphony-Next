unit SymMng.HelpForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxMemo;

type
  TfrmHelp = class(TForm)
    cxButton1: TcxButton;
    cxMemo1: TcxMemo;
    procedure FormCreate(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.dfm}

uses SymMng.Environment ;

procedure TfrmHelp.cxButton1Click(Sender: TObject);
begin
  Close ;
end;

procedure TfrmHelp.FormCreate(Sender: TObject);
begin
  cxMemo1.Lines.Text  := SymMngEnviroment.Help ;
end;

procedure TfrmHelp.FormShow(Sender: TObject);
begin
  cxButton1.Left  := (ClientWidth - cxButton1.Width) div 2 ;
end;

end.
