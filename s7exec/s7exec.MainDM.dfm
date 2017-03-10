object dms7eMain: Tdms7eMain
  OldCreateOrder = False
  Height = 272
  Width = 418
  object ActionListBuilder1: TActionListBuilder
    Actions = <
      item
        AutoStart = True
        MethodName = 'ExecTask'
        Name = 'mtdExecTask'
        Params = <>
        Visible = False
        Params = <>
      end>
    Images = <>
    Left = 48
    Top = 24
    Actions = <
      item
        AutoStart = True
        MethodName = 'ExecTask'
        Name = 'mtdExecTask'
        Params = <>
        Visible = False
        Params = <>
      end>
    Images = <>
  end
  object oqPrm: TOraQuery
    SQL.Strings = (
      
        'select nvcvalue from svm.sconst where nvcconst = '#39'SYMPHONY_PATH_' +
        'OLD'#39)
    Left = 40
    Top = 168
    object oqPrmNVCVALUE: TStringField
      FieldName = 'NVCVALUE'
      Size = 4000
    end
  end
end
