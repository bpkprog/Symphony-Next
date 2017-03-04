unit SymphonyNext.SCFEngine;

interface

uses SymphonyNext.Environment, SymphonyNext.SCFFile;

Type
  TSCFEngine = class
  private
    FFile: TSCFFile ;
    procedure InitLog ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure Execute ;

    property SCFFile: TSCFFile read FFile ;
  end;

Var
  Engine: TSCFEngine ;

implementation

Uses System.SysUtils, System.UITypes, FMX.Dialogs, FMX.SpecFoldersObj,
     SymphonyNext.Logger;

{ TSCFEngine }
{$REGION 'TSCFEngine'}
constructor TSCFEngine.Create;
begin
  Log.EnterMethod('TSCFEngine.Create', [], []);
  FFile := TSCFFile.Create ;
  Log.ExitMethod('TSCFEngine.Create');
end;

destructor TSCFEngine.Destroy;
begin
  FFile.Free ;
  inherited;
end;

procedure TSCFEngine.Execute;
Var
  Msg: String ;
  Filenames: array [0..2] of String ;
  i: Integer;
  ConfigFileName: String ; // = 'Symphony.Next.scf' ;
begin
  // здесь будет происходить основной движняк

  ConfigFileName  := ChangeFileExt(ExtractFileName(ParamStr(0)), '.scf') ;

  Log.Write(Environment.ToString);
  // 1. проверяем, есть ли в параметрах файл настройки. Если нет, то:
  //    1.1 Ищем в персональном кталоге файл Symphony.Next.scf.
  //        Если не найден или не заполнен сервер, то
  //    1.2 Ищем рядом с программой файл Symphony.Next.scf.
  //        Если не найден или не заполнен сервер, то
  //    1.3 строим новый файл

  Filenames[0]  := Environment.FileName ;
  Filenames[1]  := SpecFolders.PersonalPath + ConfigFileName ;
  Filenames[2]  := SpecFolders.AppPath + ConfigFileName ;

  for i := Low(FileNames) to High(FileNames) do
  begin
    Log.Write('Попытка загрузить файл: %s', [FileNames[i]]);
    if FileExists(Filenames[i]) then
    begin
      FFile.LoadFromFile(Filenames[i]) ;
      Log.Write('Файл "%s Загружен"', [FileNames[i]]);
      if FFile.Database.Server <> EmptyStr then
      begin
        Log.Write('Файл "%s" содержит данные о сервере БД: "%s". Прекращаем поиск конфигурационного файла.',
                                          [FileNames[i], FFile.Database.Server]);
        Break ;
      end
      else
        Log.Write('Файл "%s" не содержит данные о сервере БД. Продолжаем поиск конфигурационного файла.', [FileNames[i]]);
    end
    else
      Log.Write('Файл "%s не найден"', [FileNames[i]]);
  end;

  if FFile.Database.Server = EmptyStr then
  begin
    Log.Write('Финальный файл не содержит данных по серверу БД. Начинаем собирать информацию о конфигурации');
    FFile.BuildSCFFile ;
  end;


  // 2. Обновляем файл конфигурации, если есть обновления
  Log.Write('Обновляем файл конфигурации, если есть обновления');
  FFile.Update ;

  if Environment.Config or (FFile.Database.Server = EmptyStr) then
  begin
    Log.Write('Начинаем редактирование файла');
    if not FFile.Edit then
    begin
      Log.Write('Завершаем работу по требованию пользователя');
      Exit ;
    end;
  end;

  if not FFile.ValidConfig then
  begin
    if FFile.FileName = EmptyStr then
      Msg := 'Не удалось автоматически определить параметры запуска системы. Обратитесь к администратору'
    else
      Msg := Format('Настроечный файл "%s" имеет неверные параметры. Обратитесь к администратору', [FFile.FileName]) ;

    Log.Write('Вылетаем с сообщением: ' + Msg);
    MessageDlg(Msg, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0) ;
    Exit ;
  end;

  if (Environment.FileName = EmptyStr) and
                (FFile.FileName  = SpecFolders.AppPath + ConfigFileName) then
                  FFile.FileName  := SpecFolders.PersonalPath + ConfigFileName ;


  if FFile.Modify then
                      FFile.SaveToFile ;

  if Environment.Update then FFile.BuildSCFUpdate
                        else FFile.RunSystem ;
end;

procedure TSCFEngine.InitLog;
begin
  Log.InitLog ;
end;

{$ENDREGION}

initialization
  Log.Write('Инициализация движка при инициализации модуля SymphonyNext.SCFEngine');
  Engine  := TSCFEngine.Create ;
  Log.Write('Инициализация движка при инициализации модуля SymphonyNext.SCFEngine закончено');
finalization
  Engine.Free ;
end.
