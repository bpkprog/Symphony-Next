{*************************************************************************}
{       Менеджер пакетов отвечающих за построение пользовательского       }
{  интерфейса списка задач, акций плагина и его инструментальных панелей  }
{*************************************************************************}

unit SymMng.UIPackageManager;

interface

uses System.Generics.Defaults, System.Generics.Collections, VCL.Forms,
     stbIntf.MainUnit ;

Type
  TUIPackage = class
  private
    FFullPath: String;
    FHandle: NativeUInt;
    function GetHandle: NativeUInt;
    function GetName: String;
    function GetBilder: ISymphonyUIManager;
    function GetParentClassName: String;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    function  Load(PackageName: String): Boolean ;
    procedure UnLoad ;

    property Builder: ISymphonyUIManager read GetBilder ;
    property Handle: NativeUInt read GetHandle ;
    property FullPath: String  read FFullPath ;
    property Name: String read GetName;
    property ParentClassName: String read GetParentClassName;
  end;

  TUIPackageManager = class(TObjectList<TUIPackage>)
  private
    FPackagePnt: array[0..1] of Integer ;
    FActiveMDIForm: TForm;
    procedure InitPackagePnt ;
    function  LoadPkg(PackageName: String): Integer ;
    function  FindPackage(PackageName: String): Integer ;
    function  GetActionPackage: TUIPackage;
    function  GetTaskPackage: TUIPackage;
    function  SearchUIPackageName(BuildFunctionName: String): String ;
    procedure LoadActionPackage(PackageName: String) ;
    procedure LoadTaskPackage(PackageName: String) ;
    function  GetActionPackageHandle: NativeUInt;
    function  GetTaskPackageHandle: NativeUInt;
    function  GetParentClassName: String;
    procedure SetActiveMDIForm(const Value: TForm);
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const AComparer: IComparer<TUIPackage>; AOwnsObjects: Boolean = True); overload;
    constructor Create(const Collection: TEnumerable<TUIPackage>; AOwnsObjects: Boolean = True); overload;

    procedure InitPackages(ActionPackageName, TaskPackageName: String) ;
    procedure CloseForm(AForm: TForm) ;

    property ActionPackage: TUIPackage read GetActionPackage  ;
    property TaskPackage: TUIPackage read GetTaskPackage  ;
    property ActionPackageHandle: NativeUInt read GetActionPackageHandle ;
    property TaskPackageHandle: NativeUInt read GetTaskPackageHandle ;
    property ParentClassName: String read GetParentClassName;
    property ActiveMDIForm: TForm  read FActiveMDIForm write SetActiveMDIForm;
  end;

implementation

uses System.SysUtils, WinAPI.Windows, XML.XMLIntf, XMLValUtil ,
     SymMng.PackageManager,
     Logger ;

Type
  TPackageDescFunc        = function : IXMLNode ;
  TGetUIManagerFunc       = function : ISymphonyUIManager ;

{ TUIPackage }
{$REGION 'TUIPackage'}
constructor TUIPackage.Create;
begin
  FFullPath := EmptyStr ;
  FHandle   := 0 ;
end;

destructor TUIPackage.Destroy;
begin
{  if Handle > 0 then
                      UnLoad ;}
  inherited;
end;

function TUIPackage.GetBilder: ISymphonyUIManager;
Var
  Fn: TGetUIManagerFunc ;
begin
  Log.EnterMethod('TUIPackage.GetBilder', [], []);
  Try
    Result  := nil ;
    if Handle = 0 then
    begin
      log.Write('Пакет не загружен, API не определено.');
      Exit ;
    end;

    Log.Write('Ищем в пакете функцию GetUIManager');
    Fn        := GetProcAddress(Handle, 'GetUIManager') ;
    if Assigned(Fn) then
    begin
      Log.Write('В пакете функция GetUIManager найдена. Получаем интерфейс');
      Result    := Fn ;
      if Result = nil then Log.Write('Интерфейс из пакета не получен')
                      else Log.Write('Интерфейс из пакета получен') ;
    end
    else
      Log.Write('В пакете функция GetUIManager не найдена');
  Finally
    Log.ExitMethod('TUIPackage.GetBilder');
  End;
end;

function TUIPackage.GetHandle: NativeUInt;
begin
  Result  := FHandle ;
end;

function TUIPackage.GetName: String;
begin
  Result  := ExtractFileName(FullPath) ;
end;

function TUIPackage.GetParentClassName: String;
Var
  FnInfo: TPackageDescFunc ;
  PkgInfo: IXMLNode ;
begin
  Log.EnterMethod('GetParentClassName', [], []);
  Try
    Result  := EmptyStr ;
    if Handle = 0 then
                      Exit ;

    FnInfo  := GetProcAddress(Handle, 'PackageDesc') ;
    if Assigned(FnInfo) then
                              PkgInfo := FnInfo ;
    Result  := AsStr(PkgInfo.ChildValues['PARENTCLASS']) ;
    Log.Write('Возврашаем результат: %s', [Result]);
  Finally
    Log.ExitMethod('GetParentClassName');
  End;
end;

function TUIPackage.Load(PackageName: String): Boolean;
begin
  Result  := False ;
  if not FileExists(PackageName) then
    raise EFileNotFoundException.CreateFmt('Библиотека "%s" не найдена', [PackageName]);

  FHandle := PackageManager.Load(PackageName) ;
  Result  := Handle > 0 ;
  if Result then
                FFullPath  := PackageName ;
end;

procedure TUIPackage.UnLoad;
begin
  if Handle > 0 then
  begin
    PackageManager.UnLoad(Handle);
    FHandle := 0 ;
  end;
end;

{$ENDREGION}

{ TUIPackageManager }
{$REGION 'TUIPackageManager'}
constructor TUIPackageManager.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects) ;
  InitPackagePnt ;
end;

constructor TUIPackageManager.Create(const AComparer: IComparer<TUIPackage>;
  AOwnsObjects: Boolean);
begin
  inherited Create(AComparer, AOwnsObjects) ;
  InitPackagePnt ;
end;

procedure TUIPackageManager.CloseForm(AForm: TForm);
begin
  if ActionPackage <> nil then
  begin
    ActionPackage.Builder.UnMergeUI(AForm);
  end;
  if FActiveMDIForm = AForm then
                                FActiveMDIForm  := nil ;
end;

constructor TUIPackageManager.Create(const Collection: TEnumerable<TUIPackage>;
  AOwnsObjects: Boolean);
begin
  inherited Create(Collection, AOwnsObjects) ;
  InitPackagePnt ;
end;

function TUIPackageManager.FindPackage(PackageName: String): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to Count - 1 do
    if LowerCase(Items[i].FullPath) = LowerCase(PackageName) then
    begin
      Result  := i ;
      Break ;
    end;
end;

function TUIPackageManager.GetActionPackage: TUIPackage;
Var
  Index: Integer ;
begin
  Result  := nil ;
  Index   := -1 ;
  case FPackagePnt[0] of
//    -2: Result := nil ;
    -1: Index  := FPackagePnt[1] ;
  else
    Index  := FPackagePnt[0] ;
  end;

  if (Index >= 0) and (Index < Count) then
                                          Result  := Items[Index] ;
end;

function TUIPackageManager.GetActionPackageHandle: NativeUInt;
begin
  Result  := 0 ;
  if ActionPackage <> nil then
                            Result  := ActionPackage.Handle ;
end;

function TUIPackageManager.GetParentClassName: String;
begin
  Result  := TaskPackage.ParentClassName ;
end;

function TUIPackageManager.GetTaskPackage: TUIPackage;
begin
  case FPackagePnt[1] of
    -2: Result := nil ;
    -1: Result  := Items[FPackagePnt[0]] ;
  else
    Result  := Items[FPackagePnt[1]] ;
  end;
end;

function TUIPackageManager.GetTaskPackageHandle: NativeUInt;
begin
  Result  := 0 ;
  if TaskPackage <> nil then
                            Result  := TaskPackage.Handle ;
end;

procedure TUIPackageManager.InitPackagePnt;
var
  i: Integer;
begin
  for i := Low(FPackagePnt) to High(FPackagePnt) do
                                  FPackagePnt[i]  := -2 ;
end;

procedure TUIPackageManager.InitPackages(ActionPackageName, TaskPackageName: String);
begin
  Log.EnterMethod('InitPackages', ['ActionPackageName', 'TaskPackageName'], [ActionPackageName, TaskPackageName]);
  Try
    if (ActionPackageName = EmptyStr) or (not FileExists(ActionPackageName)) then
    begin
      ActionPackageName := SearchUIPackageName('GetUIManager') ;
      Log.Write('Найден пакет создания интерфейса акций: %s', [ActionPackageName]);
    end;

    if (TaskPackageName = EmptyStr) or (not FileExists(TaskPackageName)) then
    begin
      TaskPackageName := SearchUIPackageName('GetUIManager') ;
      Log.Write('Найден пакет создания интерфейса задач: %s', [TaskPackageName]);
    end;

    Log.Write('Загружаем пакеты интерфейсов');
    LoadActionPackage(ActionPackageName);
    LoadTaskPackage(TaskPackageName);
    Log.Write('Пакеты интерфейсов загружены');
  Finally
    Log.ExitMethod('InitPackages');
  End;
end;

procedure TUIPackageManager.LoadActionPackage(PackageName: String);
begin
  FPackagePnt[0]  := LoadPkg(PackageName) ;
end;

function TUIPackageManager.LoadPkg(PackageName: String): Integer;
Var
  Pkg: TUIPackage ;
begin
  Result  := FindPackage(PackageName) ;
  if Result < 0 then
  begin
    Pkg := TUIPackage.Create ;
    Pkg.Load(PackageName) ;
    Result  := Add(Pkg) ;
  end
  else Result := -1 ;
end;

procedure TUIPackageManager.LoadTaskPackage(PackageName: String);
begin
  FPackagePnt[1]  := LoadPkg(PackageName) ;
end;

function TUIPackageManager.SearchUIPackageName(BuildFunctionName: String): String;
Var
  Path: String ;
  SearchRec: TSearchRec;
  FindResult: Integer;
  FileName: String ;
  PkgHandle: NativeUint ;
  p1, p2: Pointer ;
begin
  Result  := EmptyStr ;
  Path    := ExtractFilePath(ParamStr(0)) ;
  FindResult := FindFirst(Path + 'stb*.bpl', faAnyFile, SearchRec);
  Try
    While FindResult = 0 do
    begin
      FileName := Path + SearchRec.Name ;

      Try
        PkgHandle := PackageManager.Load(FileName) ;
        Try
          p1        := GetProcAddress(PkgHandle, 'PackageDesc') ;
          p2        := GetProcAddress(PkgHandle, PChar(BuildFunctionName)) ;
          if Assigned(p1) and Assigned(p2) then
          begin
            Result  := FileName ;
            Break ;
          end;
        Finally
          PackageManager.UnLoad(PkgHandle);
        End;
      Except

      End;

      FindResult := FindNext(SearchRec) ;
    end;
  Finally
    System.SysUtils.FindClose(SearchRec);
  End;
end;

procedure TUIPackageManager.SetActiveMDIForm(const Value: TForm);
begin
  if FActiveMDIForm <> Value then
  begin
    if FActiveMDIForm <> nil then
              ActionPackage.Builder.SetContextVisible(FActiveMDIForm, False) ;
    if Value <> nil then
    begin
//      ActionPackage.Builder.MergeUI(Value);
      ActionPackage.Builder.SetContextVisible(Value, True) ;
    end;

    FActiveMDIForm := Value;
  end;
end;

{$ENDREGION}

end.
