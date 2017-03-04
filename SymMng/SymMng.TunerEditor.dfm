object frmTunerEditor: TfrmTunerEditor
  Left = 0
  Top = 0
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
  ClientHeight = 373
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 332
    Width = 393
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      393
      41)
    object cxbOk: TcxButton
      Left = 229
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      ModalResult = 1
      OptionsImage.ImageIndex = 0
      TabOrder = 0
    end
    object cxbCancel: TcxButton
      Left = 310
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      OptionsImage.ImageIndex = 1
      TabOrder = 1
    end
  end
  object cxpcMain: TcxPageControl
    Left = 0
    Top = 0
    Width = 393
    Height = 332
    Align = alClient
    TabOrder = 1
    Properties.CustomButtons.Buttons = <>
    Properties.Rotate = True
    Properties.Style = 1
    Properties.TabPosition = tpLeft
    ClientRectBottom = 328
    ClientRectLeft = 4
    ClientRectRight = 389
    ClientRectTop = 4
  end
end
