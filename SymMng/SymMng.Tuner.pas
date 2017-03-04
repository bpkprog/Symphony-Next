{**********************************************************************}
{    Настройщик: объект управляющий параметрами системы и плагинов     }
{**********************************************************************}

unit SymMng.Tuner;

interface

uses System.Classes, SymphonyPlugIn.ParamInterface, cioIntf.MainUnit,
     SymphonyPlugIn.TunerFrame, SymMng.TunerFrame ;

Type
  TCFGGroupList = class(TInterfaceList) ;

  TPlugInTunerFrameFunc = procedure (PlugInName: String; var FrameClass: TfrmSymphonyPlugInTunerClass) of object ;

  TSymMngTuner = class
  private
    FCFGGroups: TCFGGroupList ;
    FIOs: array[0..1] of IConstIO ;
    FGetPlugInTunerFrame: TPlugInTunerFrameFunc;
    function  GetPackageName(PkgType: String): String ;
    procedure InitLocalIO(UserName: String) ;
    procedure InitDBIO(Session: TObject; DBType: String) ;
    function  GetAsBoolean(ParamName: String): Boolean;
    function  GetAsDateTime(ParamName: String): TDateTime;
    function  GetAsFloat(ParamName: String): Double;
    function  GetAsInteger(ParamName: String): Integer;
    function  GetAsString(ParamName: String): String;
    function  GetGroupCount: Integer;
    function  GetGroups(IndexOrName: Variant): ISymphonyPlugInCFGGroup;
    function  GetParamValue(ParamName: String): Variant;
    procedure SetAsBoolean(ParamName: String; const Value: Boolean);
    procedure SetAsDateTime(ParamName: String; const Value: TDateTime);
    procedure SetAsFloat(ParamName: String; const Value: Double);
    procedure SetAsInteger(ParamName: String; const Value: Integer);
    procedure SetAsString(ParamName: String; const Value: String);
    procedure SetParamValue(ParamName: String; const Value: Variant);
    procedure SetGetPlugInTunerFrame(const Value: TPlugInTunerFrameFunc);
  public
    constructor Create(Session: TObject; UserName, DBType: String) ;
    destructor  Destroy ; override ;

    function AddGroup(GroupName: String): ISymphonyPlugInCFGGroup ;
    function IndexOf(GroupName: String): Integer ;
    function Edit: Boolean ;

    property GroupCount: Integer read GetGroupCount ;
    property Groups[IndexOrName: Variant]: ISymphonyPlugInCFGGroup read GetGroups ;

    property AsBoolean[ParamName: String]: Boolean read GetAsBoolean write SetAsBoolean ;
    property AsDateTime[ParamName: String]: TDateTime read GetAsDateTime write SetAsDateTime ;
    property AsFloat[ParamName: String]: Double read GetAsFloat write SetAsFloat ;
    property AsInteger[ParamName: String]: Integer read GetAsInteger write SetAsInteger ;
    property AsString[ParamName: String]: String read GetAsString write SetAsString ;
    property ParamValue[ParamName: String]: Variant read GetParamValue write SetParamValue;

    property GetPlugInTunerFrame: TPlugInTunerFrameFunc  read FGetPlugInTunerFrame write SetGetPlugInTunerFrame;
  end;

implementation

uses System.SysUtils, System.Variants, WinAPI.Windows, VCL.Forms, VCL.Controls,
     SymphonyPlugIn.ParamImpl,
     XMLValUtil, SpecFoldersObj , SymMng.TunerEditor, SymMng.PackageManager;

Type
  TLocalGetConstIOFunc = function(AFileName: String): IConstIO ;
  TDBGetConstIOFunc = function (ASession: TObject): IConstIO ;


{ TSymMngTuner }
{$REGION 'TSymMngTuner'}
function TSymMngTuner.AddGroup(GroupName: String): ISymphonyPlugInCFGGroup;
Var
  Index: Integer ;
  i: Integer;
begin
  // Ищем, возможно уже грузили данную группу
  Index := IndexOf(GroupName) ;
  if Index < 0 then
  begin
    // Групапне загружена, создаем её
    Result      := TSymphonyPlugInCFGGroup.Create ;
    Result.Name := GroupName ;
    FCFGGroups.Add(Result) ;
  end
  else Result := Groups[Index] ;

  // Загружаем данные, сначала из БД, потом из файла
  for i := High(FIOs) downto Low(FIOs) do
    if FIOs[i] <> nil then
        if i = High(FIOs) then
                              Result.Assign(FIOs[i].LoadCFGGroup(GroupName))
                          else
                              Result.Merge(FIOs[i].LoadCFGGroup(GroupName));
end;

constructor TSymMngTuner.Create(Session: TObject; UserName, DBType: String);
begin
  FCFGGroups  := TCFGGroupList.Create ;

  InitLocalIO(UserName) ;
  InitDBIO(Session, DBType) ;
end;

destructor TSymMngTuner.Destroy;
var
  i: Integer;
begin
  for i := Low(FIOs) to High(FIOs) do
                                      FIOs[i] := nil ;
  FCFGGroups.Free ;
  inherited;
end;

function TSymMngTuner.Edit: Boolean;
Var
  frm: TfrmTunerEditor ;
  Frame: TfrmSymMngTuner ;
  FrameClass: TfrmSymphonyPlugInTunerClass ;
  FramePlg: TfrmSymphonyPlugInTuner ;
  i: Integer;
  j: Integer;
begin
  Result  := False ;
  frm     := TfrmTunerEditor.Create(Application.MainForm) ;
  Try
    Frame     := TfrmSymMngTuner.Create(frm);
    Frame.Tag := 0 ;
    frm.AddGroup(Groups[0], Frame);

    if Assigned(FGetPlugInTunerFrame) then

    for i := 1 to GroupCount - 1 do
    begin
      FGetPlugInTunerFrame(Groups[i].Name, FrameClass) ;
      if Assigned(FrameClass) then
      begin
        FramePlg      := FrameClass.Create(frm) ;
        FramePlg.Tag  := i ;
        frm.AddGroup(Groups[i], FramePlg);
      end;
    end;

    frm.ShowModal ;
    Result  := frm.ModalResult = mrOk ;
    if not Result then
                      Exit ;

    for i := 0 to frm.ComponentCount - 1 do
      if frm.Components[i] is TfrmSymphonyPlugInTuner then
      begin
        FramePlg  := frm.Components[i] as TfrmSymphonyPlugInTuner ;
        FramePlg.Save(Groups[FramePlg.Tag]);
      end;

    for i := 0 to GroupCount - 1 do
        for j := Low(FIOs) to High(FIOs) do
                FIOs[j].SaveCFGGroup(Groups[i]) ;
  Finally
    frm.Release ;
  End;
end;

function TSymMngTuner.GetAsBoolean(ParamName: String): Boolean;
begin
  Result  := AsBool(ParamValue[ParamName]) ;
end;

function TSymMngTuner.GetAsDateTime(ParamName: String): TDateTime;
begin
  Result  := XMLValUtil.AsDateTime(ParamValue[ParamName]) ;
end;

function TSymMngTuner.GetAsFloat(ParamName: String): Double;
begin
  Result  := XMLValUtil.AsFloat(ParamValue[ParamName]) ;
end;

function TSymMngTuner.GetAsInteger(ParamName: String): Integer;
begin
  Result  := AsInt(ParamValue[ParamName]) ;
end;

function TSymMngTuner.GetAsString(ParamName: String): String;
begin
  Result  := AsStr(ParamValue[ParamName]) ;
end;

function TSymMngTuner.GetGroupCount: Integer;
begin
  Result := FCFGGroups.Count ;
end;

function TSymMngTuner.GetGroups(IndexOrName: Variant): ISymphonyPlugInCFGGroup;
var
  i: Integer;
begin
  if VarIsNumeric(IndexOrName) then
          Result  := ISymphonyPlugInCFGGroup(FCFGGroups.Items[IndexOrName])
  else
  begin
    Result    := nil ;
    for i := 0 to GroupCount - 1 do
      if Groups[i].Name = IndexOrName then
      begin
        Result  := Groups[i] ;
        Break ;
      end;
  end;
end;

function TSymMngTuner.GetPackageName(PkgType: String): String;
begin
  Result  := SpecFolders.AppPath + Format('cio%s.bpl', [PkgType]) ;
end;

function TSymMngTuner.GetParamValue(ParamName: String): Variant;
Var
  i: Integer ;
begin
  Result  := null ;
  for i := 0 to GroupCount - 1 do
  begin
    Result := Groups[i].PersonalParams.ParamValue[ParamName] ;
    if not VarIsNull(Result) then
      Result := Groups[i].CommonParams.ParamValue[ParamName] ;
    if not VarIsNull(Result) then
                                Break ;
  end;
end;

function TSymMngTuner.IndexOf(GroupName: String): Integer;
var
  i: Integer;
begin
  Result  := -1 ;
  for i := 0 to GroupCount - 1 do
    if Groups[i].Name = GroupName then
    begin
      Result:= i ;
      Break ;
    end;
end;

procedure TSymMngTuner.InitDBIO(Session: TObject; DBType: String);
Var
  PkgName: String ;
  Handle: NativeUInt ;
  Fn: TDBGetConstIOFunc ;
begin
  FIOs[1]   := nil ;
  PkgName   := GetPackageName(DBType) ;

  if FileExists(PkgName) then
  begin
    Handle  :=  PackageManager.Load(PkgName) ;
    if Handle = 0 then
                      Exit ;

    Fn  := GetProcAddress(Handle, 'GetConstIO') ;
    if Assigned(Fn) then
                        FIOs[1] := Fn(Session) ;
  end ;
end;

procedure TSymMngTuner.InitLocalIO(UserName: String);
Var
  FileName: String ;
  PkgName: String ;
  Handle: NativeUInt ;
  Fn: TLocalGetConstIOFunc ;
begin
  FIOs[0]   := nil ;
  FileName  := SpecFolders.AppDataPath + UserName + '.cfg' ;
  PkgName   := GetPackageName('XML') ;

  if FileExists(PkgName) then
  begin
    Handle  :=  PackageManager.Load(PkgName) ;
    if Handle = 0 then
                      Exit ;

    Fn  := GetProcAddress(Handle, 'GetConstIO') ;
    if Assigned(Fn) then
                        FIOs[0] := Fn(FileName) ;
  end ;
end;

procedure TSymMngTuner.SetAsBoolean(ParamName: String; const Value: Boolean);
begin
  ParamValue[ParamName]   := Value ;
end;

procedure TSymMngTuner.SetAsDateTime(ParamName: String; const Value: TDateTime);
begin
  ParamValue[ParamName]   := Value ;
end;

procedure TSymMngTuner.SetAsFloat(ParamName: String; const Value: Double);
begin
  ParamValue[ParamName]   := Value ;
end;

procedure TSymMngTuner.SetAsInteger(ParamName: String; const Value: Integer);
begin
  ParamValue[ParamName]   := Value ;
end;

procedure TSymMngTuner.SetAsString(ParamName: String; const Value: String);
begin
  ParamValue[ParamName]   := Value ;
end;

procedure TSymMngTuner.SetGetPlugInTunerFrame(const Value: TPlugInTunerFrameFunc);
begin
  FGetPlugInTunerFrame := Value;
end;

procedure TSymMngTuner.SetParamValue(ParamName: String; const Value: Variant);
Var
  i: Integer ;
  Index: Integer ;
begin
  for i := 0 to GroupCount - 1 do
  begin
    Index := Groups[i].PersonalParams.IndexOf(ParamName) ;
    if Index >= 0 then
    begin
      Groups[i].PersonalParams.Params[Index].Value := Value ;
      Break ;
    end;

    Index := Groups[i].CommonParams.IndexOf(ParamName) ;
    if Index >= 0 then
    begin
      Groups[i].CommonParams.Params[Index].Value := Value ;
      Break ;
    end;
  end;
end;

{$ENDREGION}

end.
