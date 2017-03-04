unit TNSNameCore;

interface

uses System.Classes, Generics.Collections
     {$IFDEF MSWINDOWS}
     , WinAPI.Windows, Winapi.ShellAPI
     {$ENDIF}  ;

Type
  TTNSNode = class ;
  TTNSNodeList = TObjectList<TTNSNode> ;

  TTNSNode = class
  private
    FChildren: TTNSNodeList ;
    FName: String;
    FValue: String ;
    FLevel: Integer;
    function GetChildCount: Integer;
    function GetChildNode(Index: Integer): TTNSNode;
    function GetValue: String;
    procedure SetName(const AValue: String);
    procedure SetValue(const AValue: String);
    function  IsLeafValue(const AValue: String): Boolean ;
    procedure SetLeafValue(const AValue: String) ;
    procedure DecodeValue(const AValue: String) ;
    procedure SetLevel(const Value: Integer);
  public
    constructor Create ; virtual ;
    destructor Destroy ; override ;

    function AddChild: TTNSNode ; overload ;
    function AddChild(NodeData: String): TTNSNode ; overload ;

    property Name: String  read FName write SetName;
    property Value: String read GetValue write SetValue;
    property Level: Integer  read FLevel write SetLevel;
    property ChildCount: Integer read GetChildCount ;
    property ChildNode[Index: Integer]: TTNSNode read GetChildNode ;
  end;

  TTNSNames = class(TTNSNode)
  private
    FComments: TSTringList ;
    FFileName: String;
    function GetCommentCount: Integer;
    function GetComments(Line: Integer): String;
    procedure SetComments(Line: Integer; const AValue: String);
    procedure SetFileName(const AValue: String);
  public
    constructor Create ; override ;
    destructor Destroy ; override ;

    procedure LoadFromFile(AFileName: String) ;
    procedure SaveToFile(AFileName: String) ;

    property FileName: String  read FFileName write SetFileName;
    property CommentCount: Integer read GetCommentCount ;
    property Comments[Line: Integer]: String read GetComments write SetComments ;
  end;

  TOracleCriticalSection = class(TObject)
  private
    FSection: TRTLCriticalSection;
    Entered: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Enter;
    procedure Leave;
  end;

  TOraEnvironment = class
  private
    FHomeList:  TStringList ;
    FOCISection: TOracleCriticalSection ;   // Critical OCI section
    FOriginalPath: String ;                 // DefaultPath;
    FOracleTNSNames: String ;               // Full Path to the tnsnames.ora file
    FOracleNLSLANG: String ;                // NLS_LANG value
    FOracleHomeKey:   String ;              // Oracle registry key
    FOracleHomeDir:   String ;              // ORACLE_HOME directory
    FOracleHomeName:  String ;              // Forced Oracle home (name)
    FOracleDefaultDomain: String ;          // Default Domain (from sqlnet.ora file)
    FOracleBinDir:    Boolean ;             // ORACLE_HOME bin directory exists
    FDefaultHomeName: Boolean ;             // Was default OracleHome used?
    FHDLL: THandle ;                        // Handle of loaded OCI DLL
    InitOCILog:      String ;               // InitOCI logging
    OCIDLL: String ;                        // Name of OCI DLL
    DefaultOCIDLL: Boolean ;                // Was default OCI DLL used?
    ExcludedOCIDLLs: String ;               // Comma separated list of excluded OCI DLL's
    OCI70: Boolean ;
    OCI72: Boolean ;
    OCI73: Boolean ;
    OCI80: Boolean ;
    OCI81: Boolean ;
    OCI90: Boolean ;
    OCI92: Boolean ;
    OCI80Detected:   Boolean ;
    OCI81Detected:   Boolean ;
    OCI90Detected:   Boolean ;
    OCI92Detected:   Boolean ;
    function GetORACLE_HOME: String;
    function Gettnsnames: String;

    procedure AddToPath(var Path: String; Addition: String);
    function  GetParamString(Name: String): String;
    function  OracleHome: String;
    procedure InitOCI;
    function  GetOCIDLLList(DoLog: Boolean): TStringList;
    function  FindOCIDLL: Integer;
    function  DLLInit:Integer;
    function  DLLLoaded:Boolean;
    procedure DLLExit;
    procedure GetProc(Handle: THandle; var OK:Boolean; var Ad:pointer; const Name:AnsiString);
    procedure OCILog(const S: String);
    {$IFDEF MSWINDOWS}
    // Чисто виндовые функции
    procedure BuildOracleHomeList;
    function  FindHomeKey: String;
    function  ReadRegString(Root: HKEY; const Key, Name: String): String;
    function  ReadRegNames(Root: HKEY; const Key: String): TStrings;
    {$ENDIF}
  public
    constructor Create ;
    destructor Destroy ; override ;

    property ORACLE_HOME: String read GetORACLE_HOME;
    property tnsnames: String read Gettnsnames ;
  end;

implementation

uses System.SysUtils, System.StrUtils ;

Type
  ub4     = LongInt;
  sword   = Integer;
  OCIEnv  = pointer;  // OCI environment handle

Const
  OPRT = '(' ;
  CPRT = ')' ;
  EQCH = '=' ;

Const // Result of DLLInit
  dllOK         = 0;
  dllNoFile     = 1;    // No dll file found
  dllMismatch   = 2;    // dll was no oci dll
  dllNoRegistry = 3;    // No Oracle registry entry found

Const // Modes
  OCI_DEFAULT        = $00; // the default value for parameters and attributes
  OCI_THREADED       = $01; // the application is in threaded environment
  OCI_OBJECT         = $02; // the application is in object environment
  OCI_NON_BLOCKING   = $04; // non blocking mode of operation
  OCI_ENV_NO_MUTEX   = $08; // the environment handle will not be protected by a mutex internally

Var
  opinit:procedure(mode: ub4); cdecl;
  OCIInitialize:
    function(mode: ub4;
             ctxp: pointer;
             malocfp: Pointer;
             ralocfp: Pointer;
             mfreefp: pointer): sword; cdecl;
  OCIEnvCreate:
     function(var envhp: OCIEnv;
              mode: ub4;
              ctxp: Pointer;
              malocfp: Pointer;
              ralocfp: Pointer;
              mfreefp: Pointer;
              xtramemsz: Integer;
              usrmempp: Pointer): sword; cdecl;


{ TTNSNode }
{$REGION 'TTNSNode'}
function TTNSNode.AddChild: TTNSNode;
begin
  Result  := TTNSNode.Create ;
  Result.Level  := Level + 1 ;
  FChildren.Add(Result) ;
end;

function TTNSNode.AddChild(NodeData: String): TTNSNode;
Var
  Node: TTNSNode ;
  Index: Integer ;
  Buffer: String ;
  ChData: String ;
  i, OPCnt, CPCnt: Integer ;
begin
  if NodeData = EmptyStr then
                             Exit ;
  ChData  := EmptyStr ;
  OPCnt   := 0 ; CPCnt  := 0 ;

  for i := 1 to Length(NodeData) do
  begin
    ChData  := ChData + NodeData[i] ;
    if NodeData[i] = OPRT then
                              Inc(OPCnt) ;
    if NodeData[i] = CPRT then
                              Inc(CPCnt) ;
    if (OPCnt > 0) and (OPCnt = CPCnt) then
    begin
      Node      := AddChild ;

      Index     := Pos(EQCH, ChData) ;
      Buffer    := Copy(ChData, 1, Index - 1) ;
      if StartsStr(OPRT, Buffer) then
      begin
        Buffer  := Copy(Buffer, 2, Length(Buffer) - 1) ;
        if EndsStr(CPRT, ChData) then
                          ChData  := Copy(ChData, 1, Length(ChData) - 1) ;
      end;
      Node.Name := Buffer ;

      Buffer      := Trim(Copy(ChData, Index + 1, Length(ChData) - Index + 1)) ;
      Node.Value  := Buffer ;
      ChData      := EmptyStr ;
    end;
  end;
end;

constructor TTNSNode.Create;
begin
  FChildren := TTNSNodeList.Create ;
  FName     := EmptyStr ;
  FValue    := EmptyStr ;
  FLevel    := 0 ;
end;

procedure TTNSNode.DecodeValue(const AValue: String);
Var
  EQIndex: Integer ;
  ChName, ChValue: String ;
begin
  AddChild(AValue)
end;

destructor TTNSNode.Destroy;
begin
  FChildren.Free;
  inherited;
end;

function TTNSNode.GetChildCount: Integer;
begin
  Result  := FChildren.Count ;
end;

function TTNSNode.GetChildNode(Index: Integer): TTNSNode;
begin
  Result  := FChildren.Items[Index]
end;

function TTNSNode.GetValue: String;
var
  i: Integer;
begin
  if ChildCount = 0 then
                        Result  := FValue
  else
  begin
    Result  := EmptyStr ;
    for i := 0 to ChildCount - 1 do
    begin
      Result  := Result + StringOfChar(' ', 3 * Level) + OPRT +
                    ChildNode[i].Name + EQCH + ChildNode[i].Value +
                    IfThen(ChildNode[i].ChildCount > 0,
                            StringOfChar(' ', 3 * Level), EmptyStr) +
                     CPRT + #13+#10    ;
    end;
    Result  := #13#10 + Result  ;
  end;
end;

function TTNSNode.IsLeafValue(const AValue: String): Boolean;
begin
  Result    := Pos('=', AValue) < 1 ;
end;

procedure TTNSNode.SetLeafValue(const AValue: String);
begin
  FValue  := AValue ;
end;

procedure TTNSNode.SetLevel(const Value: Integer);
begin
  FLevel := Value;
end;

procedure TTNSNode.SetName(const AValue: String);
begin
  FName := AValue;
end;

procedure TTNSNode.SetValue(const AValue: String);
begin
  if IsLeafValue(AValue) then
                              SetLeafValue(AValue)
                        else
                              DecodeValue(Trim(AValue)) ;
end;

{$ENDREGION}

{ TTNSNames }
{$REGION 'TTNSNames'}
constructor TTNSNames.Create;
begin
  inherited ;
  FComments := TStringList.Create ;
end;

destructor TTNSNames.Destroy;
begin
  FComments.Free ;
  inherited;
end;

function TTNSNames.GetCommentCount: Integer;
begin
  Result  := FComments.Count ;
end;

function TTNSNames.GetComments(Line: Integer): String;
begin
  Result  := EmptyStr ;
  if Line < CommentCount then
          Result  := FComments.Strings[Line] ;
end;

procedure TTNSNames.LoadFromFile(AFileName: String);
Var
  sl: TStringList ;
  i, j: Integer;
  PRT: Integer ;
  Buffer: String ;
  NodeData: String ;
  FullData: Boolean ;
begin
  sl  := TStringList.Create ;
  Try
    sl.LoadFromFile(AFileName);
    FileName  := AFileName ;
    NodeData  := EmptyStr ;
    Buffer    := EmptyStr ;
    PRT       := 0 ;
    for i := 0 to sl.Count - 1 do
    begin
      Buffer  := Trim(sl.Strings[i]) ;
      if Length(Buffer) = 0 then
                                Continue ;

      if StartsStr('#', Buffer) then
              Comments[CommentCount]  := Buffer
      else
      begin
        for j := 1 to Length(Buffer) do
        begin
          NodeData  := NodeData + Buffer[j] ;
          if Buffer[j] = OPRT then Inc(PRT) ;
          if Buffer[j] = CPRT then Dec(PRT) ;

          if FullData and (PRT = 0) and (Length(NodeData) > 0) then
          begin
            AddChild(NodeData) ;
            NodeData  := EmptyStr ;
            FullData  := False ;
          end;

          FullData := FullData or (Buffer[j] = EQCH) ;
        end;
      end;
    end;
  Finally
    sl.Free ;
  End;
end;

procedure TTNSNames.SaveToFile(AFileName: String);
Var
  sl: TStringList ;
  i: Integer ;
begin
  sl  := TStringList.Create ;
  Try
    for i := 0 to CommentCount - 1 do
                                    sl.Add(Comments[i]) ;
    if CommentCount > 0 then
                            sl.Add(EmptyStr) ;
    for i := 0 to ChildCount - 1 do
    begin
      sl.Add(ChildNode[i].Name + '=' + ChildNode[i].Value) ;
      sl.Add(EmptyStr) ;
    end;

    sl.SaveToFile(AFileName);
    FFileName := AFileName ;
  Finally
    sl.Free ;
  End;
end;

procedure TTNSNames.SetComments(Line: Integer; const AValue: String);
begin
  if Line < CommentCount then
                    FComments.Strings[Line] := AValue
  else
      FComments.Add(AValue)
end;

procedure TTNSNames.SetFileName(const AValue: String);
begin
  FFileName := AValue;
end;

{$ENDREGION}

{ TOracleCriticalSection }
{$REGION ''}
constructor TOracleCriticalSection.Create;
begin
  inherited Create;
  Entered := 0;
  InitializeCriticalSection(FSection);
end;

destructor TOracleCriticalSection.Destroy;
begin
  DeleteCriticalSection(FSection);
  inherited Destroy;
end;

procedure TOracleCriticalSection.Enter;
begin
  EnterCriticalSection(FSection);
  Inc(Entered);
end;

procedure TOracleCriticalSection.Leave;
begin
  if Entered > 0 then
  begin
    Dec(Entered);
    LeaveCriticalSection(FSection);
  end;
end;

{$ENDREGION}

{ TOraEveronment }
{$REGION 'TOraEveronment'}
procedure TOraEnvironment.AddToPath(var Path: String; Addition: String);
begin
  if (Length(Path) > 0) and (Path[Length(Path)] <> PathDelim) then
                                                      Path := Path + PathDelim;
  Path := Path + Addition;
end;

procedure TOraEnvironment.BuildOracleHomeList;
var
  HomeCountString, HomeKey, HomeName, HomeDir: String;
  HomeIndex, HomeCount, Error, i: Integer;
  Names: TStrings;
begin
  if FHomeList = nil then
  begin
    FHomeList := TStringList.Create;
    FHomeList.Sorted := True;
  end;
  FHomeList.Clear;

  HomeCountString := ReadRegString(HKEY_LOCAL_MACHINE, 'SOFTWARE\ORACLE\ALL_HOMES', 'HOME_COUNTER');
  Val(HomeCountString, HomeCount, Error);
  if Error = 0 then
  begin
    if HomeCount <= 1 then
                          HomeCount := 1;  // HomeCount < 1? Try it anyway
    HomeIndex := 0;
    repeat
      HomeKey := 'SOFTWARE\ORACLE\HOME' + IntToStr(HomeIndex);
      HomeDir := ReadRegString(HKEY_LOCAL_MACHINE, HomeKey, 'ORACLE_HOME');
      HomeName := ReadRegString(HKEY_LOCAL_MACHINE, HomeKey, 'ORACLE_HOME_NAME');
      if (HomeName <> '') and (HomeDir <> '') and DirectoryExists(HomeDir + '\bin') then
      begin
        FHomeList.AddObject(HomeName, TObject(HomeIndex));
        dec(HomeCount);
      end;
      inc(HomeIndex);
    until (HomeIndex = 1000) or (HomeCount <= 0);
  end;
  // Find Oracle10g homes
  Names := ReadRegNames(HKEY_LOCAL_MACHINE, 'SOFTWARE\ORACLE');
  for i := 0 to Names.Count - 1 do
  begin
    if AnsiUpperCase(Copy(Names[i], 1, 4)) = 'KEY_' then
    begin
      HomeDir := ReadRegString(HKEY_LOCAL_MACHINE, 'SOFTWARE\ORACLE\' + Names[i], 'ORACLE_HOME');
      if (HomeDir <> '') and DirectoryExists(HomeDir + '\bin') then
        FHomeList.AddObject(Copy(Names[i], 5, Length(Names[i])), TObject(-1));
    end;
  end;
  Names.Free;
end;

constructor TOraEnvironment.Create;
begin
  FOCISection := TOracleCriticalSection.Create ;
  FHomeList   := TStringList.Create ;
end;

destructor TOraEnvironment.Destroy;
begin
  FOCISection.Free ;
  FHomeList.Free ;
  inherited;
end;

procedure TOraEnvironment.DLLExit;
begin
  {$IFDEF LINUX}
{ Leads to segmentation violation, GLIBC bug?
  if MTSLoaded then dlclose(HMTS);
  if DLLLoaded then dlclose(HDLL);}
  HMTS := nil;
  HDLL := nil;
{$ELSE}
  if DLLLoaded then FreeLibrary(FHDLL);
  FHDLL := hInstance_Error - 1;
{$ENDIF}
  if DefaultOCIDLL then OCIDLL := '';
  if FDefaultHomeName then FOracleHomeName := '';
  FOracleDefaultDomain := '';

  FOracleHomeKey   := '';
  FOracleHomeDir   := '';
  FOracleTNSNames  := '';
  FOracleNLSLANG   := '';
end;

function TOraEnvironment.DLLInit: Integer;
Var
  OriginalPath: String ;
begin
  Result := dllOK;
  if DLLLoaded then Exit;          // exit if already loaded
  InitOCILog := '';
  Result := FindOCIDLL;
  if Result <> dllOK then Exit;
{$IFDEF LINUX}
  HDLL := dlopen(PAnsiChar(OCIDLL), RTLD_NOW);
{$ELSE}
  {$IFDEF CompilerVersion6}
  AdjustPath(ExtractFileDir(OCIDLL));
  {$ENDIF}
  FHDLL := LoadLibrary(PChar(OCIDLL));
  if not DLLLoaded then
  begin
    // Try again with Oracle's bin directory as default path
    OriginalPath := GetCurrentDir;
    SetCurrentDir(ExtractFileDir(OCIDLL));
    {$IFDEF CompilerVersion6}
    AdjustPath(ExtractFileDir(OCIDLL));
    {$ENDIF}
    FHDLL := LoadLibrary(PChar(OCIDLL));
  end;
{$ENDIF}
  if not DLLLoaded then
  begin
    OCILog('LoadLibrary(' + OCIDLL + ') returned ' + IntToStr(Integer(FHDLL)));
    {$IFDEF LINUX} OCILog(dlerror); {$ENDIF}
    Result := dllNoFile
  end
  else
  begin
    OCI70 := True;
    OCI72 := OCI70;
    OCI73 := OCI72;
    GetProc(FHDLL, OCI73, @opinit, 'opinit');
    // OCI 8 Relational functions
    OCI80 := True ;
    OCI80Detected := True;
    GetProc(FHDLL, OCI80Detected, @OCIInitialize, 'OCIInitialize');
    OCI81Detected := OCI80Detected;
    GetProc(FHDLL, OCI81Detected, @OCIEnvCreate, 'OCIEnvCreate');
  end;
end;

function TOraEnvironment.DLLLoaded: Boolean;
begin
  {$IFDEF LINUX}
  Result := FHDLL <> nil;
  {$ELSE}
  Result := FHDLL >= hInstance_Error;
  {$ENDIF}
end;

function TOraEnvironment.FindHomeKey: String;
var
  HomeName, HomeKey, ForcedHome, HomeDir, FoundHomeName: String;
  i, HomeIndex, HomePathPos, p: Integer;
  Path: String;
begin
  if FOracleHomeKey <> '' then
  begin
    Result := FOracleHomeKey;
    Exit;
  end;

  BuildOracleHomeList;

  // Check if there are multiple oracle homes
  if FHomeList.Count = 0 then
    Result := 'SOFTWARE\ORACLE'
  else
  begin
    ForcedHome := AnsiUpperCase(GetParamString('ORACLEHOME'));
    if ForcedHome = '' then
                          ForcedHome := FOracleHomeName;

    FDefaultHomeName := False;
    FoundHomeName := '';
    HomeKey := '';
    Result := '';
    SetLength(Path, 10000);
    SetLength(Path, GetEnvironmentVariable(PChar('PATH'), PChar(Path), Length(Path)));
    Path := AnsiUpperCase(Path);
    HomePathPos := Length(Path);
    for i := 0 to FHomeList.Count - 1 do
    begin
      HomeIndex := Integer(FHomeList.Objects[i]);
      HomeName  := FHomeList[i];
      if HomeIndex >= 0 then
        HomeKey   := 'SOFTWARE\ORACLE\HOME' + IntToStr(HomeIndex)
      else
        HomeKey   := 'SOFTWARE\ORACLE\KEY_' + HomeName;
      if AnsiUpperCase(HomeName) = AnsiUpperCase(ForcedHome) then
      begin
        Result := HomeKey;
        FoundHomeName := HomeName;
        Break;
      end;
      // Determine position in Path environment
      HomeDir := ReadRegString(HKEY_LOCAL_MACHINE, HomeKey, 'ORACLE_HOME');
      if HomeDir <> '' then
      begin
        AddToPath(HomeDir, 'bin');
        p := Pos(AnsiUpperCase(HomeDir), Path);
        if (p > 0) and (p < HomePathPos) then
        begin
          Result := HomeKey;
          FoundHomeName := HomeName;
          HomePathPos := p;
        end;
      end;
    end;
    // If none detected as preference, use the last one
    if Result = '' then
    begin
      Result := HomeKey;
      FoundHomeName := HomeName;
    end;
    if FOracleHomeName = '' then
    begin
      FDefaultHomeName := True;
      FOracleHomeName  := FoundHomeName;
    end;
  end;
  HomeDir := ReadRegString(HKEY_LOCAL_MACHINE, Result, 'ORACLE_HOME');
  if (HomeDir = '') or (not DirectoryExists(HomeDir + '\bin')) then
                                                                Result := '';
  FOracleHomeKey := Result;
end;

function TOraEnvironment.FindOCIDLL: Integer;
var List: TStringList;
    DLL: String;
{$IFNDEF LINUX}
    Excluded, UseAllDLLs: Boolean;
    i, Code, Offset: Integer;
    fv, fvMax: Double;
{$ENDIF}
begin
  DefaultOCIDLL := False;
  ExcludedOCIDLLs := UpperCase(ExcludedOCIDLLs);
  Result := dllOK;
  DLL := GetParamString('OCIDLL');           // First check parameter
  if DLL <> '' then OCIDLL := DLL;
  if OCIDLL <> '' then
  begin
    OCILog('OCIDLL forced to ' + OCIDLL);
    Exit;
  end;
{$IFDEF LINUX}
  List := GetOCIDLLList(True);
  if List.Count > 0 then OCIDLL := List[0];
  if OCIDLL = '' then Result := dllNoFile;
  if OCIDLL <> '' then OCILog('Using: ' + OCIDLL);
{$ELSE}
  FOracleHomeDir := OracleHome;
  OCILog('OracleHomeKey: ' + FOracleHomeKey);
  OCILog('OracleHomeDir: ' + FOracleHomeDir);
  List := GetOCIDLLList(True);
  if FOracleHomeDir = '' then
    Result := dllNoRegistry
  else begin
    fvMax := 0.0;
    UseAllDLLs := True;
    repeat
      UseAllDLLs := not UseAllDLLs;
      for i := 0 to List.Count - 1 do
      begin
        DLL := ExtractFilename(List[i]);
        Excluded := (not UseAllDLLs) and (Pos('"' + UpperCase(DLL) +'"', ExcludedOCIDLLs) > 0);
        if not Excluded then
        begin
          if UpperCase(DLL) = 'OCI.DLL' then
          begin
            OCIDLL := List[i];
            DefaultOCIDLL := True;
            Break;
          end;
          Offset := 4;
          if UpperCase(Copy(DLL,4,2)) = 'NT' then inc(Offset, 2);
          val('0.' + Copy(DLL, Offset, Pos('.', DLL) - Offset), fv, Code);
          if (Code = 0) and (fv > fvMax) then
          begin
            fvMax  := fv;
            OCIDLL := List[i];
            Result := dllOK;
            DefaultOCIDLL := True;
          end;
        end;
      end;
    until UseAllDLLs or (OCIDLL <> '');
    if OCIDLL = '' then Result := dllNoFile;
    if OCIDLL <> '' then OCILog('Using: ' + OCIDLL);
  end;
{$ENDIF}
  List.Free;
end;

function TOraEnvironment.GetOCIDLLList(DoLog: Boolean): TStringList;
{$IFDEF LINUX}
var Path: String;
    i: Integer;
    Paths: TStringList;
{$ELSE}
var Path: String;
    Error, Code, Offset: Integer;
    fv: Double;
    DTA: TSearchRec;
label Retry;
{$ENDIF}
begin
  FOracleHomeDir := OracleHome;
  Result := TStringList.Create;
{$IFDEF LINUX}
  Paths := TStringList.Create;
  GetEnvPaths(Paths, 'ORACLE_HOME');
  for i := 0 to Paths.Count - 1 do
  begin
    Path := Paths[i];
    if DoLog then OCILog('OracleHome: ' + Path);
    AddToPath(Path, 'lib/');
    Paths[i] := Path;
  end;
  GetEnvPaths(Paths, 'LD_LIBRARY_PATH');
  for i := 0 to Paths.Count - 1 do
  begin
    Path := Paths[i];
    AddToPath(Path, 'libclntsh.so');
    if FileExists(Path) then
    begin
      Result.Add(Path);
      Break;
    end;
  end;
  Paths.Free;
{$ELSE}
  Path := FOracleHomeDir;
  if Path <> '' then
  begin
    Retry:
    if FOracleBinDir then AddToPath(Path, 'bin\') else AddToPath(Path, '');
    if FileExists(Path + 'oci.dll') then
    begin
      if DoLog then OCILog('Found: ' + 'oci.dll');
      Result.Add(Path + 'oci.dll');
    end;
    Error := FindFirst(Path + 'ora*.dll', faAnyFile,DTA);
    while Error = 0 do
    begin
      Offset := 4;
      if UpperCase(Copy(DTA.Name,4,2)) = 'NT' then inc(Offset, 2);
      val('0.' + Copy(DTA.Name, Offset, Pos('.', DTA.Name) - Offset), fv, Code);
      if (Code = 0) and (fv > 0) then
      begin
        if DoLog then OCILog('Found: ' + DTA.Name);
        Result.Add(Path + DTA.Name);
      end;
      Error := FindNext(DTA);
    end;
    System.SysUtils.FindClose(DTA);
    // for ODAC instant client, search without bin
    if (Result.Count = 0) and FOracleBinDir then
    begin
      Path := FOracleHomeDir;
      FOracleBinDir := False;
      Goto Retry;
    end;
    //
  end;
{$ENDIF}
end;

function TOraEnvironment.GetORACLE_HOME: String;
begin
  Result  := OracleHome ;
end;

function TOraEnvironment.GetParamString(Name: String): String;
var
  i: Integer;
begin
  Result  := EmptyStr ;

  for i := 1 to ParamCount do
  begin
    if Pos(AnsiUpperCase(Name) + '=', AnsiUpperCase(ParamStr(i))) > 0 then
    begin
      Result := Copy(ParamStr(i), Length(Name) + 2, 255);
      Exit;
    end;
  end;
end;

procedure TOraEnvironment.GetProc(Handle: THandle; var OK: Boolean;
                                      var Ad: pointer; const Name: AnsiString);
begin
  if not OK then
    Ad := nil
  else begin
    {$IFDEF LINUX}
    Ad := dlsym(Handle, PAnsiChar(Name));
    {$ELSE}
    Ad := GetProcAddress(Handle, PAnsiChar(Name));
    {$ENDIF}
    if Ad = nil then OK := False;
  end;
end;

function TOraEnvironment.Gettnsnames: String;
begin
  {$IFDEF LINUX}
    //  Ищем в Linux по переменной окружения
    FOracleTNSNames := GetEnv('TNS_ADMIN');
    if FOracleTNSNames = '' then
    begin
      FOracleTNSNames := OracleHome;
      if FOracleTNSNames <> '' then AddToPath(FOracleTNSNames, 'network/admin');
    end;
    if FOracleTNSNames <> '' then
    try
  {$ELSE}

    FindHomeKey;
    // Initialize the dll, needed for OCI80 boolean
    InitOCI;
    try
      // Get TNS_ADMIN from the environment variable
      SetLength(FOracleTNSNames, 1000);
      SetLength(FOracleTNSNames, GetEnvironmentVariable(PChar('TNS_ADMIN'),
                PChar(FOracleTNSNames), Length(FOracleTNSNames)));
      // Get TNS_ADMIN from the registry
      if FOracleTNSNames = '' then
        FOracleTNSNames := ReadRegString(HKEY_LOCAL_MACHINE, FOracleHomeKey, 'TNS_ADMIN');
      // Retry from SOFTWARE\ORACLE if necessary
      if (FOracleTNSNames = '') and (StrIComp(PChar(FOracleHomeKey), 'SOFTWARE\ORACLE') <> 0) then
        FOracleTNSNames := ReadRegString(HKEY_LOCAL_MACHINE, 'SOFTWARE\ORACLE', 'TNS_ADMIN');
      if FOracleTNSNames = '' then
      begin
        // Check Oracle8 registry entries
        if OCI80Detected then
          FOracleTNSNames := ReadRegString(HKEY_LOCAL_MACHINE, FOracleHomeKey, 'NET80')
        else
          FOracleTNSNames := ReadRegString(HKEY_LOCAL_MACHINE, FOracleHomeKey, 'NET20');
        if FOracleTNSNames <> '' then
          AddToPath(FOracleTNSNames, 'Admin')
        else begin
          // If TNS_ADMIN, NET80/NET20 not set, use default path
          FOracleTNSNames := OracleHome;
          if OCI80Detected and not OCI81Detected then
            AddToPath(FOracleTNSNames, 'Net80\Admin')
          else
            AddToPath(FOracleTNSNames, 'Network\Admin');
        end;
      end;
    {$ENDIF}
      AddToPath(FOracleTNSNames, 'tnsnames.ora');
    except;
      // If something goes wrong, let it go wrong silent
    end;
  Result := FOracleTNSNames;
end;

procedure TOraEnvironment.InitOCI;
var
  Error: Integer;
  Msg: String;
begin
  FOCISection.Enter;
  try
    if not DLLLoaded then
    begin
      Error := DLLInit;
      Msg := '';
      case Error of
        dllNoRegistry : Msg := 'SQL*Net not properly installed';
        dllNoFile :     if OCIDLL <> '' then
                            Msg := 'Could not load "' + OCIDLL + '"'
                        else
                          Msg := 'Could not locate OCI dll';
        dllMismatch : Msg := 'Could not initialize "' + OCIDLL + '"';
      end;
      if Error <> dllOK then
      begin
        DLLExit;
        raise Exception.Create('Initialization error'#13#10 + Msg + #13#10#13#10 + InitOCILog);
      end;
      // Never use OCI7's threadsafe mode, you can't use obreak and we do our own mutexing
      if OCI73 and (not OCI80) then opinit(0);
      // We do use OCI8's threadsafe mode though
      if OCI80 and not OCI81 then OCIInitialize(OCI_OBJECT or OCI_THREADED, nil, nil, nil, nil);
    end;
  finally
    FOCISection.Leave;
  end;
end;

procedure TOraEnvironment.OCILog(const S: String);
begin
  if InitOCILog <> '' then InitOCILog := InitOCILog + #13#10;
  InitOCILog := InitOCILog + S;
end;

function TOraEnvironment.OracleHome: String;
{$IFDEF LINUX}
var Paths: TStringList;
{$ELSE}
var HomeDir: String;
    Path: String;
{$ENDIF}

begin
  FOracleBinDir := True;
  {$IFDEF LINUX}
  Paths := TStringList.Create;
  GetEnvPaths(Paths, 'ORACLE_HOME');
  if Paths.Count > 0 then Result := Paths[0] else Result := '';
  Paths.Free;
  {$ELSE}
  Result := ReadRegString(HKEY_LOCAL_MACHINE, FindHomeKey, 'ORACLE_HOME');
  if Result = '' then
  begin
    FOracleHomeKey := '';
    SetLength(HomeDir, 10000);
    SetLength(HomeDir, GetEnvironmentVariable(PChar('ORACLE_HOME'), PChar(HomeDir), Length(HomeDir)));
    if (HomeDir = '') or (HomeDir = '.') then
    begin
      SetLength(Path, 10000);
      SetLength(Path, GetEnvironmentVariable(PChar('PATH'), PChar(Path), Length(Path)));
      HomeDir := ExtractFileDir(FileSearch('oci.dll', Path));
      FOracleBinDir := (Length(HomeDir) > 4) and (AnsiUpperCase(Copy(HomeDir, Length(HomeDir) - 3, 4)) = '\BIN');
      if FOracleBinDir then SetLength(HomeDir, Length(HomeDir) - 4);
    end else begin
      FOracleBinDir := DirectoryExists(HomeDir + '\bin');
    end;
    Result := HomeDir;
  end;
  {$ENDIF}
end;

function TOraEnvironment.ReadRegNames(Root: HKEY; const Key: String): TStrings;
var Handle: HKey;
    R, Index: Integer;
    BufSize: Cardinal;
    S: String;
begin
  Result := TStringList.Create;
  if RegOpenKeyEx(Root, PChar(Key), 0, KEY_READ, Handle) = ERROR_SUCCESS then
  begin
    Index := 0;
    Repeat
      BufSize := 1024;
      SetLength(S, BufSize);
      R := RegEnumKeyEx(Handle, Index, {@S[1]} PChar(S), BufSize, nil, nil, nil, nil);
      if (R = ERROR_SUCCESS) and (BufSize > 0) then
      begin
        SetLength(S, BufSize);
        Result.Add(S);
      end;
      inc(Index);
    until R <> ERROR_SUCCESS;
    RegCloseKey(Handle);
  end;
end;

function TOraEnvironment.ReadRegString(Root: HKEY; const Key, Name: String): String;
var
  Handle: HKey;
  BufSize: Integer;
  DataType: Integer;
begin
  Result := '';
  if RegOpenKeyEx(Root, PChar(Key), 0, KEY_READ, Handle) = ERROR_SUCCESS then
  begin
    DataType := reg_sz;
    BufSize := 1024 * SizeOf(Char);
    SetLength(Result, BufSize div SizeOf(Char));
    if RegQueryValueEx(Handle, PChar(Name), nil, @DataType, @Result[1], @BufSize) <> ERROR_SUCCESS then
      BufSize := 0;
    Dec(BufSize); // Skip the terminating #0
    if BufSize < 0 then BufSize := 0;
    SetLength(Result, BufSize div SizeOf(Char));
    RegCloseKey(Handle);
  end;
end;

{$ENDREGION}

end.
