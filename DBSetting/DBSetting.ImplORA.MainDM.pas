unit DBSetting.ImplORA.MainDM;

interface

uses
  System.SysUtils, System.Classes, XML.XMLIntf, OraCall, Data.DB, DBAccess, Ora;

type
  TdmORAMain = class(TDataModule)
    OraSession1: TOraSession;
  private
    { Private declarations }
    FSession: TOraSession ;
  public
    { Public declarations }
    function Init(ASession: TOraSession): Boolean ;
    function GetDataSetSetting(IDDataSet: Integer): IXMLDocument ;
  end;

var
  dmORAMain: TdmORAMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmORAMain }

function TdmORAMain.GetDataSetSetting(IDDataSet: Integer): IXMLDocument;
begin

end;

function TdmORAMain.Init(ASession: TOraSession): Boolean;
var
  i: Integer;
begin
  if FSession = ASession then
                              Exit ;

  FSession := ASession ;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TOraDataSet then
          (Components[i] as TOraDataSet).Session  := ASession ;
end;

initialization
  dmORAMain := TdmORAMain.Create(nil);
finalization
  dmORAMain.Free ;
end.
