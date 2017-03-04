unit TemplateOraSymPlugInFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SymphonyPlugIn.ORABaseFrame, OraCall,
  Data.DB, DBAccess, Ora;

type
  TfrmPlugInTemplate = class(TSymphonyPlugInORABaseFrame)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPlugInTemplate: TfrmPlugInTemplate;

implementation

{$R *.dfm}

initialization
  RegisterClass(TfrmPlugInTemplate);
end.
