unit SymphonyPlugIn.MSSQLBaseFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SymphonyPlugIn.BaseFrame, SymphonyPlugIn.ParamInterface,
  Data.DB, Data.Win.ADODB;

type
  TSymphonyPlugInMSSQLBaseFrame = class(TSymphonyPlugInBaseFrame)
    ADOConnection1: TADOConnection;
  private
    { Private declarations }
  protected
    procedure SetMSSQLSession(ASession: TADOConnection) ; virtual ; abstract ;
    procedure SetSession(ASession: TObject) ; override ;
    procedure SetData(AData: TObject) ; override ;
    procedure SetData(AData: ISymphonyPlugInCommand) ; override ;
  public
    { Public declarations }
    class function  PackageDBType: String ; override ;
  end;

var
  SymphonyPlugInMSSQLBaseFrame: TSymphonyPlugInMSSQLBaseFrame;

implementation

{$R *.dfm}

{ TSymphonyPlugInBaseFrame1 }

class function TSymphonyPlugInMSSQLBaseFrame.PackageDBType: String;
begin
  Result  := 'MSSQL' ;
end;

procedure TSymphonyPlugInMSSQLBaseFrame.SetData(AData: TObject);
begin
  {ѕереопределенные методы будут заниматьс€ обработкой переданных данных}
end;

procedure TSymphonyPlugInMSSQLBaseFrame.SetData(AData: ISymphonyPlugInCommand);
begin
  {ѕереопределенные методы будут заниматьс€ обработкой переданных данных}
end;

procedure TSymphonyPlugInMSSQLBaseFrame.SetSession(ASession: TObject);
begin
  inherited;
  if ASession = nil then
                        Exit ;
  if not (ASession is TADOConnection) then
    raise Exception.CreateFmt('Ќе верный тип сессии: "%s". “ребуетс€ сесси€ типа TADOConnection', [ASession.ClassName]);

  SetMSSQLSession(ASession as TADOConnection);
end;

end.
