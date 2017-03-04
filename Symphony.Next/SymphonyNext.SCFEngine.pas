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
  // ����� ����� ����������� �������� �������

  ConfigFileName  := ChangeFileExt(ExtractFileName(ParamStr(0)), '.scf') ;

  Log.Write(Environment.ToString);
  // 1. ���������, ���� �� � ���������� ���� ���������. ���� ���, ��:
  //    1.1 ���� � ������������ ������� ���� Symphony.Next.scf.
  //        ���� �� ������ ��� �� �������� ������, ��
  //    1.2 ���� ����� � ���������� ���� Symphony.Next.scf.
  //        ���� �� ������ ��� �� �������� ������, ��
  //    1.3 ������ ����� ����

  Filenames[0]  := Environment.FileName ;
  Filenames[1]  := SpecFolders.PersonalPath + ConfigFileName ;
  Filenames[2]  := SpecFolders.AppPath + ConfigFileName ;

  for i := Low(FileNames) to High(FileNames) do
  begin
    Log.Write('������� ��������� ����: %s', [FileNames[i]]);
    if FileExists(Filenames[i]) then
    begin
      FFile.LoadFromFile(Filenames[i]) ;
      Log.Write('���� "%s ��������"', [FileNames[i]]);
      if FFile.Database.Server <> EmptyStr then
      begin
        Log.Write('���� "%s" �������� ������ � ������� ��: "%s". ���������� ����� ����������������� �����.',
                                          [FileNames[i], FFile.Database.Server]);
        Break ;
      end
      else
        Log.Write('���� "%s" �� �������� ������ � ������� ��. ���������� ����� ����������������� �����.', [FileNames[i]]);
    end
    else
      Log.Write('���� "%s �� ������"', [FileNames[i]]);
  end;

  if FFile.Database.Server = EmptyStr then
  begin
    Log.Write('��������� ���� �� �������� ������ �� ������� ��. �������� �������� ���������� � ������������');
    FFile.BuildSCFFile ;
  end;


  // 2. ��������� ���� ������������, ���� ���� ����������
  Log.Write('��������� ���� ������������, ���� ���� ����������');
  FFile.Update ;

  if Environment.Config or (FFile.Database.Server = EmptyStr) then
  begin
    Log.Write('�������� �������������� �����');
    if not FFile.Edit then
    begin
      Log.Write('��������� ������ �� ���������� ������������');
      Exit ;
    end;
  end;

  if not FFile.ValidConfig then
  begin
    if FFile.FileName = EmptyStr then
      Msg := '�� ������� ������������� ���������� ��������� ������� �������. ���������� � ��������������'
    else
      Msg := Format('����������� ���� "%s" ����� �������� ���������. ���������� � ��������������', [FFile.FileName]) ;

    Log.Write('�������� � ����������: ' + Msg);
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
  Log.Write('������������� ������ ��� ������������� ������ SymphonyNext.SCFEngine');
  Engine  := TSCFEngine.Create ;
  Log.Write('������������� ������ ��� ������������� ������ SymphonyNext.SCFEngine ���������');
finalization
  Engine.Free ;
end.
