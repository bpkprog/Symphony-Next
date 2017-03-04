inherited SymphonyPlugInIBBaseFrame: TSymphonyPlugInIBBaseFrame
  Width = 217
  Height = 97
  ExplicitWidth = 217
  ExplicitHeight = 97
  object IBDatabase1: TIBDatabase
    Params.Strings = (
      'user_name=sysdba'
      'password=masterkey')
    LoginPrompt = False
    DefaultTransaction = IBTransactionRead
    ServerType = 'IBServer'
    Left = 40
    Top = 32
  end
  object IBTransactionRead: TIBTransaction
    DefaultDatabase = IBDatabase1
    Left = 132
    Top = 32
  end
end
