unit s7exec.MainDM;

interface

uses
  System.SysUtils, System.Classes,
  SymphonyPlugIn.ActionInterface, SymphonyPlugIn.ActionListBuilder,
  SymphonyPlugIn.PackageInterface, SymphonyPlugIn.ParamInterface,
  OraCall, Data.DB, DBAccess, Ora, MemDS ;

type
  Tdms7eMain = class(TDataModule)
    ActionListBuilder1: TActionListBuilder;
    oqPrm: TOraQuery;
    oqPrmNVCVALUE: TStringField;
  private
    { Private declarations }
    procedure SetSession(ASession: TOraSession) ;
    function  GetExecFile: String ;
    function  GetParamFile(AData: ISymphonyPlugInCommand): String ;
    function  WriteParamFile(FileName: String ; AData: ISymphonyPlugInCommand): Boolean ;
    function  GetTaskParam(AData: ISymphonyPlugInCommand): String ;
  public
    { Public declarations }
    function ExecTask(ASession: TOraSession; AData: ISymphonyPlugInCommand): boolean;
  end;

var
  dms7eMain: Tdms7eMain;

function PackageInterface: IPlugInPackage ; export ;
function ExecTask(ASession: TObject; AData: ISymphonyPlugInCommand): boolean; export;

exports PackageInterface, ExecTask ;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses WinAPI.ShellAPI, XML.XMLDoc, XML.XMLIntf, VCL.Forms,
     SpecFoldersObj, XMLValUtil ;

Type
  TS7EPackageImpl = class(TInterfacedObject, IPlugInPackage)
  public
    function GetActionList: ISymphonyPlugInActionList ;
    function TunerFrameClassName: String ;
    function PackageDBType: String  ;
  end;

function PackageInterface: IPlugInPackage ;
begin
  Result  := TS7EPackageImpl.Create ;
end;

function ExecTask(ASession: TObject; AData: ISymphonyPlugInCommand): boolean;
begin
  Result  := dms7eMain.ExecTask(ASession as TOraSession, AData) ;
end;


{ TS7EPackageImpl }

function TS7EPackageImpl.GetActionList: ISymphonyPlugInActionList;
begin
  Result  := dms7eMain.ActionListBuilder1.GetActionList ;
end;

function TS7EPackageImpl.PackageDBType: String;
begin
  Result  := 'ORA' ;
end;

function TS7EPackageImpl.TunerFrameClassName: String;
begin
  Result  := EmptyStr ;
end;

{ Tdms7eMain }

function Tdms7eMain.ExecTask(ASession: TOraSession; AData: ISymphonyPlugInCommand): boolean;
Var
  Exe, Prm: String ;
begin
  Result  := False ;
  SetSession(ASession);
  Exe     := GetExecFile ;
  Prm     := '"' + GetParamFile(AData) + '"' ;
  Result  := ShellExecute(Application.Handle, 'open', PChar(Exe), PChar(Prm), '', 10) > 32 ;
end;

function Tdms7eMain.GetExecFile: String;
begin
  Result  := EmptyStr ;
  with oqPrm do
  begin
    Open ;
    Result  := oqPrmNVCVALUE.AsString ;
    Close ;
  end;
end;

function Tdms7eMain.GetParamFile(AData: ISymphonyPlugInCommand): String;
begin
  Result  := SpecFolders.GetTempFile('s7e', '.xml') ;
  WriteParamFile(Result, AData) ;
end;

function Tdms7eMain.GetTaskParam(AData: ISymphonyPlugInCommand): String;
Var
  XML: IXMLDocument ;
  Node: IXMLNode ;
begin
  Result        := EmptyStr ;
  XML           := TXMLDocument.Create(EmptyStr);
  XML.XML.Text  := AsStr(AData.ParamValue['TASK']) ;
  XML.Active    := True ;
  Node          := XML.DocumentElement.ChildNodes.Nodes['PARAMS'] ;
  Result        := AsStr(Node.ChildValues['TASK_PARAMS']) ;
end;

procedure Tdms7eMain.SetSession(ASession: TOraSession);
begin
  oqPrm.Session := ASession ;
end;

function Tdms7eMain.WriteParamFile(FileName: String ; AData: ISymphonyPlugInCommand): Boolean;
Var
  XML: IXMLDocument ;
  Doc: IXMLNode ;
begin
  XML := TXMLDocument.Create(EmptyStr);
  XML.Active    := true ;
  XML.Encoding  := 'utf-8' ;
  XML.DocumentElement := XML.CreateNode('InterprocessData') ;
  Doc                 := XML.DocumentElement ;
  Doc.Attributes['DataBase']    := oqPrm.Session.Server   ;
  Doc.Attributes['User']        := oqPrm.Session.Username ;
  Doc.Attributes['Password']    := oqPrm.Session.Password ;
  Doc.Attributes['Handle']      := Application.Handle ;
  Doc.Attributes['Parameters']  := GetTaskParam(AData) ; //'ikodtreetask=' + AsStr(AData.ParamValue['TASK ID']) ;
  XML.SaveToFile(FileName);

  Result  := FileExists(FileName) ;
end;

initialization
  dms7eMain := Tdms7eMain.Create(nil);
finalization
  dms7eMain.Free ;
end.
