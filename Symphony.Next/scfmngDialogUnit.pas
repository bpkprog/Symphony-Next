unit scfmngDialogUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ComboEdit, FMX.ListBox,
  SymphonyNext.SCFFile, FMX.Menus;

type
  TfrmSCFDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edRootPath: TEdit;
    Button1: TButton;
    cbOSName: TComboBox;
    cbOSBit: TComboBox;
    ceDBType: TComboEdit;
    ceServer: TComboEdit;
    ceDatabase: TComboEdit;
    Button3: TButton;
    Button2: TButton;
    Label7: TLabel;
    edVer: TEdit;
    Button4: TButton;
    pmVer: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Label8: TLabel;
    edAutorun: TEdit;
    Button5: TButton;
    cbHideTaskList: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edVerValidating(Sender: TObject; var Text: string);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure edRootPathValidate(Sender: TObject; var Text: string);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure cbOSNameChange(Sender: TObject);
    procedure cbOSBitChange(Sender: TObject);
    procedure ceDBTypeChange(Sender: TObject);
    procedure edAutorunChange(Sender: TObject);
  private
    { Private declarations }
    FFile: TSCFFile ;
    FResultDialog: Boolean;
    function  GetXML: String;
    procedure SetXML(const Value: String);
    procedure LoadControl ;
    procedure SaveControl ;
    function  GetResultDialog: Boolean;
    procedure SetVersionFromFile(AFileName: String) ;
    procedure LoadDBTypeList ;
    function  GetBinPath: String ;
  public
    { Public declarations }
    property ResultDialog: Boolean read GetResultDialog;
    property XML: String read GetXML write SetXML ;
  end;

var
  frmSCFDialog: TfrmSCFDialog;

implementation

{$R *.fmx}

uses  {$IFDEF MSWINDOWS}
        WinAPI.Windows,  FMX.SpecFoldersObj,
     {$ENDIF}
     System.StrUtils, SymphonyNext.SCFEngine, SymphonyNext.Logger;
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}

Type
  TBuildDBList = function (DBList: TStrings): Boolean ;

procedure TfrmSCFDialog.Button1Click(Sender: TObject);
Var
  Path: String ;
begin
  Path  := edRootPath.Text ;
  if SelectDirectory('Выбери корневой каталог', Path, Path) then
                                                      edRootPath.Text := Path ;
end;

procedure TfrmSCFDialog.Button2Click(Sender: TObject);
begin
  FResultDialog := True ;
  Close ;
end;

procedure TfrmSCFDialog.Button3Click(Sender: TObject);
begin
  FResultDialog := False ;
  Close ;
end;

procedure TfrmSCFDialog.Button4Click(Sender: TObject);
Var
  P: TPointF ;
begin
  P.X := edVer.Position.X ;
  P.Y := edVer.Position.Y + edVer.Height ;
  P := ClientToScreen(P) ;
  pmVer.Popup(P.X, P.Y);
end;

procedure TfrmSCFDialog.cbOSBitChange(Sender: TObject);
begin
  LoadDBTypeList;
end;

procedure TfrmSCFDialog.cbOSNameChange(Sender: TObject);
begin
  LoadDBTypeList;
end;

procedure TfrmSCFDialog.ceDBTypeChange(Sender: TObject);
Var
  SrvName: String ;
  PkgFileName: String ;
  PkgHandle: NativeUInt ;
  DBLProc: TBuildDBList ;
begin
  SrvName     := ceServer.Text ;
  PkgFileName := Format('%sscfdbl%s.bpl', [GetBinPath, ceDBType.Text]) ;
  if not FileExists(PkgFileName) then
                                    Exit ;
  Try
    PkgHandle := LoadPackage(PkgFileName) ;
    if PkgHandle = 0 then
                        Exit ;
    Try
      DBLProc := GetProcAddress(PkgHandle, 'BuildDBList') ;
      if Assigned(DBLProc) then
      begin
          DBLProc(ceServer.Items) ;
      end;

      if ceServer.Items.IndexOf(SrvName) >= 0 then
                                              ceServer.Text := SrvName ;
    Finally
      UnloadPackage(PkgHandle);
    End;
  Except

  End;
end;

procedure TfrmSCFDialog.edAutorunChange(Sender: TObject);
begin
  if edAutorun.Text = EmptyStr then
                                  cbHideTaskList.IsChecked  := False ;
end;

procedure TfrmSCFDialog.edRootPathValidate(Sender: TObject; var Text: string);
begin
  if FFile.CheckRootPath(Text) then
                                  LoadDBTypeList ;
end;

procedure TfrmSCFDialog.edVerValidating(Sender: TObject; var Text: string);
begin
  with edVer.TextSettings do
    if Text = FFile.Version then
                                Font.Style := Font.Style - [TFontStyle.fsBold]
    else
                                Font.Style := Font.Style + [TFontStyle.fsBold]  ;
end;

procedure TfrmSCFDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := TCloseAction.caFree ;
  if ResultDialog then
  begin
    Engine.SCFFile.XML  := XML ;
    Engine.SCFFile.SetModifyFile ;
  end ;
end;

procedure TfrmSCFDialog.FormCreate(Sender: TObject);
begin
  FFile := TSCFFile.Create ;
  XML   := Engine.SCFFile.XML ;
end;

procedure TfrmSCFDialog.FormDestroy(Sender: TObject);
begin
  FFile.Free ;
end;

function TfrmSCFDialog.GetBinPath: String;
Var
  OSBin: String ;
  Path: String ;
begin
  Result  := EmptyStr ;
  Path      := edRootPath.Text ;
  if (Path = EmptyStr) or (not FFile.CheckRootPath(edRootPath.Text)) then
                                                                        Exit ;
  if Path[Length(Path)] <> PathDelim then
                                        Path  := Path + PathDelim ;

  OSBin := EmptyStr ;
  if cbOSName.ItemIndex > 0 then
            OSBin := LowerCase(Copy(cbOSName.Items[cbOSName.ItemIndex], 1, 1)) ;

  OSBin  := OSBin + 'bin' ;

  if cbOSBit.ItemIndex > 0 then
                              OSBin := OSBin + '64' ;

  Result  := Path + OSBin + PathDelim ;
end;

function TfrmSCFDialog.GetResultDialog: Boolean;
begin
  Result  := FResultDialog ;
end;

function TfrmSCFDialog.GetXML: String;
begin
  SaveControl ;
  Result  := FFile.XML ;
end;

procedure TfrmSCFDialog.LoadControl;
begin
  edVer.Text          := FFile.Version            ;
  cbOSName.ItemIndex  := cbOSName.Items.IndexOf(FFile.Platform.Name) ;
  cbOSBit.ItemIndex   := Ord(FFile.Platform.Bit)  ;
  edRootPath.Text     := FFile.RootPath           ;
  edAutorun.Text      := FFile.AutoRunList        ;
  ceDBType.Text       := FFile.Database.DBType    ;
  ceServer.Text       := FFile.Database.Server    ;
  ceDatabase.Text     := FFile.Database.DataBase  ;
  cbHideTaskList.IsChecked  := FFile.HideTaskList ;
end;

procedure TfrmSCFDialog.LoadDBTypeList;
Var
  SearchRec: TSearchRec;
  FindResult: Integer;
  FileName: String ;
  OSBin: String ;
  Path: String ;
  DBType: String ;
begin
  DBType  := ceDBType.Text ;
  ceDBType.Items.Clear ;
  Path      := GetBinPath ;
  FileName  := EmptyStr ;
  FindResult := FindFirst(Path + 'SymDB*.bpl', faAnyFile, SearchRec);
  Try
    While FindResult = 0 do
    begin
      FileName := Copy(SearchRec.Name, 6, Length(SearchRec.Name) - 9) ;
      ceDBType.Items.Add(FileName) ;
      FindResult := FindNext(SearchRec) ;
    end;

    ceDBType.ItemIndex  := ceDBType.Items.IndexOf(DBType) ;
  Finally
    System.SysUtils.FindClose(SearchRec);
  End;
end;

procedure TfrmSCFDialog.MenuItem1Click(Sender: TObject);
begin
  edVer.Text  := FFile.Version ;
end;

procedure TfrmSCFDialog.MenuItem2Click(Sender: TObject);
Var
  FileName: String ;
begin
  FileName  := SpecFolders.AppPath + 'default.scf' ;
  SetVersionFromFile(FileName);
end;

procedure TfrmSCFDialog.MenuItem3Click(Sender: TObject);
Var
  fl: TSCFFile ;
  FileName: String ;
  Path: String ;
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  Path      := edRootPath.Text ;
  if Path = EmptyStr then
                          Exit ;
  if Path[Length(Path)] <> PathDelim then
                                        Path  := Path + PathDelim ;
  Path      := Path + ReplaceStr('update*config*', '*', PathDelim) ;
  FileName  := EmptyStr ;
  FindResult := FindFirst(Path + '*.scf', faAnyFile, SearchRec);
  Try
    While FindResult = 0 do
    begin
      if FileName < SearchRec.Name then
                                      FileName := SearchRec.Name ;
      FindResult := FindNext(SearchRec) ;
    end;

    SetVersionFromFile(Path + FileName);
  Finally
    System.SysUtils.FindClose(SearchRec);
  End;
end;

procedure TfrmSCFDialog.SaveControl;
begin
  FFile.Version           := edVer.Text ;
  FFile.RootPath          := edRootPath.Text ;
  FFile.AutoRunList       := edAutorun.Text  ;
  FFile.Platform.Name     := cbOSName.Items[cbOSName.ItemIndex] ;
  FFile.Platform.Bit      := TBits(cbOSBit.ItemIndex) ;
  FFile.Database.DBType   := ceDBType.Text  ;
  FFile.Database.Server   := ceServer.Text  ;
  FFile.Database.DataBase := ceDatabase.Text;
  FFile.HideTaskList      := cbHideTaskList.IsChecked ;
end;

procedure TfrmSCFDialog.SetVersionFromFile(AFileName: String);
Var
  fl: TSCFFile ;
begin
  if not FileExists(AFileName) then
                                  Exit ;
  fl  := TSCFFile.Create ;
  Try
    fl.LoadFromFile(AFileName) ;
    edVer.Text  := fl.Version ;
  Finally
    fl.Free ;
  End;
end;

procedure TfrmSCFDialog.SetXML(const Value: String);
begin
  FFile.XML := Value ;
  LoadControl ;
end;

initialization
  Log.Write('Инициализация модуля scfmngDialogUnit');
end.
