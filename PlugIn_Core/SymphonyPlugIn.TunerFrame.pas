unit SymphonyPlugIn.TunerFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  SymphonyPlugIn.ParamInterface ;

type
  TfrmSymphonyPlugInTuner = class(TFrame)
  private
    { Private declarations }
  public
    { Public declarations }
    function  GetCaption: String ; virtual ; abstract ;
    function  GetDescription: String ; virtual ; abstract ;
    procedure Load(Params: ISymphonyPlugInCFGGroup) ; virtual ; abstract ;
    procedure Save(Params: ISymphonyPlugInCFGGroup) ; virtual ; abstract ;

    property Caption: String read GetCaption ;
    property Description: String read GetDescription ;
  end;

  TfrmSymphonyPlugInTunerClass = class of TfrmSymphonyPlugInTuner ;

implementation

{$R *.dfm}

end.
