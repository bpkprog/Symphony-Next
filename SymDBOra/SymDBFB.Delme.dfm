object DataModule1: TDataModule1
  OldCreateOrder = False
  Height = 150
  Width = 215
  object IBDatabase1: TIBDatabase
    DatabaseName = '192.168.56.101:c:\DB\se.fdb'
    Params.Strings = (
      'user_name=sysdba'
      'password=masterkey')
    ServerType = 'IBServer'
    Left = 60
    Top = 36
  end
end
