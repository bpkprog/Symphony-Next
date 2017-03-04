unit SymphonyPlugIn.IBBaseFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IBX.IBDatabase,
  SymphonyPlugIn.ParamInterface, SymphonyPlugIn.BaseFrame, Data.DB;

type
  TSymphonyPlugInIBBaseFrame = class(TSymphonyPlugInBaseFrame)
    IBDatabase1: TIBDatabase;
    IBTransactionRead: TIBTransaction;
  private
    { Private declarations }
    procedure PrepareIBDatabase(ADatabase: TIBDatabase) ;
  protected
    procedure SetIBDatabase(ADatabase: TIBDatabase; ATransaction: TIBTransaction) ; virtual ; abstract ;
    procedure SetSession(ASession: TObject) ; override ;
    procedure SetData(AData: TObject) ; override ;
    procedure SetData(AData: ISymphonyPlugInCommand) ; override ;
  public
    { Public declarations }
    destructor Destroy ; override ;
    class function  PackageDBType: String ; override ;
  end;

var
  SymphonyPlugInIBBaseFrame: TSymphonyPlugInIBBaseFrame;

implementation

{$R *.dfm}

{ TSymphonyPlugInIBBaseFrame }

destructor TSymphonyPlugInIBBaseFrame.Destroy;
var
  i: Integer;
  ATransaction: TIBTransaction ;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TIBTransaction then
    begin
      ATransaction  := TIBTransaction(Components[i]) ;
      if ATransaction.Active then
                                ATransaction.Commit ;
    end;
  inherited;
end;

class function TSymphonyPlugInIBBaseFrame.PackageDBType: String;
begin
  Result  := 'IB' ;
end;

procedure TSymphonyPlugInIBBaseFrame.PrepareIBDatabase(ADatabase: TIBDatabase);
Var
  ATransaction: TIBTransaction ;
begin
  if ADatabase.DefaultTransaction = nil then
  begin
    ATransaction  := TIBTransaction.Create(Self);
    ATransaction.AddDatabase(ADatabase) ;
    ADatabase.DefaultTransaction  := ATransaction ;
  end;
  SetIBDatabase(ADatabase, ADatabase.DefaultTransaction);
end;

procedure TSymphonyPlugInIBBaseFrame.SetData(AData: ISymphonyPlugInCommand);
begin
  inherited;
  {ѕереопределенные методы будут заниматьс€ обработкой переданных данных}
end;

procedure TSymphonyPlugInIBBaseFrame.SetData(AData: TObject);
begin
  inherited;
  {ѕереопределенные методы будут заниматьс€ обработкой переданных данных}
end;

procedure TSymphonyPlugInIBBaseFrame.SetSession(ASession: TObject);
begin
  inherited;
  if ASession = nil then
                        Exit ;
  if not (ASession is TIBDatabase) then
    raise Exception.CreateFmt('Ќе верный тип сессии: "%s". “ребуетс€ сесси€ типа TIBDatabase', [ASession.ClassName]);

  PrepareIBDatabase(ASession as TIBDatabase);
end;

end.
