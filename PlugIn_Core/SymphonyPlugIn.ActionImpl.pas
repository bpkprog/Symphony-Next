unit SymphonyPlugIn.ActionImpl;

interface

uses System.Classes, VCL.Graphics, VCL.Forms, Generics.Collections,
    SymphonyPlugIn.ParamInterface, SymphonyPlugIn.ActionInterface;

Type
  TIconList = TObjectList<TBitmap> ;

  TSymphonyPlugInAction = class(TInterfacedObject, ISymphonyPlugInAction)
  private
    FParams: TInterfaceList ;
    FForms: TFormList ;
    FCaption: String ;
    FFrameClassName: String ;
    FMethodName: String ;
    FIcons: TIconList ;
    FCommand: ISymphonyPlugInCommand;
    FName: String;
    FBeginGroup: Boolean;
    FBar: String;
    FAutoStart: Boolean;
    FVisible: Boolean ;
    FContextName: String ;
    FTabCaption: String;
    FTabIndex: Integer;
    FFormCaption: String ;

    FGetHandleFunc: TSymphonyPlugInGetHandleFunc ;
    FGetOwnerFormFunc: TSymphonyPlugInGetOwnerFormFunc ;
    FGetSessionFunc: TSymphonyPlugInGetSessionFunc ;
    FGetParamFunc: TSymphonyPlugInGetParamFunc ;
    FTunerParams: ISymphonyPlugInCFGGroup;

    procedure SetAutoStart(const Value: Boolean);
    procedure SetBar(const Value: String) ;
    procedure SetCaption(const Value: String) ;
    procedure SetFrameClassName(const Value: String) ;
    procedure SetPlugInMethodName(const Value: String) ;
    procedure SetName(const Value: String) ;
    procedure SetVisible(const Value: Boolean);
    procedure SetBeginGroup(const Value: Boolean) ;
    procedure SetContextName(const Value: String) ;
    procedure SetTabCaption(const Value: String) ;
    procedure SetTabIndex(const Value: Integer) ;
    procedure SetFormCaption(const Value: String) ;

    function  OpenFrame(CmdLine: String): Boolean ;
    function  ExecutePluginMethod(CmdLine: String): Boolean ;
    function  GetFormByID(FormID: String): TForm ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    function  GetBar: String ;
    function  GetCaption: String ;
    function  GetCommand: ISymphonyPlugInCommand ;
    function  GetFrameClassName: String ;
    function  GetPlugInMethodName: String ;
    function  GetIconCount: Integer ;
    function  GetIcon(Index: Integer): VCL.Graphics.TBitmap ;
    function  GetName: String ;
    function  GetBeginGroup: Boolean ;
    function  GetAutoStart: Boolean ;
    function  GetVisible: Boolean;
    function  GetContextName: String ;
    function  GetTabCaption: String ;
    function  GetTabIndex: Integer ;
    function  GetFormCaption: String ;
    function  GetForms: TFormList ;

    procedure SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc) ;
    procedure SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc) ;
    procedure SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc) ;
    procedure SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc) ;

    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function  GetTunerParams: ISymphonyPlugInCFGGroup;

    procedure AddActionIcon(AIcon: VCL.Graphics.TBitmap) ;
    procedure ClearIcons ;
    function  Execute(CmdLine: String = ''): Boolean ;
    procedure ShowForms ;                           // Показывает формы акции
    function  IndexOfForm(AForm: TForm): Integer ;

    property AutoStart: Boolean  read GetAutoStart write SetAutoStart;
    property Bar: String read GetBar write SetBar ;
    property Caption: String  read GetCaption write SetCaption ;
    property Command: ISymphonyPlugInCommand read GetCommand ;
    property ContextName: String read GetContextName write SetContextName;
    property FormCaption: String read GetFormCaption write SetFormCaption ;
    property Forms: TFormList read GetForms ;
    property FrameClassName: String read GetFrameClassName write SetFrameClassName ;
    property PlugInMethodName: String read GetPlugInMethodName write SetPlugInMethodName;
    property Icon[Index: Integer]: VCL.Graphics.TBitmap read GetIcon;
    property Name: String read GetName write SetName ;
    property BeginGroup: Boolean read GetBeginGroup  write SetBeginGroup;
    property TabCaption: String read GetTabCaption write SetTabCaption ;
    property TabIndex: Integer read GetTabIndex write SetTabIndex ;
    property Visible: Boolean read GetVisible write SetVisible ;
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
  end;

{  TSymphonyPlugInPrintAction = class(TSymphonyPlugInAction)
  public
    function  Execute: Boolean ;
  end;}

  TSymphonyPlugInActionList = class(TInterfacedObject, ISymphonyPlugInActionList)
  private
    FActList: TInterfaceList ;
    FCaption: String;
    FGetHandleFunc: TSymphonyPlugInGetHandleFunc ;
    FGetOwnerFormFunc: TSymphonyPlugInGetOwnerFormFunc ;
    FGetSessionFunc: TSymphonyPlugInGetSessionFunc ;
    FGetParamFunc: TSymphonyPlugInGetParamFunc ;
    FTunerParams: ISymphonyPlugInCFGGroup;
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function GetTunerParams: ISymphonyPlugInCFGGroup;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    function AddAction: TSymphonyPlugInAction ;
    function GetCaption: String ;
    function GetCount: Integer ;
    function GetBarCount: Integer ;
    function FindAction(ActionName: String): ISymphonyPlugInAction ;
    function GetAction(Index: Integer): ISymphonyPlugInAction ;
    function GetBar(Index: Integer): String ;
    procedure SetCaption(const Value: String) ;

    // Процедуры для установки функций получения контекста запуска акции для всего списка акций
    procedure SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc) ;
    procedure SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc) ;
    procedure SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc) ;
    procedure SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc) ;

    // запуск автозагрузки
    function  ExecAutoRun: Boolean ;
    function  Execute(CmdLine: String): Boolean ;
    procedure ShowForms ;

    property Caption: String read GetCaption write SetCaption;
    property Count: Integer read GetCount ;
    property Action[Index: Integer]: ISymphonyPlugInAction read GetAction ;
    property BarCount: Integer read GetBarCount ;
    property Bar[Index: Integer]: String read GetBar ;
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
  end;

implementation

uses System.SysUtils, System.StrUtils, System.Types, System.Variants,
     WinAPI.Windows, WinAPI.Messages, VCL.Controls, XMLValUtil,
     SymphonyPlugIn.ParamImpl, SymphonyPlugIn.BaseFrame, Logger ;

{ TSymphonyPlugInAction }
{$REGION 'TSymphonyPlugInAction'}
procedure TSymphonyPlugInAction.AddActionIcon(AIcon: VCL.Graphics.TBitmap);
begin
  FIcons.Add(AIcon) ;
end;

procedure TSymphonyPlugInAction.ClearIcons;
begin
  FIcons.Free ;
  FIcons := TIconList.Create ;
end;

constructor TSymphonyPlugInAction.Create;
begin
  FIcons            := TIconList.Create ;
  FCommand          := TSymphonyPlugInCommand.Create ;
  FForms            := TFormList.Create ;
  FCaption          := EmptyStr ;
  FFormCaption      := EmptyStr ;
  FFrameClassName   := EmptyStr ;
  FMethodName       := EmptyStr ;
  FBeginGroup       := False ;
  FAutoStart        := False ;
  FVisible          := True ;
  FGetHandleFunc    := nil ;
  FGetOwnerFormFunc := nil ;
  FGetSessionFunc   := nil ;
  FGetParamFunc     := nil ;
end;

destructor TSymphonyPlugInAction.Destroy;
begin
  FParams.Free ;
  FIcons.Free ;
  FForms.Free ;
  inherited;
end;

function TSymphonyPlugInAction.Execute(CmdLine: String): Boolean;
begin
  Log.EnterMethod('TSymphonyPlugInAction.Execute', ['CmdLine'], [CmdLine]);
  Try
  Try
    Result  := False ;
    if PlugInMethodName <> EmptyStr then
                                          Result := ExecutePluginMethod(CmdLine)
    else if FrameClassName <> EmptyStr then
                                          Result := OpenFrame(CmdLine)
    else
      raise Exception.Create('Для акции не определен ни метод, ни класс фрейма');
  Except On E: Exception do
    begin
      Log.WriteExceptionInfo(E);
      raise ;
    end;
  End;
  Finally
    Log.ExitMethod('TSymphonyPlugInAction.Execute');
  End;
end;

function TSymphonyPlugInAction.ExecutePluginMethod(CmdLine: String): Boolean;
Var
  fn: TSymphonyPlugInProc ;
  Handle: NativeUInt ;
  Session: TObject ;
  Data: ISymphonyPlugInCommand ;
begin
  // Определяем через указатели на методы
  // Handle пакета плагина, сессию соединения с БД и дополнтельгые параметры
  // Если все собрано и функция в пакете определена, то запускаем её
  Log.EnterMethod('TSymphonyPlugInAction.ExecutePluginMethod', ['CmdLine'], [CmdLine]);
  Try
    Result  := False ;

    if Assigned(FGetHandleFunc) then Handle := FGetHandleFunc(Self)
    else raise Exception.Create('Не определен метод определения Handle библиотеки') ;

    if Handle = 0  then
    begin
      Log.Write('Плагин не загружен: Handle = 0');
      Exit ;
    end;

    if Assigned(FGetSessionFunc) then Session := FGetSessionFunc(Self)
    else raise Exception.Create('Не определен метод определения сессии базы данных') ;

    Data    := TSymphonyPlugInCommand.Create ;
    if Assigned(FGetParamFunc) then
                                  Data.Assign(FGetParamFunc(Self))
                             else
                                  Data.Assign(Command) ;
    Data.ParseParams(CmdLine);

    fn  := GetProcAddress(Handle, PChar(PlugInMethodName)) ;
    if not Assigned(fn) then
    begin
      Log.Write('Функция акции %s в плагине не найдена. Уходим.', [PlugInMethodName]);
      Exit ;
    end;

    Log.Write('Выполняем функцию плагина %s',  [PlugInMethodName]);
    Result  := fn(Session, Data) ;
  Finally
    Log.ExitMethod('TSymphonyPlugInAction.ExecutePluginMethod');
  End;
end;

function TSymphonyPlugInAction.GetAutoStart: Boolean;
begin
  Result  := FAutoStart ;
end;

function TSymphonyPlugInAction.GetBar: String;
begin
  Result := FBar ;
end;

function TSymphonyPlugInAction.GetBeginGroup: Boolean;
begin
  Result  := FBeginGroup ;
end;

function TSymphonyPlugInAction.GetCaption: String;
begin
  Result  := FCaption ;
end;

function TSymphonyPlugInAction.GetCommand: ISymphonyPlugInCommand;
begin
  Result  := FCommand ;
end;

function TSymphonyPlugInAction.GetContextName: String;
begin
  Result  := FContextName ;
end;

function TSymphonyPlugInAction.GetFormByID(FormID: String): TForm;
var
  i: Integer;
  ChildID: PChar ;
Const
  ChildIDLen = 256 ;
begin
  Result  := nil ;
  GetMem(ChildID, ChildIDLen);
  Try
    for i := 0 to Forms.Count - 1 do
    begin
      SendMessage(Forms.Items[i].Handle, WM_GET_CHILDID, NativeUInt(ChildID), 0) ;
      if AnsiLowerCase(ChildID) = AnsiLowerCase(FormID) then
      begin
        Result  := Forms.Items[i] ;
        Break;
      end;
    end;
  Finally
    FreeMem(ChildID, ChildIDLen);
  End;
end;

function TSymphonyPlugInAction.GetFormCaption: String;
begin
  Result  := FFormCaption ;
end;

function TSymphonyPlugInAction.GetForms: TFormList;
begin
  Result  := FForms ;
end;

function TSymphonyPlugInAction.GetFrameClassName: String;
begin
  Result  := FFrameClassName ;
end;

function TSymphonyPlugInAction.GetIcon(Index: Integer): VCL.Graphics.TBitmap;
begin
  Result  := FIcons.Items[Index] ;
end;

function TSymphonyPlugInAction.GetIconCount: Integer;
begin
  Result  := FIcons.Count ;
end;

function TSymphonyPlugInAction.GetPlugInMethodName: String;
begin
  Result  := FMethodName ;
end;

function TSymphonyPlugInAction.GetName: String;
begin
  if FName = EmptyStr then
        Result := ReplaceStr(FrameClassName + '_' + Command.Command, ' ', '_')
  else
        Result  := FName ;
end;

function TSymphonyPlugInAction.GetTabCaption: String;
begin
  Result  := FTabCaption ;
end;

function TSymphonyPlugInAction.GetTabIndex: Integer;
begin
  Result  := FTabIndex ;
end;

function TSymphonyPlugInAction.GetTunerParams: ISymphonyPlugInCFGGroup;
begin
  Result  := FTunerParams ;
end;

function TSymphonyPlugInAction.GetVisible: Boolean;
begin
  Result  := FVisible ;
end;

function TSymphonyPlugInAction.IndexOfForm(AForm: TForm): Integer;
Var
  i: Integer ;
begin
  Result  := -1 ;
  for i := 0 to Forms.Count - 1 do
    if Forms.Items[i] = AForm then
    begin
      Result  := i ;
      Break ;
    end;
end;

function TSymphonyPlugInAction.OpenFrame(CmdLine: String): Boolean;
Var
  FrameClass: TSymphonyPlugInBaseFrameClass ;
  frm: TSymphonyPlugInBaseFrame ;
  form: TForm ;
  Unique: Boolean ;
  FormID: String ;
  Handle: NativeUInt ;
  Session: TObject ;
  Data: ISymphonyPlugInCommand ;
begin
  Result  := False ;
  Unique  := False ;
  // Определяем параметры запуска плагина
  if Assigned(FGetHandleFunc) then Handle := FGetHandleFunc(Self)
  else raise Exception.Create('Не определен метод определения Handle библиотеки') ;

  if Assigned(FGetSessionFunc) then Session := FGetSessionFunc(Self)
  else raise Exception.Create('Не определен метод определения сессии базы данных') ;

  Unique  := True ;
  Data    := TSymphonyPlugInCommand.Create ;
  if Assigned(FGetParamFunc) then
  begin
    Data.Assign(FGetParamFunc(Self)) ;
    Unique  := AsBool(Data.ParamValue['UNIQUE'], False) ;
  end
  else Data.Assign(Command) ;
  Data.ParseParams(CmdLine);

  if (Forms.Count > 0) and Unique then
  begin
    // Если плагин должен быть загружен лишь однажды, то
    // ищем по ID и если находим, то показываем уже созданное окно
    form  := GetFormByID(FrameClassName + '.' + AsStr(Data.ParamValue['ID'])) ;
    if form <> nil then
    begin
//      form  := Forms.Items[0] ;
      form.Show ;
      form.BringToFront ;
      Exit ;
    end;
  end;

  // Получаем форму, на которую будем натягивать плагин
  if Assigned(FGetOwnerFormFunc) then
  begin
    form := FGetOwnerFormFunc(Self) ;
    if form = nil then
            raise Exception.Create('Ошибка создания окна для библиотеки');

    form.Caption  := FormCaption ;
    Forms.Add(form) ;
  end
  else raise Exception.Create('Не определен метод определения окна') ;

  // Создаем фрейм и натягиваем его на форму
  FrameClass  := TSymphonyPlugInBaseFrameClass(GetClass(FrameClassName)) ;
  if not Assigned(FrameClass) then
    raise Exception.CreateFmt('В библиотеке %s класс %s не найден!',
                                                [Name, FrameClassName]);

  frm             := FrameClass.CreatePlugIn(form, Session, Data);
  frm.ContextName := ContextName ;
  frm.Parent      := form ;
  frm.Align       := alClient ;
  frm.Visible     := True ;
  frm.TunerParams := TunerParams ;

  form.OnCloseQuery := frm.FrameCloseQuery ;

  // Форму с фреймом показываем
  form.Show ;
  form.BringToFront ;
end;

procedure TSymphonyPlugInAction.SetAutoStart(const Value: Boolean);
begin
  FAutoStart := Value;
end;

procedure TSymphonyPlugInAction.SetBar(const Value: String);
begin
  FBar  := Value ;
end;

procedure TSymphonyPlugInAction.SetBeginGroup(const Value: Boolean);
begin
  FBeginGroup := Value ;
end;

procedure TSymphonyPlugInAction.SetCaption(const Value: String);
begin
  FCaption  := Value ;
end;

procedure TSymphonyPlugInAction.SetContextName(const Value: String);
begin
  FContextName  := Value ;
end;

procedure TSymphonyPlugInAction.SetFormCaption(const Value: String);
begin
  FFormCaption  := Value ;
end;

procedure TSymphonyPlugInAction.SetFrameClassName(const Value: String);
begin
  FFrameClassName  := Value ;
  if (FFrameClassName <> EmptyStr) and (FCommand.Command = EmptyStr) then
                                                  FCommand.Command := 'open' ;
end;

procedure TSymphonyPlugInAction.SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc);
begin
  FGetHandleFunc  := AFunc ;
end;

procedure TSymphonyPlugInAction.SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc);
begin
  FGetOwnerFormFunc := AFunc ;
end;

procedure TSymphonyPlugInAction.SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc);
begin
  FGetParamFunc := AFunc ;
end;

procedure TSymphonyPlugInAction.SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc);
begin
  FGetSessionFunc := AFunc ;
end;

procedure TSymphonyPlugInAction.SetPlugInMethodName(const Value: String);
begin
  FMethodName := Value ;
  if (FMethodName <> EmptyStr) and (FCommand.Command = EmptyStr) then
                                                FCommand.Command  := 'exec' ;
end;

procedure TSymphonyPlugInAction.SetName(const Value: String);
begin
  FName := Value ;
end;

procedure TSymphonyPlugInAction.SetTabCaption(const Value: String);
begin
  FTabCaption := Value ;
end;

procedure TSymphonyPlugInAction.SetTabIndex(const Value: Integer);
begin
  FTabIndex := Value ;
end;

procedure TSymphonyPlugInAction.SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
begin
  FTunerParams := Value;
end;

procedure TSymphonyPlugInAction.SetVisible(const Value: Boolean);
begin
  FVisible  := Value ;
end;

procedure TSymphonyPlugInAction.ShowForms;
Var
  i: Integer ;
begin
  for i := Forms.Count - 1 downto 0 do
    with Forms.Items[i] do begin Show ; BringToFront ; end ;
end;

{$ENDREGION}

{ TSymphonyPlugInActionList }
{$REGION 'TSymphonyPlugInActionList'}
function TSymphonyPlugInActionList.AddAction: TSymphonyPlugInAction;
begin
  Result  := TSymphonyPlugInAction.Create ;
  FActList.Add(Result) ;

  Result.SetGetHandleFunc(FGetHandleFunc);
  Result.SetGetOwnerFormFunc(FGetOwnerFormFunc);
  Result.SetGetSessionFunc(FGetSessionFunc);
  Result.SetGetParamFunc(FGetParamFunc);
  Result.TunerParams  := TunerParams ;
end;

constructor TSymphonyPlugInActionList.Create;
begin
  FActList  := TInterfaceList.Create ;
end;

destructor TSymphonyPlugInActionList.Destroy;
begin
  FActList.Free ;
  inherited;
end;

function TSymphonyPlugInActionList.ExecAutoRun: Boolean ;
var
  i: Integer;
begin
  Log.EnterMethod('TSymphonyPlugInActionList.ExecAutoRun', [], []);
  Try
    Result  := True ;
    for i := 0 to Count - 1 do
    begin
      Log.Write('i = %d?  Акция: %s  AutoStart = %s', [i, Action[i].Name, BoolToStr(Action[i].AutoStart)]);
      if Action[i].AutoStart then
      begin
        Log.Write('Старт акции %s из списка автозагрузки', [Action[i].Name]);
        Result := Result and Action[i].Execute ;
      end;
    end;
  Finally
    Log.ExitMethod('TSymphonyPlugInActionList.ExecAutoRun');
  End;
end;

function TSymphonyPlugInActionList.Execute(CmdLine: String): Boolean;
Var
  i: Integer ;
  A: ISymphonyPlugInAction ;
  Al: TStringDynArray ;
  Ac: TStringDynArray ;
  AcCmd: String ;
  AcName: String ;
  AcParams: String ;
begin
  Result  := True ;
  Al  := SplitString(CmdLine, '$') ;
  for i := Low(Al) to High(al) do
  begin
    AcCmd     := Al[i] ;
    Ac        := SplitString(AcCmd, '&') ;
    AcName    := Ac[Low(Ac)] ;
    AcParams  := Copy(AcCmd, Length(AcName) + 2, Length(AcCmd) - Length(AcName)) ;

    A         := FindAction(AcName) ;
    if A <> nil then
        Result  := Result and A.Execute(AcParams)
    else
        Result  := False ;
  end;
end;

function TSymphonyPlugInActionList.FindAction(ActionName: String): ISymphonyPlugInAction;
Var
  i: Integer ;
begin
  Result  := nil ;
  for i := 0 to Count - 1 do
    if LowerCase(Action[i].Name) = Lowercase(ActionName) then
    begin
      Result  := Action[i] ;
      Break ;
    end;
end;

function TSymphonyPlugInActionList.GetAction(Index: Integer): ISymphonyPlugInAction;
begin
  Result  := FActList.Items[Index] as ISymphonyPlugInAction;
end;

function TSymphonyPlugInActionList.GetBar(Index: Integer): String;
Var
  i, j: Integer ;
  Buffer: String ;
  BarName: String ;
begin
  j       := -1 ;
  Result  := EmptyStr ;
  Buffer  := EmptyStr ;
  if Index < 0 then
                    Exit ;

  for i := 0 to Count - 1 do
  begin
    BarName := '%' + Action[i].Bar + '%' ;
    if Pos(BarName, Buffer) < 1 then
    begin
      Buffer  := Buffer + BarName ;
      Inc(j) ;
    end;

    if j = Index then
    begin
      Result  := Action[i].Bar ;
      Break ;
    end;
  end;
end;

function TSymphonyPlugInActionList.GetBarCount: Integer;
Var
  i: Integer ;
  Buffer: String ;
  BarName: String ;
begin
  Result  := 0 ;
  Buffer  := EmptyStr ;

  for i := 0 to Count - 1 do
  begin
    BarName := '%' + Action[i].Bar + '%' ;
    if Pos(BarName, Buffer) < 1 then
    begin
      Buffer  := Buffer + BarName ;
      Inc(Result) ;
    end;
  end;
end;

function TSymphonyPlugInActionList.GetCaption: String;
begin
  Result  := FCaption ;
end;

function TSymphonyPlugInActionList.GetCount: Integer;
begin
  Result  := FActList.Count ;
end;

function TSymphonyPlugInActionList.GetTunerParams: ISymphonyPlugInCFGGroup;
begin
  Result  := FTunerParams ;
end;

procedure TSymphonyPlugInActionList.SetCaption(const Value: String);
begin
  FCaption  := Value ;
end;

procedure TSymphonyPlugInActionList.SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc);
Var
  i: Integer ;
begin
  FGetHandleFunc  := AFunc ;
  for i := 0 to count - 1 do
                            Action[i].SetGetHandleFunc(AFunc);
end;

procedure TSymphonyPlugInActionList.SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc);
Var
  i: Integer ;
begin
  FGetOwnerFormFunc  := AFunc ;
  for i := 0 to count - 1 do
                            Action[i].SetGetOwnerFormFunc(AFunc);
end;

procedure TSymphonyPlugInActionList.SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc);
Var
  i: Integer ;
begin
  FGetParamFunc  := AFunc ;
  for i := 0 to count - 1 do
                            Action[i].SetGetParamFunc(AFunc);
end;

procedure TSymphonyPlugInActionList.SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc);
Var
  i: Integer ;
begin
  FGetSessionFunc  := AFunc ;
  for i := 0 to count - 1 do
                            Action[i].SetGetSessionFunc(AFunc);
end;

procedure TSymphonyPlugInActionList.SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
Var
  i: Integer;
begin
  FTunerParams := Value;
  for i := 0 to Count - 1 do
       Action[i].TunerParams  := Value ;
end;

procedure TSymphonyPlugInActionList.ShowForms;
Var
  i: Integer ;
begin
  for i := Count - 1 downto 0 do
                                Action[i].ShowForms ;
end;

{$ENDREGION}

end.
