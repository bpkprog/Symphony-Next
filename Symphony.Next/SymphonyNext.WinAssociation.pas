unit SymphonyNext.WinAssociation;

interface

procedure RegFileExt(Ext, ExtDesc, ContextBtnText: string);

implementation

uses System.SysUtils, System.Win.Registry,
     WinAPI.Windows, WinAPI.Messages, SymphonyNext.Consts, SymphonyNext.Logger;

procedure RegFileExt(Ext, ExtDesc, ContextBtnText: string);
var
  Reg: TRegistry;
Const
  CLPath = 'SOFTWARE\Classes\' ;
begin
  Log.EnterMethod('RegFileExt', ['Ext', 'ExtDesc', 'ContextBtnText'], [Ext, ExtDesc, ContextBtnText]);
  Try
    //���� ���������� ��� �������� �� ������ ������ Error
    if (Trim(Ext) = EmptyStr) or (Trim(ExtDesc) = EmptyStr) then
        Exit
    else
    begin
      Reg := TRegistry.Create(KEY_ALL_ACCESS);
      Try
        //����������� ������ ���� �����
        Reg.RootKey := HKEY_CURRENT_USER ; // HKEY_CLASSES_ROOT;

        //������������ ����������
        if not Reg.OpenKey(CLPath + Ext, True) then
          raise ERegistryException.CreateFmt('������ �������� ����� "%s"', [Ext]) ; //.ER

        Reg.WriteString('', ExtDesc); //HLREL
        Reg.CloseKey;

        //������������ ������ ��� ������ � ���� �����������
        Reg.OpenKey(CLPath + ExtDesc + '\DefaultIcon', True);
        Reg.WriteString('', ParamStr(0) + ',0');
        Reg.CloseKey;

        // �������� �� ������
        if not (Trim(ContextBtnText) = EmptyStr) then
        begin
          //������ � ����������� ����
          Reg.OpenKey(CLPath + ExtDesc + '\shell\Open', True);
          Reg.WriteString('', ContextBtnText);
          Reg.CloseKey;
        end;

        //����-������
        Reg.OpenKey(CLPath + ExtDesc + '\shell\Open\Command', True);
        Reg.WriteString('', ParamStr(0) + ' "%1"');
        Reg.CloseKey;

        Reg.OpenKey(CLPath + ExtDesc + '\shell\' + scfExtModifyDesc, True);
        Reg.WriteString('', scfExtModifyCaption);
        Reg.CloseKey;

        Reg.OpenKey(CLPath + ExtDesc + '\shell\' + scfExtModifyDesc + '\Command', True);
        Reg.WriteString('', ParamStr(0) + ' /config "%1"');
        Reg.CloseKey;

      Finally
        Reg.Free;
      End;

      //����� ����������� ���������� ��������� ������(������ ��� ��������� �� ��� ���� explorer'�?)=)
      PostMessage(HWND_BROADCAST, WM_SETTINGCHANGE, SPI_SETNONCLIENTMETRICS, 0);
    end;
  Except on E: Exception do
    Log.Write('����������: %s', [E.Message]);
  End;

  Log.ExitMethod('RegFileExt');
end;

end.
