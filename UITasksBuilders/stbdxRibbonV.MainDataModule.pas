unit stbdxRibbonV.MainDataModule;

interface

uses
  System.SysUtils, System.Classes, XML.XMLIntf,
  System.ImageList, Vcl.ImgList, cxGraphics, Vcl.Controls, VCL.Forms,
  dxBar, dxRibbon, SymphonyPlugIn.ActionInterface, stbIntf.MainUnit,
  UITaskContolManager, UISPActionManager ;

type
  TImageIndexes = array[0..6] of Integer ;

  TdmRVMain = class(TDataModule)
    cxilDefs: TcxImageList;
    cxILLogo: TcxImageList;
    cxilDefSmall: TcxImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure CloseApplication(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure BarVisibleChange(Sender: TdxBarManager;  ABar: TdxBar);
    procedure RibbonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FManager: TdxBarManager ;
    FRibbon: TdxRibbon ;
    FTaskBar: TDxBar ;
    FMenu: TdxBarPopupMenu ;
    FImgList: array[0..1] of TcxImageList ;
    FImgIndex: TImageIndexes ;
    FImgLargeIndex: TImageIndexes ;
    FTaskControlMng: TUITaskControlManager ;
    FActionControlMng: TUISPActionManager ;
    FShiftCmd: TShiftState ;

    procedure PreapareUIComponents(UIParent: TComponent; Events: TEventList) ;
    function  CreateUIControls(AForm: TForm; Events: TEventList): TdxRibbon ;
    procedure CreateButtonOnMenu(Menu: TdxBarApplicationMenu; Caption: String; ImageIndex: Integer; OnExecute: TNotifyEvent) ;
    procedure SetUIFields(Ribbon: TdxRibbon) ;
    procedure CopyImages(Source: TCustomImageList; Dest: TCustomImageList; var Indexes: TImageIndexes) ;
    procedure CopyIndexes(Source: TImageIndexes; var Dest: TImageIndexes) ;
    procedure AddTasksGroup(TaskGroup: IXMLNode; OnExecute: TNotifyEvent) ;
    procedure AddTaskGroupToMenu(TaskGroup: IXMLNode; Menu: TdxBarPopupMenu; OnExecute: TNotifyEvent) ;
    procedure AddTaskToMenu(ATask: IXMLNode; Menu: TdxBarPopupMenu; OnExecute: TNotifyEvent) ;
    function  GetTaskLargeImageIndex(ATask: IXMLNode): Integer ;
    function  GetTaskImageIndex(ATask: IXMLNode): Integer ; overload ;
    function  GetTaskImageIndex(ATask: IXMLNode; ImageList: TcxImageList; ImageSize: Integer): Integer ; overload ;
    function  GetControl(ATask: IXMLNode): TObject;
    function  GetTask(AControl: TObject): IXMLNode;
    function  GetMenuButton(Acaption: String): TdxBarButton ;
    function  GetAction(AControl: TObject): ISymphonyPlugInAction;
    function  GetControl2(AAction: ISymphonyPlugInAction): TObject;
    function  CreateControlForAction(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton ;
    procedure CreateClosePlugInControls(Actions: ISymphonyPlugInActionList; OnClosePlugIn: TNotifyEvent) ;
    function  CreateButton(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton ;
    function  GetBar(Action: ISymphonyPlugInAction): TdxBar ;
    function  GetRibbonTab(Action: ISymphonyPlugInAction): TdxRibbonTab ;
    function  GetRibbonContext(Action: ISymphonyPlugInAction): TdxRibbonContext ;
    function  GetActionImageIndex(Action: ISymphonyPlugInAction; ImageList: TcxImageList; ImageSize: Integer): Integer ; overload ;
    function  GetActionImageIndex(Action: ISymphonyPlugInAction): Integer ; overload ;
    function  GetActionLargeImageIndex(Action: ISymphonyPlugInAction): Integer ;
    function  FormIncludeRibbon(AForm: TForm): Boolean ;
    function  FindFrame(AForm: TForm): TFrame ;
    function  FindRibbon(AForm: TForm): TdxRibbon ;
    function  FindBarManager(AForm: TForm): TdxBarManager ;
    procedure MergeRibbons(AForm: TForm) ;
    procedure MergeToolBars(AForm: TForm) ;
  public
    { Public declarations }
    function  BuildTasks(UIParent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean ;

    function  BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean ;
    procedure DestroyActions(Actions: ISymphonyPlugInActionList) ;
    function  ActionForControl(AControl: TObject): ISymphonyPlugInAction ;
    function  ControlForAction(AAction: ISymphonyPlugInAction): TObject ;

    procedure MergeUI(AForm: TForm) ;
    procedure UnMergeUI(AForm: TForm) ;

    function SetContextVisible(AForm: TForm; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AContextName: String; AVisible: Boolean; AActiveTab: Boolean = False): boolean ; overload ;

    property Task[AControl: TObject]: IXMLNode read GetTask ;
    property Control[ATask: IXMLNode]: TObject read GetControl ;
    property Action[AControl: TObject]: ISymphonyPlugInAction read GetAction ;
    property Control2[AAction: ISymphonyPlugInAction]: TObject read GetControl2 ;
  end;

  TdxRibbonVUIManager = class(TInterfacedObject, ISymphonyUIManager)
  private
    FdmRVMain: TdmRVMain;
  public
    constructor Create ;
    destructor Destroy ; override ;

    function BuildTasks(Parent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean ;
    function TaskForControl(AControl: TObject): IXMLNode ;
    function ControlForTask(ATask: IXMLNode): TObject ;

    function  BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList;  Events: TEventList): Boolean ;
    procedure DestroyActions(Actions: ISymphonyPlugInActionList) ;
    function  ActionForControl(AControl: TObject): ISymphonyPlugInAction ;
    function  ControlForAction(AAction: ISymphonyPlugInAction): TObject ;

    procedure MergeUI(AForm: TForm) ;
    procedure UnMergeUI(AForm: TForm) ;

    function SetContextVisible(AForm: TForm; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AContextName: String; AVisible: Boolean): boolean ; overload ;
  end;

var
  dmRVMain: TdmRVMain;

function PackageDesc: IXMLNode ; export ;
function GetUIManager: ISymphonyUIManager ; export ;

exports PackageDesc, GetUIManager ;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses XML.XMLDoc, VCL.Graphics, iexBitmaps, IdCoderMIME, XMLValUtil,
      dxBarApplicationMenu ;

Type
  TdxBarControlAccess = class(TdxBarControl);

Var
   RibbonVUIManager: ISymphonyUIManager ;

function PackageDesc: IXMLNode ;
Var
  Doc: IXMLDocument ;
begin
  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  Doc.DocumentElement := Doc.CreateNode('PACKAGEINFO') ;
  Result              := Doc.DocumentElement ;

  Result.ChildValues['CAPTION']     := 'Панели инструментов с выпадающими меню' ;
  Result.ChildValues['HINT']        := 'Каждая группа задач располагается в выпадающем меню на единственной закладке панели инструментов' ;
  Result.ChildValues['PARENTCLASS'] := 'TdxRibbon' ;
end;

function GetUIManager: ISymphonyUIManager ;
begin
  Result  := RibbonVUIManager ;
end;

{ TdmRHMain }
{$REGION 'TdmRHMain'}
function TdmRVMain.ActionForControl(AControl: TObject): ISymphonyPlugInAction;
begin
  Result  := FActionControlMng.Action[AControl] ;
end;

procedure TdmRVMain.AddTaskGroupToMenu(TaskGroup: IXMLNode; Menu: TdxBarPopupMenu; OnExecute: TNotifyEvent);
Var
  btn: TdxBarButton ;
  Link: TdxBarItemLink ;
  SubMenu: TdxBarPopupMenu ;
  i: Integer ;
  ListNode, Node: IXMLNode ;
begin
  ListNode      := TaskGroup.ChildNodes.Nodes['CHILDREN'] ;
  for i := 0 to ListNode.ChildNodes.Count - 1 do
  begin
    Node  := ListNode.ChildNodes.Nodes[i] ;
    if Node.ChildValues['ITASKTYPE'] < 0 then
    begin
      SubMenu             := TdxBarPopupMenu.Create(FManager.Owner);
      SubMenu.BarManager  := FManager ;

      btn                 := TdxBarButton.Create(Fmanager.Owner) ;
      btn.BarManager      := FManager ;
      btn.Caption         := AsStr(TaskGroup.ChildValues['CAPTION']) ;
      btn.LargeImageIndex := GetTaskLargeImageIndex(TaskGroup) ;
      btn.ImageIndex      := GetTaskImageIndex(TaskGroup) ;
      btn.DropDownMenu    := SubMenu ;

      Link                := Menu.ItemLinks.Add ;
      Link.Item           := btn ;

      AddTaskGroupToMenu(Node, SubMenu, OnExecute) ;
    end
    else
            AddTaskToMenu(Node, Menu, OnExecute);
  end;
end;

procedure TdmRVMain.AddTasksGroup(TaskGroup: IXMLNode; OnExecute: TNotifyEvent);
Var
  btn: TdxbarlargeButton ;
  Link: TdxBarItemLink ;
  Menu: TdxBarPopupMenu ;
begin
  Menu                := TdxBarPopupMenu.Create(FManager.Owner) ;
  Menu.BarManager     := FManager ;

  btn                 := TdxBarLargeButton.Create(FManager.Owner);
  btn.BarManager      := FManager ;
  btn.Caption         := AsStr(TaskGroup.ChildValues['CAPTION'], '*') ;
  btn.LargeImageIndex := GetTaskLargeImageIndex(TaskGroup) ;
  btn.ImageIndex      := GetTaskImageIndex(TaskGroup) ;
  btn.ButtonStyle     := bsDropDown ;
  btn.DropDownMenu    := Menu ;

  Link                := FTaskBar.ItemLinks.Add ;
  Link.Item           := btn ;

  AddTaskGroupToMenu(TaskGroup, Menu, OnExecute)
end;

procedure TdmRVMain.AddTaskToMenu(ATask: IXMLNode; Menu: TdxBarPopupMenu; OnExecute: TNotifyEvent);
Var
  btn: TdxBarButton ;
  Link: TdxBarItemLink ;
begin
  btn                 := TdxBarButton.Create(FRibbon.Owner);
  btn.Caption         := AsStr(ATask.ChildValues['CAPTION']) ;
  btn.Hint            := AsStr(ATask.ChildValues['HINT'])    ;
  btn.LargeImageIndex := GetTaskLargeImageIndex(ATask) ;
  btn.ImageIndex      := GetTaskImageIndex(ATask) ;
  btn.OnClick         := OnExecute ;
  Link                := Menu.ItemLinks.Add ;
  Link.Item           := btn ;
  FTaskControlMng.AddControl(ATask, btn);
end;

procedure TdmRVMain.BarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
begin
  if (ABar <> nil) and (ABar.Control <> nil) then
  begin
    TdxBarControlAccess(ABar.Control).OnMouseDown := RibbonMouseDown ;
  end;
end;

function TdmRVMain.BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean;
Var
  i: Integer ;
  CreatedControls: Integer ;
begin
  Result  := True ;
  CreatedControls := 0 ;
  if FManager = nil then
                        PreapareUIComponents(Parent, Events) ;

  for i := 0 to Actions.Count - 1 do
    if Actions.Action[i].Visible then
    begin
      Inc( CreatedControls ) ;
      FActionControlMng.AddControl(Actions.Action[i],
                        CreateControlForAction(Actions.Action[i], Events.OnExecute)) ;
    end;

  if (CreatedControls > 0) and (Actions.Count > 0) and Assigned(Events.OnClosePlugIn) then
                        CreateClosePlugInControls(Actions, Events.OnClosePlugIn) ;
end;

function TdmRVMain.BuildTasks(UIParent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean;
var
  i: Integer;
  Node: IXMLNode ;
  btn: TdxBarButton ;
begin
  Result  := True ;
  PreapareUIComponents(UIParent, Events) ;

  for i := 0 to Tasks.ChildNodes.Count - 1 do
  begin
    Node  := Tasks.ChildNodes.Nodes[i] ;
    if Node.ChildValues['ITASKTYPE'] = -1 then
    begin
      AddTasksGroup(Node, Events.OnExecute) ;
    end
    else
    begin
      if FMenu = nil then
      begin
        btn   := GetMenuButton('Задачи пользователя') ;
        FMenu := btn.DropDownMenu as TdxBarPopupMenu ;

        FTaskBar.ItemLinks.Add.Item := btn ;
      end;
      AddTaskToMenu(Node, FMenu, Events.OnExecute) ;
    end;
  end;
end;

procedure TdmRVMain.CloseApplication(Sender: TObject);
begin
  Application.MainForm.Close ;
end;

function TdmRVMain.ControlForAction(AAction: ISymphonyPlugInAction): TObject;
begin
  Result  := FActionControlMng.Control[AAction] ;
end;

procedure TdmRVMain.CopyImages(Source, Dest: TCustomImageList;  var Indexes: TImageIndexes);
var
  i: Integer;
  bmp: TBitmap ;
begin
  for i := Low(Indexes) to High(Indexes) do
  begin
    bmp := TBitmap.Create ;
    Try
      Source.GetBitmap(i, bmp) ;
      Indexes[i]  := Dest.Add(bmp, nil) ;
    Finally
      bmp.Free ;
    End;
  end ;
end;

procedure TdmRVMain.CopyIndexes(Source: TImageIndexes; var Dest: TImageIndexes);
var
  i: Integer;
begin
  for i := Low(Source) to High(Source) do
                                        Dest[i] := Source[i] ;
end;

function TdmRVMain.CreateButton(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton;
begin
  Result                  := TdxBarLargeButton.Create(FManager.Owner);
  Result.BarManager       := FManager ;
  Result.Caption          := Action.Caption ;
  Result.ImageIndex       := GetActionImageIndex(Action) ;
  Result.LargeImageIndex  := GetActionLargeImageIndex(Action) ;
  Result.OnClick          := OnExecute ;
  if Action.Visible then
                        Result.Visible  := ivAlways
                    else
                        Result.Visible  := ivNever ;
end;

procedure TdmRVMain.CreateButtonOnMenu(Menu: TdxBarApplicationMenu; Caption: String; ImageIndex: Integer; OnExecute: TNotifyEvent);
Var
  btn: TdxBarButton ;
  Link: TdxBarItemLink ;
begin
  btn                     := TdxBarButton.Create(FManager.Owner) ;
  btn.BarManager          := FManager ;
  btn.Caption             := Caption ;
  btn.ImageIndex          := ImageIndex ;
  btn.OnClick             := OnExecute ;
  Menu.ItemLinks.Add.Item := btn ;
end;

procedure TdmRVMain.CreateClosePlugInControls(Actions: ISymphonyPlugInActionList; OnClosePlugIn: TNotifyEvent);
Var
  act: ISymphonyPlugInAction ;
  bar: TdxBar ;
  btn: TdxBarButton ;
  Cntx: TdxRibbonContext ;
  cntxlist: TStringList ;
  link: TdxbarItemLink ;
  i: Integer;
  j: Integer;
begin
  btn                 := TdxBarLargeButton.Create(FManager.Owner);
  btn.BarManager      := FManager ;
  btn.ImageIndex      := FImgIndex[3] ;
  btn.LargeImageIndex := FImgLargeIndex[3] ;
  btn.Caption         := 'Закрыть задачу' ;
  btn.OnClick         := OnClosePlugIn ;

  if Actions.Count > 0 then
                      FActionControlMng.AddControl(Actions.Action[0], btn) ;

  cntxlist        := TStringList.Create ;
  Try
    for i := 0 to Actions.Count - 1 do
    begin
      act := Actions.Action[i] ;
      if cntxlist.IndexOf(act.ContextName) = -1 then
      begin
        cntxlist.Add(act.ContextName) ;
        Cntx    := FRibbon.Contexts.Find(act.ContextName) ;
        if (Cntx <> nil) and (Cntx.TabCount > 0) and
                          (Cntx.Tabs[Cntx.TabCount - 1].Groups.Count > 0) then
        begin
          with Cntx.Tabs[Cntx.TabCount - 1] do
                                  bar := Groups[Groups.Count - 1].ToolBar ;
          if bar <> nil then
          begin
            link            := bar.ItemLinks.Add ;
            link.Item       := btn ;
            link.BeginGroup := True ;
          end;
        end;
      end;
    end;
  Finally
    cntxlist.Free ;
  End;
end;

function TdmRVMain.CreateControlForAction(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton;
Var
  bar: TdxBar ;
  link: TdxBarItemLink ;
begin
  // 1. Получаем кнопку из акции
  Result  := CreateButton(Action, OnExecute) ;

  // 2. Получаем бар
  bar     := GetBar(Action) ;

  // 3. Заталкиваем кнопку на бар
  link      := bar.ItemLinks.Add ;
  link.Item := Result ;
end;

function TdmRVMain.CreateUIControls(AForm: TForm; Events: TEventList): TdxRibbon;
Var
  RibbonTab: TdxRibbonTab ;
  Menu: TdxBarApplicationMenu ;
  btn: TdxBarButton ;
  mbtn: TdxBarApplicationMenuButton ;
  Link: TdxBarItemLink ;
  bmp: TBitmap ;
  i: Integer;
begin
  bmp := TBitmap.Create ;
  Try
    FImgList[0]     := TcxImageList.Create(AForm);
    FImgList[0].Height  := 16 ;
    FImgList[0].Width   := 16 ;

    FImgList[1]     := TcxImageList.Create(AForm);
    FImgList[1].Height  := 32 ;
    FImgList[1].Width   := 32 ;

    for i := 1 to 6 do
    begin
      cxilDefs.GetBitmap(i, bmp) ;
      FImgList[0].AddBitmap(bmp, nil, bmp.Canvas.Pixels[0, 0], True, True) ;
      FImgList[1].AddBitmap(bmp, nil, bmp.Canvas.Pixels[0, 0], True, True) ;
    end;
  Finally
    bmp.Free ;
  End;

  FManager  := TdxBarManager.Create(AForm);
  FManager.AlwaysSaveText           := True ;
  FManager.ImageOptions.Images      := FImgList[0];
  FManager.ImageOptions.LargeImages := FImgList[1];
  FManager.OnBarVisibleChange       := BarVisibleChange ;

  FTaskBar  := FManager.AddToolBar ;
  FTaskBar.Caption  := 'Задачи пользователя' ;

  FRibbon   := TdxRibbon.Create(AForm);
  FRibbon.Parent      := AForm ;
  FRibbon.BarManager  := FManager ;
  With FRibbon.Tabs.Add do
  begin
    Caption := 'Задачи пользователя' ;
    Groups.Add.ToolBar  := FTaskBar ;
  end;
  cxilDefs.GetImage(0, FRibbon.ApplicationButton.Glyph);

  Menu            := TdxBarApplicationMenu.Create(FManager.Owner) ;
  Menu.BarManager := FManager ;
  mbtn  := Menu.Buttons.Add ;
  mbtn.Item := TdxBarButton.Create(FManager.Owner);
  mbtn.Item.BarManager  := FManager ;
  mbtn.Item.Caption     := 'Прикрыть лавочку' ;
  mbtn.Item.ImageIndex  := 1 ;
  mbtn.Item.OnClick := CloseApplication ;

  FRibbon.ApplicationButton.Menu  := Menu ;
  CreateButtonOnMenu(Menu, 'Печать',          4, Events.OnPrint ) ;
  CreateButtonOnMenu(Menu, 'Экспорт в Excel', 5, Events.OnExportExcel ) ;
  CreateButtonOnMenu(Menu, 'Параметры',       3, Events.OnEditTuner ) ;
  CreateButtonOnMenu(Menu, 'Закрыть',         1, CloseApplication ) ;

  with FRibbon.QuickAccessToolbar do
  begin
    Position := qtpAboveRibbon;
    Toolbar := FManager.AddToolBar;
    Toolbar.Visible := True;
  end;

  Result  := FRibbon ;
end;

procedure TdmRVMain.DataModuleCreate(Sender: TObject);
begin
  FTaskBar  := nil ;
  FMenu     := nil ;
  FTaskControlMng   := TUITaskControlManager.Create ;
  FActionControlMng := TUISPActionManager.Create ;
end;

procedure TdmRVMain.DataModuleDestroy(Sender: TObject);
begin
  FActionControlMng.Free ;
  FTaskControlMng.Free ;
end;

procedure TdmRVMain.DestroyActions(Actions: ISymphonyPlugInActionList);
var
  i, j, g, l: Integer;
  btn: TObject ;
  tab: TdxRibbonTab ;
  bar: TdxBar ;
  link: TdxBarItemLink ;
  BtnIndex: Integer;
begin
  FRibbon.ActiveTab := FRibbon.Tabs[0] ;

  for i := 0 to Actions.Count - 1 do
  begin
    BtnIndex  := FActionControlMng.IndexByAction(Actions.Action[i]) ;
    btn       := FActionControlMng.Items[BtnIndex].Control ;
    while btn <> nil do
    begin
      for j := FRibbon.TabCount - 1 downto 0 do
      begin
        tab := FRibbon.Tabs[j] ;
        for g := tab.Groups.Count - 1 downto 0 do
        begin
          bar := tab.Groups[g].ToolBar ;
          for l := bar.ItemLinks.Count - 1 downto 0 do
            if bar.ItemLinks[l].Item = btn then
            begin
              bar.ItemLinks.Delete(l);
            end;

          // Удаляем панель, если там нет больше контролов. До кучи удаляем группу
          if bar.ItemLinks.Count = 0 then
          begin
            FManager.Bars.Delete(bar.Index);

            // при удалении панели, группа походу сама аннулируется.
            //Так что удаление группы убираем
//            if g < tab.Groups.Count then
//                                        tab.Groups.Delete(g);
          end;
        end;

        // удаляем закладку, если не осталось групп на закладке
        if tab.Groups.Count = 0 then
        begin
          if FRibbon.ActiveTab = tab then
            if tab.Index = 0 then FRibbon.ActiveTab := FRibbon.Tabs[FRibbon.TabCount - 1]
                             else FRibbon.ActiveTab := FRibbon.Tabs[0] ;
          FRibbon.Tabs.Delete(tab.Index);
        end;
      end;

      FActionControlMng.Remove(FActionControlMng.Items[BtnIndex]) ;
      btn.Free ;

      BtnIndex  := FActionControlMng.IndexByAction(Actions.Action[i]) ;
      if BtnIndex < 0 then btn  := nil
      else btn       := FActionControlMng.Items[BtnIndex].Control ;
    end;

    {Находим у кнопке линк
    К линку находим панельку
    для панельки находим закладку рибона и группу, где сидит панелька
    удаляем линк и кнопку
    если на панельке нет больше кнопок, то удаляем панельку и группу где она сидит
    если на закладке нет больше групп, удаляем закладку}
  end;
end;

function TdmRVMain.FindBarManager(AForm: TForm): TdxBarManager;
Var
  i: Integer ;
  frm: TFrame ;
begin
  Result  := nil ;
  frm     := FindFrame(AForm) ;
  if frm = nil then
                   Exit ;

  for i := 0 to frm.ComponentCount - 1 do
    if frm.Components[i] is TdxBarManager then
    begin
      Result:= TdxBarManager(frm.Components[i]) ;
      Break ;
    end;
end;

function TdmRVMain.FindFrame(AForm: TForm): TFrame;
var
  i: Integer;
begin
  Result  := nil ;
  for i := 0 to AForm.ComponentCount - 1 do
    if AForm.Components[i] is TFrame then
    begin
      Result  := TFrame(AForm.Components[i]) ;
      Break ;
    end;
end;

function TdmRVMain.FindRibbon(AForm: TForm): TdxRibbon;
Var
  i: Integer ;
  frm: TFrame ;
  Container: Tcomponent ;
begin
  Result  := nil ;
  frm     := FindFrame(AForm) ;
  if frm = nil then
                   Container  := AForm
               else
                    Container := frm ;

  for i := 0 to Container.ComponentCount - 1 do
    if Container.Components[i] is TdxRibbon then
    begin
      Result:= TdxRibbon(Container.Components[i]) ;
      Break ;
    end;
end;

function TdmRVMain.FormIncludeRibbon(AForm: TForm): Boolean;
begin
  Result  := FindRibbon(AForm) <> nil ;
end;

function TdmRVMain.GetTaskImageIndex(ATask: IXMLNode): Integer;
begin
  Result  := GetTaskImageIndex(ATask, FImgList[0], 16) ;
  if Result < 0 then
                    Result := 0 ;
end;

function TdmRVMain.GetAction(AControl: TObject): ISymphonyPlugInAction;
begin
  Result  := FActionControlMng.Action[AControl] ;
  if Result = nil then
                      Exit ;

  Result.Command.ParamValue['UNIQUE'] := not (ssShift in FShiftCmd)
end;

function TdmRVMain.GetActionImageIndex(Action: ISymphonyPlugInAction; ImageList: TcxImageList; ImageSize: Integer): Integer;
Var
  bmp: TBitmap ;
  i: Integer;
begin
  Result  := 0 ;
  if Action.IconCount = 0 then
                              Exit ;
  bmp := Action.Icon[0] ;
  for i := 1 to Action.IconCount - 1 do
    if (Action.Icon[i].Width > bmp.Width) and (Action.Icon[i].Width <= ImageSize) then
                  bmp := Action.Icon[i] ;

  Result  := ImageList.AddBitmap(bmp, nil, bmp.Canvas.Pixels[0, 0], True, True) ;
end;

function TdmRVMain.GetActionImageIndex(Action: ISymphonyPlugInAction): Integer;
begin
  Result  := GetActionImageIndex(Action, FImgList[0], 16) ;
end;

function TdmRVMain.GetActionLargeImageIndex(Action: ISymphonyPlugInAction): Integer;
begin
  Result  := GetActionImageIndex(Action, FImgList[1], 32) ;
end;

function TdmRVMain.GetBar(Action: ISymphonyPlugInAction): TdxBar;
Var
  tab: TdxRibbonTab ;
begin
  Result  := FManager.BarByCaption(Action.Bar) ;
  if Result <> nil then
                      Exit ;

  Result          := FManager.Bars.Add ;
  Result.Caption  := Action.Bar ;
  Result.Visible  := True ;
  TdxBarControlAccess(Result.Control).OnMouseDown := RibbonMouseDown ;

  Tab             := GetRibbonTab(Action) ;
  Tab.Groups.Add.ToolBar  := Result ;
end;

function TdmRVMain.GetControl(ATask: IXMLNode): TObject;
begin
  Result  := FTaskControlMng.Control[ATask] ;
end;

function TdmRVMain.GetControl2(AAction: ISymphonyPlugInAction): TObject;
begin
  Result  := FActionControlMng.Control[AAction] ;
end;

function TdmRVMain.GetMenuButton(ACaption: String): TdxBarButton;
Var
  Menu: TdxBarPopupMenu ;
begin
  Menu                  := TdxBarPopupMenu.Create(FManager.Owner);
  Menu.BarManager       := FManager ;

  Result  := TdxBarLargeButton.Create(FManager.Owner);
  Result.BarManager     := FManager ;
  Result.Caption        := ACaption ;
  Result.ButtonStyle    := bsDropDown ;
  Result.DropDownMenu   := Menu ;
  Result.ImageIndex     := 0 ;
  Result.LargeImageIndex:= 0 ;
end;

function TdmRVMain.GetRibbonContext(Action: ISymphonyPlugInAction): TdxRibbonContext;
begin
  Result  := FRibbon.Contexts.Find(Action.ContextName) ;
  if Result = nil then
  begin
    Result          := FRibbon.Contexts.Add ;
    Result.Caption  := Action.ContextName ;
    Result.Visible  := True ;
  end;
end;

function TdmRVMain.GetRibbonTab(Action: ISymphonyPlugInAction): TdxRibbonTab;
begin
  if (Action.TabCaption = EmptyStr) and (FRibbon.Tabs.Count > 0) then
                    Result := FRibbon.Tabs[Action.TabIndex]
  else
  begin
    Result := FRibbon.Tabs.Find(Action.TabCaption) ;
    if Result = nil then
    begin
      Result          := FRibbon.Tabs.Add ;
      if Action.TabCaption = EmptyStr then
          Result.Caption  :=  Action.Caption
      else
          Result.Caption  := Action.TabCaption ;
      Result.Context  := GetRibbonContext(Action) ;
    end;
  end;

  FRibbon.ActiveTab := Result ;
end;

function TdmRVMain.GetTask(AControl: TObject): IXMLNode;
begin
  Result  := FTaskControlMng.Task[AControl] ;
  Result.ChildNodes.Nodes['PARAMS'].ChildValues['UNIQUE'] := not (ssShift in FShiftCmd) ;
end;

function TdmRVMain.GetTaskImageIndex(ATask: IXMLNode; ImageList: TcxImageList; ImageSize: Integer): Integer;
Var
  i: Integer ;
  IcoList, Ico: IXMLNode ;
  Filename: String ;
  bmp: TIEBitmap ;
  Decoder: TIdDecoderMIME ;
  ms: TMemoryStream ;
begin
  Result:= -1 ;
  bmp := TIEBitmap.Create ;
  Try
    IcoList := ATask.ChildNodes.Nodes['ICONS'] ;
    for i := 0 to IcoList.ChildNodes.Count - 1 do
    begin
      Ico := IcoList.ChildNodes.Nodes[i] ;
      if AsInt(Ico.ChildValues['SIZE']) = ImageSize then
      begin
        Filename  := AsStr(Ico.ChildValues['ICONPATH']) ;
        if FileExists(Filename) then
              bmp.Read(FileName)
        else
        begin
          Decoder := TIdDecoderMIME.Create(nil) ;
          ms      := TMemoryStream.Create ;
          Try
            Decoder.DecodeStream(AsStr(Ico.ChildValues['BODY']), ms);
            if ms.Size > 0 then
            begin
              ms.Position := 0 ;
              bmp.Read(ms);
            end;
          Finally
            Decoder.Free ;
            ms.Free ;
          End;
        end;

        Result  := ImageList.AddBitmap(bmp.VclBitmap, nil, bmp.VclBitmap.Canvas.Pixels[0, 0], True, True) ;
        Break ;
      end;
    end;
  Finally
    bmp.Free ;
  End;
end;

function TdmRVMain.GetTaskLargeImageIndex(ATask: IXMLNode): Integer;
begin
  Result  := GetTaskImageIndex(ATask, FImgList[1], 32) ;
  if Result < 0 then
                    Result := 0 ;
end;

procedure TdmRVMain.MergeRibbons(AForm: TForm);
Var
  rb: TdxRibbon ;
  tab: TdxRibbonTab ;
  group: TdxRibbonTabGroup ;
  Cntx: TdxRibbonContext ;
  i: Integer ;
  j: Integer;
begin
  Cntx        := FRibbon.Contexts.Find(AForm.Caption) ;
  if Cntx = nil then
  begin
    Cntx := FRibbon.Contexts.Add ;
    Cntx.Caption  := AForm.Caption ;
  end;

  rb          := FindRibbon(AForm) ;
  rb.Visible  := False ;
  for i := 0 to rb.TabCount - 1 do
  begin
    tab := FRibbon.Tabs.Add ;
    tab.Caption := rb.Tabs[i].Caption ;
    tab.Context := Cntx ;

    for j := 0 to rb.Tabs[i].Groups.Count - 1 do
    begin
      group         := tab.Groups.Add ;
      group.ToolBar := rb.Tabs[i].Groups[j].ToolBar ;
    end;
  end;

  Cntx.Visible  := True ;
end;

procedure TdmRVMain.MergeToolBars(AForm: TForm);
Var
  bm: TdxBarManager ;
  tab: TdxRibbonTab ;
  group: TdxRibbonTabGroup ;
  bar: TdxBar ;
  Cntx: TdxRibbonContext ;
  TabCaption: String ;
  BarCaption: String ;
  i: Integer ;
  j: Integer;
begin
  bm         := FindBarManager(AForm) ;
  if bm = nil then
                  Exit ;

  Cntx        := FRibbon.Contexts.Find(AForm.Name) ;
  if Cntx = nil then
  begin
    Cntx := FRibbon.Contexts.Add ;
    Cntx.Caption  := AForm.Name ;
    Cntx.Visible  := False ;
  end;

  // Создаем закладки для контекста
  for i := 0 to bm.Bars.Count - 1 do
    if bm.Bars[i].DockControl = nil then
    begin
      bar := bm.Bars[i] ;
      j   := Pos(':', bar.Caption) ;
      if j > 0 then TabCaption  := Copy(bar.Caption, 1, j - 1)
               else TabCaption  := AForm.Caption ;

      tab := nil ;
      for j := 0 to Cntx.TabCount - 1 do
        if Cntx.Tabs[j].Caption = TabCaption then
        begin
          tab := Cntx.Tabs[j] ;
          Break ;
        end;

      if tab = nil then
      begin
        tab         := FRibbon.Tabs.Add ;
        tab.Caption := TabCaption ;
        tab.Context := Cntx ;
      end
    end;

  for i := 0 to bm.Bars.Count - 1 do
    if bm.Bars[i].DockControl = nil then
    begin
      Cntx.Visible    := True ;

      BarCaption      := bm.Bars[i].Caption ;
      j               := Pos(':', BarCaption) ;
      if j > 0 then
      begin
        TabCaption  := Copy(BarCaption, 1, j - 1) ;
        BarCaption  := Copy(BarCaption, j + 1, Length(BarCaption) - j) ;
      end
      else TabCaption  := AForm.Caption ;


      bar         := FManager.Bars.Add ;
      bar.Caption := BarCaption ;
      bar.Visible := True ;
      bar.Merge(bm.bars[i]);

      tab := nil ;
      for j := 0 to Cntx.TabCount - 1 do
        if Cntx.Tabs[j].Caption = TabCaption then
        begin
          tab := Cntx.Tabs[j] ;
          Break ;
        end;

      if tab = nil then
                       tab  := Cntx.Tabs[0] ;

      with tab.Groups.Add do
      begin
        ToolBar  := bar ;
      end;
    end;
end;

procedure TdmRVMain.MergeUI(AForm: TForm);
Var
  Events: TEventList ;
begin
  if FManager = nil then
                        PreapareUIComponents(nil, Events);
  if FormIncludeRibbon(AForm) then
                                  MergeRibbons(AForm)
                              else
                                  MergeToolBars(AForm) ;
end;

procedure TdmRVMain.PreapareUIComponents(UIParent: TComponent; Events: TEventList);
Var
  frm: TForm ;
  rbn: TdxRibbon ;
begin
  if UIParent is TdxRibbon then
                              SetUIFields(UIParent as TdxRibbon)
  else
  begin
    if UIParent is TForm then frm := UIParent as TForm
                         else frm  := Application.MainForm ;

    rbn := FindRibbon(frm) ;
    if rbn = nil then
                    rbn := CreateUIControls(frm, Events) ;
    SetUIFields(rbn) ;
  end ;
end;

procedure TdmRVMain.RibbonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FShiftCmd := Shift ;
end;

function TdmRVMain.SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean;
begin
  Result  := SetContextVisible(AAction.ContextName, AVisible) ;
end;

function TdmRVMain.SetContextVisible(AForm: TForm; AVisible: Boolean): boolean;
var
  i: Integer;
begin
  for i := 0 to FActionControlMng.Count - 1 do
    if FActionControlMng.Items[i].Action.Forms.IndexOf(AForm) > -1 then
    begin
      Result  := SetContextVisible(FActionControlMng.Items[i].Action, AVisible) ;
      Break ;
    end;

  SetContextVisible(AForm.Name, AVisible, True) ;
end;

function TdmRVMain.SetContextVisible(AContextName: String; AVisible: Boolean; AActiveTab: Boolean = False): boolean;
Var
  Cntx: TdxRibbonContext ;
begin
  Result  := False ;
  Cntx    := FRibbon.Contexts.Find(AContextName) ;
  if Cntx <> nil then
  begin
    Cntx.Visible  := AVisible ;
    Result        := True ;

    if (Cntx.TabCount > 0) and AActiveTab then
                                            FRibbon.ActiveTab := Cntx.Tabs[0] ;
  end;
end;

procedure TdmRVMain.SetUIFields(Ribbon: TdxRibbon);
begin
  FManager    := Ribbon.BarManager ;
  FRibbon     := Ribbon ;
  FImgList[0] := FManager.ImageOptions.Images as TcxImageList ;
  FImgList[1] := FManager.ImageOptions.LargeImages as TcxImageList ;

  if FImgList[0] <> nil then
  begin
    if FImgList[0].Width = cxilDefSmall.Width then
          CopyImages(cxilDefSmall, FImgList[0], FImgIndex)
    else
          CopyImages(cxilDefs, FImgList[0], FImgLargeIndex)
  end;

  if FImgList[0] = FImgList[1] then
  begin
    if FImgList[0].Width = cxilDefSmall.Width then
      CopyIndexes(FImgIndex, FImgLargeIndex)
    else
      CopyIndexes(FImgLargeIndex, FImgIndex)
  end
  else
  begin
     if FImgList[1].Width = cxilDefSmall.Width then
          CopyImages(cxilDefSmall, FImgList[1], FImgIndex)
    else
          CopyImages(cxilDefs, FImgList[1], FImgLargeIndex)
  end;
end;

procedure TdmRVMain.UnMergeUI(AForm: TForm);
Var
  tab: TdxRibbonTab ;
  bar: TdxBar ;
  act: ISymphonyPlugInAction ;
  Cntx: TdxRibbonContext ;
  i: Integer ;
  j: Integer;
  b: Integer ;
begin
  // Удаляем присоединенные панели
  Cntx        := FRibbon.Contexts.Find(AForm.Name) ;
  if Cntx = nil then
                    Exit ;
  for i := Cntx.TabCount - 1 downto 0 do
  begin
    tab := Cntx.Tabs[i] ;

    if (FRibbon.ActiveTab = tab) and (FRibbon.TabCount > 1) then
                                FRibbon.ActiveTab := FRibbon.Tabs[0] ;

    for j := tab.Groups.Count - 1 downto 0 do
    begin
      bar := tab.Groups[j].ToolBar ;
      FManager.Bars.Delete(bar.Index);
//      tab.Groups.Delete(j);
    end;

    FRibbon.Tabs.Remove(tab) ;
  end;

  //Удаляем или прячем панели с акциями
  // НЕЛЬЗЯ!!!! Акции закрываются при выгрузке плагина.
  // Акции могут запускать функции и фреймы не относящиеся к текущему (убиваемому) окну
{  for i := 0 to FActionControlMng.Count - 1 do
  begin
    act := FActionControlMng.Items[i].Action ;
    // прячем контекст
    Cntx        := FRibbon.Contexts.Find(act.ContextName) ;
    if Cntx <> nil then
                       Cntx.Visible  := False
    else
        Continue ;

    if (act.Forms.IndexOf(AForm) >= 0) and (act.Forms.Count < 2) then
    begin
      // удаляем панельки
      for j := Cntx.TabCount - 1 to 0 do
      begin
        tab := Cntx.Tabs[j] ;
        if not (tab = nil) then
        begin
          for b := tab.Groups.Count - 1 to 0 do
            FManager.Bars.Delete(tab.Groups[b].ToolBar.Index);
          FRibbon.Tabs.Delete(tab.Index);
        end;
      end;
    end;
  end;  }
end;

{$ENDREGION}

{ TdxRibbonVUIManager }
{$REGION 'TdxRibbonVUIManager'}
function TdxRibbonVUIManager.ActionForControl(AControl: TObject): ISymphonyPlugInAction;
begin
  Result  := FdmRVMain.Action[AControl] ;
end;

function TdxRibbonVUIManager.BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList;  Events: TEventList): Boolean;
begin
  Result  := FdmRVMain.BuildActions(Parent, Actions, Events) ;
end;

function TdxRibbonVUIManager.BuildTasks(Parent: TComponent; Tasks: IXMLNode;  Events: TEventList): Boolean;
begin
  Result  := FdmRVMain.BuildTasks(Parent, Tasks, Events) ;
end;

function TdxRibbonVUIManager.ControlForAction(AAction: ISymphonyPlugInAction): TObject;
begin
  Result  := FdmRVMain.Control2[AAction] ;
end;

function TdxRibbonVUIManager.ControlForTask(ATask: IXMLNode): TObject;
begin
  Result  := FdmRVMain.Control[ATask] ;
end;

constructor TdxRibbonVUIManager.Create;
begin
  FdmRVMain := TdmRVMain.Create(nil);
end;

destructor TdxRibbonVUIManager.Destroy;
begin
  FdmRVMain.Free ;
  inherited;
end;

procedure TdxRibbonVUIManager.DestroyActions(Actions: ISymphonyPlugInActionList);
begin
  FdmRVMain.DestroyActions(Actions);
end;

procedure TdxRibbonVUIManager.MergeUI(AForm: TForm);
begin
  FdmRVMain.MergeUI(AForm);
end;

function TdxRibbonVUIManager.SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean;
begin
  Result  := FdmRVMain.SetContextVisible(AAction, AVisible) ;
end;

function TdxRibbonVUIManager.SetContextVisible(AForm: TForm; AVisible: Boolean): boolean;
begin
  Result  := FdmRVMain.SetContextVisible(AForm, AVisible) ;
end;

function TdxRibbonVUIManager.SetContextVisible(AContextName: String; AVisible: Boolean): boolean;
begin
  Result  := FdmRVMain.SetContextVisible(AContextName, AVisible) ;
end;

function TdxRibbonVUIManager.TaskForControl(AControl: TObject): IXMLNode;
begin
  Result  := FdmRVMain.Task[AControl] ;
end;

procedure TdxRibbonVUIManager.UnMergeUI(AForm: TForm);
begin
  FdmRVMain.UnMergeUI(AForm);
end;

{$ENDREGION}

initialization
  RibbonVUIManager  := TdxRibbonVUIManager.Create ;
finalization
  RibbonVUIManager  := nil ;
end.
