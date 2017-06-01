{*******************************************************}
{             Главная форма приложения                  }
{*******************************************************}
unit SymMng.MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,

  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  cxPC, dxBarBuiltInMenu, cxClasses, dxTabbedMDI,

  XML.XMLIntf, WPS2,

  SymphonyPlugIn.PlugInManager, SymphonyPlugIn.ActionInterface,
  SymphonyPlugIn.TunerFrame, SymphonyPlugIn.ParamInterface,
  SymphonyPlugIn.UsageTaskStatInterface,

  SymMng.SymphonyTask, SymMng.UIPackageManager, SymMng.Consts,
  SymMng.Tuner, SymMng.ConnectionMng, SymMng.TunerFrame ;

type
  TfrmSymMngMain = class(TForm)
    PlugInMng: TPlugInManager;
    dxTabbedMDIManager1: TdxTabbedMDIManager;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PlugInMngGetSession(PlugInName, DBType, ServerName, DatabaseName, UserName, Password: string; var Session: TObject);
    function  PlugInMngGetOwnerForm(Source: ISymphonyPlugInAction): TForm;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PlugInMngLoadActions(APlugIn: TPlugIn);
    procedure WMMERGEUI(var Msg: TMessage) ; message WM_MERGEUI ;
    procedure WMCHANGECHILD(var Msg: TMessage) ; message WM_CHANGECHILD ;
    procedure WMMDIACTIVATE(var Msg: TMessage) ; message WM_MDIACTIVATE ;
    procedure WMEXECAUTORUN(var Msg: TMessage) ; message WM_EXEC_AUTORUN ;
    procedure WMEXECPLUGIN(var Msg: TMessage) ; message WM_EXEC_PLUGIN ;
    procedure WMEXECQUEUEITEM(var Msg: TMessage) ; message WM_EXEC_QUEUEITEM ;
    procedure GetPlugInTunerFrame(PlugInName: String; var FrameClass: TfrmSymphonyPlugInTunerClass) ;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetActiveFormStyle(Sender: TObject);
    function  PlugInMngGetTunerParam(APlugIn: TPlugIn): ISymphonyPlugInCFGGroup;
  private
    { Private declarations }
    FConnectionManager: TConnectionMng ;
    FTuner: TSymMngTuner ;
    FUIPackageManager: TUIPackageManager ;
    FUsageTaskStatistician: IUsageTaskStatistician ;
    FTaskList: TSymphonyTaskList ;
    FShiftCmd: TShiftState ;
    FCmdQueue: TStringlist ;

    function  InitConnectionManager: Boolean ;
    procedure InitTuner(UserName, DBType: String) ;
    procedure UsageTaskStatistician(DBType: String) ;
    function  GetConnected: Boolean;
    function  ExecCmdLine(CmdLine: String): Boolean ;
    procedure ExecAutoRunList ;
    procedure CreateTreeTask(TreeTaskNode: IXMLNode) ;
    function  LoadTreeTask: IXMLNode ;
    procedure BuildTaskUI(TaskList: IXMLNode) ;
    function  GetUIActionPackageName4User: String ;
    function  GetUITaskPackageName4User: String ;
    function  GetUITaskParent(ParentClass: String): TComponent ;
    procedure OnTaskExecute(Source: TObject) ;
    procedure OnActionExecute(Source: TObject) ;
    procedure OnClosePlugIn(Source: TObject) ;
    procedure OnEditTuner(Source: TObject) ;
    procedure OnPrint(Source: TObject) ;
    procedure OnExportToExcel(Source: TObject) ;
    function  ExecutePlugIn(FileName: String; CmdLine: String): Boolean ;
    function  FindPlugInByControl(Source: TObject): TPlugIn ;
    function  GetSystemPackageName(PkgName: String): String ;
    function  GetWPS: TWindowPosStorage ;
    procedure SetScreenEvents ;
    function  ExecuteCommonMethod(MethodName: String): Boolean ;
    function  GetRootPath: String ;
    function  GetRootSubFolder(SubFolder: String): String ;
    procedure CheckEVPath ;
    procedure LoadFormCaption ;
    procedure LoadFormIcon ;
  public
    { Public declarations }
    procedure UpdateUIControls(AForm: TForm) ;
    procedure CloseChildForm(AForm: TForm) ;

    property Connected: Boolean read GetConnected ;
  end;

var
  frmSymMngMain: TfrmSymMngMain;

implementation

{$R *.dfm}

uses System.StrUtils, System.Types, ShellAPI, XMLValUtil, Logger,
     stbIntf.MainUnit, smplCmdParser.MainUnit,
     SymMng.Environment, SymMng.ChildForm, SymMng.PackageManager,
     SymMng.MainDataModule, SpecFoldersObj ;

Type
  TGetTasksFunc = function (Session: TObject; UserName: String): IXMLNode;
  TExecuteCommonMethodFunc = function (MethodName: String; Params: TObject = nil): Boolean ;


procedure TfrmSymMngMain.BuildTaskUI(TaskList: IXMLNode);
Var
  Events: TEventList ;
begin
  Log.EnterMethod('BuildTaskUI', [], []);
  Try Try
    
    if (FUIPackageManager = nil) or 
          (FUIPackageManager.TaskPackage = nil) or
                (FUIPackageManager.TaskPackage.Handle = 0) then
                                                                Exit ;
    Log.Write('Пакет интерфейса загружен, продолжаем строить интерфейс');
    Log.Write('Назначаем обработчики сообщений');
    Events.OnExecute  := OnTaskExecute ;
    Events.OnClosePlugIn  := OnClosePlugIn ;
    Events.OnEditTuner    := OnEditTuner ;
    Events.OnPrint        := OnPrint ;
    Events.OnExportExcel  := OnExportToExcel ;

    Log.Write('Строим интерфейс');
    with FUIPackageManager.TaskPackage do
      if not Builder.BuildTasks(GetUITaskParent(ParentClassName), TaskList, Events) then
          MessageDlg(Format('Ошибка построения интерфейса пользователя для списка задач [Библиотека: %s]', [FullPath]), mtError, [mbOK], 0) ;
  Except on E: Exception do
    Log.WriteExceptionInfo(E);
  End;
  Finally
    Log.ExitMethod('BuildTaskUI');
  End;
end;

procedure TfrmSymMngMain.CheckEVPath;
Var
  DestPath: String ;
  EVPath: String ;
  parr: TStringDynArray ;
  Index: Integer ;
  i, j: Integer ;
  Flag: Boolean ;
Const
  SubFolderArray: array[0..0] of String = ('PlugIn') ;
begin
  Flag    := False ;
  EVPath  := GetEnvironmentVariable('PATH') ;
  parr    := SplitString(AnsiUppercase(EVPath), ';') ;

  for j := Low(SubFolderArray) to High(SubFolderArray) do
  begin
    DestPath  := GetRootSubFolder(SubFolderArray[j]) ;
    Index   := -1 ;
    for i := Low(parr) to High(parr) do
      if parr[i] = AnsiUpperCase(DestPath) then
      begin
        Index := i ;
        Break ;
      end;

    if Index < 0 then
    begin
      Evpath  := EVPath + ';' + DestPath ;
      Flag  := True ;
    end;
  end;

  if Flag then
              SetEnvironmentVariable('PATH', PChar(EVPath)) ;
end;

procedure TfrmSymMngMain.CloseChildForm(AForm: TForm);
begin
  FUIPackageManager.CloseForm(AForm);
  PlugInMng.CloseForm(AForm);
end;


procedure TfrmSymMngMain.WMEXECAUTORUN(var Msg: TMessage);
begin
  SetScreenEvents;
  ExecAutoRunList;
  if SymMngEnviroment.AutoClose then
                                    Close;
end;

procedure TfrmSymMngMain.WMEXECPLUGIN(var Msg: TMessage);
Var
  Cmd: String ;
  Async: Integer ;
  CmdRes: Integer ;
begin
  Async   := Msg.WParam ;           // Ассинхронность выполнения = 1 отложенный запуск,
                                    // при остальных значениях выполнять немедленно
  Cmd     := String(Msg.LParam) ;   // Командная строка на выполнение

  if Async = 1 then
  begin
    // Осуществляем отложенный запуск.
    // Кладем команду в очередь и сообщаем окну о наличии в очереди команды
    FCmdQueue.Add(Cmd) ;
    PostMessage(Handle, WM_EXEC_QUEUEITEM, 0, 0) ;
    Msg.Result  := 0 ;
  end
  else // Немедленное выполнение команды
  begin
      CmdRes  := 0 ;
      if not ExecCmdLine(Cmd) then
                                  CmdRes  := 1 ;
      Msg.Result  := CmdRes ;
  end;
end;

procedure TfrmSymMngMain.WMEXECQUEUEITEM(var Msg: TMessage);
begin
  if FCmdQueue.Count = 0 then
                            Exit ;
  ExecCmdLine(FCmdQueue.Strings[0]);
  FCmdQueue.Delete(0);
  if FCmdQueue.Count > 0 then
                            PostMessage(Handle, WM_EXEC_QUEUEITEM, 0, 0) ;
end;

procedure TfrmSymMngMain.CreateTreeTask(TreeTaskNode: IXMLNode);
begin
  Log.EnterMethod('CreateTreeTask', [], []);
  Try
    Try
      FTaskList     := TSymphonyTaskList.Create ;
      if SymMngEnviroment.TaskUI then
                      BuildTaskUI(TreeTaskNode.ChildNodes.Nodes['TASKS']) ;
    Except on E: Exception do
      Log.WriteExceptionInfo(E) ;
    End;
  Finally
    Log.ExitMethod('CreateTreeTask');
  End;
end;

procedure TfrmSymMngMain.ExecAutoRunList;
begin
  if SymMngEnviroment.AutoRunCmd <> EmptyStr then
                                   ExecCmdLine(SymMngEnviroment.AutoRunCmd);
end;

function TfrmSymMngMain.ExecCmdLine(CmdLine: String): Boolean;
Var
  i: Integer ;
  FileName: String ;
  Path: String ;
  PlugInsCmd: TCMDPlugInCommandLine ;
Const
  PluginPath = {$IFDEF CPU64}'PlugIn64'{$ELSE}'PlugIn'{$ENDIF} ;
begin
  Result  := False ;
  if CmdLine = EmptyStr then
                            Exit ;

  Path  := ExtractFilePath(Application.ExeName) ;
  Path  := ReverseString(Copy(Path, 1, Length(Path) - 1)) ;
  i     := Pos(PathDelim, Path) ;
  if i > 1 then
            Path  := ReverseString(Copy(Path, i, Length(Path) - i + 1)) ;
  Path  := Path + PluginPath + PathDelim ;

  PlugInsCmd  := TCMDPlugInCommandLine.Create ;
  Try
    PlugInsCmd.CmdLine  := CmdLine ;
    Result  := True ;
    for i := 0 to PlugInsCmd.Count - 1 do
    begin
      FileName  := PlugInsCmd.Items[i].Name ;
      if LowerCase(Copy(FileName, Length(FileName) - 3, 4)) <> '.bpl' then
                                                FileName  := FileName + '.bpl' ;
      FileName  := Path + FileName ;
      if FileExists(FileName) then
             Result := Result and ExecutePlugIn(FileName, PlugInsCmd.Items[i].Params) ;
    end;
  Finally
    PlugInsCmd.Free ;
  End;
end;

function TfrmSymMngMain.ExecuteCommonMethod(MethodName: String): Boolean;
Var
  PkgHandle: THandle ;
  Fn: TExecuteCommonMethodFunc ;
begin
  Result  := False ;
  if MDIChildCount = 0 then
                          Exit ;
  PkgHandle := LoadPackage('smplBaseFrame.bpl') ;
  if PkgHandle = 0 then
      raise Exception.Create('Ошибка загрузки пакета smplBaseFrame');
  Fn  := GetProcAddress(PkgHandle, 'ExecuteCommonMethod') ;
  if Assigned(Fn) then
                      Result  := Fn(MethodName) ;
end;

function TfrmSymMngMain.ExecutePlugIn(FileName: String; CmdLine: String): Boolean;
Var
  Index: Integer  ;
begin
  Result  := False ;
  Index   := PlugInMng.LoadPlugIn(FileName) ;
  if Index >= 0 then
  begin
    if CmdLine = EmptyStr then
                             Result := PlugInMng.PlugIn[Index].ExecAutoRun
                          else
                             Result := PlugInMng.PlugIn[Index].Execute(CmdLine)  ;
  end;
end;

function TfrmSymMngMain.FindPlugInByControl(Source: TObject): TPlugIn;
Var
  act: ISymphonyPlugInAction ;
begin
  Result  := nil ;
  act     := FUIPackageManager.ActionPackage.Builder.ActionForControl(Source) ;
  if act = nil then
                  Exit ;
  Result  := PlugInMng.FindPlugInByAction(act) ;
end;

procedure TfrmSymMngMain.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  WPS: TWindowPosStorage ;
begin
  Screen.OnActiveFormChange := nil ;
  WPS := GetWPS ;
  Try
    WPS.Save(Self);
  Finally
    WPS.Free ;
  End;
end;

procedure TfrmSymMngMain.FormCreate(Sender: TObject);
Var
  TreeTaskNode: IXMLNode ;
  WPS: TWindowPosStorage ;
begin
  CheckEVPath ;
  SpecFolders.ClearTempDir ;

  if not InitConnectionManager then
  begin
    Close ;
    Exit ;
  end;

  FCmdQueue := TStringlist.Create ;   // Создаем очередь задач

  LoadFormCaption ;
  LoadFormIcon;

  Log.Write('Загружаем список задач');
  TreeTaskNode  := LoadTreeTask ;
//  Log.Write(TreeTaskNode.XML) ;
  Log.Write('Передаем данные в настройщик системы');
  InitTuner(TreeTaskNode.ChildNodes.Nodes['USER'].ChildValues['USERNAME'], SymMngEnviroment.DBType) ;

  Log.Write('Создаем менеджер интерфейсов');
  FUIPackageManager := TUIPackageManager.Create ;
  Log.Write('Инициируем менеджер интерфейсов');
  FUIPackageManager.InitPackages(GetUIActionPackageName4User, GetUITaskPackageName4User);

  Log.Write('Создаем объект WPS');
  WPS := GetWPS ;
  Try
    Log.Write('Загружаем данные с помощью WPS');
    WPS.Load(Self);
  Finally
    Log.Write('Удаляем объект WPS');
    WPS.Free ;
  End;

  Log.Write('Создаем перечень задач');
  CreateTreeTask(TreeTaskNode) ;
  Log.Write('Загрузка статистики по задачам');
  UsageTaskStatistician(FConnectionManager.BaseConnection.DBType) ;
  Log.Write('Окончание создания главной формы');

  PostMessage(Handle, WM_EXEC_AUTORUN, 0, 0) ;
end;

procedure TfrmSymMngMain.FormDestroy(Sender: TObject);
begin
  FCmdQueue.Free ;
  FTaskList.Free ;
  FUIPackageManager.Free ;
  FConnectionManager.Free ;
  FUsageTaskStatistician  := nil ;
end;

procedure TfrmSymMngMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FShiftCmd  := Shift ;
end;

procedure TfrmSymMngMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FShiftCmd := [] ;
end;

procedure TfrmSymMngMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FShiftCmd := Shift ;
end;

procedure TfrmSymMngMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FShiftCmd := [] ;
end;

function TfrmSymMngMain.GetConnected: Boolean;
begin
  Result  := (FConnectionManager.BaseConnection <> nil) and
                          (FConnectionManager.BaseConnection.Session <> nil) ;
end;

procedure TfrmSymMngMain.GetPlugInTunerFrame(PlugInName: String; var FrameClass: TfrmSymphonyPlugInTunerClass);
Var
  Index: Integer ;
  FrameClassName: String ;
  pl: TPlugIn ;
begin
  FrameClass  := nil ;

  Index   := PlugInMng.IndexOf(PlugInName) ;
  if Index < 0 then
                  Exit ;
  pl              := PlugInMng.PlugIn[Index] ;
  FrameClassName  := Pl.PackageIntf.TunerFrameClassName ;
  FrameClass      := TfrmSymphonyPlugInTunerClass(GetClass(FrameClassName)) ;
end;

function TfrmSymMngMain.GetRootPath: String;
Var
  i: Integer ;
  Path: String ;
begin
  Result  := EmptyStr ;
  Path  := ExtractFilePath(Application.ExeName) ;
  Path  := ReverseString(Copy(Path, 1, Length(Path) - 1)) ;
  i     := Pos(PathDelim, Path) ;
  if i > 1 then
              Path  := ReverseString(Copy(Path, i, Length(Path) - i + 1)) ;
  Result  := Path ;
  if Result[Length(Result)] <> PathDelim then
                                          Result  := Result + PathDelim ;
end;

function TfrmSymMngMain.GetRootSubFolder(SubFolder: String): String;
Const
  SuffixPath = {$IFDEF CPU64}'64'{$ELSE}''{$ENDIF} ;
begin
  Result  := GetRootPath + SubFolder + SuffixPath + PathDelim ;
end;

function TfrmSymMngMain.GetSystemPackageName(PkgName: String): String;
begin
  Result  := PkgName ;
  if FileExists(Result) then
                            Exit ;
  if LowerCase(Copy(Result, Length(Result) - 3, 4)) <> '.bpl' then
                                                  Result  := Result + '.bpl' ;
  if FileExists(Result) then
                            Exit ;
  Result  := ExtractFilePath(Application.ExeName) + Result ;
end;

function TfrmSymMngMain.GetUIActionPackageName4User: String;
begin
  // Тут поднимаем настройку пользователя и возвращем выбранный им пакет
  Log.EnterMethod('GetUIActionPackageName4User', [], []);
  Try
    Result  := FTuner.AsString['SYMMNG_UIACTION'] ;
    if Result <> EmptyStr then
                            Result  := GetSystemPackageName(Result) ;

    Log.Write('Возвращаем результат: %s', [Result]);
  Finally
    Log.ExitMethod('GetUIActionPackageName4User');
  End;
end;

function TfrmSymMngMain.GetUITaskPackageName4User: String;
begin
  Log.EnterMethod('GetUITaskPackageName4User', [], []);
  Try
    Result := FTuner.AsString['SYMMNG_UITASK'] ;
    if Result <> EmptyStr then
                            Result  := GetSystemPackageName(Result) ;
    Log.Write('Возвращаем результат: %s', [Result]);
  Finally
    Log.ExitMethod('GetUITaskPackageName4User');
  End;
end;

function TfrmSymMngMain.GetUITaskParent(ParentClass: String): TComponent;
Var
  i: Integer ;
begin
  Log.EnterMethod('GetUITaskParent', ['ParentClass'], [ParentClass]);
  Try
    Result:= Self ;
    for i := 0 to ComponentCount - 1 do
      if UpperCase(Components[i].ClassName) = UpperCase(ParentClass) then
      begin
        Result  := Components[i] ;
        Break ;
      end;
    Log.Write('Возвращаем родителя для размещения интерфейса: %s', [Result.ClassName]);
  Finally
    Log.ExitMethod('GetUITaskParent');
  End;
end;

function TfrmSymMngMain.GetWPS: TWindowPosStorage;
begin
  Result  := TWindowPosStorage.Create ;
end;

function TfrmSymMngMain.InitConnectionManager: Boolean;
Var
  Conn: TConnection ;
begin
  Result  := False ;
  FConnectionManager  := TConnectionMng.Create ;
  Try
    Conn  := FConnectionManager.GetConnection('SymMng', SymMngEnviroment.DBType,
                                                        SymMngEnviroment.Server, SymMngEnviroment.Database,
                                                        SymMngEnviroment.UserName, SymMngEnviroment.Password) ;
    Result  := not (Conn.Session = nil) ;
  except on E: Exception do
    begin
      if not (E is EAbort) then
                            MessageDlg(E.Message, mtError, [mbOK], 0) ;
      Result := False ;
    end;
  End;
end;

procedure TfrmSymMngMain.InitTuner(UserName, DBType: String);
begin
  FTuner  := TSymMngTuner.Create(FConnectionManager.BaseConnection.Session, UserName, DBType);
  FTuner.GetPlugInTunerFrame  := GetPlugInTunerFrame ;
  FTuner.AddGroup('SymMng.exe') ;
end;

procedure TfrmSymMngMain.LoadFormCaption;
Var
  FileName: String ;
  Buffer: String ;
  ss: TStringStream ;
begin
  FileName  := ExtractFilePath(Application.ExeName) + 'formcaption.dat' ;
  if not FileExists(FileName) then
                                  Exit ;
  ss  := TStringStream.Create ;
  Try
    ss.LoadFromFile(FileName);
    Caption := ss.DataString ;
  Finally
    ss.Free ;
  End;
end;

procedure TfrmSymMngMain.LoadFormIcon;
Var
  FileName: String ;
begin
  FileName  := ExtractFilePath(Application.ExeName) + 'favicon.ico' ;
  if not FileExists(FileName) then
                                  Exit ;

  Application.Icon.LoadFromFile(FileName) ;
  Icon.LoadFromFile(FileName);
end;

function TfrmSymMngMain.LoadTreeTask: IXMLNode;
Var
  FileName: String ;
  PkgHandle: NativeUInt ;
  Fn: TGetTasksFunc ;
begin
  //FileName  := Format('%sSymTask%s.bpl', [ExtractFilePath(Application.ExeName), FConnectionManager.BaseConnection.DBType]) ;
  FileName  := GetSystemPackageName(Format('SymTask%s.bpl', [FConnectionManager.BaseConnection.DBType])) ;
  if not FileExists(FileName) then
    raise EFileNotFoundException.CreateFmt('Библиотека %s не найдена', [FileName]);

  PkgHandle := PackageManager.Load(FileName) ;
  if PkgHandle = 0 then
    raise Exception.CreateFmt('Ошибка загрузки библиотеки %s', [FileName]);
  Try
    Fn  := GetProcAddress(PkgHandle, 'GetTasks') ;
    if Assigned(Fn) then
                       Result := Fn(FConnectionManager.BaseConnection.Session, FConnectionManager.BaseConnection.UserName) ;
  Finally
    PackageManager.Unload(PkgHandle);
  End;
end;

procedure TfrmSymMngMain.OnActionExecute(Source: TObject);
Var
  Act: ISymphonyPlugInAction ;
begin
  if FUIPackageManager.ActionPackageHandle = 0 then
    raise Exception.Create('Не загружена библиотека пользовательского интерфейса');

  Act  := FUIPackageManager.ActionPackage.Builder.ActionForControl(Source) ;
  if Act = nil then
    raise Exception.Create('Для выбранного элемента акция не обнаружена');

  Act.Execute ;
end;

procedure TfrmSymMngMain.OnClosePlugIn(Source: TObject);
Var
  pl: TPlugIn ;
begin
  pl  := FindPlugInByControl(Source) ;
  if pl = nil then
                  Exit ;

  FUIPackageManager.ActionPackage.Builder.DestroyActions(pl.Actions);
  PlugInMng.ClosePlugIn(pl);
end;

procedure TfrmSymMngMain.OnEditTuner(Source: TObject);
begin
  FTuner.Edit ;
end;

procedure TfrmSymMngMain.OnExportToExcel(Source: TObject);
begin
  ExecuteCommonMethod('ExportExcel') ;
end;

procedure TfrmSymMngMain.OnPrint(Source: TObject);
begin
  ExecuteCommonMethod('Print') ;
end;

procedure TfrmSymMngMain.OnTaskExecute(Source: TObject);
Var
  Task, Params: IXMLNode ;
  PlugInName: String ;
  PlugInIndex: Integer ;
  TaskIndex: Integer ;
  TaskType: Integer ;
  Unique: Boolean ;
begin
  Log.EnterMethod('TfrmSymMngMain.OnTaskExecute', ['Source'], [Source.ClassName]);
  Try
  if FUIPackageManager.TaskPackageHandle = 0 then
    raise Exception.Create('Не загружена библиотека пользовательского интерфейса');

  Log.Write('Запрашиваем у пакета интерфейса задачу');
  Task  := FUIPackageManager.TaskPackage.Builder.TaskForControl(Source) ;
  if Task = nil then
    raise Exception.Create('Для выбранного элемента задача не обнаружена');

  Log.Write('Получена задача:');
  Log.Write(Task.XML);
  Params      := Task.ChildNodes.Nodes['PARAMS'] ;
  Unique      := AsBool(Params.ChildValues['UNIQUE'], True) ;
  PlugInName  := AsStr(Task.ChildValues['FILENAME']) ;
  TaskType    := AsInt(Task.ChildValues['ITASKTYPE']) ;
  Log.Write('Плагин: %s, тип задачи: %d', [PlugInName, TaskType]);
  if TaskType in [0, 3] then
  begin
    Log.Write('Тип задачи 3, ищем плагин в списке загруженных или загружаем его заново');
    PlugInIndex := PlugInMng.LoadPlugIn(PlugInName) ;
    Log.Write('Индекс плагина %d', [PlugInIndex]);

    if PlugInIndex >= 0 then
    begin
      Log.Write('Плагин загружен, ищем задачу');
      TaskIndex := FTaskList.IndexOfTask(Task) ;
      Log.Write('Индекс задачи: %d', [TaskIndex]);
      if TaskIndex < 0 then
      begin
        Log.Write('Задача не загружена, открываем её');
        FTaskList.OpenTask(Task, PlugInMng.PlugIn[PlugInIndex])
      end
      else
      begin
        Log.Write('Задача уже загружена, показываем формы или отрабатываем список автозагрузки');
        if FTaskList.Items[TaskIndex].PlugIn = nil then
        begin
          FTaskList.Items[TaskIndex].PlugIn := PlugInMng.PlugIn[PlugInIndex] ;
        end;

        with FTaskList.Items[TaskIndex].PlugIn do
          if (not Unique) or (ssShift in FShiftCmd) or (FormCount = 0) then
                                                                    ExecAutoRun
                                                         else
                                                                    ShowForms ;
        UpdateUIControls(Self) ;
      end;
    end
    else
      raise Exception.CreateFmt('Ошибка загрузки библиотеки "%s"', [PlugInName]);
  end
  else if PlugInName <> EmptyStr then
    ShellExecute(Handle, 'open', PChar(PlugInName), '', '', SW_SHOWDEFAULT) ;

  FShiftCmd := [] ;

  if Assigned(FUsageTaskStatistician) then
     FUsageTaskStatistician.ExecuteTask(FConnectionManager.BaseConnection.Session,
                                                              AsInt(Task, 'ID'));

  Finally
    Log.ExitMethod('TfrmSymMngMain.OnTaskExecute');
  End;
end;

function TfrmSymMngMain.PlugInMngGetOwnerForm(Source: ISymphonyPlugInAction): TForm;
begin
  Result  := TfrmSMChildForm.Create(Self) ;
  PostMessage(Handle, WM_MERGEUI, Result.Handle, 0) ;
end;

procedure TfrmSymMngMain.PlugInMngGetSession(PlugInName, DBType, ServerName, DatabaseName, UserName, Password: string; var Session: TObject);
begin
  if (DBType = EmptyStr) or (ServerName = EmptyStr) then
    Session := FConnectionManager.BaseConnection.Session
  else
    Session := FConnectionManager.GetConnection(PlugInName, DBType, ServerName,
                                                DatabaseName, UserName, Password).Session ;
end;

function TfrmSymMngMain.PlugInMngGetTunerParam(APlugIn: TPlugIn): ISymphonyPlugInCFGGroup;
begin
  Result  := FTuner.Groups[APlugIn.Name] ;
end;

procedure TfrmSymMngMain.PlugInMngLoadActions(APlugIn: TPlugIn);
Var
  Events: TEventList ;
begin
  if FUIPackageManager.ActionPackageHandle = 0 then
    raise Exception.Create('Нет библиотеки загрузки пользовательского интерфейса плагинов');

  Events.OnExecute      := OnActionExecute ;
  Events.OnClosePlugIn  := OnClosePlugIn ;
  Events.OnEditTuner    := OnEditTuner ;
  Events.OnPrint        := OnPrint ;
  Events.OnExportExcel  := OnExportToExcel ;

  FUIPackageManager.ActionPackage.Builder.BuildActions(nil, APlugIn.Actions, Events);
  FTuner.AddGroup(APlugIn.Name) ;
end;

procedure TfrmSymMngMain.SetActiveFormStyle(Sender: TObject);
begin
  if Screen.ActiveForm <> nil then
            dmMain.SymphonyPluginGridStyle1.SetStyle(Screen.ActiveForm) ;
end;

procedure TfrmSymMngMain.SetScreenEvents;
begin
  Screen.OnActiveFormChange := SetActiveFormStyle ;
end;

procedure TfrmSymMngMain.UpdateUIControls(AForm: TForm);
Var
  i, j: Integer ;
  pl: TPlugIn ;
begin
  for i := 0 to PlugInMng.PlugInCount - 1 do
  begin
    pl  := PlugInMng.PlugIn[i] ;
    for j := 0 to pl.ActionCount - 1 do
      if pl.Action[j].Forms.IndexOf(ActiveMDIChild) >= 0 then
      begin
        FUIPackageManager.ActiveMDIForm := ActiveMDIChild ;
        Exit ;
      end;
  end;
  FUIPackageManager.ActiveMDIForm := nil ;
end;

procedure TfrmSymMngMain.UsageTaskStatistician(DBType: String);
Var
  PkgHandle: NativeUInt ;
  PkgName: String ;
  Fn: TGetUTSInterfaceFunc ;
begin
  FUsageTaskStatistician  := nil ;
  PkgName := Format('uts%s.bpl', [DBType]) ;
  PkgName := GetSystemPackageName(PkgName) ;
  if not FileExists(PkgName) then
                                Exit ;
  PkgHandle := LoadPackage(PkgName) ;
  if PkgHandle = 0 then
                       Exit ;
  Fn  := GetProcAddress(PkgHandle, 'GetUTSInterface') ;
  if Assigned(Fn) then
                      FUsageTaskStatistician  := Fn ;
end;

procedure TfrmSymMngMain.WMCHANGECHILD(var Msg: TMessage);
var
  i: Integer;
  frm: TForm ;
begin
  frm := nil ;
  for i := 0 to MDIChildCount - 1 do
    if MDIChildren[i].Handle = Msg.WParam then
    begin
      frm := MDIChildren[i];
      FUIPackageManager.ActionPackage.Builder.SetContextVisible(frm, Msg.LParam > 0) ;
    end;
end;

procedure TfrmSymMngMain.WMMDIACTIVATE(var Msg: TMessage);
var
  i: Integer ;
begin
  with dxTabbedMDIManager1.TabProperties do
    for i := 0 to PageCount - 1 do
      if Pages[i].MDIChild.Handle = Msg.WParam then
      begin
        dxTabbedMDIManager1.TabProperties.PageIndex := i ;
        Break ;
      end;
end;

procedure TfrmSymMngMain.WMMERGEUI(var Msg: TMessage);
var
  i: Integer;
  frm: TForm ;
begin
  frm := nil ;
  for i := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[i].Handle = Msg.WParam then
    begin
      frm := MDIChildren[i];
    end ;

    FUIPackageManager.ActionPackage.Builder.SetContextVisible(MDIChildren[i], False) ;
  end;

  if frm <> nil then
  begin
    FUIPackageManager.ActionPackage.Builder.MergeUI(frm);
    FUIPackageManager.ActionPackage.Builder.SetContextVisible(frm, True) ;
    dmMain.SymphonyPluginGridStyle1.SetStyle(frm);
  end;
end;

end.
