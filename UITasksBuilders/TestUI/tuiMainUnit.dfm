object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 566
  ClientWidth = 998
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object dxBreadcrumbEdit1: TdxBreadcrumbEdit
    Left = 736
    Top = 28
    Width = 200
    Height = 24
    Properties.Buttons = <>
    Properties.PathEditor.RecentPaths = <>
    SelectedPath = 'Root\New Item (2)\New Item\New Item'
    TabOrder = 0
    NodeData = {
      01000000445855464D54040052006F006F007400000000000000030000004458
      55464D5408004E006500770020004900740065006D0000000000000001000000
      445855464D5408004E006500770020004900740065006D000000000000000100
      0000445855464D5408004E006500770020004900740065006D00000000000000
      00000000445855464D540C004E006500770020004900740065006D0020002800
      3100290000000000000000000000445855464D540C004E006500770020004900
      740065006D00200028003200290000000000000001000000445855464D540800
      4E006500770020004900740065006D0000000000000001000000445855464D54
      08004E006500770020004900740065006D0000000000000000000000}
  end
  object CategoryButtons1: TCategoryButtons
    Left = 729
    Top = 172
    Width = 261
    Height = 221
    BevelKind = bkSoft
    BevelWidth = 6
    ButtonFlow = cbfVertical
    ButtonWidth = 200
    ButtonOptions = [boAllowReorder, boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boCaptionOnlyBorder]
    Categories = <
      item
        Caption = #1056#1072#1079
        Color = 15395839
        Collapsed = False
        Items = <
          item
            Caption = #1054#1076#1080#1085
          end
          item
            Caption = #1044#1074#1072
          end
          item
            Caption = #1058#1088#1080
          end>
      end
      item
        Caption = #1044#1074#1072
        Color = 16771839
        Collapsed = False
        Items = <
          item
            Caption = #1044#1077#1089#1103#1090#1100
          end
          item
            Caption = #1044#1074#1072#1076#1094#1072#1090#1100
          end
          item
            Caption = #1058#1088#1080#1076#1094#1072#1090#1100
          end>
      end
      item
        Caption = #1058#1088#1080
        Color = 16771818
        Collapsed = False
        Items = <
          item
            Caption = #1057#1090#1086
          end
          item
            Caption = #1044#1074#1077#1089#1090#1080
          end
          item
            Caption = #1058#1088#1080#1089#1090#1072
          end>
      end>
    RegularButtonColor = clWhite
    SelectedButtonColor = 15132390
    TabOrder = 1
  end
  object ButtonGroup1: TButtonGroup
    Left = 728
    Top = 80
    Width = 257
    Height = 81
    ButtonOptions = [gboAllowReorder, gboFullSize, gboGroupStyle, gboShowCaptions]
    Items = <
      item
        Caption = #1056#1072#1079
      end
      item
        Caption = #1044#1074#1072
      end
      item
        Caption = #1058#1088#1080
      end>
    TabOrder = 2
  end
  object dxRibbon1: TdxRibbon
    Left = 0
    Top = 0
    Width = 998
    Height = 25
    ColorSchemeName = 'Blue'
    Contexts = <
      item
        Caption = #1056#1072#1079
      end
      item
        Caption = #1044#1074#1072
        Visible = True
      end>
    TabOrder = 3
    TabStop = False
    object dxRibbon1Tab1: TdxRibbonTab
      Caption = 'dxRibbon1Tab1'
      Groups = <>
      Index = 0
      ContextIndex = 0
    end
    object dxRibbon1Tab2: TdxRibbonTab
      Active = True
      Caption = 'dxRibbon1Tab2'
      Groups = <>
      Index = 1
      ContextIndex = 1
    end
    object dxRibbon1Tab3: TdxRibbonTab
      Caption = 'dxRibbon1Tab3'
      Groups = <>
      Index = 2
      ContextIndex = 0
    end
  end
  object ButtonGroup2: TButtonGroup
    Left = 728
    Top = 399
    Width = 257
    Height = 114
    ButtonHeight = 36
    ButtonOptions = [gboFullSize, gboShowCaptions]
    Images = cxImageList1
    Items = <
      item
        Caption = #1056#1072#1079
        ImageIndex = 0
      end
      item
        Caption = #1044#1074#1072
        ImageIndex = 1
      end
      item
        Caption = #1058#1088#1080
        ImageIndex = 2
      end>
    TabOrder = 8
  end
  object cxPageControl1: TcxPageControl
    Left = 136
    Top = 220
    Width = 393
    Height = 237
    TabOrder = 9
    Properties.ActivePage = cxTabSheet3
    Properties.CustomButtons.Buttons = <>
    Properties.Rotate = True
    Properties.Style = 1
    Properties.TabHeight = 32
    Properties.TabPosition = tpLeft
    ClientRectBottom = 233
    ClientRectLeft = 89
    ClientRectRight = 389
    ClientRectTop = 4
    object cxTabSheet3: TcxTabSheet
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' '#1088#1072#1079
      ImageIndex = 2
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 285
      ExplicitHeight = 161
    end
    object cxTabSheet2: TcxTabSheet
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' '#1076#1074#1072
      ImageIndex = 1
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 281
      ExplicitHeight = 165
    end
    object cxTabSheet1: TcxTabSheet
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' '#1090#1088#1080
      ImageIndex = 0
      ExplicitLeft = 0
      ExplicitTop = 25
      ExplicitWidth = 281
      ExplicitHeight = 165
    end
  end
  object dxBarManager1: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 684
    Top = 84
    DockControlHeights = (
      0
      0
      46
      0)
    object dxBarManager1Bar1: TdxBar
      Caption = 'Custom 1'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 1032
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarStatic1'
        end
        item
          Visible = True
          ItemName = 'dxBarCombo1'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarButton1: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarStatic1: TdxBarStatic
      Caption = #1053#1072#1081#1090#1080' '#1080' '#1074#1099#1087#1086#1083#1085#1080#1090#1100':'
      Category = 0
      Hint = #1053#1072#1081#1090#1080' '#1080' '#1074#1099#1087#1086#1083#1085#1080#1090#1100':'
      Visible = ivAlways
    end
    object dxBarCombo1: TdxBarCombo
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      OnKeyPress = dxBarCombo1KeyPress
      Items.Strings = (
        #1055#1088#1080#1093#1086#1076
        #1056#1072#1089#1093#1086#1076
        #1040#1082#1090#1099' '#1074#1099#1073#1099#1090#1080#1103
        #1040#1082#1090#1099' '#1089#1074#1077#1088#1082#1080
        #1040#1082#1090#1099' '#1074#1099#1087#1086#1083#1085#1077#1085#1085#1099#1093' '#1091#1089#1083#1091#1075
        #1040#1082#1090#1099' '#1080#1085#1074#1077#1085#1090#1072#1088#1080#1079#1072#1094#1080#1080
        #1042#1085#1091#1090#1088#1077#1085#1085#1080#1077' '#1087#1077#1088#1077#1084#1077#1097#1077#1085#1080#1103)
      ItemIndex = -1
    end
    object dxBarLookupCombo1: TdxBarLookupCombo
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
        DDDD000000000000000D0FFFF0FFFFFFFF0D0F77F0F777777F0D0CCCC0CCCCCC
        CC0D0C77C0C777777C0D0CCCC0CCCCCCCC0D0F77F0F777777F0D0FFFF0FFFFFF
        FF0D0F77F0F777777F0D0FFFF0FFFFFFFF0D000000000000000D0FFFCCCCFFF0
        DDDD0F777777FFF0DDDD0FFFCCCCFFF0DDDD000000000000DDDD}
      RowCount = 7
    end
  end
  object cxImageList1: TcxImageList
    Height = 32
    Width = 32
    FormatVersion = 1
    DesignInfo = 8126936
    ImageInfo = <
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000010000000200000004000000050000000600000007000000070000
          0006000000050000000400000002000000010000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000010000
          0003000000060000000B0000001000000015000000180000001A0000001A0000
          001800000016000000110000000C000000070000000400000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000100000003000000070000
          000E000000171E11094D4C2B1795744223D17A4425D996542DFF96542DFF7A44
          25D9744223D14C2A17961E11094F000000190000001000000008000000040000
          0001000000010000000000000000000000000000000000000000000000000000
          000000000000000000000000000100000001000000040000000B00000015321C
          0F6B824928E19F6137FFB47B4BFFC4915CFFC99560FFD3A36BFFD3A46BFFC895
          60FFC5905CFFB47B4CFFA06238FF814929E2321C0F6D000000180000000D0000
          0005000000010000000100000000000000000000000000000000000000000000
          0000000000000000000100000001000000050000000D120A0636754325CFA76A
          3EFFC7935EFFD5A56CFFD4A46DFFD4A56CFFD4A56CFFD4A56CFFD4A56CFFD5A5
          6CFFD4A56CFFD5A56DFFD4A66DFFC7945FFFA76A3FFF764426D1120A063A0000
          0010000000060000000100000001000000000000000000000000000000000000
          00000000000000000001000000050000000E26160C5590552FF0BE8956FFD6A6
          6EFFD5A56DFFD5A56DFFD5A66DFFD6A76EFFD5A76EFFD5A76EFFD5A76FFFD6A7
          6FFFD6A76EFFD5A76EFFD5A66EFFD5A66DFFD6A66FFFBE8957FF91542FF12616
          0C5A000000120000000600000001000000000000000000000000000000000000
          000000000000000000040000000C26160C539B5F38FAC79560FFD5A76EFFD6A6
          6EFFD5A76FFFD6A770FFD6A870FFD6A871FFD6A871FFD6A871FFD7A871FFD7A9
          71FFD6A870FFD6A870FFD6A871FFD6A86FFFD6A76FFFD5A86FFFC79562FF9A5F
          38FA26160D590000001000000005000000010000000000000000000000000000
          00000000000200000009160D0738925934EECA9A64FFD6A870FFD6A76FFFD6A8
          70FFD7A972FFD7A972FFD7AA73FFDAB17BFFE0BC8DFFE1BE91FFE1BF91FFE0BD
          8EFFDAB07BFFD8AB73FFD7AA73FFD7A972FFD7A971FFD7A870FFD6A970FFCA9A
          65FF925934EF160D073E0000000C000000030000000100000000000000000000
          00010000000500000010774829CBC08C5CFFD8A972FFD6A872FFD8A972FFD8AA
          74FFD8AB74FFD8AB75FFD8AC75FFCEA478FFA46E45FF9E653DFF9E653DFFA46E
          45FFD0A97EFFDAAE79FFD8AC76FFD8AC75FFD8AA74FFD8AB73FFD7AA72FFD7AA
          73FFC08D5DFF7A492AD000000016000000070000000100000000000000000000
          00020000000A34201365AB734AFFD8AD76FFD7AA73FFD8AB74FFD8AB75FFD9AC
          76FFDAAD77FFDAAD78FFDAAF79FFA46D44FFD9C3B4FFF8F2EDFFF9F3EFFFE1CF
          C1FFA67047FFDDB683FFDAAF78FFDAAD78FFDAAD77FFD9AC76FFD8AB75FFD8AA
          74FFD9AD78FFAC744BFF341F126B0000000E0000000300000001000000010000
          00040000000F875332DDCC9B6AFFD8AB76FFD8AB75FFD9AC77FFD9AF78FFDAB0
          79FFDAB07AFFDBB17BFFDBB17CFF9C633AFFECDFD8FFF1E6DDFFF2E6DDFFF9F4
          F0FF9E673EFFE0BA88FFDCB27CFFDBB17BFFDAB07AFFDAB079FFDAAF78FFD9AD
          77FFD9AC77FFCC9C6BFF885432DF000000160000000700000001000000020000
          000727190F4EAF7852FFDAB17BFFD8AC76FFDAAD78FFDBB079FFDBB17BFFDBB2
          7CFFDCB27FFFDCB37FFFDCB480FF9C633AFFEADDD4FFF2E7E0FFF2E8DFFFF8F3
          EEFF9F6840FFE1BC8CFFDEB480FFDCB380FFDCB37EFFDCB27CFFDBB17BFFDAB0
          79FFD9AD77FFDBB17DFFAF7952FF2A1A10570000000B00000002000000020000
          000956362192C5976EFFDBAF7BFFDAB079FFDBB07BFFDBB27CFFDEB886FFE5C4
          98FFE6C69CFFE7C79CFFE7C79CFF9C633AFFEBDED6FFF3EAE2FFF3E9E2FFF9F4
          F0FFA06A42FFE9CEA5FFE7C89DFFE6C79CFFE5C599FFE0B988FFDCB37FFFDCB1
          7EFFDBB17AFFDBB27EFFC5986FFF563722980000000E00000003000000020000
          000B7B4F32C6D1A77AFFDBB17CFFDBB27BFFDCB27FFFDEB480FFD0AA7EFFA46E
          44FF9E673EFFA06A42FFA26D45FFA57049FFF4ECE5FFF5ECE5FFF5ECE5FFF9F5
          F1FFA26C44FFA26E46FFA36F48FFA47049FFAC7B54FFD6B28BFFDFB785FFDCB4
          80FFDCB27FFFDCB37EFFD2A97BFF7C5032CA0000001100000004000000030000
          000C99633EECD8B281FFDBB27DFFDCB37FFFDEB482FFDFB683FFA46E45FFD4BC
          AEFFF9F5F1FFF9F5F2FFFAF6F3FFFAF6F3FFF6EEE8FFF6EEE8FFF5EEE8FFF5ED
          E7FFFAF6F2FFFAF5F2FFF9F5F1FFFAF5F2FFE1CFC3FFA57047FFE3BE8EFFDFB6
          83FFDEB481FFDCB580FFDAB483FF99643FED0000001300000005000000030000
          000CA46D46FADEBA8AFFDEB480FFDEB581FFDFB784FFE0B887FF9C633AFFE6D9
          D3FFF5EDE7FFF5EEE8FFF7EFE9FFF7EFEBFFF7F1EBFFF7F1EBFFF6F1ECFFF7F0
          EBFFF6EFE9FFF6EEE8FFF5EDE7FFF5EBE5FFFAF6F3FF9E653DFFE4C192FFE0B8
          86FFDFB784FFDEB582FFDFBD8CFFA56E47FA0000001300000005000000030000
          000BA67049FAE4C297FFDEB582FFE0B785FFE0B987FFE3C08FFF9C633AFFDFCF
          C7FFF2EAE4FFF6F0EBFFF7F1EDFFF8F2EEFFF9F3EEFFF9F3EEFFF8F2EEFFF8F2
          EDFFF7F1EDFFF7F0EBFFF6EFE9FFF5EDE7FFF5EFEBFF9E653DFFE6C698FFE2BB
          89FFE0B987FFDFB784FFE4C398FFA7714AFA0000001200000005000000020000
          000A9E6B45ECE3C69DFFDFB986FFE2BD8CFFE6CB9EFFE8D1A6FFA36E45FFBE9E
          8CFFCCB6AEFFCFBAB1FFD1BDB5FFD4C1BAFFEDE3DEFFF9F5F2FFFAF5F1FFF9F4
          F0FFE5D7D1FFDDCDC5FFDDCCC4FFDDCEC6FFCFB5A7FFA57047FFE9D0A5FFE6C6
          97FFE2BD8BFFE0BA8AFFE4C69FFF9E6D47ED0000001100000004000000020000
          0008835A3BC5DEC19FFFE6C79AFFE9D1A5FFE9D2A8FFEAD5AAFFD7B990FFAD7C
          53FF9C633AFF9C633AFF9C633AFF9C633AFFECE4E0FFFAF8F4FFFAF7F4FFFCFB
          F9FF9C633AFF9C633AFF9C633AFF9C633AFFAD7B52FFD8B78EFFEACFA3FFE8CC
          9EFFE6C89BFFE4C394FFDFC2A1FF835A3CC80000000E00000003000000010000
          00065D422C8FD8BB9DFFEBD7AFFFEAD3AAFFEBD6ACFFEBD7AEFFECD9AFFFEDDA
          B0FFEDDAB2FFEEDBB4FFEEDCB4FF9C633AFFECE4E1FFFBFAF8FFFCF9F7FFFDFB
          FAFFA7754EFFF0DDB7FFEDD8B0FFEDD7AEFFECD5ABFFEBD2A7FFEAD1A5FFE9CE
          A2FFE8CC9FFFE9CCA2FFD7B898FF5D422D940000000B00000003000000010000
          00042D221848C6A07DFFF2E3C5FFEBD6AEFFECD9AFFFECDAB2FFEDDBB3FFEEDC
          B4FFEFDDB6FFEFDDB7FFF0DFB8FF9C633AFFECE5E1FFFCFCFAFFFCFBF9FFFDFC
          FBFFA57049FFF1DFBBFFEFDBB4FFEED9B1FFEDD7AFFFECD6ABFFEBD3A9FFEAD1
          A5FFE9CEA3FFF0DDBBFFC49B77FF2D20174E0000000700000002000000000000
          000200000007A07A5ADAE9D9BFFFEDDCB5FFEDDCB4FFEDDDB5FFEEDEB8FFEFDF
          B9FFF0E0BAFFF0E1BBFFF1E2BBFF9C633AFFE5D9D5FFF9F6F6FFFDFCFBFFF5F2
          F0FFA26C45FFF2E2BEFFF1DEB7FFEFDCB5FFEEDBB3FFEDD8B0FFECD5ADFFEBD4
          A9FFEBD3A9FFE8D4BAFF9C7453DC0000000E0000000400000001000000000000
          0001000000043E31245BCBA885FFF5ECD1FFEEDDB7FFEEDFB8FFEFE0BBFFF0E2
          BCFFF1E3BDFFF1E4BFFFF2E4BFFFA46F47FFC0A392FFCFBAB4FFCFBBB5FFC3A6
          97FFA7744DFFF3E5C1FFF2E1BBFFF1DFB8FFEFDCB6FFEFDBB3FFEDD9B0FFECD6
          ACFFF4E6CAFFC9A27EFF3E2E2161000000080000000200000000000000000000
          00000000000200000006947457C6E4D1B6FFF2E7C9FFEFE2BCFFF1E3BEFFF1E4
          BFFFF2E5C1FFF2E6C2FFF3E6C3FFDEC6A1FFAF7F57FF9C633AFF9C633AFFAF7F
          58FFDEC7A2FFF3E5C1FFF2E3BDFFF2E1BBFFF0DFB8FFEFDDB6FFEEDAB3FFF2E2
          C2FFE3CDB1FF926F51C80000000C000000040000000100000000000000000000
          0000000000010000000319140F28B6936FECEFE3CCFFF5EACDFFF1E5C1FFF2E7
          C2FFF2E8C3FFF3E8C4FFF3E9C5FFF4E9C5FFF4EAC7FFF4EAC7FFF4E9C6FFF5E9
          C6FFF4E8C5FFF3E6C2FFF3E6C1FFF3E4BEFFF1E1BCFFF0DFB9FFF4E5C6FFEFE1
          CAFFB28D6AED19130E2D00000006000000020000000000000000000000000000
          000000000000000000010000000431271E46C6A27EF9EFE3CBFFF8F1D8FFF3E8
          C4FFF3E9C5FFF4EAC7FFF4EAC8FFF4EBC8FFF5EBC9FFF5ECC9FFF5EBC9FFF5EB
          C8FFF4EAC7FFF4E8C5FFF3E7C4FFF3E5C0FFF2E3BEFFF7EDD3FFEEE0C8FFC39D
          78FA30251B4A0000000700000002000000000000000000000000000000000000
          00000000000000000000000000010000000432281F45BB9876EEE6D5BAFFFBF7
          E3FFF7F0D3FFF4EBC8FFF5ECCBFFF5EDCBFFF6EDCBFFF5EDCCFFF5EDCBFFF5EC
          CBFFF5EBC9FFF5EAC7FFF4E8C5FFF6EDCFFFFBF5E1FFE6D2B7FFB99471EE3127
          1D4A000000070000000200000001000000000000000000000000000000000000
          0000000000000000000000000000000000010000000318130F239E8163C8D8BA
          98FFF1E5CFFFFCF9E7FFFBF6E0FFF8F2D8FFF8F3D6FFF6EFCDFFF6EFCDFFF8F2
          D6FFF8F1D6FFFBF5DEFFFCF8E6FFF1E5CEFFD7B896FF9C7E5FCA17130E280000
          0006000000020000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000100000002000000054136
          2956AE916EDAD4B591FFE5D1B4FFF1E6CFFFF4EAD5FFFCF9E8FFFDF9E8FFF5EA
          D5FFF1E5CEFFE4CFB1FFD3B38EFFAD8E6CDA4336295B00000007000000040000
          0002000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000010000
          000300000004251E1832665642829F8465C5A78C6BCECFAC85FCCFAC85FCA68A
          6ACF9F8366C666544184251E1734000000060000000400000002000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000010000000200000003000000040000000500000005000000050000
          0005000000040000000400000003000000020000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000001000000010000000100000001000000010000
          0001000000010000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000010000000200000004000000050000000600000007000000070000
          0006000000050000000400000002000000010000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000010000
          0003000000060000000B0000001000000015000000180000001A0000001A0000
          001800000016000000110000000C000000070000000400000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000100000003000000070000
          000E000000171E11094D4C2B1795744223D17A4425D996542DFF96542DFF7A44
          25D9744223D14C2A17961E11094F000000190000001000000008000000040000
          0001000000010000000000000000000000000000000000000000000000000000
          000000000000000000000000000100000001000000040000000B00000015321C
          0F6B824928E19F6137FFB47B4BFFC4915CFFC99560FFD3A36BFFD3A46BFFC895
          60FFC5905CFFB47B4CFFA06238FF814929E2321C0F6D000000180000000D0000
          0005000000010000000100000000000000000000000000000000000000000000
          0000000000000000000100000001000000050000000D120A0636754325CFA76A
          3EFFC7935EFFD5A56CFFD4A46DFFD4A56CFFD4A56CFFD4A56CFFD4A56CFFD5A5
          6CFFD4A56CFFD5A56DFFD4A66DFFC7945FFFA76A3FFF764426D1120A063A0000
          0010000000060000000100000001000000000000000000000000000000000000
          00000000000000000001000000050000000E26160C5590552FF0BE8956FFD6A6
          6EFFD5A56DFFD5A56DFFD5A66DFFD6A76EFFD5A76EFFD5A76EFFD5A76FFFD6A7
          6FFFD6A76EFFD5A76EFFD5A66EFFD5A66DFFD6A66FFFBE8957FF91542FF12616
          0C5A000000120000000600000001000000000000000000000000000000000000
          000000000000000000040000000C26160C539B5F38FAC79560FFD5A76EFFD6A6
          6EFFD5A76FFFD6A770FFD6A870FFD6A871FFD6A871FFD6A871FFD7A871FFD7A9
          71FFD6A870FFD6A870FFD6A871FFD6A86FFFD6A76FFFD5A86FFFC79562FF9A5F
          38FA26160D590000001000000005000000010000000000000000000000000000
          00000000000200000009160D0738925934EECA9A64FFD6A870FFD6A76FFFD6A8
          70FFD7A972FFD7A972FFD7AA73FFD7AB73FFD8AA73FFD8AA74FFD7AB74FFD8AB
          74FFD7AA73FFD8AB73FFD7AA73FFD7A972FFD7A971FFD7A870FFD6A970FFCA9A
          65FF925934EF160D073E0000000C000000030000000100000000000000000000
          00010000000500000010774829CBC08C5CFFD8A972FFD6A872FFD8A972FFD8AA
          74FFD8AB74FFD8AB75FFD8AC75FFD9AD76FFD9AD76FFD9AD77FFD9AD77FFD9AC
          77FFD9AC76FFD9AC76FFD8AC76FFD8AC75FFD8AA74FFD8AB73FFD7AA72FFD7AA
          73FFC08D5DFF7A492AD000000016000000070000000100000000000000000000
          00020000000A34201365AB734AFFD8AD76FFD7AA73FFD8AB74FFD8AB75FFD9AC
          76FFDAAD77FFDAAD78FFDAAF79FFDAB079FFDAB079FFDAB07AFFDAB07AFFDAB0
          7AFFDAB07AFFDAAF79FFDAAF78FFDAAD78FFDAAD77FFD9AC76FFD8AB75FFD8AA
          74FFD9AD78FFAC744BFF341F126B0000000E0000000300000001000000010000
          00040000000F875332DDCC9B6AFFD8AB76FFD8AB75FFD9AC77FFD9AF78FFDAB0
          79FFDAB07AFFDBB17BFFDBB17CFFDCB27EFFDCB37EFFDCB37EFFDCB37FFFDCB3
          7FFFDBB27EFFDCB27CFFDCB27CFFDBB17BFFDAB07AFFDAB079FFDAAF78FFD9AD
          77FFD9AC77FFCC9C6BFF885432DF000000160000000700000001000000020000
          000727190F4EAF7852FFDAB17BFFD8AC76FFDAAD78FFDBB079FFDBB17BFFDBB2
          7CFFDCB27FFFDCB37FFFDCB480FFDEB481FFDEB581FFDEB582FFDEB582FFDEB5
          82FFDEB581FFDEB481FFDEB480FFDCB380FFDCB37EFFDCB27CFFDBB17BFFDAB0
          79FFD9AD77FFDBB17DFFAF7952FF2A1A10570000000B00000002000000020000
          000956362192C5976EFFDBAF7BFFDAB079FFDBB07BFFDBB27CFFDEB886FFE5C4
          98FFE6C69CFFE7C79CFFE7C79CFFE7C89EFFE7C99EFFE7C99FFFE7C99EFFE7C9
          9EFFE7C89EFFE7C99DFFE7C89DFFE6C79CFFE5C599FFE0B988FFDCB37FFFDCB1
          7EFFDBB17AFFDBB27EFFC5986FFF563722980000000E00000003000000020000
          000B7B4F32C6D1A77AFFDBB17CFFDBB27BFFDCB27FFFDEB480FFD0AA7EFFA36D
          44FF9C633AFF9C633AFF9C633AFF9C633AFF9C633AFF9C633AFF9C633AFF9C63
          3AFF9C633AFF9C633AFF9C633AFF9C633AFFA36D44FFD3AE85FFDFB785FFDCB4
          80FFDCB27FFFDCB37EFFD2A97BFF7C5032CA0000001100000004000000030000
          000C99633EECD8B281FFDBB27DFFDCB37FFFDEB482FFDFB683FFA46E45FFD4BC
          AEFFF9F5F1FFF9F5F2FFFAF6F3FFFAF6F3FFFAF6F3FFFAF6F3FFFAF6F3FFFAF6
          F3FFFAF6F2FFFAF5F2FFF9F5F1FFFAF5F2FFE1CFC2FFA46E46FFE3BE8EFFDFB6
          83FFDEB481FFDCB580FFDAB483FF99643FED0000001300000005000000030000
          000CA46D46FADEBA8AFFDEB480FFDEB581FFDFB784FFE0B887FF9C633AFFE6D9
          D3FFF5EDE7FFF5EEE8FFF7EFE9FFF7EFEBFFF7F1EBFFF7F1EBFFF6F1ECFFF7F0
          EBFFF6EFE9FFF6EEE8FFF5EDE7FFF5EBE5FFFAF6F3FF9C633AFFE4C192FFE0B8
          86FFDFB784FFDEB582FFDFBD8CFFA56E47FA0000001300000005000000030000
          000BA67049FAE4C297FFDEB582FFE0B785FFE0B987FFE3C08FFF9C633AFFDFCF
          C7FFF2EAE4FFF6F0EBFFF7F1EDFFF8F2EEFFF9F3EEFFF9F3EEFFF8F2EEFFF8F2
          EDFFF7F1EDFFF7F0EBFFF6EFE9FFF5EDE7FFF5EFEBFF9C633AFFE6C698FFE2BB
          89FFE0B987FFDFB784FFE4C398FFA7714AFA0000001200000005000000020000
          000A9E6B45ECE3C69DFFDFB986FFE2BD8CFFE6CB9EFFE8D1A6FFA36E45FFBE9E
          8CFFCCB6AEFFCFBAB1FFD1BDB5FFD4C1BAFFD6C4BDFFD8C7C1FFDAC9C2FFDCCB
          C4FFDCCBC5FFDDCDC5FFDDCCC4FFDDCEC6FFCEB4A5FFA36E45FFE9D0A5FFE6C6
          97FFE2BD8BFFE0BA8AFFE4C69FFF9E6D47ED0000001100000004000000020000
          0008835A3BC5DEC19FFFE6C79AFFE9D1A5FFE9D2A8FFEAD5AAFFD7B990FFAD7C
          53FF9C633AFF9C633AFF9C633AFF9C633AFF9C633AFF9C633AFF9C633AFF9C63
          3AFF9C633AFF9C633AFF9C633AFF9C633AFFAD7B52FFD8B78EFFEACFA3FFE8CC
          9EFFE6C89BFFE4C394FFDFC1A1FF835A3CC80000000E00000003000000010000
          00065D422C8FD8BB9CFFEBD7AFFFEAD3AAFFEBD6ACFFEBD7AEFFECD9AFFFEDDA
          B0FFEDDAB2FFEEDBB4FFEEDCB4FFEEDBB4FFEEDCB5FFEFDCB5FFEFDCB5FFEFDB
          B4FFEFDBB2FFEED9B1FFEDD8B0FFEDD7AEFFECD5ABFFEBD2A7FFEAD1A5FFE9CE
          A2FFE8CC9FFFE9CCA2FFD7B798FF5D422D940000000B00000003000000010000
          00042D221848C6A07CFFF1E3C3FFEBD6AEFFECD9AFFFECDAB2FFEDDBB3FFEEDC
          B4FFEFDDB6FFEFDDB7FFF0DFB8FFF0DFB9FFF0E0B9FFF0DFB8FFF0DFB8FFF0DF
          B8FFF0DEB7FFEFDCB5FFEFDBB4FFEED9B1FFEDD7AFFFECD6ABFFEBD3A9FFEAD1
          A5FFE9CEA3FFEFDDBBFFC49B76FF2D20174E0000000700000002000000000000
          000200000007A07A5ADAE9D9BDFFEDDCB5FFEDDCB4FFEDDDB5FFEEDEB8FFEFDF
          B9FFF0E0BAFFF0E1BBFFF1E2BBFFF1E2BDFFF1E3BDFFF2E2BDFFF1E3BCFFF1E2
          BBFFF2E0BAFFF1DFB9FFF1DEB7FFEFDCB5FFEEDBB3FFEDD8B0FFECD5ADFFEBD4
          A9FFEBD3A9FFE8D4B8FF9C7453DC0000000E0000000400000001000000000000
          0001000000043E31245BCBA885FFF5ECCFFFEEDDB7FFEEDFB8FFEFE0BBFFF0E2
          BCFFF1E3BDFFF1E4BFFFF2E4BFFFF2E5C0FFF2E5C0FFF2E5C0FFF2E4BFFFF3E4
          BFFFF2E3BEFFF2E2BCFFF2E1BBFFF1DFB8FFEFDCB6FFEFDBB3FFEDD9B0FFECD6
          ACFFF4E7C9FFC9A27EFF3E2E2161000000080000000200000000000000000000
          00000000000200000006947457C6E4D1B4FFF2E7C8FFEFE2BCFFF1E3BEFFF1E4
          BFFFF2E5C1FFF2E6C2FFF3E6C3FFF3E7C3FFF4E7C3FFF3E8C3FFF3E7C2FFF3E6
          C2FFF3E6C1FFF3E4C0FFF2E3BDFFF2E1BBFFF0DFB8FFEFDDB6FFEEDAB3FFF1E2
          C1FFE2CDB0FF926F51C80000000C000000040000000100000000000000000000
          0000000000010000000319140F28B6936FECEFE3CAFFF4EACBFFF1E5C1FFF2E7
          C2FFF2E8C3FFF3E8C4FFF3E9C5FFF4E9C5FFF4EAC7FFF4EAC7FFF4E9C6FFF5E9
          C6FFF4E8C5FFF3E6C2FFF3E6C1FFF3E4BEFFF1E1BCFFF0DFB9FFF4E5C4FFEEE0
          C7FFB28D6AED19130E2D00000006000000020000000000000000000000000000
          000000000000000000010000000431271E46C6A27DF9EEE2C8FFF7F1D5FFF3E8
          C4FFF3E9C5FFF4EAC7FFF4EAC8FFF4EBC8FFF5EBC9FFF5ECC9FFF5EBC9FFF5EB
          C8FFF4EAC7FFF4E8C5FFF3E7C4FFF3E5C0FFF2E3BEFFF6EDD1FFEEE0C6FFC39D
          78FA30251B4A0000000700000002000000000000000000000000000000000000
          00000000000000000000000000010000000432281F45BB9875EEE6D5B8FFFAF7
          E0FFF7F0D2FFF4EBC8FFF5ECCBFFF5EDCBFFF6EDCBFFF5EDCCFFF5EDCBFFF5EC
          CBFFF5EBC9FFF5EAC7FFF4E8C5FFF7EDCEFFFAF5DEFFE6D2B6FFB99471EE3127
          1D4A000000070000000200000001000000000000000000000000000000000000
          0000000000000000000000000000000000010000000318130F239E8163C8D7BA
          98FFF0E5CCFFFCF9E4FFF9F6DDFFF8F2D6FFF7F2D5FFF6EFCDFFF6EFCDFFF7F2
          D4FFF8F1D5FFF9F4DDFFFCF8E2FFF0E5CDFFD6B895FF9C7E5FCA17130E280000
          0006000000020000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000100000002000000054136
          2956AE916EDAD4B591FFE5D1B2FFF1E6CDFFF4EAD2FFFCF9E6FFFCF9E6FFF4EA
          D3FFF1E5CCFFE4CFB1FFD3B38EFFAD8E6CDA4336295B00000007000000040000
          0002000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000010000
          000300000004251E1832665642829F8465C5A78C6BCECFAC85FCCFAC85FCA68A
          6ACF9F8366C666544184251E1734000000060000000400000002000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000010000000200000003000000040000000500000005000000050000
          0005000000040000000400000003000000020000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000001000000010000000100000001000000010000
          0001000000010000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000010000000200000004000000050000000600000007000000070000
          0006000000050000000400000002000000010000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000010000
          0003000000060000000B0000001000000015000000180000001A0000001A0000
          001800000016000000110000000C000000070000000400000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000100000003000000070000
          000E0000001707140E4D133324951D4E38D11D513BD9246448FF246448FF1E51
          3BD91C4E38D11233249607140F4F000000190000001000000008000000040000
          0001000000010000000000000000000000000000000000000000000000000000
          000000000000000000000000000100000001000000040000000B000000150C21
          176B1F563FE1257151FF278963FF299D72FF2AA176FF2BB07FFF2BAF80FF2AA2
          76FF2A9E72FF278964FF267151FF20573FE20C21186D000000180000000D0000
          0005000000010000000100000000000000000000000000000000000000000000
          0000000000000000000100000001000000050000000D040C09361C503ACF2678
          56FF2AA074FF2CB180FF2BB180FF2CB081FF2CB081FF2CB180FF2CB181FF2CB1
          80FF2CB080FF2CB081FF2CB180FF2AA074FF277957FF1D5039D1040C093A0000
          0010000000060000000100000001000000000000000000000000000000000000
          00000000000000000001000000050000000E09191255236248F029946BFF2CB1
          81FF2CB181FF2CB181FF2CB282FF2CB282FF2CB282FF2CB282FF2DB282FF2DB2
          82FF2CB182FF2CB281FF2CB181FF2CB181FF2CB181FF29956CFF246248F10919
          135A000000120000000600000001000000000000000000000000000000000000
          000000000000000000040000000C09191253256C4EFA2A9F74FF2CB181FF2DB1
          82FF2CB283FF2DB283FF2DB283FF2EB283FF2EB284FF2EB384FF2EB383FF2EB3
          84FF2EB384FF2EB283FF2EB383FF2EB383FF2DB282FF2DB182FF2A9F74FF256D
          4FFA091A12590000001000000005000000010000000000000000000000000000
          00000000000200000009050F0B38246549EE2EA47AFF2EB383FF2DB283FF2EB3
          83FF2EB384FF2EB385FF2EB484FF51C7A2FF60CFAEFF37B98DFF2EB485FF2FB5
          85FF2FB485FF2EB485FF2EB485FF2EB384FF2EB383FF2EB384FF2FB384FF2FA5
          7AFF23644AEF050F0B3E0000000C000000030000000100000000000000000000
          000100000005000000101D513BCB2E9770FF30B385FF2EB384FF2EB484FF2EB4
          85FF2FB586FF2FB586FF50C6A1FF32916EFF1E7652FF4AB995FF30B587FF31B6
          87FF30B686FF30B587FF30B587FF2FB586FF2EB486FF2EB485FF2EB485FF30B4
          86FF2E9871FF1D533CD000000016000000070000000100000000000000000000
          00020000000A0C231A652D7D5CFF34B689FF2EB384FF2EB485FF2FB586FF30B5
          86FF31B688FF4EC59FFF389774FF7CAE9AFFA2C4B6FF2F8C6AFF41BF95FF32B7
          89FF32B789FF31B688FF31B689FF31B688FF30B588FF30B686FF2FB486FF2EB4
          85FF34B68AFF2D7E5EFF0D241A6B0000000E0000000300000001000000010000
          00040000000F205B43DD32A67DFF30B587FF2FB586FF30B587FF31B688FF31B7
          88FF4BC49DFF3E9F7CFF6BA28BFFF9F5F1FFF5EFEAFF45896CFF4CB491FF35BB
          8DFF34B98BFF34B98AFF33B98AFF32B989FF32B789FF32B688FF31B688FF30B5
          87FF31B688FF33A77DFF215E44DF000000160000000700000001000000020000
          0007091B144E308061FF37B98BFF30B587FF30B688FF31B688FF33B78AFF48C4
          9BFF46A786FF5A967DFFF6F4F0FFF3E8DFFFF3E8DFFFC8D9D0FF247A58FF4FC5
          9EFF35BB8DFF35BB8DFF34BA8CFF34BA8BFF34BA8BFF33B98AFF32B989FF31B7
          88FF31B688FF37B98CFF308162FF0A1D15570000000B00000002000000020000
          0009153B2B923A9B78FF35B98BFF32B788FF32B989FF33B98BFF46C39AFF4CAF
          8EFF4A8A6FFFF4F4F1FFF4EAE2FFF4E9E0FFF3E8E0FFF7EDE7FF699D87FF409D
          7CFF3FC094FF37BC8FFF37BC8EFF36BB8EFF36BB8DFF35BA8DFF34BA8BFF34B9
          8BFF32B78AFF36BA8CFF3B9C79FF153C2C980000000E00000003000000020000
          000B1E553FC63DAC86FF35B88CFF33B78AFF33B98BFF45C398FF54B797FF4084
          67FFEAEFEAFFF5EBE3FFF2E6DEFFEDDFD6FFF4E9E1FFF4E9E0FFE3E8E1FF2570
          50FF56C19EFF39BE91FF39BE90FF38BD90FF37BC8FFF37BC8EFF35BB8DFF35BB
          8CFF33B98BFF35B98DFF3EAD87FF1E5640CA0000001100000004000000030000
          000C256A4EEC3EB88EFF34BA8CFF35B98CFF3FBF94FF57BD9DFF347B5CFFE5EC
          E8FFF6EDE6FFF1E6DDFFCAC3B6FF9DAA97FFEFE3DCFFF4EAE2FFF6EBE5FF9DBD
          AFFF318464FF4FC8A2FF3ABF94FF3ABF92FF39BE91FF38BD90FF37BD8FFF36BB
          8EFF35BB8CFF35BB8CFF3FB98FFF256D50ED0000001300000005000000030000
          000C287455FA43C096FF35BA8BFF36BB8DFF37B488FF1F704EFFC9D0C8FFF7ED
          E7FFF1E5DEFFBEBCB0FF2E7354FF246F4EFFB5B7A8FFF1E6DFFFF4EAE3FFF6F1
          ECFF548B72FF4EAD8DFF42C49AFF3CC195FF3BC094FF3BBF92FF39BE90FF39BD
          90FF37BC8EFF35BB8DFF44C197FF287657FA0000001300000005000000030000
          000B287656FA4CC49BFF35BC8DFF37BC8EFF37BC8EFF24805CFF608A72FFE4D5
          CCFFB2B5A7FF2C7757FF3CBD96FF3BBB93FF2B7151FFC8C3B6FFF4E9E2FFF5EB
          E4FFE1E8E2FF2D7355FF5FCAABFF40C59AFF3EC197FF3CC195FF3BC094FF3ABF
          92FF38BD90FF38BC8EFF4EC59DFF297859FA0000001200000005000000020000
          000A267052EC55C39FFF39BD91FF38BE90FF3ABE92FF3CC096FF257E5BFF4A7C
          61FF2B7F5EFF41CBA3FF45D3ACFF46D3ADFF39B28DFF3C7457FFDACFC5FFF5EB
          E4FFF7EDE8FFADC7BAFF2E8061FF5ED8B7FF43CDA4FF40C99FFF3DC399FF3CBF
          94FF3ABF92FF3BBF92FF56C5A0FF277256ED0000001100000004000000020000
          0008205D46C559BD9DFF3DC094FF3CC296FF43CDA6FF45D2ACFF44CEA8FF319D
          7AFF46D2ACFF48D5B0FF49D5B0FF49D5B0FF49D5B1FF34A481FF4C7B60FFE0D2
          CAFFF5ECE5FFF9F3EFFF699882FF459D7FFF57D6B3FF44CFA6FF43CDA4FF41C8
          A0FF3DC196FF3FC196FF5BBF9FFF205F47C80000000E00000003000000010000
          00061643328F58B194FF49CDA6FF47D2ACFF48D3AEFF49D5AFFF49D5B0FF4AD7
          B2FF4BD7B2FF4CD8B4FF4DD7B4FF4DD8B4FF4CD8B4FF4DD7B4FF329B78FF4B7B
          61FFDFD2C9FFF6EBE5FFEFF0ECFF468066FF58B699FF55D6B1FF45CFA7FF45CE
          A5FF43CAA3FF48C9A2FF58B295FF174433940000000B00000003000000010000
          00040B201848409E80FF63DEC0FF4BD4B1FF4CD7B2FF4DD7B3FF4ED7B4FF4FD8
          B4FF4FD9B7FF50DAB7FF50DAB7FF51DAB8FF51DAB7FF50DAB7FF51D9B7FF38A6
          84FF47795EFFDDD0C7FFF6ECE7FFF0F2EFFF478368FF61C1A5FF56D5B3FF47CF
          A8FF46CDA6FF62D8B8FF409C7DFF0B20184E0000000700000002000000000000
          0002000000072D7D62DA6CD4BBFF55D9B7FF51D8B5FF51D9B6FF53DAB8FF53DB
          BAFF54DCB9FF55DBBAFF55DCBBFF56DCBBFF55DCBAFF56DDBBFF56DDBAFF55DC
          BAFF40B090FF487A60FFD9CCC4FFF3E9E3FFEDF1EDFF4B876DFF67C7ACFF57D6
          B3FF4ED2ADFF6ECFB6FF29785DDC0000000E0000000400000001000000000000
          0001000000041231275B48A98CFF72E5CAFF56DBB9FF56DBBAFF58DCBCFF58DC
          BCFF59DDBDFF59DEBDFF5ADFBEFF5ADFBFFF5BDFBFFF5ADFBEFF5ADFBEFF59DE
          BDFF59DDBCFF47BB9AFF367559FFBAB9ADFFECDFD8FFDDDFDAFF237150FF45BA
          96FF70DFC3FF46A487FF10302561000000080000000200000000000000000000
          000000000002000000062B765EC66CCEB6FF6AE3C6FF5CDDBDFF5DDEBFFF5EDE
          C0FF5EDFC0FF5FE1C2FF60E1C2FF5FE1C2FF60E1C2FF5FE0C2FF5EE1C1FF5EE0
          C1FF5DDFBFFF5CDFBEFF55CFAFFF2E8464FF72937DFF8FA392FF2D8463FF63D8
          B9FF6DCBB1FF287259C80000000C000000040000000100000000000000000000
          00000000000100000003081410283B9679EC7EDFCBFF6FE4C9FF63E0C3FF63E0
          C3FF64E1C4FF65E2C4FF64E3C5FF64E3C5FF64E3C5FF65E3C5FF64E2C5FF63E2
          C4FF63E2C3FF61E0C1FF5FDFBFFF5EDEBDFF48B797FF2A8362FF61D2B5FF80DB
          C6FF379274ED07140F2D00000006000000020000000000000000000000000000
          00000000000000000001000000041028204644A689F982DFCBFF7EEAD3FF69E2
          C6FF69E3C7FF6AE4C7FF6AE4C8FF6AE5C9FF6AE4C8FF6AE4C8FF6AE4C8FF69E4
          C7FF68E3C6FF66E2C4FF64E0C2FF62DFC1FF61DDBEFF7AE5CDFF82DCC7FF40A2
          83FA0E271F4A0000000700000002000000000000000000000000000000000000
          000000000000000000000000000100000004102921453F9E81EE77D5BEFF93F1
          DFFF7BE9D1FF6FE5CAFF6FE6CBFF70E6CBFF70E6CBFF6FE7CCFF6EE6CBFF6DE6
          CAFF6CE4C8FF6BE3C6FF69E2C5FF75E5CBFF92EEDAFF75D2BAFF3B9B7CEE0F28
          204A000000070000000200000001000000000000000000000000000000000000
          000000000000000000000000000000000001000000030814102335856DC85ABF
          A3FF8BE4D2FF9DF4E5FF8DEFDCFF82EBD5FF7EEBD4FF75E8CFFF74E8CEFF7DEA
          D2FF7FEAD3FF8CEDDAFF9DF2E2FF8BE4D0FF58BEA1FF318469CA071410280000
          0006000000020000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000100000002000000051738
          2E563D987CDA54BD9EFF75D4BCFF8EE6D3FF94EAD9FFA7F5E8FFA7F5E8FF95EA
          D9FF8DE6D3FF73D3BAFF52BB9CFF399679DA16392E5B00000007000000040000
          0002000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000010000
          0003000000040D201A32255A4A82388D73C53B957ACE49B896FC49BA98FC3A95
          7ACF378D74C6235A4A840C201A34000000060000000400000002000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000010000000200000003000000040000000500000005000000050000
          0005000000040000000400000003000000020000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000001000000010000000100000001000000010000
          0001000000010000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end>
  end
end