unit SymphonyNext.SCFFile;

interface

uses System.UITypes, Xml.XMLIntf, SymphonyNext.Environment ;

Type
  TBits = (osb32, osb64) ;
  TOSFamily = (osfWindows, osfAndroid, osfiOS, osfMacOS, osfLinux) ;

  TSCFFile = class;

  TSCFBaseObject = class
  protected
    procedure WriteLog(AMessage: String) ;
    function  BitsToStr(ABit: TBits): String ;
    function  BitsToInt(ABit: TBits): Integer ;
    function  OSFamilyToStr(AOSFamily: TOSFamily): String ;
  public
    procedure Assign(Source: TSCFBaseObject) ; virtual ; abstract ;
    procedure Load(ANode: IXMLNode) ; virtual ; abstract ;
    procedure Save(ANode: IXMLNode) ; virtual ; abstract ;
  end;

  TPlatform = class(TSCFBaseObject)
  private
    FFile: TSCFFile ;
    FBit: TBits;
    FName: String;
    FOSFamily: TOSFamily;

    procedure SetBit(const Value: TBits);
    procedure SetName(const Value: String);
    function GetExecPath(ABit: TBits): String;
    function GetPlugInPath(ABit: TBits): String;
    procedure SetOSFamily(const Value: TOSFamily);
    function  MinBit(b1, b2: TBits): TBits ;
  public
    constructor Create(AFile: TSCFFile) ;

    procedure BuildPlatformInfo ;

    procedure Assign(Source: TSCFBaseObject) ; override ;
    procedure Load(ANode: IXMLNode) ; override ;
    procedure Save(ANode: IXMLNode) ; override ;

    property Bit: TBits  read FBit write SetBit;
    property ExecPath[ABit: TBits]: String   read GetExecPath ;
    property PlugInPath[ABit: TBits]: String read GetPlugInPath ;
    property OSFamily: TOSFamily  read FOSFamily write SetOSFamily;
    property Name: String  read FName write SetName;
  end;

  TDataBase = class(TSCFBaseObject)
  private
    FFile: TSCFFile ;
    FDBType: String;
    FDataBase: String;
    FServer: String;
    procedure SetDataBase(const Value: String);
    procedure SetDBType(const Value: String);
    procedure SetServer(const Value: String);
    function  GetDBTypeFromFileName(AFileName: String): String ;
  public
    constructor Create(AFile: TSCFFile) ;

    procedure BuildDataBaseInfo ;
    procedure FindDBKind(APath: String) ;
    function  DBPackageCount(APath: String): Integer ;

    procedure Assign(Source: TSCFBaseObject) ; override ;
    procedure Load(ANode: IXMLNode) ; override ;
    procedure Save(ANode: IXMLNode) ; override ;

    property DBType: String  read FDBType write SetDBType;
    property Server: String  read FServer write SetServer;
    property DataBase: String  read FDataBase write SetDataBase;
  end;

  TSCFFile = class(TSCFBaseObject)
  private
    FVersion: String;
    FRootPath: String;
    FDataBase: TDataBase ;
    FPlatform: TPlatform ;
    FFileName: String;
    FHideTaskList: Boolean ;
    FModify: Boolean ;
    FDialogDLLHandle: NativeUInt ;
    FAutoRunList: String;

    function  GetDataBase: TDataBase;
    function  GetPlatform: TPlatform;
    function  GetNewFileName: String ;
    procedure SetRootPath(const Value: String);
    procedure SetVersion(const Value: String);
    procedure SetFileName(const Value: String);
    function  GetValidDBType: Boolean;
    function  GetValidRootPath: Boolean;
    function  GetSymMngPath: String;
    procedure ExecuteUpdatePlugin(AFileName: String) ;
    procedure ExecuteUpdatePlugins ;
    function  GetValidConfig: Boolean;
    function  GetFullExecPath(AFileName: String): String ; overload ;
    function  GetFullExecPath(ABit: TBits; AFileName: String): String ; overload ;
    function  GetXML: String;
    procedure SetXML(const Value: String);
    function  GetModify: Boolean;
    procedure SetNextVersion ;
    function  GetNextVersion(AVersion: String): String ;
    function  GetLastVersion: String ;
    {$IFDEF MSWINDOWS}
    procedure CreateShortLink(AFileName: String) ;
    function  ShortLinkExists(AFileName: String): Boolean ;
    procedure SetAutoRunList(const Value: String);
    procedure SetHideTaskList(const Value: Boolean);
    {$ENDIF}
  public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure BuildSCFFile ;
    procedure BuildSCFUpdate ;
    procedure SetModifyFile ;

    procedure Assign(Source: TSCFBaseObject) ; override ;
    procedure LoadFromFile ; overload ;
    procedure LoadFromFile(AFileName: String) ; overload ;
    procedure Load(ANode: IXMLNode) ; override ;
    procedure Save(ANode: IXMLNode) ; override ;
    procedure SaveToFile(AFileName: String) ; overload ;
    procedure SaveToFile ; overload ;

    procedure Update ;
    function  Edit: Boolean ;
    procedure RunSystem ;
    function  CheckRootPath(ARootPath: String): Boolean ;

    property FileName: String  read FFileName write SetFileName;
    property Version: String  read FVersion write SetVersion;
    property RootPath: String  read FRootPath write SetRootPath;
    property Platform: TPlatform read GetPlatform ;
    property Database: TDataBase read GetDataBase ;
    property HideTaskList: Boolean read FHideTaskList write SetHideTaskList;
    property AutoRunList: String  read FAutoRunList write SetAutoRunList;

    property XML: String read GetXML write SetXML ;
    property Modify: Boolean read GetModify ;
    property SymMngPath: String read GetSymMngPath ;
    property ValidRootPath: Boolean read GetValidRootPath ;
    property ValidDBType: Boolean read GetValidDBType ;
    property ValidConfig: Boolean read GetValidConfig ;
  end;

implementation

Uses System.Types, System.Classes, System.SysUtils, System.StrUtils, XML.XMLDoc,
     FMX.Forms,
     {$IFDEF MSWINDOWS}
        WinAPI.Windows, Winapi.ShellAPI, ShlObj, ComObj, ActiveX,
        FMX.SpecFoldersObj,
     {$ENDIF}
     XMLValUtil , scfmngDialogUnit, SymphonyNext.Logger;

Type
  TUpdateProcExec = function : Integer ;
  TUpdateProcErrorMsg = function (ErrorCode: Integer): String ;
  TConfigSymphonyProc = function (App: TApplication; var ConfigData: String): Boolean ;

Const
  UpdateProcExecName = 'ExecuteUpdate' ;
  UpdateProcErrorMsgName = 'GetErrorMessage' ;

{ TPlatform }
{$REGION 'TPlatform'}
procedure TPlatform.Assign(Source: TSCFBaseObject);
Var
  pl: TPlatform ;
begin
  Log.EnterMethod('TPlatform.Assign', [], []);
  pl  := Source as TPlatform ;
  Name  := pl.Name ;
  Bit   := pl.Bit  ;
  Log.ExitMethod('TPlatform.Assign');
end;

procedure TPlatform.BuildPlatformInfo;
Var
  SymMngPath: String ;
  SymDBName: String ;
  i, N: Integer ;
begin
  Log.EnterMethod('TPlatform.BuildPlatformInfo', [], []);
  // 3. Операционку исправляем принудительно.
  Name := Environment.OSName ;

  // 4. Если под 64-бита есть исполняемый файл и текущая ОС 64-х битная,
  //    то устанавливаем битность 64, иначе 32
  if Environment.OSBit = 64 then
  begin
    Log.Write('Разрядность текущей ОС: 64bit. Определяем минимальную возможную разрядность.');
    Bit  := MinBit(Bit, osb64) ;
    if not FileExists(FFile.SymMngPath) then Bit  := osb32 ;
  end
  else
  begin
    Log.Write('Разрядность текущей ОС: 32bit. Принудительно устанавливаем разрядность.');
    Bit  := osb32 ;
  end;

  case Bit of
    osb32: N  := 1;
    osb64: N  := 2;
  end;

  if FFile.Database.DBType <> EmptyStr then
    for i := 1 to N do
    begin
      SymDBName := Format('%s%sSymDB%s.bpl', [FFile.RootPath, FFile.Platform.ExecPath[FFile.Platform.Bit] + PathDelim, FFile.Database.DBType]) ;
      Log.Write('Проверка выбранной разрядности. Поиск файла "%s"', [SymDBName]);
      if not FileExists(SymDBName)  then
                                        {FFile.Platform.}Bit := osb32
                                    else
                                        Break ;
    end;

  Log.ExitMethod('TPlatform.BuildPlatformInfo');
end;

constructor TPlatform.Create(AFile: TSCFFile);
begin
  FFile := AFile ;
end;

function TPlatform.GetExecPath(ABit: TBits): String;
begin
  Log.EnterMethod('TPlatform.GetExecPath', ['ABit'], [BitsToStr(ABit)]);
  case OSFamily of
    osfWindows: Result  := 'bin'  ;
    osfAndroid: Result  := 'abin' ;
    osfiOS:     Result  := 'ibin';
  end;

  if ABit = osb64 then
                      Result := Result + '64' ;

  Log.Write('OSFamily = %s   ABit = %s  Result = "%s"',
                          [OSFamilyToStr(OSFamily), BitsToStr(ABit), Result]);
  Log.ExitMethod('TPlatform.GetExecPath');
end;

function TPlatform.GetPlugInPath(ABit: TBits): String;
begin
  Log.EnterMethod('TPlatform.GetPlugInPath', ['ABit'], [BitsToStr(ABit)]);
  case OSFamily of
    osfWindows: Result  := 'plugin'  ;
    osfAndroid: Result  := 'aplugin' ;
    osfiOS:     Result  := 'iplugin';
  end;

  if ABit = osb64 then
                      Result := Result + '64' ;
  Log.Write('OSFamily = %s   ABit = %s  Result = "%s"',
                          [OSFamilyToStr(OSFamily), BitsToStr(ABit), Result]);
  Log.ExitMethod('TPlatform.GetPlugInPath');
end;

procedure TPlatform.Load(ANode: IXMLNode);
Var
  OSNode: IXMLNode ;
begin
  Log.EnterMethod('TPlatform.Load', ['ANode'], [ANode.XML]);
  OSNode  := ANode.ChildNodes.Nodes['OS'] ;
  Name    := AsStr(OSNode.Attributes['NAME'], 'WINDOWS') ;
  if AsInt(OSNode.ChildValues['BIT']) = 64 then Bit := osb64
                                           else Bit := osb32 ;
  Log.ExitMethod('TPlatform.Load');
end;

function TPlatform.MinBit(b1, b2: TBits): TBits;
begin
  if Ord(b1)  < Ord(b2) then Result := b1
                        else Result := b2 ;
end;

procedure TPlatform.Save(ANode: IXMLNode);
Var
  OSNode: IXMLNode ;
begin
  Log.EnterMethod('TPlatform.Save', ['ANode'], [ANode.XML]);
  OSNode  := ANode.ChildNodes.Nodes['OS'] ;
  OSNode.Attributes['NAME'] := Name ;
  OSNode.ChildValues['BIT'] := BitsToInt(Bit) ;
  Log.Write('Данные сохранены: ', [OSNode.XML]);
  Log.ExitMethod('TPlatform.Save');
end;

procedure TPlatform.SetBit(const Value: TBits);
begin
  Log.EnterMethod('TPlatform.SetBit', ['Value'], [BitsToStr(Value)]);
  FBit := Value;
  Log.ExitMethod('TPlatform.SetBit');
end;

procedure TPlatform.SetName(const Value: String);
begin
  Log.EnterMethod('TPlatform.SetName', ['Value'], [Value]);
  FName := UpperCase(Value) ;
  if FName = 'ANDROID' then FOSFamily := osfAndroid
  else if FName = 'IOS' then FOSFamily := osfiOS
  else if FName = 'MACOS' then FOSFamily := osfMacOS
  else if FName = 'LINUX' then FOSFamily := osfLinux
  else OSFamily := osfWindows ;

  Log.Write('Установлен тип ОС: %s', [OSFamilyToStr(FOSFamily)]);
  Log.ExitMethod('TPlatform.SetName');
end;

procedure TPlatform.SetOSFamily(const Value: TOSFamily);
begin
  Log.EnterMethod('TPlatform.SetOSFamily', ['Value'], [OSFamilyToStr(Value)]);
  FOSFamily := Value;
  case FOSFamily of
    osfWindows: FName := 'WINDOWS';
    osfAndroid: FName := 'ANDROID' ;
    osfiOS:     FName := 'IOS';
    osfMacOS:   FName := 'MACOS' ;
    osfLinux:   FName := 'LINUX' ;
  end;
  Log.Write('Установлен наименование ОС: %s', [FName]);
  Log.ExitMethod('TPlatform.SetOSFamily');
end;

{$ENDREGION}

{ TDataBase }
{$REGION 'TDataBase'}
procedure TDataBase.Assign(Source: TSCFBaseObject);
Var
  sdb: TDataBase ;
begin
  Log.EnterMethod('TDataBase.Assign', [], []);
  sdb       := Source as TDataBase ;
  DBType    := sdb.DBType ;
  Server    := sdb.Server ;
  DataBase  := sdb.DataBase ;
  Log.ExitMethod('TDataBase.Assign');
end;

procedure TDataBase.BuildDataBaseInfo;
Var
  SymDBName: String ;
  SymTaskName: String ;
  SearchPath: String ;
  b: TBits ;
  i, N: Integer;
begin
  Log.EnterMethod('TDataBase.BuildDataBaseInfo', [], []);
  // 5. Проверяем наличие пакетов для указанного типа БД  в default.scf
  case FFile.Platform.Bit of
    osb32: N  := 1;
    osb64: N  := 2;
  end;

  if DBType <> EmptyStr then
  begin
    Log.Write('Проверяем разрядность  системы для типа базы данных "%s"', [DBType]);
    for i := 1 to N do
    begin
      SymDBName := Format('%s%sSymDB%s.bpl', [FFile.RootPath, FFile.Platform.ExecPath[FFile.Platform.Bit] + PathDelim, DBType]) ;
      SymTaskName := Format('%s%sSymTask%s.bpl', [FFile.RootPath, FFile.Platform.ExecPath[FFile.Platform.Bit] + PathDelim, DBType]) ;
      if not FileExists(SymDBName)  then
                                        FFile.Platform.Bit := osb32
                                    else
                                        Break ;
    end;
  end;

  if (DBType = EmptyStr) or (not FileExists(SymDBName)) then
    for b := FFile.Platform.Bit downto osb32 do
    begin
      SearchPath  := Format('%s%s', [FFile.RootPath, FFile.Platform.ExecPath[b] + PathDelim]) ;
      Log.Write('Ищем пакеты баз данных в каталоге: %s', [SearchPath]);
      FindDBKind(SearchPath) ;
      if (DBType <> EmptyStr) and
                      (DBPackageCount(SearchPath) = 2) then
      begin
        Log.Write('Корректируем разрядность системы');
        FFile.Platform.Bit  := b ;
        Break ;
      end;
    end;
  Log.ExitMethod('TDataBase.BuildDataBaseInfo');
end;

constructor TDataBase.Create(AFile: TSCFFile);
begin
  FFile := AFile ;
end;

function TDataBase.DBPackageCount(APath: String): Integer;
begin
  Result  := 0 ;
  if FileExists(Format('%sSymDB%s.bpl', [APath, DBType])) then Inc(Result)
                                                          else Exit ;
  if FileExists(Format('%sSymTask%s.bpl', [APath, DBType])) then Inc(Result) ;
end;

procedure TDataBase.FindDBKind(APath: String);
var
  SearchRec: TSearchRec;
  FindResult: Integer;
  FindType: String ;
  OneType: String ;
  TwoType: String ;
begin
  Log.EnterMethod('TDataBase.FindDBKind', ['APath'], [APath]);
  OneType     := EmptyStr ;
  TwoType     := EmptyStr ;
  FindResult  := FindFirst(APath + 'SymDB*.bpl', faAnyFile, SearchRec);
  Try
    while FindResult = 0 do
    begin
      FindType    := GetDBTypeFromFileName(SearchRec.Name) ;
      if FileExists(Format('%sSymTask%s.bpl', [APath, FindType])) then
                TwoType := FindType
      else
                OneType := FindType ;

      Log.Write('Найден файл: "%s"   Тип базы данных: "%s"', [SearchRec.Name, FindType]);
      FindResult  := FindNext(SearchRec);
    end;

    Log.Write('Найденные типы баз данных: с двумя пакетами "%s", с одним пакетом "%s"', [TwoType, OneType]);

    DBType  := IfThen(TwoType = EmptyStr, OneType, TwoType) ;
  Finally
    System.SysUtils.FindClose(SearchRec) ;
  End;
  Log.ExitMethod('TDataBase.FindDBKind');
end;

function TDataBase.GetDBTypeFromFileName(AFileName: String): String;
begin
  Result  := ChangeFileExt(ExtractFileName(AFileName), '') ;
  Result  := ReplaceStr(Result, 'SymDB', '') ;
  Result  := ReplaceStr(Result, 'SymTask', '') ;
end;

procedure TDataBase.Load(ANode: IXMLNode);
begin
  Log.EnterMethod('TDataBase.Load', ['ANode'], [ANode.XML]);
  DBType    := AsStr(ANode.ChildValues['TYPE'])     ;
  Server    := AsStr(ANode.ChildValues['SERVER'])   ;
  DataBase  := AsStr(ANode.ChildValues['DATABASE']) ;
  Log.ExitMethod('TDataBase.Load');
end;

procedure TDataBase.Save(ANode: IXMLNode);
begin
  Log.EnterMethod('TDataBase.Save', ['ANode'], [ANode.XML]);
  ANode.ChildValues['TYPE']      := DBType    ;
  ANode.ChildValues['SERVER']    := Server    ;
  ANode.ChildValues['DATABASE']  := DataBase  ;
  Log.Write('Данные сохранены: %s', [ANode.XML]);
  Log.ExitMethod('TDataBase.Save');
end;

procedure TDataBase.SetDataBase(const Value: String);
begin
  Log.EnterMethod('TDataBase.SetDataBase', ['Value'], [Value]);
  FDataBase := Value;
  Log.ExitMethod('TDataBase.SetDataBase');
end;

procedure TDataBase.SetDBType(const Value: String);
begin
  Log.EnterMethod('DataBase.SetDBType', ['Value'], [Value]);
  FDBType := Value;
  Log.ExitMethod('DataBase.SetDBType');
end;

procedure TDataBase.SetServer(const Value: String);
begin
  Log.EnterMethod('TDataBase.SetServer', ['Value'], [Value]);
  FServer := Value;
  Log.ExitMethod('TDataBase.SetServer');
end;

{$ENDREGION}

{ TSCFFile }
{$REGION 'TSCFFile'}
procedure TSCFFile.Assign(Source: TSCFBaseObject);
Var
  fl: TSCFFile ;
begin
  Log.EnterMethod('TSCFFile.Assign', [], []);
  fl          := Source as TSCFFile ;
  Version     := fl.Version ;
  RootPath    := fl.RootPath ;
  AutoRunList := fl.AutoRunList ;
  Platform.Assign(fl.Platform);
  Platform.BuildPlatformInfo ;
  Database.Assign(fl.Database);
  FModify     := True ;
  Log.ExitMethod('TSCFFile.Assign');
end;

procedure TSCFFile.BuildSCFFile ;
Var
  DefaultFile: String ;
begin
  Log.EnterMethod('TSCFFile.BuildSCFFile', [], []);
  // 0. Устанавливаем нулевую версию файла.
  //    Текущая версия подгрузится в default.scf
  //    При формировании обновления, будем делать подполнительное обновление с нулевой версии
  Version   := GetLastVersion ;
  Log.Write('Забираем имя файла из командной строки');
  FileName  := Environment.FileName ;

  // 1. Грузим файл по умолчанию, если он есть
  DefaultFile := ExtractFilePath(ParamStr(0)) + 'default.scf' ;
  Log.Write('DefaultFile = %s', [DefaultFile]);
  if FileExists(DefaultFile) then
  begin
    Log.Write('Файл "%s" существует. Загружаем его.', [DefaultFile]);
    Try
      LoadFromFile(DefaultFile) ;
    Except
    End;
  end;

  // 2. Если путь пустой или не правильный на данном клиенте,
  //    то исправляем его на путь, откуда стартовала программа
  if not ValidRootPath then
  begin
    Log.Write('Корневой каталог приложения "%s" не удоволетворяет требованиям ', [RootPath]);
    RootPath := SpecFolders.AppPath ;
    Log.Write('Назначен корневой каталог приложения: %s', [RootPath]);
  end ;

  Log.Write('Корневой каталог приложения: %s', [RootPath]);

  Platform.BuildPlatformInfo ;
  Database.BuildDataBaseInfo ;
  FModify := True ;
  Log.ExitMethod('TSCFFile.BuildSCFFile');
end;

procedure TSCFFile.BuildSCFUpdate;
Var
  UpdateFile: String ;
  Fl: TSCFFile ;
begin
  Log.EnterMethod('TSCFFile.BuildSCFUpdate', [], []);
  if not ValidRootPath then
  begin
    Log.Write('Не верный корневой каталог');
    Log.ExitMethod('TSCFFile.BuildSCFUpdate');
    Exit ;
  end;

  UpdateFile  := RootPath + ReplaceStr('update*config*', '*', PathDelim) ;
  if not DirectoryExists(UpdateFile) then
                                        ForceDirectories(UpdateFile) ;

  UpdateFile  := UpdateFile + Version + '.scf' ;
  Log.Write('Будет сформирован файл обновления: "%s"', [UpdateFile]);
  SetNextVersion ;
  SaveToFile(UpdateFile);
  Log.ExitMethod('TSCFFile.BuildSCFUpdate');
end;

function TSCFFile.CheckRootPath(ARootPath: String): Boolean;
Var
  SearchRec: TSearchRec;
begin
  Result  := (ARootPath <> EmptyStr) ;
  if Result then
  begin
    if ARootPath[Length(ARootPath)] <> PathDelim then
                                          ARootPath := ARootPath + PathDelim ;
    Result := FindFirst(ARootPath + 'bin*', faDirectory, SearchRec) = 0 ;
    System.SysUtils.FindClose(SearchRec) ;
  end ;
end;

constructor TSCFFile.Create;
begin
  Log.EnterMethod('TSCFFile.Create', [], []);
  FDataBase         := TDataBase.Create(Self) ;
  FPlatform         := TPlatform.Create(Self) ;
  FAutoRunList      := EmptyStr ;
  FModify           := False ;
  FDialogDLLHandle  := 0 ;
  Log.ExitMethod('TSCFFile.Create');
end;

procedure TSCFFile.CreateShortLink(AFileName: String);
var
  MyObject: IUnknown;
  MySLink: IShellLink;
  MyPFile: IPersistFile;
  WideFile: String;
  Path: String ;
begin
  Log.EnterMethod('TSCFFile.CreateShortLink', ['AFileName'], [AFileName]);
  if ShortLinkExists(AFileName) then
  begin
    Log.Write('Ссылка уже существует');
    Log.ExitMethod('TSCFFile.CreateShortLink');
    Exit ;
  end;

  MyObject := CreateComObject(CLSID_ShellLink);
  MySLink := MyObject as IShellLink;
  MyPFile := MyObject as IPersistFile;
  with MySLink do
  begin
    Path  := RootPath ;
    SetPath(PChar(AFileName));
    SetArguments('');
    SetWorkingDirectory(PChar(Path));
  end;
  WideFile := SpecFolders.DesktopPath + ChangeFileExt(ExtractFilename(AFileName), '.lnk');
  MyPFile.Save(PWChar(WideFile), False);

  Log.ExitMethod('TSCFFile.CreateShortLink');
end;

destructor TSCFFile.Destroy;
begin
  FDataBase.Free ;
  FPlatform.Free ;
  if FDialogDLLHandle > 0 then
        UnloadPackage(FDialogDLLHandle);
  inherited;
end;

function TSCFFile.Edit: Boolean;
begin
  Log.EnterMethod('TSCFFile.Edit', [], []);
  Result:= False ;
  Application.Initialize ;
  Application.CreateForm(TfrmSCFDialog, frmSCFDialog);
  Application.Run;
  Result  := frmSCFDialog.ResultDialog ;
  Log.ExitMethod('TSCFFile.Edit');
end;

procedure TSCFFile.ExecuteUpdatePlugin(AFileName: String);
Var
  PkgHandle: NativeUInt ;
  ExecResult: Integer ;
  ErrMsg: String ;
  ExecProc: TUpdateProcExec ;
  ErrMsgProc: TUpdateProcErrorMsg ;
begin
  Log.EnterMethod('TSCFFile.ExecuteUpdatePlugin', ['AFileName'], [AFileName]);
  PkgHandle := LoadPackage(AFileName) ;
  if PkgHandle = 0 then
                       Exit ;
  Try
    {$IFDEF MSWINDOWS}
    ExecProc  := GetProcAddress(PkgHandle, 'ExecuteUpdate') ;
    if Assigned(ExecProc) then
    begin
      ExecResult  := ExecProc ;
      if ExecResult <> 0 then
      begin
        ErrMsgProc  := GetProcAddress(PkgHandle, 'GetErrorMessage') ;
        if Assigned(ErrMsgProc) then
          ErrMsg  := ErrMsgProc(ExecResult) ;
          if ErrMsg <> EmptyStr then
                    raise Exception.Create(ErrMsg);
      end;
    end;
    {$ELSE}
      raise Exception.CreateFmt('Не реализована функция обновления в плагине обновлений "%s"', [AFileName]);
    {$ENDIF}
  Finally
    UnloadPackage(PkgHandle);
    Log.ExitMethod('TSCFFile.ExecuteUpdatePlugin');
  End;
end;

procedure TSCFFile.ExecuteUpdatePlugins;
Var
  SearchRec: TSearchRec;
  FindResult: Integer;
  Path: String ;
begin
  Log.EnterMethod('TSCFFile.ExecuteUpdatePlugins', [], []);
  Path  := RootPath + Platform.ExecPath[Platform.Bit] + PathDelim ;
  Log.Write('Поиск плагинов обновления в каталоге: %s', [Path]);
  FindResult := FindFirst(Path + 'scfupd*.bpl', faAnyFile, SearchRec);
  Try
    While FindResult = 0 do
    begin
      Try
        ExecuteUpdatePlugin(Path + SearchRec.Name) ;
      except on E: Exception do
        WriteLog(E.Message) ;
      End;
      FindResult := FindNext(SearchRec) ;
    end;
  Finally
    System.SysUtils.FindClose(SearchRec);
  End;
  Log.ExitMethod('TSCFFile.ExecuteUpdatePlugins');
end;

function TSCFFile.GetDataBase: TDataBase;
begin
  Result  := FDataBase ;
end;

function TSCFFile.GetFullExecPath(ABit: TBits; AFileName: String): String;
begin
  Result  := RootPath + Platform.ExecPath[ABit] + PathDelim + AFileName ;
end;

function TSCFFile.GetLastVersion: String;
Var
  sl: TStringList ;
  SearchRec: TSearchRec;
  FindResult: Integer;
  Path: String ;
begin
  Result  := EmptyStr ;
  Log.EnterMethod('GetLastVersion', [], []);
  sl      := TStringList.Create ;
  Try
    Path    := RootPath + ReplaceStr('update*config*', '*', PathDelim) + '*.scf' ;
    Log.Write('Каталог поиска файлов обновлений: %s', [Path]);
    FindResult := FindFirst(Path, faAnyFile, SearchRec);
    Try
      While FindResult = 0 do
      begin
        Log.Write('Найден файл: %s', [SearchRec.Name]);
        sl.Add(Copy(SearchRec.Name, 1, Length(SearchRec.Name) - 4)) ;
        FindResult := FindNext(SearchRec) ;
      end;
    Finally
      System.SysUtils.FindClose(SearchRec);
    End;

    Log.Write('Найдено файлов: %d', [sl.Count]);

    if sl.Count = 0 then Result := 'sym-0'
    else
    begin
      sl.Sort ;
      Result  := sl.Strings[sl.Count - 1] ;
    end;
    Log.Write('Назначена версия файла: %s', [Result]);
  Finally
    sl.Free ;
  End;
  Log.ExitMethod('GetLastVersion');
end;

function TSCFFile.GetModify: Boolean;
begin
  Result  := FModify or (not FileExists(FileName)) ;
end;

function TSCFFile.GetFullExecPath(AFileName: String): String;
begin
  Result  := GetFullExecPath(Platform.Bit, AFileName) ;
end;

function TSCFFile.GetNewFileName: String;
begin
  Result  := ChangeFileExt(ExtractFileName(ParamStr(0)), '.scf') ;
  {$IFDEF MSWINDOWS}
    Result  := SpecFolders.PersonalPath + Result ;
  {$ELSE}
    Result  := '~/' + Result ;
  {$ENDIF}
end;

function TSCFFile.GetNextVersion(AVersion: String): String;
Var
  VerParts: TStringDynArray ;
  NextNum: Integer ;
  N, i: Integer ;
begin
  Log.EnterMethod('TSCFFile.GetNextVersion', ['AVersion'], [AVersion]);

  NextNum   := -1 ;
  VerParts  := SplitString(AVersion, '-') ;
  if High(VerParts) > Low(VerParts) then
  begin
    Log.Write('Номер текущей версии: ', [VerParts[High(VerParts)]]);
    NextNum := StrToIntDef(VerParts[High(VerParts)], -1) ;
    if NextNum >= 0 then
                        Inc(NextNum) ;
  end;

  if NextNum < 0 then
  begin
    Result  := AVersion + '-1' ;
    Log.Write('Текущая версия не соответствует стандарту. Назначена новая версия: %s', [Result]);
  end
  else
  begin
    Result  := EmptyStr ;
    for i := Low(VerParts) to High(VerParts) - 1 do
                                          Result  := Result + VerParts[i] ;
    Result  := Result+ '-' + IntToStr(NextNum) ;
    Log.Write('Текущая версия соответствует стандарту. Назначена новая версия: %s', [Result]);
  end;
  Log.ExitMethod('TSCFFile.GetNextVersion');
end;

function TSCFFile.GetPlatform: TPlatform;
begin
  Result  := FPlatform ;
end;

function TSCFFile.GetSymMngPath: String;
begin
  Result  := RootPath + Platform.ExecPath[Platform.Bit] + PathDelim + 'SymMng.exe' ;
end;

function TSCFFile.GetValidConfig: Boolean;
Var
  Path: String ;
  ExeName: String ;
  SymDBName: String ;
  SymTaskName: String ;
begin
  Log.EnterMethod('TSCFFile.GetValidConfig', [], []);
  Log.Write('RootPath = %s', [RootPath]);
  Path          := RootPath + Platform.ExecPath[Platform.Bit] + PathDelim;
  Log.Write('Path = %s', [Path]);
  ExeName       := Path + 'SymMng.exe' ;
  Log.Write('ExeName = %s', [ExeName]);
  SymDBName     := Format('%sSymDB%s.bpl', [Path, database.DBType]) ;
  Log.Write('SymDBName = %s', [SymDBName]);
  SymTaskName   := Format('%sSymTask%s.bpl', [Path, database.DBType]) ;
  Log.Write('SymTaskName = %s', [SymTaskName]);

  Result        := FileExists(ExeName) and FileExists(SymDBName) and FileExists(SymTaskName) ;

  Log.Write('Файл %s %s найден', [ExeName, IfThen(FileExists(ExeName), EmptyStr, 'не')]);
  Log.Write('Файл %s %s найден', [SymDBName, IfThen(FileExists(SymDBName), EmptyStr, 'не')]);
  Log.Write('Файл %s %s найден', [SymTaskName, IfThen(FileExists(SymTaskName), EmptyStr, 'не')]);
  Log.Write('Конфигурация: %s', [IfThen(Result, 'корректна', 'не корректна')]);

  Log.ExitMethod('TSCFFile.GetValidConfig');
end;

function TSCFFile.GetValidDBType: Boolean;
Var
  DBPkgName: String ;
  DBPkgPath: String ;
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  Log.EnterMethod('TSCFFile.GetValidDBType', [], []);
  Result  := ValidRootPath ;
  if not Result then
  begin
    Log.Write('Не правильный корневой каталог системы');
    Exit ;
  end;
  Result      := False ;
  DBPkgName   := Format('SymDB%s.bpl', [DataBase.DBType]) ;
  Log.Write('Имя пакета базы данных: %s', [DBPkgName]);
  FindResult  := FindFirst(RootPath + 'bin*', faDirectory, SearchRec);
  Try
    while FindResult = 0 do
    begin
      DBPkgPath   := RootPath + SearchRec.Name + PathDelim+ DBPkgName;
      Result      := Result or FileExists(DBPkgPath) ;
      Log.Write('Поиск пакета базы данных: %s', [DBPkgPath]);
      if Result then
                    Break ;
      FindResult  := FindNext(SearchRec) ;
    end;
  Finally
    System.SysUtils.FindClose(SearchRec) ;
  End;
  Log.Write('Тип базы данных %s', [IfThen(Result, 'корректен', 'не корректен')]);
  Log.ExitMethod('TSCFFile.GetValidDBType');
end;

function TSCFFile.GetValidRootPath: Boolean;
begin
  Result  := CheckRootPath(RootPath) ;
end;

function TSCFFile.GetXML: String;
Var
  Doc: IXMLDocument ;
begin
  Doc := TXMLDocument.Create(nil);
  Doc.Active    := True ;
  DOC.DocumentElement := Doc.CreateNode('SCF') ;
  Doc.Encoding  := 'UTF-8' ;
  Save(Doc.DocumentElement);
  Doc.DocumentElement.ChildValues['FILENAME'] := FileName ;
  Result  := Doc.XML.Text ;
end;

procedure TSCFFile.Load(ANode: IXMLNode);
begin
  Log.EnterMethod('TSCFFile.Load', ['ANode'], [ANode.XML]);
  Version     := AsStr(ANode.Attributes['VERSION']) ;
  RootPath    := AsStr(ANode.ChildValues['ROOTPATH']) ;
  AutoRunList := AsStr(ANode.ChildValues['AUTORUNLIST']) ;
  FDataBase.Load(ANode.ChildNodes.Nodes['DB']);
  FPlatform.Load(ANode.ChildNodes.Nodes['PLATFORM']) ;
  FHideTaskList := AsBool(ANode.ChildValues['HIDETASKLIST']) ;
  FModify   := False ;
  Log.Write('В Файл загружены данные:' + #10#13 + XML);
  Log.ExitMethod('TSCFFile.Load');
end;

procedure TSCFFile.LoadFromFile(AFileName: String);
Var
  Doc: IXMLDocument ;
begin
  Log.EnterMethod('TSCFFile.LoadFromFile', ['AFileName'], [AFileName]);
  if not FileExists(AFileName) then
  begin
    Log.Write('Файл "%s" не найден', [AFileName]);
    raise EFileNotFoundException.CreateFmt('Файл "%s" не найден', [AFileName]);
  end;

  Log.Write('Создание XML-документа');
  Doc := TXMLDocument.Create(AFileName);
  Load(Doc.DocumentElement) ;
  FileName  := AFileName ;
  Log.ExitMethod('TSCFFile.LoadFromFile');
end;

procedure TSCFFile.RunSystem;
Var
  ExecName: String ;
  Params: String ;
  Path: String ;
  ExecRes: NativeInt ;
begin
  Log.EnterMethod('TSCFFile.RunSystem', [], []);
  Try
    ExecName  := SymMngPath ;
    Params    := Format('-dbt:%s -s:%s -db:%s -e:%s',
                          [Database.DBType, DataBase.Server, DataBase.DataBase, AutoRunList]) ;
    if HideTaskList then
                        Params  := Params + ' -ht' ;

    Path      := ExtractFilePath(ExecName) ;

    Log.Write('Путь к исполняемому файлу: %s', [ExecName]);
    Log.Write('Параметры командной строки: %s', [Params]);
    Log.Write('Рабочий каталог: %s', [Path]);
    {$IFDEF MSWINDOWS}
    ExecRes := ShellExecute(0, 'open', PChar(ExecName), PChar(Params), PChar(Path), SW_SHOWDEFAULT) ;
    Log.Write('Результат запуска: %d', [ExecRes]);
    {$ELSE}
    raise Exception.CreateFmt('Пока не умеем запускать под %s приложение %s', [Platform.Name, ExecName]);
    {$ENDIF}
  Finally
    Log.ExitMethod('TSCFFile.RunSystem');
  End;
end;

procedure TSCFFile.LoadFromFile;
begin
  LoadFromFile(FileName) ;
end;

procedure TSCFFile.Save(ANode: IXMLNode);
begin
  Log.EnterMethod('TSCFFile.Save', ['ANode'], [ANode.XML]);
  ANode.Attributes['VERSION']       := Version ;
  ANode.ChildValues['ROOTPATH']     := RootPath ;
  ANode.ChildValues['AUTORUNLIST']  := AutoRunList ;
  FDataBase.Save(ANode.ChildNodes.Nodes['DB']);
  FPlatform.Save(ANode.ChildNodes.Nodes['PLATFORM']);
  ANode.ChildValues['HIDETASKLIST'] := FHideTaskList ;
  FModify   := False ;
  Log.Write('Данные сохранены: ', [ANode.XML]);
  Log.ExitMethod('TSCFFile.Save');
end;

procedure TSCFFile.SaveToFile(AFileName: String);
Var
  Doc: IXMLDocument ;
  Path: String ;
begin
  Log.EnterMethod('TSCFFile.SaveToFile', ['AFileName'], [AFileName]);
  Doc := TXMLDocument.Create(nil);
  Doc.Active    := True ;
  Doc.Encoding  := 'UTF-8' ;
  DOC.DocumentElement := Doc.CreateNode('SCF') ;

  Save(Doc.DocumentElement);
  Path  := ExtractFilePath(AFileName) ;
  if not DirectoryExists(Path) then
                                  ForceDirectories(Path) ;
  Doc.SaveToFile(AFileName);
  {$IFDEF MSWINDOWS}
    CreateShortLink(AFileName) ;
  {$ENDIF}
  Log.ExitMethod('TSCFFile.SaveToFile');
end;

procedure TSCFFile.SaveToFile;
begin
  if FileName = EmptyStr then
        FileName  := GetNewFileName ;
  if FileName = EmptyStr then
      raise Exception.Create('Не задано имя настроечного файла');
  SaveToFile(FileName) ;
end;

procedure TSCFFile.SetAutoRunList(const Value: String);
begin
  FAutoRunList := Value;
  FModify := True ;
end;

procedure TSCFFile.SetFileName(const Value: String);
begin
  Log.EnterMethod('TSCFFile.SetFileName', ['Value'], [Value]);
  FFileName := Value;
  FModify := True ;
  Log.Write('FileName = %s', [FFileName]);
  Log.ExitMethod('TSCFFile.SetFileName');
end;

procedure TSCFFile.SetHideTaskList(const Value: Boolean);
begin
  FHideTaskList := Value;
  FModify       := True ;
end;

procedure TSCFFile.SetModifyFile;
begin
  FModify := True ;
end;

procedure TSCFFile.SetNextVersion;
begin
  Version := GetNextVersion(Version) ;
end;

procedure TSCFFile.SetRootPath(const Value: String);
Var
  Ch: Char ;
begin
  Log.EnterMethod('TSCFFile.SetRootPath', ['Value'], [Value]);
  FRootPath := Value ;
  if (FRootPath <> EmptyStr) then
  begin
    Ch  := FRootPath[Length(FRootPath)] ;
    if Ch <> PathDelim then
                             FRootPath := FRootPath + PathDelim ;
  end;
  FModify := True ;
  Log.Write('RootPath = %s', [FRootPath]);
  Log.ExitMethod('TSCFFile.SetRootPath');
end;

procedure TSCFFile.SetVersion(const Value: String);
begin
  Log.EnterMethod('TSCFFile.SetVersion', ['Value'], [Value]);
  FVersion  := Value ;
  FModify := True ;
  Log.Write('Version = %s', [FVersion]);
  Log.ExitMethod('TSCFFile.SetVersion');
end;

procedure TSCFFile.SetXML(const Value: String);
Var
  Doc: IXMLDocument ;
begin
  Log.EnterMethod('TSCFFile.SetXML', ['Value'], [Value]);
  FModify := True ;
  Doc := TXMLDocument.Create(nil);
  Doc.XML.Text  := Value ;
  Doc.Active    := True ;
  Load(Doc.DocumentElement);
  Log.ExitMethod('TSCFFile.SetXML');
end;

function TSCFFile.ShortLinkExists(AFileName: String): Boolean;
var
  MyObject: IUnknown;
  MySLink: IShellLink;
  MyPFile: IPersistFile;
  pfd: TWin32FindDataW ;
  SearchRec: TSearchRec;
  FindResult: Integer;
  WideFile: String;
  LinkFile: String ;
  Path: String ;
begin
  Log.EnterMethod('TSCFFile.ShortLinkExists', ['AFileName'], [AFileName]);
  Result  := False ;
  Path    := SpecFolders.DesktopPath ;

  MyObject := CreateComObject(CLSID_ShellLink);
  MySLink := MyObject as IShellLink;
  MyPFile := MyObject as IPersistFile;

  FindResult  := FindFirst(Path + '*.lnk', faAnyFile, SearchRec);
  Try
    while FindResult = 0 do
    begin
      LinkFile  := DupeString(' ', MAX_PATH) ;
      WideFile  := Path + SearchRec.Name ;
      Log.Write('Найден ярлык: %s', [WideFile]);
      MyPFile.Load(PChar(WideFile), STGM_READ) ;
      MySLink.GetPath(PChar(LinkFile), MAX_PATH, pfd, SLGP_RAWPATH) ;
      LinkFile  := Trim(LinkFile) ;
      Result  := UpperCase(LinkFile) = UpperCase(AFileName) ;
      if Result then
                    Break ;

      FindResult  := FindNext(SearchRec) ;
    end;
  Finally
    System.SysUtils.FindClose(SearchRec) ;
  End;

  Log.ExitMethod('TSCFFile.ShortLinkExists');
end;

procedure TSCFFile.Update;
Var
  UpdateFile: String ;
  Fl: TSCFFile ;
begin
  Log.EnterMethod('TSCFFile.Update', [], []);
  if not ValidRootPath then
  begin
    Log.Write('Неправильный корневой каталог системы');
    Log.ExitMethod('TSCFFile.Update');
    Exit ;
  end;
  UpdateFile  := RootPath + ReplaceStr('update*config*', '*', PathDelim) + Version + '.scf' ;
  Log.Write('Файл обновления: %s', [UpdateFile]);
  if not FileExists(UpdateFile) then
  begin
    Log.Write('Файл обновления не найден');
    Log.ExitMethod('TSCFFile.Update');
    Exit ;
  end;
  Log.Write('Создаем временный файл, загружаем туда файл обновления и копируем данные в текущий файл');
  Fl  := TSCFFile.Create ;
  Try
    Fl.LoadFromFile(UpdateFile) ;
    Assign(Fl);
  Finally
    Fl.Free ;
  End;

  ExecuteUpdatePlugins ;
  FModify := True ;
  Log.ExitMethod('TSCFFile.Update');
end;

{$ENDREGION}

{ TSCFBaseObject }

function TSCFBaseObject.BitsToInt(ABit: TBits): Integer;
begin
  case ABit of
    osb32: Result := 32 ;
    osb64: Result := 64;
  else
    Result  := -1 ;
  end;
end;

function TSCFBaseObject.BitsToStr(ABit: TBits): String;
begin
  Result  := IntToStr(BitsToInt(ABit)) ;
end;

function TSCFBaseObject.OSFamilyToStr(AOSFamily: TOSFamily): String;
begin
  case AOSFamily of
    osfWindows: Result  := 'Windows' ;
    osfAndroid: Result  := 'Android' ;
    osfiOS: Result  := 'iOS' ;
    osfMacOS: Result  := 'MacOS' ;
    osfLinux: Result  := 'Linux' ;
  else
    Result  := 'О!!! Чудо!!!!' ;
  end;
end;

procedure TSCFBaseObject.WriteLog(AMessage: String);
begin
  {Здесь логгируем сообщение}
end;

end.
