unit SymphonyPlugIn.PlugInManager;

interface

uses
  System.Classes, Generics.Collections, Vcl.ExtCtrls, Vcl.Forms,
  SymphonyPlugIn.PackageInterface, SymphonyPlugIn.ActionInterface,
  SymphonyPlugIn.ParamInterface ;

Type
  TPlugIn = class ;
  TPlugInList = TObjectList<TPlugIn> ;
  TPlugInPackageInterface = function: IPlugInPackage ;
  TPlugInEvent = procedure (APlugIn: TPlugIn) of object ;
  TPlugInGetSessonParam = procedure (var ServerName: String; var DatabaseName: String; var UserName: String ; var Password: String) of object ;
  TGetSessionForPlugInFunc = procedure (PlugInName, DBType, ServerName, DatabaseName, UserName, Password: String; var Session: TObject) of object ;
  TGetTunerParamsFunc = function (APlugIn: TPlugIn): ISymphonyPlugInCFGGroup of object;

  TPlugInManager = class(TComponent)
  private
    { Private declarations }
    FPlgList: TPlugInList ;
    FGarbageCollector: TTimer ;
    FOnGetParams: TSymphonyPlugInGetParamFunc;
    FOnGetOwnerForm: TSymphonyPlugInGetOwnerFormFunc;
    FOnGetSession: TGetSessionForPlugInFunc;
    FOnClosePlugIn: TPlugInEvent;
    FTunerParams: ISymphonyPlugInCFGGroup;
    FOnGetTunerParam: TGetTunerParamsFunc ;

    function  GetPlugIn(Index: Integer): TPlugIn;
    function  GetPlugInCount: Integer;
    procedure SetOnGetOwnerForm(const Value: TSymphonyPlugInGetOwnerFormFunc);
    procedure SetOnGetParams(const Value: TSymphonyPlugInGetParamFunc);
    procedure SetOnGetSession(const Value: TGetSessionForPlugInFunc);
    procedure SetOnLoadActions(const Value: TPlugInEvent);
    procedure SetOnClosePlugIn(const Value: TPlugInEvent);
    procedure GarbageCollectorExecute(Source: TObject) ;
    procedure SetOnGetTunerParam(const Value: TGetTunerParamsFunc);
  protected
    FOnLoadActions: TPlugInEvent;

    procedure DoOnClosePlugIn(APlugIn: TPlugIn) ;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  LoadPlugIn(PlugInName: String): Integer ;
    function  IndexOf(PlugInName: String): Integer ;
    function  FindPlugInByAction(Action: ISymphonyPlugInAction): TPlugIn ;
    procedure CloseForm(Form: TForm) ;
    procedure ClosePlugIn(APlugIn: TPlugIn) ;
    procedure StartGarbageCollector ;

    property PlugInCount: Integer read GetPlugInCount ;
    property PlugIn[Index: Integer]: TPlugIn read GetPlugIn ;
  published
    property OnGetOwnerForm: TSymphonyPlugInGetOwnerFormFunc  read FOnGetOwnerForm write SetOnGetOwnerForm;
    property OnGetSession: TGetSessionForPlugInFunc  read FOnGetSession write SetOnGetSession;
    property OnGetParams: TSymphonyPlugInGetParamFunc  read FOnGetParams write SetOnGetParams;
    property OnClosePlugIn: TPlugInEvent  read FOnClosePlugIn write SetOnClosePlugIn;
    property OnLoadActions: TPlugInEvent  read FOnLoadActions write SetOnLoadActions;
    property OnGetTunerParam: TGetTunerParamsFunc read FOnGetTunerParam write SetOnGetTunerParam ;
  end;

  TPlugIn = class
  private
    FManager: TPlugInManager ;
    FActions: ISymphonyPlugInActionList ;
    FName: String;
    FHandle: NativeUInt;
    FCaption: String;
    FStopped: Boolean ;
    FOnGetParams: TSymphonyPlugInGetParamFunc;
    FOnGetSessonParam: TPlugInGetSessonParam;
    FTunerParams: ISymphonyPlugInCFGGroup;
    procedure SetCaption(const Value: String);
    procedure SetHandle(const Value: NativeUInt);
    procedure SetName(const Value: String);
    function  GetHandle: NativeUInt;
    function  GetPlugInHandle(Source: ISymphonyPlugInAction): NativeUInt ;
    procedure SetOnGetParams(const Value: TSymphonyPlugInGetParamFunc);
    function  GetSessionForPlugIn(Source: ISymphonyPlugInAction): TObject ;
    procedure SetOnGetSessonParam(const Value: TPlugInGetSessonParam);
    function  GetAction(Index: Integer): ISymphonyPlugInAction;
    function  GetActionCount: Integer;
    function  GetFormCount: Integer;
    procedure UnLoad ;
    function  GetPackageIntf: IPlugInPackage;
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function  GetTunerParams: ISymphonyPlugInCFGGroup;
  public
    constructor Create(AManager: TPlugInManager) ;
    destructor  Destroy ; override ;

    class function GetFullPlugInName(ShortPlugInName: String): String ;
    class function GetShortPlugInName(FullPlugInName: String): String ;
    function  Load(PlugInName: String): Boolean ; // Загрузка пакета, получение акций
    function  ExecAutoRun: Boolean ;      // Запуск акций с признаком AutoStart
    function  Execute(CmdLine: String): Boolean ;      // Запуск акций из командной строки
    procedure ShowForms ;                         // Показать все формы загруженные плагином
    procedure CloseForm(Form: TForm) ;
    procedure Stop ;

    property Actions: ISymphonyPlugInActionList read FActions ;
    property Action[Index: Integer]: ISymphonyPlugInAction read GetAction ;
    property ActionCount: Integer read GetActionCount ;
    property Caption: String  read FCaption write SetCaption;
    property FormCount: Integer read GetFormCount ;
    property Handle: NativeUInt  read GetHandle write SetHandle;
    property Name: String  read FName write SetName;
    property PackageIntf: IPlugInPackage read GetPackageIntf ;
    property Stopped: Boolean read FStopped ;
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
    property OnGetParams: TSymphonyPlugInGetParamFunc  read FOnGetParams write SetOnGetParams;
    property OnGetSessonParam: TPlugInGetSessonParam  read FOnGetSessonParam write SetOnGetSessonParam;
  end ;

procedure Register;

implementation

uses System.SysUtils, System.StrUtils, WinAPI.Windows, SpecFoldersObj ;

{
Type
  TPackageDBTypeFunc =  function: String  ;}

procedure Register;
begin
  RegisterComponents('Symphony', [TPlugInManager]);
end;

{ TPlugInManager }
{$REGION 'TPlugInManager'}
procedure TPlugInManager.CloseForm(Form: TForm);
var
  i: Integer;
begin
  for i := 0 to PlugInCount - 1 do
                                  PlugIn[i].CloseForm(Form);
end;

procedure TPlugInManager.ClosePlugIn(APlugIn: TPlugIn);
begin
  APlugIn.Stop ;
end;

constructor TPlugInManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner) ;
  FPlgList  := TPlugInList.Create ;
  FGarbageCollector := TTimer.Create(Self);
  FGarbageCollector.Enabled   := False ;
  FGarbageCollector.Interval  := 10000 ;
  FGarbageCollector.OnTimer   := GarbageCollectorExecute ;
end;

destructor TPlugInManager.Destroy;
begin
  FPlgList.Free ;
  FGarbageCollector.Free ;
  inherited;
end;

procedure TPlugInManager.DoOnClosePlugIn(APlugIn: TPlugIn);
begin
  if Assigned(FOnClosePlugIn) then
                                  FOnClosePlugIn(APlugIn) ;
end;

function TPlugInManager.FindPlugInByAction(Action: ISymphonyPlugInAction): TPlugIn;
var
  i: Integer;
  pl: TPlugIn ;
  j: Integer;
begin
  Result  := nil ;
  for i := 0 to PlugInCount - 1 do
  begin
    pl  := PlugIn[i] ;
    for j := 0 to pl.ActionCount - 1 do
      if pl.Action[j] = Action then
      begin
        Result  := pl ;
        Break ;
      end;
  end;
end;

procedure TPlugInManager.GarbageCollectorExecute(Source: TObject);
var
  i: Integer;
  StoppedCount: Integer ;
begin
  StoppedCount  := 0 ;
  for i := PlugInCount - 1 downto 0 do
      if PlugIn[i].Stopped then
      begin
        Inc(StoppedCount) ;

        if PlugIn[i].Actions = nil then
        begin
          PlugIn[i].UnLoad ;
          FPlgList.Remove(PlugIn[i]) ;
        end
        else
            PlugIn[i].FActions  := nil ;
      end;

  if StoppedCount = 0 then
                          FGarbageCollector.Enabled := False ;
end;

function TPlugInManager.GetPlugIn(Index: Integer): TPlugIn;
begin
  Result  := FPlgList.Items[Index] ;
end;

function TPlugInManager.GetPlugInCount: Integer;
begin
  Result  := FPlgList.Count ;
end;

function TPlugInManager.IndexOf(PlugInName: String): Integer;
Var
  i: Integer ;
begin
  Result  := -1 ;
  PlugInName  := TPlugIn.GetShortPlugInName(PlugInName) ;

  for i := 0 to PlugInCount - 1 do
    if PlugIn[i].Name = PlugInName then
    begin
      Result  := i;
      Break ;
    end;
end;

function TPlugInManager.LoadPlugIn(PlugInName: String): Integer;
Var
  pl: TPlugIn ;
begin
  Result  := -1 ;
  Try
    Result  := IndexOf(PlugInName) ;

    if Result < 0 then
    begin
      pl      := TPlugIn.Create(Self) ;
      Try
        pl.Load(PlugInName) ;
        Result  := FPlgList.Add(pl) ;
      Except on E: Exception do
        begin
          pl.Free ;
        end;
      End;
    end
    else
    begin
      pl          := PlugIn[Result] ;
      pl.Load(PlugInName) ;
    end ;
  Finally
  End;
end;

procedure TPlugInManager.SetOnClosePlugIn(const Value: TPlugInEvent);
begin
  FOnClosePlugIn := Value;
end;

procedure TPlugInManager.SetOnGetOwnerForm(const Value: TSymphonyPlugInGetOwnerFormFunc);
begin
  FOnGetOwnerForm := Value;
end;

procedure TPlugInManager.SetOnGetParams(const Value: TSymphonyPlugInGetParamFunc);
begin
  FOnGetParams := Value;
end;

procedure TPlugInManager.SetOnGetSession(const Value: TGetSessionForPlugInFunc);
begin
  FOnGetSession := Value;
end;

procedure TPlugInManager.SetOnGetTunerParam(const Value: TGetTunerParamsFunc);
begin
  FOnGetTunerParam := Value;
end;

procedure TPlugInManager.SetOnLoadActions(const Value: TPlugInEvent);
begin
  FOnLoadActions := Value;
end;

procedure TPlugInManager.StartGarbageCollector;
begin
  FGarbageCollector.Enabled := True ;
end;

{$ENDREGION}

{ TPlugIn }
{$REGION 'TPlugIn'}
function TPlugIn.ExecAutoRun: Boolean;
begin
  Result  := False ;
  if FActions <> nil then
                        Result  := FActions.ExecAutoRun ;
end;

function TPlugIn.Execute(CmdLine: String): Boolean ;
begin
  if FActions <> nil then
                        Result  := FActions.Execute(CmdLine) ;
end;

procedure TPlugIn.Stop;
var
  i, j: Integer;
  act: ISymphonyPlugInAction ;
begin
  // закрываем все формы для акций
  for i := 0 to ActionCount - 1 do
  begin
    act := Action[i] ;
    for j := act.Forms.Count - 1 downto 0 do
                                            act.Forms.Items[j].Close ;
  end;

  FStopped  := True ;

  FManager.DoOnClosePlugIn(Self);
  FManager.StartGarbageCollector ;
end;

procedure TPlugIn.UnLoad;
begin
  if Handle > 0 then
  begin
    UnloadPackage(Handle);
    Handle  := 0 ;
  end;
end;

procedure TPlugIn.CloseForm(Form: TForm);
var
  i: Integer;
  act: ISymphonyPlugInAction ;
  j: Integer;
begin
  for i := 0 to ActionCount - 1 do
  begin
    act   := Action[i] ;
    for j := act.Forms.Count - 1 downto 0 do
      if act.Forms.Items[j] = Form then
          act.Forms.Delete(j);
  end;
end;

constructor TPlugIn.Create(AManager: TPlugInManager);
begin
  FManager  := AManager ;
  FActions  := nil ;
  FStopped  := False ;
end;

destructor TPlugIn.Destroy;
begin
  FActions  := nil ;
  UnLoad ;
end;

function TPlugIn.GetAction(Index: Integer): ISymphonyPlugInAction;
begin
  Result  := FActions.Action[Index] ;
end;

function TPlugIn.GetActionCount: Integer;
begin
  Result  := FActions.Count ;
end;

function TPlugIn.GetFormCount: Integer;
var
  i: Integer;
begin
  Result  := 0 ;
  if FActions = nil then
                        Exit ;
  for i := 0 to ActionCount - 1 do
                          Result  := Result + Action[i].Forms.Count ;
end;

function TPlugIn.GetHandle: NativeUInt;
begin
  Result  := FHandle ;
end;

function TPlugIn.GetPackageIntf: IPlugInPackage;
Var
  Fn: TPlugInPackageInterface ;
begin
  Result := nil ;
  if Handle = 0 then
                    Exit ;
  Fn  := GetProcAddress(Handle, 'PackageInterface') ;
  if Assigned(Fn) then
                      Result  := Fn ;
end;

function TPlugIn.GetPlugInHandle(Source: ISymphonyPlugInAction): NativeUInt;
begin
  Result  := Handle ;
end;

// Функция вызывается из акции по указателю на метод
// Метод должен запросить у главной формы (через указатель на метод) сессию базы данных
function TPlugIn.GetSessionForPlugIn(Source: ISymphonyPlugInAction): TObject;
Var
  DBType, ServerName, DBName, UserName, Password: String ;
  Fn: TPlugInPackageInterface ;
begin
  if not Assigned(FManager.FOnGetSession) then
    raise Exception.Create('Не определен метод получения соединения с базой данных');

  // Получаем тип базы данных от пакета
  DBType  := EmptyStr ;
  Fn      := GetProcAddress(Handle, 'PackageInterface') ;
  if Assigned(Fn) then
  begin
    DBType  := Fn.PackageDBType ;
  end;

  // Получаем имя сервера и базы данных от задачи, если плагин прикреплен к задаче
  ServerName  := EmptyStr ; DBName  := EmptyStr ;
  if Assigned(FOnGetSessonParam) then
                                      FOnGetSessonParam(ServerName, DBName, UserName, Password) ;

  FManager.FOnGetSession(Name, DBType, ServerName, DBName, UserName, Password, Result) ;
end;

class function TPlugIn.GetFullPlugInName(ShortPlugInName: String): String;
Var
  i: Integer ;
  FileName: String ;
  Path: String ;
Const
  PluginPath = {$IFDEF CPU64}'PlugIn64'{$ELSE}'PlugIn'{$ENDIF} ;
begin
  Result  := AnsiLowerCase(ShortPlugInName) ;
  if Pos(PathDelim, Result) > 0 then
    if FileExists(Result) then Exit
                          else Result := ExtractFileName(Result) ;


  Path  := ExtractFilePath(Application.ExeName) ;
  Path  := ReverseString(Copy(Path, 1, Length(Path) - 1)) ;
  i     := Pos(PathDelim, Path) ;  // убираем из пути каталог bin или bin64
  if i > 1 then
            Path  := ReverseString(Copy(Path, i, Length(Path) - i + 1)) ;
  Path  := Path + PluginPath + PathDelim ;

  if Copy(Result, Length(Result) - 3, 4) <> '.bpl' then
                                                  Result  := Result + '.bpl' ;
  Result  := Path + Result ;
  if (not FileExists(Result)) and FileExists(ShortPlugInName) then
                                                    Result  := ShortPlugInName ;
end;

class function TPlugIn.GetShortPlugInName(FullPlugInName: String): String;
begin
  Result  := ExtractFileName(FullPlugInName) ;  // Убираем путь к файлу
  Result  := AnsiLowerCase(Result);             // Преобразуем к нижнему регистру
  // убираем расширение у файла
  if Copy(Result, Length(Result) - 3, 4) = '.bpl' then
                              Result  := Copy(Result, 1, Length(Result) - 4) ;
end;

function TPlugIn.GetTunerParams: ISymphonyPlugInCFGGroup;
begin
  Result  := FTunerParams ;
end;

function TPlugIn.Load(PlugInName: String): Boolean ;
Var
  fn: TPlugInPackageInterface ;
  pkgIntf: IPlugInPackage ;
  FullName: String ;
begin
  Try
    Try
      Result    := False ;
      if (not Stopped) and (Handle > 0) then
                                            Exit ;
      FStopped  := False ;

      FullName  := GetFullPlugInName(PlugInName)  ;
      Name      := GetShortPlugInName(PlugInName) ;
{      if FullName = PlugInName then
            Name  := ExtractFileName(PlugInName)
      else
            Name := PlugInName ;}

      if not FileExists(FullName) then
                                      Exit ;

      if Handle = 0 then
      begin
        Handle  := LoadPackage(FullName) ;
      end;
      fn      := GetProcAddress(Handle, 'PackageInterface') ;
      if not Assigned(fn) then
                              Exit ;
      pkgIntf   := fn ;
      FActions  := pkgIntf.GetActionList ;
      if Assigned(FManager.FOnLoadActions) then
                                               FManager.FOnLoadActions(Self) ;

      if Assigned(FManager.OnGetTunerParam) then
            TunerParams := FManager.OnGetTunerParam(Self) ;


      FActions.SetGetHandleFunc(GetPlugInHandle) ;
      FActions.SetGetOwnerFormFunc(FManager.OnGetOwnerForm);
      FActions.SetGetSessionFunc(GetSessionForPlugIn);
      if Assigned(FOnGetParams) then FActions.SetGetParamFunc(FOnGetParams)
                                else FActions.SetGetParamFunc(FManager.OnGetParams);
      FActions.TunerParams  := TunerParams ;
    Except on E: Exception do
    End;
  Finally
  End;
end;

procedure TPlugIn.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TPlugIn.SetHandle(const Value: NativeUInt);
begin
  FHandle := Value;
end;

procedure TPlugIn.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TPlugIn.SetOnGetParams(const Value: TSymphonyPlugInGetParamFunc);
begin
  FOnGetParams := Value;
  if FActions <> nil then
                         FActions.SetGetParamFunc(FOnGetParams) ;
end;

procedure TPlugIn.SetOnGetSessonParam(const Value: TPlugInGetSessonParam);
begin
  FOnGetSessonParam := Value;
end;

procedure TPlugIn.SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
begin
  FTunerParams  := Value ;
end;

procedure TPlugIn.ShowForms;
begin
  if FActions <> nil then
                        FActions.ShowForms ;
end;

{$ENDREGION}

end.
