{*******************************************************}
{             Дочерняя форма приложения                 }
{                                                       }
{   Форма создается при создании фрейма плагина, по     }
{   запросу менеджера плагинов. Созданный фрейм         }
{   размещается на экземпляре данной формы              }
{*******************************************************}
unit SymMng.ChildForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SymMng.Consts;

type
  TfrmSMChildForm = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure WMGETCHILDID(var Msg: TMessage) ; message WM_GET_CHILDID ;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSMChildForm: TfrmSMChildForm;

implementation

{$R *.dfm}

uses SymMng.MainUnit ;

procedure TfrmSMChildForm.FormActivate(Sender: TObject);
begin
//  frmSymMngMain.UpdateUIControls(Self);
  PostMessage(Application.MainFormHandle, WM_CHANGECHILD, Handle, 1) ;
end;

procedure TfrmSMChildForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree ;
//  frmSymMngMain.UpdateUIControls(Self);
  PostMessage(Application.MainFormHandle, WM_CHANGECHILD, Handle, 0) ;
end;

procedure TfrmSMChildForm.FormDeactivate(Sender: TObject);
begin
//  frmSymMngMain.UpdateUIControls(Self);
  PostMessage(Application.MainFormHandle, WM_CHANGECHILD, Handle, 0) ;
end;

procedure TfrmSMChildForm.FormDestroy(Sender: TObject);
begin
  frmSymMngMain.CloseChildForm(Self);
end;

procedure TfrmSMChildForm.WMGETCHILDID(var Msg: TMessage);
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TFrame then
      SendMessage((Components[i] as TFrame).Handle, WM_GET_CHILDID, Msg.WParam, 0) ;
end;

end.
