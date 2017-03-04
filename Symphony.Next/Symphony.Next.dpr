program Symphony.Next;

uses
  ShareMem,
  System.SysUtils,
  System.StartUpCopy,
  FMX.Forms,
  SymphonyNext.Logger in 'SymphonyNext.Logger.pas',
  scfmngDialogUnit in 'scfmngDialogUnit.pas' {frmSCFDialog},
  SymphonyNext.Association in 'SymphonyNext.Association.pas',
  SymphonyNext.Consts in 'SymphonyNext.Consts.pas',
  SymphonyNext.Environment in 'SymphonyNext.Environment.pas',
  SymphonyNext.SCFEngine in 'SymphonyNext.SCFEngine.pas',
  SymphonyNext.SCFFile in 'SymphonyNext.SCFFile.pas';

{$R *.res}

begin
  // 1. ��������� ���������� ��������� ����������
  if Environment.Logged then
                            Log.InitLog ;
  Log.Write('������ �������������������. ��������� ���������� ������');
  Try
    SetSCFAssociation ;
  Except on E: Exception do
    begin
      Log.WriteException(E);
      raise ;
    end;
  End;
  Log.Write('���������� ���������. �������� �������� ������');
  Try
    Engine.Execute ;
  Except on E: Exception do
    begin
      Log.WriteException(E);
      raise ;
    end;
  End;
  Log.Write('����� �� ���������');
end.
