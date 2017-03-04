unit SymphonyPlugIn.ORABaseFrame;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Graphics, Controls, Forms, Dialogs, OraCall, Ora,
  Data.DB, DBAccess, SymphonyPlugIn.BaseFrame, SymphonyPlugIn.ParamInterface;

type
  TSymphonyPlugInORABaseFrame = class(TSymphonyPlugInBaseFrame)
  private
    { Private declarations }
  protected
    procedure SetOraSession(ASession: TOraSession) ; virtual ; abstract ;
    procedure SetSession(ASession: TObject) ; override ;
    procedure SetData(AData: TObject) ; override ;
    procedure SetData(AData: ISymphonyPlugInCommand) ; override ;
  public
    { Public declarations }
    class function  PackageDBType: String ; override ;
  end;

var
  SymphonyPlugInORABaseFrame: TSymphonyPlugInORABaseFrame;

implementation

{$R *.dfm}

{ TSymphonyPlugInBaseFrame1 }

class function TSymphonyPlugInORABaseFrame.PackageDBType: String;
begin
  Result  := 'ORA' ;
end;

procedure TSymphonyPlugInORABaseFrame.SetData(AData: TObject);
begin
  inherited;
  {ѕереопределенные методы будут заниматьс€ обработкой переданных данных}
end;

procedure TSymphonyPlugInORABaseFrame.SetData(AData: ISymphonyPlugInCommand);
begin
  inherited;
  {ѕереопределенные методы будут заниматьс€ обработкой переданных данных}
end;

procedure TSymphonyPlugInORABaseFrame.SetSession(ASession: TObject);
begin
  inherited;
  if ASession = nil then
                        Exit ;
  if not (ASession is TOraSession) then
    raise Exception.CreateFmt('Ќе верный тип сессии: "%s". “ребуетс€ сесси€ типа TOraSession', [ASession.ClassName]);

  SetOraSession(ASession as TOraSession);
end;

end.
