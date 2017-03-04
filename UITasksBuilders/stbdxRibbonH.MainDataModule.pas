unit stbdxRibbonH.MainDataModule;

interface

uses
  System.SysUtils, System.Classes, XML.XMLIntf,
  System.ImageList, Vcl.ImgList, cxGraphics, Vcl.Controls, VCL.Forms,
  dxBar, dxRibbon,
  SymphonyPlugIn.ActionInterface,
  stbIntf.MainUnit, UITaskContolManager, UISPActionManager;

type
  TImageIndexes = array[0..6] of Integer ;

  TdmRHMain = class(TDataModule)
    cxilDefs: TcxImageList;
    cxILLogo: TcxImageList;
    cxilDefSmall: TcxImageList;

    procedure DataModuleCreate(Sender: TObject);
    procedure CloseApplication(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure BarVisibleChange(Sender: TdxBarManager;  ABar: TdxBar);
    procedure RibbonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RibbonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FManager: TdxBarManager ;
    FRibbon: TdxRibbon ;
    FTaskBar: TdxBar ;
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
    procedure AddTaskGroupToTab(TaskGroup: IXMLNode; Tab: TdxRibbonTab; OnExecute: TNotifyEvent) ;
    procedure AddTaskToBar(ATask: IXMLNode; Bar: TdxBar; OnExecute: TNotifyEvent) ;
    function  GetTaskLargeImageIndex(ATask: IXMLNode): Integer ;
    function  GetTaskImageIndex(ATask: IXMLNode): Integer ; overload ;
    function  GetTaskImageIndex(ATask: IXMLNode; ImageList: TcxImageList; ImageSize: Integer): Integer ; overload ;
    function  GetControl(ATask: IXMLNode): TObject;
    function  GetTask(AControl: TObject): IXMLNode;
    function  CreateControlForAction(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton ;
    function  CreateButton(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton ;
    function  GetActionImageIndex(Action: ISymphonyPlugInAction; ImageList: TcxImageList; ImageSize: Integer): Integer ; overload ;
    function  GetActionImageIndex(Action: ISymphonyPlugInAction): Integer ; overload ;
    function  GetActionLargeImageIndex(Action: ISymphonyPlugInAction): Integer ;
    function  GetBar(Action: ISymphonyPlugInAction): TdxBar ;
    function  GetRibbonTab(Action: ISymphonyPlugInAction): TdxRibbonTab ;
    function  GetRibbonContext(Action: ISymphonyPlugInAction): TdxRibbonContext ;
    function  GetAction(AControl: TObject): ISymphonyPlugInAction;
    function  FormIncludeRibbon(AForm: TForm): Boolean ;
    function  FindFrame(AForm: TForm): TFrame ;
    function  FindRibbon(AForm: TForm): TdxRibbon ;
    function  FindBarManager(AForm: TForm): TdxBarManager ;
    procedure MergeRibbons(AForm: TForm) ;
    procedure MergeToolBars(AForm: TForm) ;
    procedure CreateClosePlugInControls(Actions: ISymphonyPlugInActionList; OnClosePlugIn: TNotifyEvent) ;
    function  GetControl2(AAction: ISymphonyPlugInAction): TObject;
  public
    { Public declarations }
    function  BuildTasks(UIParent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean ;
    function  BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean ;
    procedure DestroyActions(Actions: ISymphonyPlugInActionList) ;

    function SetContextVisible(AForm: TForm; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AContextName: String; AVisible: Boolean; AActiveTab: Boolean = False): boolean ; overload ;

    procedure MergeUI(AForm: TForm) ;
    procedure UnMergeUI(AForm: TForm) ;

    property Task[AControl: TObject]: IXMLNode read GetTask ;
    property Control[ATask: IXMLNode]: TObject read GetControl ;
    property Action[AControl: TObject]: ISymphonyPlugInAction read GetAction ;
    property Control2[AAction: ISymphonyPlugInAction]: TObject read GetControl2 ;
  end;

  TdxRibbonHUIManager = class(TInterfacedObject, ISymphonyUIManager)
  private
    FdmRHMain: TdmRHMain;
  public
    constructor Create ;
    destructor Destroy ; override ;

    function BuildTasks(Parent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean ;
    function TaskForControl(AControl: TObject): IXMLNode ;
    function ControlForTask(ATask: IXMLNode): TObject ;

    function  BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean ;
    procedure DestroyActions(Actions: ISymphonyPlugInActionList) ;
    function  ActionForControl(AControl: TObject): ISymphonyPlugInAction ;
    function  ControlForAction(AAction: ISymphonyPlugInAction): TObject ;

    procedure MergeUI(AForm: TForm) ;
    procedure UnMergeUI(AForm: TForm) ;

    function SetContextVisible(AForm: TForm; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean ; overload ;
    function SetContextVisible(AContextName: String; AVisible: Boolean): boolean ; overload ;
  end;


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
   RibbonHUIManager: ISymphonyUIManager ;

function PackageDesc: IXMLNode ;
Var
  Doc: IXMLDocument ;
begin
  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  Doc.DocumentElement := Doc.CreateNode('PACKAGEINFO') ;
  Result              := Doc.DocumentElement ;

  Result.ChildValues['CAPTION']     := 'Панели инструментов с множеством вкладок' ;
  Result.ChildValues['HINT']        := 'Каждая группа задач располагается на своей закладке панели инструментов' ;
  Result.ChildValues['PARENTCLASS'] := 'TdxRibbon' ;
end;

function GetUIManager: ISymphonyUIManager ;
begin
  Result  := RibbonHUIManager ;
end;

{ TdmRHMain }
{$REGION 'TdmRHMain'}
procedure TdmRHMain.AddTaskGroupToTab(TaskGroup: IXMLNode; Tab: TdxRibbonTab; OnExecute: TNotifyEvent);
Var
  group: TdxRibbontabGroup ;
  bar: TdxBar ;
  i: Integer ;
  ListNode, Node: IXMLNode ;
begin
  group         := tab.Groups.Add ;
  bar           := FManager.AddToolBar ;
  TdxBarControlAccess(bar.Control).OnMouseDown := RibbonMouseDown ;
  TdxBarControlAccess(bar.Control).OnMouseUp   := RibbonMouseUp ;
  bar.Caption   := TaskGroup.ChildValues['CAPTION'] ;
  group.ToolBar := bar ;
  ListNode      := TaskGroup.ChildNodes.Nodes['CHILDREN'] ;
  for i := 0 to ListNode.ChildNodes.Count - 1 do
  begin
    Node  := ListNode.ChildNodes.Nodes[i] ;
    if Node.ChildValues['ITASKTYPE'] < 0 then
            AddTaskGroupToTab(Node, tab, OnExecute)
    else
            AddTaskToBar(Node, bar, OnExecute);
  end;
end;

procedure TdmRHMain.AddTasksGroup(TaskGroup: IXMLNode; OnExecute: TNotifyEvent);
Var
  tab: TdxRibbonTab ;
  group: TdxRibbontabGroup ;
  bar: TdxBar ;
  i: Integer ;
  ListNode, Node: IXMLNode ;
begin
  tab           := FRibbon.Tabs.Add ;
  tab.Caption   := TaskGroup.ChildValues['CAPTION'] ;
  AddTaskGroupToTab(TaskGroup, tab, OnExecute)
end;

procedure TdmRHMain.AddTaskToBar(ATask: IXMLNode; Bar: TdxBar; OnExecute: TNotifyEvent);
Var
  btn: TdxBarLargeButton ;
  Link: TdxBarItemLink ;
begin
  btn                 := TdxBarLargeButton.Create(FRibbon.Owner);
  btn.Caption         := AsStr(ATask.ChildValues['CAPTION']) ;
  btn.Hint            := AsStr(ATask.ChildValues['HINT'])    ;
  btn.LargeImageIndex := GetTaskLargeImageIndex(ATask) ;
  btn.ImageIndex      := GetTaskImageIndex(ATask) ;
  btn.OnClick         := OnExecute ;
  Link                := Bar.ItemLinks.Add ;
  Link.Item           := btn ;
  FTaskControlMng.AddControl(ATask, btn);
end;

procedure TdmRHMain.BarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
begin
  if (ABar <> nil) and (ABar.Control <> nil) then
  begin
    TdxBarControlAccess(ABar.Control).OnMouseDown := RibbonMouseDown ;
    TdxBarControlAccess(ABar.Control).OnMouseUp   := RibbonMouseUp ;
  end;
end;

function TdmRHMain.BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean;
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

function TdmRHMain.BuildTasks(UIParent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean;
var
  i: Integer;
  Node: IXMLNode ;
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
      if FTaskBar = nil then
      begin
        with FRibbon.Tabs.Add do
        begin
          Caption             := 'Задачи пользователя' ;
          FTaskBar            := FManager.AddToolBar ;
          FtaskBar.Caption    := 'Задачи пользователя' ;
          Groups.Add.ToolBar  := FTaskBar ;
        end;
      end;
      AddTaskToBar(Node, FTaskBar, Events.OnExecute) ;
    end;
  end;
end;

procedure TdmRHMain.CloseApplication(Sender: TObject);
begin
  Application.MainForm.Close ;
end;

procedure TdmRHMain.CopyImages(Source, Dest: TCustomImageList;  var Indexes: TImageIndexes);
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

procedure TdmRHMain.CopyIndexes(Source: TImageIndexes; var Dest: TImageIndexes);
var
  i: Integer;
begin
  for i := Low(Source) to High(Source) do
                                        Dest[i] := Source[i] ;
end;

function TdmRHMain.CreateButton(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton;
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

procedure TdmRHMain.CreateButtonOnMenu(Menu: TdxBarApplicationMenu; Caption: String; ImageIndex: Integer; OnExecute: TNotifyEvent);
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

procedure TdmRHMain.CreateClosePlugInControls(Actions: ISymphonyPlugInActionList; OnClosePlugIn: TNotifyEvent);
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

function TdmRHMain.CreateControlForAction(Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent): TdxBarButton;
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

function TdmRHMain.CreateUIControls(AForm: TForm; Events: TEventList): TdxRibbon;
Var
  RibbonTab: TdxRibbonTab ;
  Menu: TdxBarApplicationMenu ;
  btn: TdxBarButton ;
  mbtn: TdxBarApplicationMenuButton ;
  Link: TdxBarItemLink ;
  bmp: TBitmap ;
  i: Integer ;
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

  FRibbon   := TdxRibbon.Create(AForm);
  FRibbon.Parent      := AForm ;
  FRibbon.BarManager  := FManager ;
//  FRibbon.OnMouseDown := RibbonMouseDown ;
//  FRibbon.OnMouseUp   := RibbonMouseUp ;

  cxilDefs.GetImage(0, FRibbon.ApplicationButton.Glyph);

  Menu            := TdxBarApplicationMenu.Create(FManager.Owner) ;
  Menu.BarManager := FManager ;
  mbtn  := Menu.Buttons.Add ;
  mbtn.Item := TdxBarButton.Create(FManager.Owner);
  mbtn.Item.BarManager  := FManager ;
  mbtn.Item.Caption     := 'Закрыть программу' ;
  mbtn.Item.ImageIndex  := 1 ;
  mbtn.Item.OnClick := CloseApplication ;

  FRibbon.ApplicationButton.Menu  := Menu ;
  CreateButtonOnMenu(Menu, 'Печать',          4, Events.OnPrint ) ;
  CreateButtonOnMenu(Menu, 'Экспорт в Excel', 5, Events.OnExportExcel ) ;
  CreateButtonOnMenu(Menu, 'Параметры',       3, Events.OnEditTuner ) ;
//  CreateButtonOnMenu(Menu, 'Закрыть',         1, CloseApplication ) ;

  with FRibbon.QuickAccessToolbar do
  begin
    Position := qtpAboveRibbon;
    Toolbar := FManager.AddToolBar;
    Toolbar.Visible := True;

  end;

  Result  := FRibbon ;
end;

procedure TdmRHMain.DataModuleCreate(Sender: TObject);
begin
  FManager          := nil ;
  FTaskBar          := nil ;
  FTaskControlMng   := TUITaskControlManager.Create ;
  FActionControlMng := TUISPActionManager.Create ;
end;

procedure TdmRHMain.DataModuleDestroy(Sender: TObject);
begin
  FActionControlMng.Free ;
  FTaskControlMng.Free ;
end;

procedure TdmRHMain.DestroyActions(Actions: ISymphonyPlugInActionList);
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

procedure TdmRHMain.RibbonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//  FShiftCmd := [] ;
end;

function TdmRHMain.FindBarManager(AForm: TForm): TdxBarManager;
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

function TdmRHMain.FindFrame(AForm: TForm): TFrame;
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

function TdmRHMain.FindRibbon(AForm: TForm): TdxRibbon;
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

function TdmRHMain.FormIncludeRibbon(AForm: TForm): Boolean;
begin
  Result  := FindRibbon(AForm) <> nil ;
end;

function TdmRHMain.GetTaskImageIndex(ATask: IXMLNode): Integer;
begin
  Result  := GetTaskImageIndex(ATask, FImgList[0], 16) ;
  if Result < 0 then
                    Result := 0 ;
end;

function TdmRHMain.GetAction(AControl: TObject): ISymphonyPlugInAction;
begin
  Result  := FActionControlMng.Action[AControl] ;
  if Result = nil then
                      Exit ;

  Result.Command.ParamValue['UNIQUE'] := not (ssShift in FShiftCmd)
end;

function TdmRHMain.GetActionImageIndex(Action: ISymphonyPlugInAction): Integer;
begin
  Result  := GetActionImageIndex(Action, FImgList[0], 16) ;
end;

function TdmRHMain.GetActionImageIndex(Action: ISymphonyPlugInAction; ImageList: TcxImageList; ImageSize: Integer): Integer;
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

function TdmRHMain.GetActionLargeImageIndex(Action: ISymphonyPlugInAction): Integer;
begin
  Result  := GetActionImageIndex(Action, FImgList[1], 32) ;
end;

function TdmRHMain.GetBar(Action: ISymphonyPlugInAction): TdxBar;
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
  TdxBarControlAccess(Result.Control).OnMouseUp   := RibbonMouseUp ;

  Tab             := GetRibbonTab(Action) ;
  Tab.Groups.Add.ToolBar  := Result ;
end;

function TdmRHMain.GetControl(ATask: IXMLNode): TObject;
begin
  Result  := FTaskControlMng.Control[ATask] ;
end;

function TdmRHMain.GetControl2(AAction: ISymphonyPlugInAction): TObject;
begin
  Result  := FActionControlMng.Control[AAction] ;
end;

function TdmRHMain.GetRibbonContext(Action: ISymphonyPlugInAction): TdxRibbonContext;
begin
  Result  := FRibbon.Contexts.Find(Action.ContextName) ;
  if Result = nil then
  begin
    Result          := FRibbon.Contexts.Add ;
    Result.Caption  := Action.ContextName ;
    Result.Visible  := True ;
  end;
end;

function TdmRHMain.GetRibbonTab(Action: ISymphonyPlugInAction): TdxRibbonTab;
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
        Result.Caption  := Action.Caption
      else
        Result.Caption  := Action.TabCaption ;
      Result.Context  := GetRibbonContext(Action) ;
    end;
  end;

  FRibbon.ActiveTab := Result ;
end;

function TdmRHMain.GetTask(AControl: TObject): IXMLNode;
begin
  Result  := FTaskControlMng.Task[AControl] ;
  Result.ChildNodes.Nodes['PARAMS'].ChildValues['UNIQUE'] := not (ssShift in FShiftCmd) ;
end;

function TdmRHMain.GetTaskImageIndex(ATask: IXMLNode; ImageList: TcxImageList; ImageSize: Integer): Integer;
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

function TdmRHMain.GetTaskLargeImageIndex(ATask: IXMLNode): Integer;
begin
  Result  := GetTaskImageIndex(ATask, FImgList[1], 32) ;
  if Result < 0 then
                    Result := 0 ;
end;

procedure TdmRHMain.MergeRibbons(AForm: TForm);
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
      if rb.Tabs[i].Groups[j].ToolBar.Visible then
      begin
        group         := tab.Groups.Add ;
        group.ToolBar := rb.Tabs[i].Groups[j].ToolBar ;
      end;
    if tab.Groups.Count = 0 then
    begin
      FRibbon.Tabs.Delete(tab.Index);
      tab.Free ;
    end;
  end;

  Cntx.Visible  := True ;
end;

procedure TdmRHMain.MergeToolBars(AForm: TForm);
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
    if (bm.Bars[i].DockControl = nil) and bm.Bars[i].Visible then
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

{
  if Cntx.TabCount = 0 then
  begin
    tab         := FRibbon.Tabs.Add ;
    tab.Caption := AForm.Caption ;
    tab.Context := Cntx ;
  end
  else tab  := Cntx.Tabs[0] ;}

  for i := 0 to bm.Bars.Count - 1 do
    if (bm.Bars[i].DockControl = nil) and bm.Bars[i].Visible then
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

procedure TdmRHMain.MergeUI(AForm: TForm);
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

procedure TdmRHMain.PreapareUIComponents(UIParent: TComponent; Events: TEventList);
Var
  frm: TForm ;
  rbn: TdxRibbon ;
begin
  if UIParent is TdxRibbon then
                              SetUIFields(UIParent as TdxRibbon)
  else if (UIParent is TForm) and FormIncludeRibbon(TForm(UIParent)) then
                              SetUIFields(FindRibbon(TForm(UIParent)))
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

procedure TdmRHMain.RibbonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FShiftCmd := Shift ;
end;

function TdmRHMain.SetContextVisible(AForm: TForm; AVisible: Boolean): boolean;
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

function TdmRHMain.SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean;
begin
  Result  := SetContextVisible(AAction.ContextName, AVisible) ;
end;

function TdmRHMain.SetContextVisible(AContextName: String; AVisible: Boolean; AActiveTab: Boolean = False): boolean;
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

procedure TdmRHMain.SetUIFields(Ribbon: TdxRibbon);
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

procedure TdmRHMain.UnMergeUI(AForm: TForm);
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

{ TdxRibbonHUIManager }

function TdxRibbonHUIManager.ActionForControl(AControl: TObject): ISymphonyPlugInAction;
begin
  Result  := FdmRHMain.Action[AControl] ;
end;

function TdxRibbonHUIManager.BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean;
begin
  Result  := FdmRHMain.BuildActions(Parent, Actions, Events) ;
end;

function TdxRibbonHUIManager.BuildTasks(Parent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean;
begin
  Result  := FdmRHMain.BuildTasks(Parent, Tasks, Events) ;
end;

function TdxRibbonHUIManager.ControlForAction(AAction: ISymphonyPlugInAction): TObject;
begin

end;

function TdxRibbonHUIManager.ControlForTask(ATask: IXMLNode): TObject;
begin
  Result  := FdmRHMain.Control[ATask] ;
end;

constructor TdxRibbonHUIManager.Create;
begin
  FdmRHMain := TdmRHMain.Create(Application);
end;

destructor TdxRibbonHUIManager.Destroy;
begin
  FdmRHMain.Free ;
  inherited;
end;

procedure TdxRibbonHUIManager.DestroyActions(Actions: ISymphonyPlugInActionList);
begin
  FdmRHMain.DestroyActions(Actions);
end;

procedure TdxRibbonHUIManager.MergeUI(AForm: TForm);
begin
  FdmRHMain.MergeUI(AForm) ;
end;

function TdxRibbonHUIManager.SetContextVisible(AForm: TForm; AVisible: Boolean): boolean;
begin
  Result  := FdmRHMain.SetContextVisible(AForm, AVisible) ;
end;

function TdxRibbonHUIManager.SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean;
begin
  Result  := FdmRHMain.SetContextVisible(AAction, AVisible) ;
end;

function TdxRibbonHUIManager.SetContextVisible(AContextName: String; AVisible: Boolean): boolean;
begin
  Result := FdmRHMain.SetContextVisible(AContextName, AVisible) ;
end;

function TdxRibbonHUIManager.TaskForControl(AControl: TObject): IXMLNode;
begin
  Result  := FdmRHMain.Task[AControl] ;
end;

procedure TdxRibbonHUIManager.UnMergeUI(AForm: TForm);
begin
  FdmRHMain.UnMergeUI(AForm);
end;

initialization
  RibbonHUIManager  := TdxRibbonHUIManager.Create ;
finalization
  RibbonHUIManager  := nil ;
end.
