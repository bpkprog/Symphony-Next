{**********************************************************************}
{              Набор объектов, управляющих загрузкой задач             }
{**********************************************************************}

unit SymMng.SymphonyTask;

interface

uses XML.XMLIntf, Generics.Collections,
     SymphonyPlugIn.ParamInterface, SymphonyPlugIn.ActionInterface,
     SymphonyPlugIn.PlugInManager ;

Type
  TGetPlugInForTaskFunc = function(APlugInName: String): TPlugIn ;

  TSymphonyTask = class
  private
    FPlugIn: TPlugIn;
    FXML: IXMLNode;
    function GetCaption: String;
    function GetFileName: String;
    function GetHint: String;
    function GetID: Integer;
    function Getitasktype: Integer;
    function GetParams: String;
    function GetReadOnly: Integer;
    procedure SetCaption(const Value: String);
    procedure SetFileName(const Value: String);
    procedure SetHint(const Value: String);
    procedure SetID(const Value: Integer);
    procedure Setitasktype(const Value: Integer);
    procedure SetParams(const Value: String);
    procedure SetPlugIn(const Value: TPlugIn);
    procedure SetReadOnly(const Value: Integer);
    procedure SetXML(const Value: IXMLNode);
    function  GetPlugInParam(Source: ISymphonyPlugInAction): ISymphonyPlugInCommand ;
    procedure GetSessonParam(var ServerName: String; var DatabaseName: String) ;
  public
    constructor Create ; overload ;
    constructor Create(ATask: IXMLNode) ; overload ;

    property XML: IXMLNode  read FXML write SetXML;
    property ID: Integer read GetID write SetID ;
    property Caption: String read GetCaption write SetCaption ;
    property Hint: String read GetHint write SetHint ;
    property itasktype: Integer read Getitasktype write Setitasktype ;
    property FileName: String read GetFileName write SetFileName ;
    property Params: String read GetParams write SetParams ;
    property ReadOnly: Integer read GetReadOnly write SetReadOnly ;

    property PlugIn: TPlugIn  read FPlugIn write SetPlugIn;
  end;

  TSymphonyTaskList = class(TObjectList<TSymphonyTask>)
  private
    FPluginForTask: TGetPlugInForTaskFunc;
    procedure SetPluginForTask(const Value: TGetPlugInForTaskFunc);
    function  GetPlugInName(ATask: IXMLNode): String ;
    function  GetPlugIn(PlugInName: String): TPlugIn ;
  public
    function AddTask(ATask: IXMLNode): TSymphonyTask ; overload ;
    function AddTask(ATask: IXMLNode; APlugIn: TPlugIn): TSymphonyTask ; overload ;

    function IndexOfTask(ATask: IXMLNode): Integer ;

    function OpenTask(ATask: TSymphonyTask): Boolean ; overload ;
    function OpenTask(ATask: TSymphonyTask; APlugIn: TPlugIn): Boolean ; overload ;
    function OpenTask(ATask: IXMLNode; APlugIn: TPlugIn): Boolean ; overload ;

    function CloneTask(ATask: IXMLNode): TSymphonyTask ; overload ;
    function CloneTask(ATask: TSymphonyTask): TSymphonyTask ; overload ;

    function CloseTask(ATask: IXMLNode): Boolean ; overload ;
    function CloseTask(ATask: TSymphonyTask): Boolean ; overload ;

    property PluginForTask: TGetPlugInForTaskFunc  read FPluginForTask write SetPluginForTask;
  end;

implementation

uses System.SysUtils, XML.XMLDoc, XMLValUtil, SymphonyPlugIn.ParamImpl ;

{ TSymphonyTask }
{$REGION 'TSymphonyTask'}
constructor TSymphonyTask.Create(ATask: IXMLNode);
begin
  FXML  := ATask ;
end;

constructor TSymphonyTask.Create;
Var
  Doc: IXMLDocument ;
begin
  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  FXML                := Doc.CreateNode('TASK') ;
end;

function TSymphonyTask.GetCaption: String;
begin
  Result  := AsStr(FXML.ChildValues['CAPTION']) ;
end;

function TSymphonyTask.GetFileName: String;
begin
  Result  := AsStr(FXML.ChildValues['FILENAME']) ;
end;

function TSymphonyTask.GetHint: String;
begin
  Result  := AsStr(FXML.ChildValues['HINT']) ;
end;

function TSymphonyTask.GetID: Integer;
begin
  Result  := AsInt(FXML.ChildValues['ID']) ;
end;

function TSymphonyTask.Getitasktype: Integer;
begin
  Result  := AsInt(FXML.ChildValues['ITASKTYPE']) ;
end;

function TSymphonyTask.GetParams: String;
begin
  Result  := AsStr(FXML.ChildValues['PARAMS']) ;
end;

function TSymphonyTask.GetPlugInParam(Source: ISymphonyPlugInAction): ISymphonyPlugInCommand;
begin
  Result  := Source.Command ;
  Result.ParamValue['TASK ID']  := ID ;
  Result.ParamValue['TASK']     := XML.XML ;
end;

function TSymphonyTask.GetReadOnly: Integer;
begin
  Result  := AsInt(FXML.ChildValues['READONLY']) ;
end;

procedure TSymphonyTask.GetSessonParam(var ServerName, DatabaseName: String);
begin
  {Тут надо извлечь имя базы данных и сервера и отдать его вызывающей стороне}
end;

procedure TSymphonyTask.SetCaption(const Value: String);
begin
  FXML.ChildValues['CAPTION'] := Value ;
end;

procedure TSymphonyTask.SetFileName(const Value: String);
begin
  FXML.ChildValues['FILENAME']  := Value ;
end;

procedure TSymphonyTask.SetHint(const Value: String);
begin
  FXML.ChildValues['HINT']  := Value ;
end;

procedure TSymphonyTask.SetID(const Value: Integer);
begin
  FXML.ChildValues['ID']  := Value ;
end;

procedure TSymphonyTask.Setitasktype(const Value: Integer);
begin
  FXML.ChildValues['ITASKTYPE']  := Value ;
end;

procedure TSymphonyTask.SetParams(const Value: String);
begin
  FXML.ChildValues['PARAMS']  := Value ;
end;

procedure TSymphonyTask.SetPlugIn(const Value: TPlugIn);
begin
  FPlugIn := Value;
  if FPlugIn <> nil then
  begin
    FPlugIn.OnGetSessonParam  := GetSessonParam ;
    FPlugIn.OnGetParams       := GetPlugInParam ;
  end;
end;

procedure TSymphonyTask.SetReadOnly(const Value: Integer);
begin
  FXML.ChildValues['READONLY']  := Value ;
end;

procedure TSymphonyTask.SetXML(const Value: IXMLNode);
begin
  FXML := Value;
end;

{$ENDREGION}

{ TSymphonyTaskList }
{$REGION 'TSymphonyTaskList'}
function TSymphonyTaskList.AddTask(ATask: IXMLNode): TSymphonyTask;
begin
  Result        := TSymphonyTask.Create(ATask) ;
  Result.PlugIn := GetPlugIn(GetPlugInName(ATask)) ;
  Add(Result) ;
end;

function TSymphonyTaskList.AddTask(ATask: IXMLNode; APlugIn: TPlugIn): TSymphonyTask;
begin
  Result    := TSymphonyTask.Create(ATask) ;
  Add(Result) ;
  Result.PlugIn := APlugIn  ;
end;

function TSymphonyTaskList.CloneTask(ATask: TSymphonyTask): TSymphonyTask;
begin
  Result        := AddTask(ATask.XML) ;
  Result.PlugIn := ATask.PlugIn ;
end;

function TSymphonyTaskList.CloneTask(ATask: IXMLNode): TSymphonyTask;
begin
  Result  := AddTask(ATask) ;
end;

function TSymphonyTaskList.CloseTask(ATask: TSymphonyTask): Boolean;
Var
  i, j: Integer ;
begin
  if ATask.PlugIn = nil then
                            Exit ;

  With ATask.PlugIn do
    for i := 0 to ActionCount - 1 do
      for j := Action[i].Forms.Count - 1 downto 0 do
                               Action[i].Forms.Items[i].Close ;
end;

function TSymphonyTaskList.GetPlugIn(PlugInName: String): TPlugIn;
begin
  Result  := nil ;
  if Assigned(FPluginForTask) then
                    Result  := FPluginForTask(PlugInName) ;
end;

function TSymphonyTaskList.GetPlugInName(ATask: IXMLNode): String;
begin
  Result  := AsStr(ATask.ChildValues['FILENAME'], '..\plugin\wellcome.bpl') ;
end;

function TSymphonyTaskList.IndexOfTask(ATask: IXMLNode): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to Count - 1 do
      if Items[i].XML = ATask then
      begin
        Result := i ;
        Break ;
      end;
end;

function TSymphonyTaskList.CloseTask(ATask: IXMLNode): Boolean;
Var
  Index: Integer ;
begin
  Index := IndexOfTask(ATask) ;
  if Index >= 0 then
                  CloneTask(Items[Index]) ;
end;

function TSymphonyTaskList.OpenTask(ATask: IXMLNode; APlugIn: TPlugIn): Boolean;
Var
  Index: Integer ;
  Tsk: TSymphonyTask ;
begin
  Index := IndexOfTask(ATask) ;
  if Index < 0 then Tsk := AddTask(ATask, APlugIn)
               else Tsk := Items[Index] ;
  OpenTask(Tsk, APlugIn) ;
end;

function TSymphonyTaskList.OpenTask(ATask: TSymphonyTask): Boolean;
begin
  if ATask.PlugIn = nil then
    raise Exception.CreateFmt('Для задачи %s не загружен плагин', [ATask.Caption])
  else if ATask.PlugIn.Actions = nil then
    raise Exception.CreateFmt('Для задачи %s в плагине не определены команды запуска', [ATask.Caption])
  else
           ATask.PlugIn.Actions.ExecAutoRun ;
end;

function TSymphonyTaskList.OpenTask(ATask: TSymphonyTask; APlugIn: TPlugIn): Boolean;
begin
  ATask.PlugIn  := APlugIn ;
  OpenTask(ATask) ;
end;

procedure TSymphonyTaskList.SetPluginForTask(const Value: TGetPlugInForTaskFunc);
begin
  FPluginForTask := Value;
end;

{$ENDREGION}

end.
