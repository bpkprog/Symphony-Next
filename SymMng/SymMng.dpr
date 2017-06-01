program SymMng;

{$DEFINE NOLOG}

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  SymMng.MainUnit in 'SymMng.MainUnit.pas' {frmSymMngMain},
  SymMng.Environment in 'SymMng.Environment.pas',
  SymMng.ConnectionMng in 'SymMng.ConnectionMng.pas',
  SymMng.SymphonyTask in 'SymMng.SymphonyTask.pas',
  SymMng.UIPackageManager in 'SymMng.UIPackageManager.pas',
  SymMng.ChildForm in 'SymMng.ChildForm.pas' {frmSMChildForm},
  SymMng.Consts in 'SymMng.Consts.pas',
  SymMng.Tuner in 'SymMng.Tuner.pas',
  SymMng.TunerFrame in 'SymMng.TunerFrame.pas' {frmSymMngTuner: TFrame},
  SymMng.TunerEditor in 'SymMng.TunerEditor.pas' {frmTunerEditor},
  SymMng.MainDataModule in 'SymMng.MainDataModule.pas' {dmMain: TDataModule},
  SymMng.PackageManager in 'SymMng.PackageManager.pas',
  SpecFoldersObj,
  Logger,
  SymMng.HelpForm in 'SymMng.HelpForm.pas' {frmHelp};

{$R *.res}

begin
  Log := TLog.Create(SpecFolders.AppDataPath + 'SymMng.log');
<<<<<<< HEAD
  Log.Active  := SymMngEnviroment.WriteLog ;
=======
  //Log.Active  := True ;
>>>>>>> 22bf27153e706c174662bb7267e5945a3ef03212
  Log.Write('«апуск программы');

  if SymMngEnviroment.ShowHelp then
  begin
    // показываем окно со справкой по командной строке
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.Title := 'Symphony.Next';
    Application.CreateForm(TfrmHelp, frmHelp);
    Application.Run;
  end
  // ѕроверка параметров командной строки. ≈сли все нормально, то запускаем приложение
  else if not SymMngEnviroment.ValidDBType then
    MessageDlg(Format('Ќеверные параметры командной строки%s"%s"', [#13, SymMngEnviroment.CommandLine]), mtError, [mbOK], 0)
  else
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.ShowMainForm  := not SymMngEnviroment.HideMainForm ;
    Application.Title := 'Symphony.Next';
    Application.CreateForm(TdmMain, dmMain);
    Application.CreateForm(TfrmSymMngMain, frmSymMngMain);
    //≈сли в событии OnCreate главной формы подсоединились к базе данных,
    //то запускаем приложение
    if frmSymMngMain.Connected then
                                    Application.Run;
  end;
end.
