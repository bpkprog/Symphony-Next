unit stbCatBut.MainUnit;

interface

uses System.Classes, XML.XMLIntf, Vcl.Controls, VCL.Graphics, VCL.Forms,
     VCL.CategoryButtons,
     UITaskContolManager, UISPActionManager, SymphonyPlugIn.ActionInterface,
     stbIntf.MainUnit  ;

Type
  TCategoryButtonUIManager = class(TInterfacedObject, ISymphonyUIManager)
  private
    FTaskControlManager: TUITaskControlManager ;
    FActionControlManager: TUISPActionManager ;
    FActionExecute: TNotifyEvent ;

    function  GetCategoryButtons(Parent: TComponent): TCategoryButtons ;
    function  GetImageIndex(Images: TImageList; Task: IXMLNode): Integer ;
    procedure AddButton(Category: TButtonCategory; Task: IXMLNode; onExecute: TNotifyEvent) ;
    procedure AddCategory(catbat: TCategoryButtons ; Tasks: IXMLNode; OnExecute: TNotifyEvent) ;
    function  GetLeastImage(Action: ISymphonyPlugInAction): TBitmap ;
    procedure CreateActionButton(CategoryBtns: TCategoryButtons; Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent) ;
  public
    constructor Create ;
    destructor Destroy ; override ;

    function  BuildTasks(Parent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean ;
    function  TaskForControl(AControl: TObject): IXMLNode ;
    function  ControlForTask(ATask: IXMLNode): TObject ;

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

uses System.SysUtils,
     XML.XMLDoc, iexBitmaps, IdCoderMIME, XMLValUtil,
     Vcl.ImgList ;

Var
  CategoryButtonUIManager: ISymphonyUIManager ;

function PackageDesc: IXMLNode ;
Var
  Doc: IXMLDocument ;
begin
  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  Doc.DocumentElement := Doc.CreateNode('PACKAGEINFO') ;
  Result              := Doc.DocumentElement ;

  Result.ChildValues['CAPTION']     := 'Боковая панель с кнопками' ;
  Result.ChildValues['HINT']        := 'Боковая панель с кнопками' ;
  Result.ChildValues['PARENTCLASS'] := 'TCategoryButtons' ;
end;

function GetUIManager: ISymphonyUIManager ;
begin
  Result  := CategoryButtonUIManager ;
end;

{ TCategoryButtonUIManager }

function TCategoryButtonUIManager.ActionForControl(AControl: TObject): ISymphonyPlugInAction;
Var
  catbat: TCategoryButtons ;
begin
  if AControl is TCategoryButtons then
  begin
    catbat  := TCategoryButtons(AControl) ;
    Result  := FActionControlManager.Action[catbat.FocusedItem]
  end
  else
      Result  := FActionControlManager.Action[AControl] ;
end;

procedure TCategoryButtonUIManager.AddButton(Category: TButtonCategory;  Task: IXMLNode; onExecute: TNotifyEvent);
Var
  btn: TButtonItem ;
begin
  btn             := Category.Items.Add ;
  btn.Caption     := AsStr(Task.ChildValues['CAPTION']) ;
  btn.Hint        := AsStr(Task.ChildValues['HINT']) ;
  btn.OnClick     := onExecute ;
  btn.ImageIndex  := GetImageIndex(Category.CategoryButtons.Images as TImageList, Task) ;

  FTaskControlManager.AddControl(Task, btn);
end;

procedure TCategoryButtonUIManager.AddCategory(catbat: TCategoryButtons; Tasks: IXMLNode; OnExecute: TNotifyEvent);
Var
  ctg: TButtonCategory ;
  Child, Node: IXMLNode ;
  i: Integer ;
begin
  ctg             := catbat.Categories.Add ;
  ctg.Caption     := AsStr(Tasks.ChildValues['CAPTION']) ;

  Child := Tasks.ChildNodes.Nodes['CHILDREN'] ;
  for i := 0 to Child.ChildNodes.Count - 1 do
  begin
    Node  := Child.ChildNodes.Nodes[i] ;
    if AsInt(Node.ChildValues['ITASKTYPE']) < 0 then
        AddCategory(catbat, Node, OnExecute)
    else
        AddButton(ctg, Node, onExecute) ;
  end;
end;

function TCategoryButtonUIManager.BuildActions(Parent: TComponent; Actions: ISymphonyPlugInActionList; Events: TEventList): Boolean;
Var
  catbat: TCategoryButtons ;
  imglist: TImageList ;
  act: ISymphonyPlugInAction ;
  cat: TButtonCategory ;
  btn: TButtonItem ;
  bmp: TBitmap ;
  Index: Integer ;
  i: Integer;
begin
  FActionExecute  := Events.OnExecute ;
  catbat          := GetCategoryButtons(Parent) ;
  imglist         := catbat.Images as TImageList;

  if imglist = nil then
  begin
    imglist := TImageList.Create(catbat.Owner);
    imglist.Height  := 16 ;
    imglist.Width   := 16 ;
    catbat.Images   := imglist ;
  end;

  for i := 0 to Actions.Count - 1 do
  begin
    act   := Actions.Action[i] ;
    if not act.Visible then
      // Добавляем акцию без контрола. Акция скорее всего хранит форму,
      // по которой будет управляться видимость остальных акций
        FActionControlManager.AddControl(act, nil)
    else
      // Акция видна, создаем контрол
        CreateActionButton(catbat, act, Events.OnExecute) ;
  end;
end;

function TCategoryButtonUIManager.BuildTasks(Parent: TComponent; Tasks: IXMLNode; Events: TEventList): Boolean;
Var
  catbat: TCategoryButtons ;
  imglist: TImageList ;
  Node: IXMLNode ;
  i: Integer;
begin
  catbat  := GetCategoryButtons(Parent) ;
  imglist := catbat.Images as TImageList;

  if imglist = nil then
  begin
    imglist := TImageList.Create(catbat.Owner);
    imglist.Height  := 16 ;
    imglist.Width   := 16 ;
    catbat.Images   := imglist ;
  end;

  for i := 0 to Tasks.ChildNodes.Count - 1 do
  begin
    Node  := Tasks.ChildNodes.Nodes[i] ;
    if AsInt(Node.ChildValues['ITASKTYPE']) < 0 then
        AddCategory(catbat, Node, Events.OnExecute)
    else
        AddButton(catbat.Categories[0], Node, Events.onExecute) ;
  end;

  catbat.Categories[0].Index  := catbat.Categories.Count - 1 ;

  Result:= True ;
end;

function TCategoryButtonUIManager.ControlForAction(AAction: ISymphonyPlugInAction): TObject;
begin
  Result  := FActionControlManager.Control[AAction] ;
end;

function TCategoryButtonUIManager.ControlForTask(ATask: IXMLNode): TObject;
begin
  Result  := FTaskControlManager.Control[ATask] ;
end;

constructor TCategoryButtonUIManager.Create;
begin
  FTaskControlManager   := TUITaskControlManager.Create ;
  FActionControlManager := TUISPActionManager.Create ;
end;

procedure TCategoryButtonUIManager.CreateActionButton(CategoryBtns: TCategoryButtons; Action: ISymphonyPlugInAction; OnExecute: TNotifyEvent);
Var
  ac: TUISPActionControl ;
  imglist: TImageList ;
  cat: TButtonCategory ;
  btn: TButtonItem ;
  bmp: TBitmap ;
  Index: Integer ;
begin
  if not Action.Visible then
                            Exit ;

  // Определяемся с элементом Action - Control
  ac    := nil ;
  Index := FActionControlManager.IndexByAction(Action) ;
  if Index > -1 then
      ac  := FActionControlManager.Items[Index] ;

  imglist         := CategoryBtns.Images as TImageList;

  Index := CategoryBtns.Categories.IndexOf(Action.Bar) ;
  if Index < 0 then
  begin
    cat := CategoryBtns.Categories.Insert(0) ;
    cat.Caption := Action.Bar ;
  end
  else cat  := CategoryBtns.Categories[Index] ;

  btn             := cat.Items.Add ;
  btn.Caption     := Action.Caption  ;
  btn.Hint        := Action.Caption  ;
  btn.OnClick     := onExecute ;

  // Если акция уже была с контролом, то её изображение уже загружено
  if ac = nil then
  begin
    bmp             := GetLeastImage(Action) ;
    if bmp = nil then btn.ImageIndex := -1
    else
      btn.ImageIndex  := imglist.Add(bmp, nil) ;
  end
  else
    btn.ImageIndex  := ac.ImageIndex ;

  // Если акция грузится впервые, то сохраняем её в списке менеджера
  if ac = nil then
  begin
    Index := FActionControlManager.AddControl(Action, btn);
    FActionControlManager.Items[Index].ImageIndex := btn.ImageIndex ;
  end
  else
      ac.Control  := btn ;
end;

destructor TCategoryButtonUIManager.Destroy;
begin
  FTaskControlManager.Free ;
  FActionControlManager.Free ;
  inherited;
end;

procedure TCategoryButtonUIManager.DestroyActions(Actions: ISymphonyPlugInActionList);
var
  i: Integer;
begin
  for i := Actions.Count - 1 to 0 do
                                    SetContextVisible(Actions.Action[i], False) ;
end;

{Возвращаем компонет TCategoryButton, на котором будем строить кнопки для задач и акций
 Ищем в порядке:
      1. проверяем, вдруг нам уже передали TCategoryButton
      2. Если нам передан TWinControl, ищем на нем TCategoryButton
      3. Если нам ничего не передали, ищем на главном окне приложения
      4. Если нигде ничего не нашли, создаем сами TCategoryButton на Parent или главном окне приложения}
function TCategoryButtonUIManager.GetCategoryButtons(Parent: TComponent): TCategoryButtons;
Var
  i: Integer ;
  Container: TWinControl ;
begin
  Result:= nil ;
  if Parent is TCategoryButtons then
  begin
    Result  := Parent as TCategoryButtons ;
    Exit ;
  end;

  if (Parent <> nil) and (Parent is TWinControl) then
        Container := Parent as TWinControl
  else  Container  := Application.MainForm ;

  for i := 0 to Container.ComponentCount - 1 do
    if Container.Components[i] is TCategoryButtons then
    begin
      Result  := Container.Components[i] as TCategoryButtons ;
      Exit ;
    end;

  Result := TCategoryButtons.Create(Container);
  Result.Parent := Container ;
  Result.Align  := alLeft ;
  Result.Width  := 250 ;
  Result.Visible:= True ;

  Result.ButtonOptions  := Result.ButtonOptions + [boFullSize, boBoldCaptions, boCaptionOnlyBorder] - [boVerticalCategoryCaptions] ;
//  Result.ButtonOptions  := Result.ButtonOptions - [boVerticalCategoryCaptions] ;
  Result.Categories.Add.Caption := 'Задачи пользователя' ;
end;

function TCategoryButtonUIManager.GetImageIndex(Images: TImageList; Task: IXMLNode): Integer;
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
    IcoList := Task.ChildNodes.Nodes['ICONS'] ;
    for i := 0 to IcoList.ChildNodes.Count - 1 do
    begin
      Ico := IcoList.ChildNodes.Nodes[i] ;
      if AsInt(Ico.ChildValues['SIZE']) = Images.Width then
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

        Result  := Images.AddMasked(bmp.VclBitmap, bmp.VclBitmap.Canvas.Pixels[0, 0]) ;
        Break ;
      end;
    end;
  Finally
    bmp.Free ;
  End;
end;

function TCategoryButtonUIManager.GetLeastImage(Action: ISymphonyPlugInAction): TBitmap;
Var
  i: Integer ;
  MinSize: Integer ;
begin
  Result:= nil ;
  if Action.IconCount = 0 then
                              Exit ;
  Result  := Action.Icon[0] ;
  MinSize := Result.Width ;
  for i := 1 to Action.IconCount - 1 do
    if Action.Icon[i].Width < MinSize then
    begin
      Result  := Action.Icon[i] ;
      MinSize := Result.Width ;
    end;
end;

procedure TCategoryButtonUIManager.MergeUI(AForm: TForm);
begin
  {Данный вид пакетов не поддерживает объединений интерфейсов главного и дочерних окон}
end;

function TCategoryButtonUIManager.SetContextVisible(AForm: TForm; AVisible: Boolean): boolean;
Var
  i: Integer ;
  Index: Integer ;
begin
  for i := 0 to FActionControlManager.Count - 1 do
    with FActionControlManager.Items[i].Action do
    begin
      Index := Forms.IndexOf(AForm) ;
      if Index >= 0 then
        SetContextVisible(ContextName, AVisible) ;
    end;
end;

function TCategoryButtonUIManager.SetContextVisible(AAction: ISymphonyPlugInAction; AVisible: Boolean): boolean;
Var
  i: Integer ;
  ac: TUISPActionControl ;
  Index: Integer ;
  catbat: TCategoryButtons ;
  cat: TButtonCategory ;
  btn: TButtonItem ;
begin
  Result  := False ;
  ac      := nil ;

  if not AVisible then
  begin
    // Кнопки не видимыми делать не можем. Только удалять
//    repeat
      Index   := FActionControlManager.IndexByAction(AAction) ;
      if Index > -1 then
                        ac      := FActionControlManager.Items[Index] ;

      if (ac <> nil) and (ac.Control <> nil) then
      begin
        btn     := ac.Control as TButtonItem ;

        cat     := btn.Category ;
        catbat  := cat.CategoryButtons ;

        cat.Items.Delete(btn.Index);
        if cat.Items.Count = 0 then
                                  catbat.Categories.Delete(cat.Index);
        ac.Control  := nil ;
      end;
//    until Index < 0;
  end
  else
  begin
    Index   := FActionControlManager.IndexByAction(AAction) ;
    if Index > -1 then
                      ac      := FActionControlManager.Items[Index] ;
    if (ac = nil) or (ac.Control = nil) then
        CreateActionButton(GetCategoryButtons(nil), AAction, FActionExecute);
  end;

  Result:= True ;
end;

function TCategoryButtonUIManager.SetContextVisible(AContextName: String; AVisible: Boolean): boolean;
var
  i: Integer;
begin
  Result  := False ;

  for i := 0 to FActionControlManager.Count - 1 do
    if Uppercase(FActionControlManager.Items[i].Action.ContextName) = Uppercase(AContextName) then
              SetContextVisible(FActionControlManager.Items[i].Action, AVisible) ;
  Result  := True ;
end;

function TCategoryButtonUIManager.TaskForControl(AControl: TObject): IXMLNode;
Var
  catbat: TCategoryButtons ;
begin
  if AControl is TCategoryButtons then
  begin
    catbat  := TCategoryButtons(AControl) ;
    Result  := FTaskControlManager.Task[catbat.FocusedItem]
  end
  else
        Result  := FTaskControlManager.Task[AControl] ;
end;

procedure TCategoryButtonUIManager.UnMergeUI(AForm: TForm);
begin

end;

initialization
  CategoryButtonUIManager := TCategoryButtonUIManager.Create ;
finalization
  CategoryButtonUIManager := nil ;
end.
