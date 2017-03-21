unit SymphonyPlugIn.BaseFrame;

interface

uses
  System.SysUtils, System.Variants, System.Classes, WinAPI.Messages,
  VCL.Graphics, VCL.Controls, VCL.Forms, VCL.Dialogs,
  SymphonyPlugIn.ParamInterface, SymphonyPlugIn.StateStorage,
  SymphonyPlugIn.ActionInterface, SymphonyPlugIn.MessageInterface ;

Const
  WM_GET_CHILDID = WM_USER + 05 ;

type
  TSymphonyPlugInBaseFrame = class ;
  TSymphonyPlugInBaseFrameClass = class of TSymphonyPlugInBaseFrame ;
  TClassNameFunc = function: String ;
  TOpenChildFormFunc = function (AChildClass: TSymphonyPlugInBaseFrameClass; Command: ISymphonyPlugInCommand; AUnique: Boolean = True; AID: Integer = -1): TForm of object;
  TSetOpenChildFormFunc = procedure(AFunc: TOpenChildFormFunc) ;

  TSymphonyPlugInBaseFrame = class(TFrame)
  private
    { Private declarations }
    FCaption: String;
    FParentOnActivate: TNotifyEvent ;
    FParentOnDeactivate: TNotifyEvent ;
    FContextName: String;
    FTunerParams: ISymphonyPlugInCFGGroup;

    procedure SetCaption(const Value: String) ;
    procedure SaveState ;
    procedure LoadState ;
    procedure SetContextName(const Value: String);
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    procedure WMGETCHILDID(var Msg: TMessage) ; message WM_GET_CHILDID ;
  protected
    procedure Init ; virtual ;
    procedure SetSession(ASession: TObject) ; virtual ; abstract ;
    procedure SetData(AData: TObject) ; overload ; virtual ; abstract ;
    procedure SetData(AData: ISymphonyPlugInCommand) ; overload ; virtual ; abstract ;
    procedure SetParent(AParent: TWinControl); override;
    function  CloseQuery: Boolean ; virtual ;
    procedure AddControlLeft(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlTop(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlPoint(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlWidth(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlHeight(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlSize(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlVisible(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControl(AStateStorage: TStateStorage; AControl: TControl) ;
    procedure AddControlsToStorage(AStateStorage: TStateStorage) ; virtual ;
    procedure AddParamsToStorage(AStateStorage: TStateStorage) ;  virtual ;
    procedure ApplyParamsToStorage(AStateStorage: TStateStorage) ;  virtual ;
    class function DoExecuteCommonMethod(MethodName: String; Params: TObject = nil): Boolean ; virtual ;
    procedure Print(Params: TObject = nil) ; virtual ;
    procedure ExportToExcel(Params: TObject = nil) ; virtual ;
    function  GetID: String ; virtual ;
    procedure SetID(const Value: String) ; virtual ;
    function  CreateSymphonyMessage: ISymphonyPlugInMessage ;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    constructor CreatePlugIn(AOwner: TComponent; ASession: TObject; AData: TObject); overload ; virtual ;
    constructor CreatePlugIn(AOwner: TComponent; ASession: TObject; AData: ISymphonyPlugInCommand); overload ; virtual ;
    destructor  Destroy ; override ;

    procedure FrameCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ParentActivate(Sender: TObject);
    procedure ParentDeactivate(Sender: TObject);

    procedure SetCommand(ACommand: ISymphonyPlugInCommand) ; virtual ;
    procedure TakeMessage(Message: ISymphonyPlugInMessage) ; virtual ;
    class procedure SendMessage(Message: ISymphonyPlugInMessage) ; overload ;
    class procedure SendMessage(FrameClass: TSymphonyPlugInBaseFrameClass ; Message: ISymphonyPlugInMessage) ; overload ;
    class procedure SendMessage(FrameClass: String ; Message: ISymphonyPlugInMessage) ; overload ;
    class procedure SendMessage(Frame: TSymphonyPlugInBaseFrame ; Message: ISymphonyPlugInMessage) ; overload ;
    class function  GetActiveFrame: TSymphonyPlugInBaseFrame ;
    class function  PackageDBType: String ; virtual ; abstract ;
    class function  ExecuteCommonMethod(MethodName: String; Params: TObject = nil): Boolean ;
    class function  ExecuteCmdLine(CmdLine: String; Async: Boolean = True): Boolean ;

    class procedure SetOpenChildFormFunc(AFunc: TOpenChildFormFunc) ;
    class procedure OpenChildForm(Command: ISymphonyPlugInCommand; AUnique: Boolean = True; AID: Integer = -1) ;

    class function  GetFolder(FolderKind: String): String;

    property Caption: String  read FCaption write SetCaption;
    property ContextName: String  read FContextName write SetContextName;
    property Folder[FolderKind: String]: String read GetFolder ;
    property ID: String read GetID write SetID ;
    property TunerParams: ISymphonyPlugInCFGGroup  read FTunerParams write SetTunerParams;
  end;

  TFolderKind = class
  public
    const Bin    = 'BIN' ;
    const PlugIn = 'PLUGIN' ;
    const Report = 'REPORT' ;
    const Help   = 'HELP'   ;
    const Update = 'UPDATE' ;
  end;

function PackageDBType: String  ; export ;
function ExecuteCommonMethod(MethodName: String; Params: TObject = nil): Boolean ; export ;

exports PackageDBType, ExecuteCommonMethod ;

implementation

{$R *.dfm}

uses System.StrUtils, WinAPI.Windows, Generics.Collections, SpecFoldersObj,
     SymphonyPlugIn.MessageImpl ;

Type
  TPluginFrameList = class(TList<TSymphonyPlugInBaseFrame>)
  private
    FActiveFrame: TSymphonyPlugInBaseFrame ;
    function GetActiveFrame: TSymphonyPlugInBaseFrame;
  public
    procedure ActivateFrame(AFrame: TSymphonyPlugInBaseFrame) ;
    procedure DeactivateFrame(AFrame: TSymphonyPlugInBaseFrame) ;

    property ActiveFrame: TSymphonyPlugInBaseFrame read GetActiveFrame ;
  end ;

Var
   FrameList: TPluginFrameList ;
   OpenChildFormFunc: TOpenChildFormFunc ;

function PackageDBType: String  ;
begin
  Result  := TSymphonyPlugInBaseFrame.PackageDBType ;
end;

function ExecuteCommonMethod(MethodName: String; Params: TObject = nil): Boolean ;
begin
  Result  := TSymphonyPlugInBaseFrame.ExecuteCommonMethod(MethodName, Params) ;
end;

{ TSymphonyPlugInBaseFrame }
{$REGION 'TSymphonyPlugInBaseFrame'}
procedure TSymphonyPlugInBaseFrame.AddControl(AStateStorage: TStateStorage;
  AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpLeft, scpTop, scpWidth, scpHeight, scpVisible]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlHeight(
  AStateStorage: TStateStorage; AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpHeight]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlLeft(AStateStorage: TStateStorage;
  AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpLeft]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlPoint(AStateStorage: TStateStorage;
  AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpLeft, scpTop]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlSize(AStateStorage: TStateStorage;
  AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpWidth, scpHeight]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlsToStorage(AStateStorage: TStateStorage);
begin

end;

procedure TSymphonyPlugInBaseFrame.AddControlTop(AStateStorage: TStateStorage; AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpTop]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlVisible(
  AStateStorage: TStateStorage; AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpVisible]);
end;

procedure TSymphonyPlugInBaseFrame.AddControlWidth(AStateStorage: TStateStorage;
  AControl: TControl);
begin
  AStateStorage.AddControl(AControl, [scpWidth]);
end;

procedure TSymphonyPlugInBaseFrame.AddParamsToStorage(AStateStorage: TStateStorage);
begin

end;

procedure TSymphonyPlugInBaseFrame.ApplyParamsToStorage(AStateStorage: TStateStorage);
begin

end;

function TSymphonyPlugInBaseFrame.CloseQuery: Boolean;
begin
  Result  := True ;
end;

constructor TSymphonyPlugInBaseFrame.Create(AOwner: TComponent);
begin
//  inherited;
  if AOwner = nil then
    raise Exception.Create('Не передан компонент AOwner в конструктор базового фрейма');

  if not (csDesigning in AOwner.ComponentState) then
    raise Exception.Create('Используй конструктор CreatePlugIn');

  inherited Create(AOwner) ;
end;

constructor TSymphonyPlugInBaseFrame.CreatePlugIn(AOwner: TComponent;
  ASession: TObject; AData: ISymphonyPlugInCommand);
begin
  inherited Create(AOwner) ;
  Name  := Name + IntToStr(FrameList.Count + 1) ;
  Init ;
  SetSession(ASession);
  SetData(AData);
  FrameList.Add(Self) ;
end;

function TSymphonyPlugInBaseFrame.CreateSymphonyMessage: ISymphonyPlugInMessage;
begin
  Result  := TSymphonyPlugInMessage.Create ;
end;

constructor TSymphonyPlugInBaseFrame.CreatePlugIn(AOwner: TComponent; ASession, AData: TObject);
begin
  inherited Create(AOwner) ;
  Name  := Name + IntToStr(FrameList.Count + 1) ;
  Init ;
  SetSession(ASession);
  SetData(AData);
  FrameList.Add(Self) ;
end;

destructor TSymphonyPlugInBaseFrame.Destroy;
begin
  SaveState ;
  if FrameList.Contains(Self) then
                      FrameList.Remove(Self) ;
  inherited;
end;

class function TSymphonyPlugInBaseFrame.DoExecuteCommonMethod(MethodName: String; Params: TObject = nil): Boolean;
Var
  frm: TSymphonyPlugInBaseFrame ;
begin
  Result  := False ;
  frm     := FrameList.ActiveFrame ;
  if frm = nil then
                   Exit ;
  MethodName  := LowerCase(MethodName) ;
  if MethodName = 'print' then
  begin
    frm.Print(Params) ;
    Result  := True ;
  end
  else if MethodName = 'exportexcel' then
  begin
    frm.ExportToExcel(Params) ;
    Result  := True ;
  end;
end;

class function TSymphonyPlugInBaseFrame.ExecuteCmdLine(CmdLine: String; Async: Boolean): Boolean ;
Var
  wPrm: Integer ;
  lPrm: Integer ;
begin
  Result:= False ;
  lPrm  := Integer(PChar(CmdLine)) ;
  wPrm  := 0 ;
  if Async then
                wPrm  := 1 ;

  Result  := WinAPI.Windows.SendMessage(Application.MainFormHandle, WM_USER + 50, wPrm, lPrm) = 0 ;
end;

class function TSymphonyPlugInBaseFrame.ExecuteCommonMethod(MethodName: String; Params: TObject = nil): Boolean;
begin
  Result  := DoExecuteCommonMethod(MethodName, Params) ;
end;

procedure TSymphonyPlugInBaseFrame.ExportToExcel(Params: TObject = nil);
begin

end;

procedure TSymphonyPlugInBaseFrame.FrameCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose  := CloseQuery ;
end;

class function TSymphonyPlugInBaseFrame.GetActiveFrame: TSymphonyPlugInBaseFrame;
begin
  Result  := FrameList.ActiveFrame ;
end;

class function TSymphonyPlugInBaseFrame.GetFolder(FolderKind: String): String;
Var
  RootFolder: String ;
  Index: Integer ;
  BitSuff: String ;

  function IsWow64: Boolean;
  begin
    Result := Copy(ReverseString(ExtractFilePath(SpecFolders.AppPath)), 2, 2) = '46' ;
  end;
begin
  Result      := EmptyStr ;
  BitSuff     := IfThen(IsWow64, '64', EmptyStr) ;
  RootFolder  := SpecFolders.AppPath ;
  RootFolder  := ReverseString(Copy(RootFolder, 1, Length(RootFolder) - 1)) ;
  Index := Pos('\', RootFolder) ;
  if Index > 0 then
        RootFolder  := ReverseString(Copy(RootFolder, Index, Length(RootFolder) - Index + 1)) ;

  FolderKind  := UpperCase(FolderKind) ;

  if      FolderKind = TFolderKind.Bin then  Result := RootFolder + 'bin' + BitSuff + '\'
  else if FolderKind = TFolderKind.PlugIn then  Result := RootFolder + 'PlugIn' + BitSuff + '\'
  else if FolderKind = TFolderKind.Report then  Result := RootFolder + 'Reports\'
  else if FolderKind = TFolderKind.Help   then  Result := RootFolder + 'Help\'
  else if FolderKind = TFolderKind.Update then  Result := RootFolder + 'Update\'
  else
    Result := RootFolder ;
end;

function TSymphonyPlugInBaseFrame.GetID: String;
begin
  Result  := EmptyStr ;
end;

procedure TSymphonyPlugInBaseFrame.Init;
begin
  {Переопредели в потомках, что бы инициализировать фрейм в процессе создания}
  LoadState ;
end;

procedure TSymphonyPlugInBaseFrame.LoadState;
Var
  SS: TStateStorage ;
begin
  if not (csDesigning in ComponentState) then
  begin
    SS  := TStateStorage.Create(Self) ;
    Try
      AddControlsToStorage(SS) ;
      SS.Load ;
      ApplyParamsToStorage(SS);
    Finally
      SS.Free ;
    End;
  end;
end;

class procedure TSymphonyPlugInBaseFrame.OpenChildForm(Command: ISymphonyPlugInCommand; AUnique: Boolean; AID: Integer);
begin
  if Assigned(OpenChildFormFunc) then
                                  OpenChildFormFunc(Self, Command, AUnique, AID)
  else
    raise Exception.Create('Не определена процедура создания дочернего окна');
end;

procedure TSymphonyPlugInBaseFrame.ParentActivate(Sender: TObject);
begin
  if Assigned(FParentOnActivate) then
                                    FParentOnActivate(Sender) ;
  FrameList.ActivateFrame(Self);
end;

procedure TSymphonyPlugInBaseFrame.ParentDeactivate(Sender: TObject);
begin
  if Assigned(FParentOnDeactivate) then
                                    FParentOnDeactivate(Sender) ;
  FrameList.DeactivateFrame(Self);
end;

procedure TSymphonyPlugInBaseFrame.Print(Params: TObject = nil);
begin

end;

class procedure TSymphonyPlugInBaseFrame.SendMessage(FrameClass: TSymphonyPlugInBaseFrameClass; Message: ISymphonyPlugInMessage) ;
Var
  i: Integer ;
begin
  for i := 0 to FrameList.Count - 1 do
    if  FrameList.Items[i] is FrameClass then
                                SendMessage(FrameList.Items[i], Message) ;
end;

class procedure TSymphonyPlugInBaseFrame.SendMessage(Message: ISymphonyPlugInMessage);
Var
  i: Integer ;
begin
  for i := 0 to FrameList.Count - 1 do
  begin
    SendMessage(FrameList.Items[i], Message) ;
  end;
end;

class procedure TSymphonyPlugInBaseFrame.SendMessage(FrameClass: String; Message: ISymphonyPlugInMessage);
begin
  SendMessage(TSymphonyPlugInBaseFrameClass(GetClass(FrameClass)), Message) ;
end;

procedure TSymphonyPlugInBaseFrame.SaveState;
Var
  SS: TStateStorage ;
begin
  if not (csDesigning in ComponentState) then
  begin
    SS  := TStateStorage.Create(Self) ;
    Try
      AddControlsToStorage(SS) ;
      AddParamsToStorage(SS);
      SS.Save ;
    Finally
      SS.Free ;
    End;
  end;
end;

class procedure TSymphonyPlugInBaseFrame.SendMessage(Frame: TSymphonyPlugInBaseFrame;
  Message: ISymphonyPlugInMessage);
begin
  Frame.TakeMessage(Message);
end;

procedure TSymphonyPlugInBaseFrame.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TSymphonyPlugInBaseFrame.SetCommand(ACommand: ISymphonyPlugInCommand);
begin
  {
    В переопределенных методах нужно будет писать реакцию на переданную команду.
    Например, один и тот же фрейм может создать новую запись,
    или отредактировать существующую, или открыть в режиме только чтения.
  }
end;

procedure TSymphonyPlugInBaseFrame.SetContextName(const Value: String);
begin
  FContextName := Value;
end;

procedure TSymphonyPlugInBaseFrame.SetID(const Value: String);
begin

end;

class procedure TSymphonyPlugInBaseFrame.SetOpenChildFormFunc(AFunc: TOpenChildFormFunc);
begin
  OpenChildFormFunc := AFunc ;
end;

procedure TSymphonyPlugInBaseFrame.SetParent(AParent: TWinControl);
Var
  frm: TForm ;
begin
  inherited SetParent(AParent);
  if AParent is TForm then
  begin
    ParentActivate(Self);

    frm := TForm(AParent) ;
    if Assigned(frm.OnActivate) then
                                    FParentOnActivate := frm.OnActivate ;
    frm.OnActivate  := ParentActivate ;

    if Assigned(frm.OnDeactivate) then
                                    FParentOnDeactivate := frm.OnDeactivate ;
    frm.OnDeactivate  := ParentDeactivate ;
  end;
end;

procedure TSymphonyPlugInBaseFrame.SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
begin
  FTunerParams := Value;
end;

procedure TSymphonyPlugInBaseFrame.TakeMessage(Message: ISymphonyPlugInMessage);
begin
  {В переопределенных методах нужно будет писать реакцию на приход сообщения}
end;

procedure TSymphonyPlugInBaseFrame.WMGETCHILDID(var Msg: TMessage);
begin
  StrCopy(PChar(Msg.WParam), PChar(ClassName + '.' + ID)) ;
  Msg.Result  := 0 ;
end;

{$ENDREGION}

{ TPluginFrameList }
{$REGION 'TPluginFrameList'}
procedure TPluginFrameList.ActivateFrame(AFrame: TSymphonyPlugInBaseFrame);
begin
  FActiveFrame  := AFrame ;
end;

procedure TPluginFrameList.DeactivateFrame(AFrame: TSymphonyPlugInBaseFrame);
begin
  if FActiveFrame = AFrame  then
                                FActiveFrame  := nil ;
end;

function TPluginFrameList.GetActiveFrame: TSymphonyPlugInBaseFrame;
begin
  Result  := FActiveFrame ;
end;

{$ENDREGION}

initialization
  FrameList := TPluginFrameList.Create ; // TList<TSymphonyPlugInBaseFrame>.Create ;
finalization
  FrameList.Free ;
end.
