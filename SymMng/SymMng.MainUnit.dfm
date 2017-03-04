object frmSymMngMain: TfrmSymMngMain
  Left = 0
  Top = 0
  Caption = 'Symphony.Next'
  ClientHeight = 326
  ClientWidth = 519
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object PlugInMng: TPlugInManager
    OnGetOwnerForm = PlugInMngGetOwnerForm
    OnGetSession = PlugInMngGetSession
    OnLoadActions = PlugInMngLoadActions
    OnGetTunerParam = PlugInMngGetTunerParam
    Left = 88
    Top = 52
  end
  object dxTabbedMDIManager1: TdxTabbedMDIManager
    Active = True
    FormCaptionMask = '[MainFormCaption] - [ChildFormCaption]'
    TabProperties.AllowTabDragDrop = True
    TabProperties.CloseButtonMode = cbmActiveTab
    TabProperties.CustomButtons.Buttons = <>
    TabProperties.Focusable = True
    TabProperties.Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize]
    Left = 200
    Top = 52
  end
end
