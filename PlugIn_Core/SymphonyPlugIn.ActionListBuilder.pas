unit SymphonyPlugIn.ActionListBuilder;

interface

uses System.Classes, Vcl.Controls, Vcl.ImgList, SymphonyPlugIn.ActionInterface ;

Type
  TsmplParam = class(TCollectionItem)
  private
    FName: String;
    FValue: String;
    procedure SetName(const Value: String);
    procedure SetValue(const Value: String);
  protected
    function GetDisplayName: string; override ;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Name: String  read FName write SetName;
    property Value: String  read FValue write SetValue;
  end;

  TsmplParamCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TsmplParam;
    procedure SetItem(Index: Integer; const Value: TsmplParam);
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
    function Add: TsmplParam;
    property Items[Index: Integer]: TsmplParam read GetItem write SetItem; default;
  end;

  TcmplCommand = class(TPersistent)
  private
    FParam: TsmplParamCollection;
    FCommand: String;
    procedure ReadParams(Reader:TReader);
    procedure WriteParams(Writer:TWriter);
    procedure SetCommand(const Value: String);
    procedure SetParam(const Value: TsmplParamCollection);
  protected
    procedure DefineProperties(Filer: TFiler); override ;
  public
    constructor Create;
    destructor Destroy ; override ;
  published
    property Command: String  read FCommand write SetCommand;
    property Param: TsmplParamCollection  read FParam write SetParam;
  end;

  TsmplAction = class(TCollectionItem)
  private
    FName: String;
    FMethodName: String;
    FBeginGroup: Boolean;
    FFrameClassName: String;
    FBar: String;
    FContextName: String;
    FVisible: Boolean;

    FCaption: String;
    FCommand: String;
    FAutoStart: Boolean;
    FTabIndex: Integer;
    FTabCaption: String;
    FImageIndex: Integer;
    FParams: TsmplParamCollection;
    FFormCaption: String;
    procedure SetAutoStart(const Value: Boolean);
    procedure SetBar(const Value: String);
    procedure SetBeginGroup(const Value: Boolean);
    procedure SetCaption(const Value: String);
    procedure SetCommand(const Value: String);
    procedure SetContextName(const Value: String);
    procedure SetFrameClassName(const Value: String);

    procedure SetMethodName(const Value: String);
    procedure SetName(const Value: String);
    procedure SetTabCaption(const Value: String);
    procedure SetTabIndex(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetImageIndex(const Value: Integer);
    procedure ReadParams(Reader:TReader);
    procedure WriteParams(Writer:TWriter);
    procedure SetParams(const Value: TsmplParamCollection);
    procedure SetFormCaption(const Value: String);
  protected
    procedure DefineProperties(Filer: TFiler); override ;
    function GetDisplayName: string; override ;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property AutoStart: Boolean  read FAutoStart write SetAutoStart default False;
    property Bar: String  read FBar write SetBar ;
    property BeginGroup: Boolean  read FBeginGroup write SetBeginGroup default False;
    property Caption: String  read FCaption write SetCaption ;
    property Command: String  read FCommand write SetCommand ;
    property ContextName: String   read FContextName write SetContextName ;
    property FormCaption: String  read FFormCaption write SetFormCaption;
    property FrameClassName: String   read FFrameClassName write SetFrameClassName ;
    property ImageIndex: Integer  read FImageIndex write SetImageIndex default -1;
    property MethodName: String   read FMethodName write SetMethodName ;
    property Name: String   read FName write SetName;
    property Params: TsmplParamCollection  read FParams write SetParams;
    property TabCaption: String   read FTabCaption write SetTabCaption ;
    property TabIndex: Integer  read FTabIndex write SetTabIndex default 0;
    property Visible: Boolean  read FVisible write SetVisible default True;
  end;


  TsmplActionList = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TsmplAction;
    procedure SetItem(Index: Integer; const Value: TsmplAction);
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
    function Add: TsmplAction;
    property Items[Index: Integer]: TsmplAction read GetItem write SetItem; default;
  end;


  TsmplImageList = class(TCollectionItem)
  private
    FImageList: TCustomImageList;
    procedure SetImageList(const Value: TCustomImageList);
  protected
    function GetDisplayName: string; override ;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property ImageList: TCustomImageList  read FImageList write SetImageList;
  end;


  TsmplImagesCollection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TsmplImageList;
    procedure SetItem(Index: Integer; const Value: TsmplImageList);
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
    function Add: TsmplImageList;
    property Items[Index: Integer]: TsmplImageList read GetItem write SetItem; default;
  end;

  TActionListBuilder = class(TComponent)
  private
    FActions: TsmplActionList;
    FCaption: String;
    FImages: TsmplImagesCollection;
    procedure SetActions(const Value: TsmplActionList);
    procedure SetCaption(const Value: String);
    procedure ReadActions(Reader:TReader);
    procedure WriteActions(Writer:TWriter);
    procedure ReadImages(Reader:TReader);
    procedure WriteImages(Writer:TWriter);
    procedure SetImages(const Value: TsmplImagesCollection);
  protected
    procedure DefineProperties(Filer: TFiler); override ;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetActionList: ISymphonyPlugInActionList ;
  published
    property Actions: TsmplActionList  read FActions write SetActions;
    property Caption: String  read FCaption write SetCaption;
    property Images: TsmplImagesCollection  read FImages write SetImages;
  end;

procedure Register;

implementation

Uses SysUtils, vcl.Dialogs, VCL.Graphics, SymphonyPlugIn.ActionImpl ;

Const
  PropQuestionMethodName = 'Допускается указание или имени класса фрейма (FrameClassName) или имени метода (MethodName). Очистить значение имени класса фрейма?' ;
  PropQuestionFrameClassName = 'Допускается указание или имени класса фрейма (FrameClassName) или имени метода (MethodName). Очистить значение имени метода?' ;

procedure Register;
begin
  RegisterComponents('Symphony', [TActionListBuilder]);
end;

{ TsmplParam }
{$REGION 'TsmplParam'}
procedure TsmplParam.Assign(Source: TPersistent);
begin
  inherited;
  Name  := TsmplParam(Source).Name ;
  Value := TsmplParam(Source).Value ;
end;

function TsmplParam.GetDisplayName: string;
begin
  Result  := Format('%s  = %s', [Name, Value]) ;
end;

procedure TsmplParam.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TsmplParam.SetValue(const Value: String);
begin
  FValue := Value;
end;

{$ENDREGION}

{ TsmplParamCollection }
{$REGION 'TsmplParamCollection'}
function TsmplParamCollection.Add: TsmplParam;
begin
  Result  := TsmplParam(inherited Add) ;
end;

procedure TsmplParamCollection.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

constructor TsmplParamCollection.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  inherited Create(AOwner, ItemClass) ;
end;

function TsmplParamCollection.GetItem(Index: Integer): TsmplParam;
begin
  Result  := TsmplParam(inherited Items[Index]) ;
end;

procedure TsmplParamCollection.SetItem(Index: Integer; const Value: TsmplParam);
begin
  TsmplParam(inherited Items[Index]).Assign(Value);
end;

{$ENDREGION}

{ TcmplCommand }
{$REGION ''}
constructor TcmplCommand.Create;
begin
  FParam  := TsmplParamCollection.Create(Self, TsmplParam);
end;

procedure TcmplCommand.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  // Определить методы сохранения свойства Param в файл формы
  Filer.DefineProperty('Param', ReadParams, WriteParams, True);
end;

destructor TcmplCommand.Destroy;
begin
  FParam.Free ;
  inherited;
end;

procedure TcmplCommand.ReadParams(Reader: TReader);
begin
  Reader.ReadCollection(FParam);
end;

procedure TcmplCommand.SetCommand(const Value: String);
begin
  FCommand := Value;
end;

procedure TcmplCommand.SetParam(const Value: TsmplParamCollection);
begin
  FParam.Assign(Value);
end;

procedure TcmplCommand.WriteParams(Writer: TWriter);
begin
  Writer.WriteCollection(FParam);
end;

{$ENDREGION}

{ TsmplAction }
{$REGION 'TsmplAction'}
procedure TsmplAction.Assign(Source: TPersistent);
Var
  act: TsmplAction ;
begin
  inherited;
  act := Source as TsmplAction ;
  AutoStart       := act.AutoStart ;
  Bar             := act.Bar ;
  BeginGroup      := act.BeginGroup ;
  Caption         := act.Caption ;
  Command         := act.Command ;
  ContextName     := act.ContextName ;
  FrameClassName  := act.FrameClassName ;
  ImageIndex       := act.ImageIndex ;
  MethodName      := act.MethodName ;
  Name            := act.Name ;
  TabCaption      := act.TabCaption ;
  TabIndex        := act.TabIndex ;
  Visible         := act.Visible ;
  Params.Assign(act.Params);
end;

constructor TsmplAction.Create(Collection: TCollection);
begin
  inherited Create(Collection) ;
  FParams   := TsmplParamCollection.Create(Self, TsmplParam) ;
  Visible   := True ;
  ImageIndex := -1 ;
end;

procedure TsmplAction.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  // Определить методы сохранения свойства Params в файл формы
  Filer.DefineProperty('Params', ReadParams, WriteParams, True);

end;

destructor TsmplAction.Destroy;
begin
  FParams.Free ;
  inherited;
end;

function TsmplAction.GetDisplayName: string;
begin
  Result  := Format('%s  (%s)', [Name, Caption])
end;

procedure TsmplAction.ReadParams(Reader: TReader);
begin
  Reader.ReadCollection(FParams);
end;

procedure TsmplAction.SetAutoStart(const Value: Boolean);
begin
  FAutoStart := Value;
end;

procedure TsmplAction.SetBar(const Value: String);
begin
  FBar := Value;
end;

procedure TsmplAction.SetBeginGroup(const Value: Boolean);
begin
  FBeginGroup := Value;
end;

procedure TsmplAction.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TsmplAction.SetCommand(const Value: String);
begin
  FCommand := Value;
end;

procedure TsmplAction.SetContextName(const Value: String);
begin
  FContextName := Value;
end;

procedure TsmplAction.SetFormCaption(const Value: String);
begin
  FFormCaption := Value;
end;

procedure TsmplAction.SetFrameClassName(const Value: String);
begin
  if (FrameClassName <> EmptyStr) and (Value <> EmptyStr) then
  begin
    if MessageDlg(PropQuestionFrameClassName, mtWarning, mbYesNo, 0) = mrYes then
                                                 FMethodName := EmptyStr
    else
        FFrameClassName := EmptyStr ;
  end
  else
      FFrameClassName := Value;

  if (Name = EmptyStr) and (FFrameClassName <> EmptyStr) then
                                            Name  := 'frm' + FFrameClassName ;
end;

procedure TsmplAction.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

procedure TsmplAction.SetMethodName(const Value: String);
begin
  if (FrameClassName <> EmptyStr) and (Value <> EmptyStr) then
  begin
    if MessageDlg(PropQuestionMethodName, mtWarning, mbYesNo, 0) = mrYes then
                                                 FFrameClassName := EmptyStr
    else
        FMethodName := EmptyStr ;
  end
  else
      FMethodName := Value;

  if (Name = EmptyStr) and (FMethodName <> EmptyStr) then
                                                  Name  := 'mtd' + FMethodName ;
end;

procedure TsmplAction.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TsmplAction.SetParams(const Value: TsmplParamCollection);
begin
  FParams := Value;
end;

procedure TsmplAction.SetTabCaption(const Value: String);
begin
  FTabCaption := Value;
end;

procedure TsmplAction.SetTabIndex(const Value: Integer);
begin
  FTabIndex := Value;
end;

procedure TsmplAction.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
end;

procedure TsmplAction.WriteParams(Writer: TWriter);
begin
  Writer.WriteCollection(FParams);
end;

{$ENDREGION}

{ TsmplActionList }
{$REGION 'TsmplActionList'}
function TsmplActionList.Add: TsmplAction;
begin
  Result  := TsmplAction(inherited Add) ;
end;

constructor TsmplActionList.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  inherited Create(AOwner, ItemClass) ;
end;

function TsmplActionList.GetItem(Index: Integer): TsmplAction;
begin
  Result  := TsmplAction(inherited Items[Index]) ;
end;

procedure TsmplActionList.SetItem(Index: Integer; const Value: TsmplAction);
begin
  TsmplAction(inherited Items[Index]).Assign(Value);
end;

{$ENDREGION}

{ TActionListBuilder }
{$REGION 'TActionListBuilder'}
constructor TActionListBuilder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActions  := TsmplActionList.Create(Self, TsmplAction);
  FImages   := TsmplImagesCollection.Create(Self, TsmplImageList);
end;

procedure TActionListBuilder.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  // Определить методы сохранения свойства Actions в файл формы
  Filer.DefineProperty('Actions', ReadActions, WriteActions, True);
  Filer.DefineProperty('Images', ReadImages, WriteImages, True);
end;

destructor TActionListBuilder.Destroy;
begin
  FActions.Free ;
  FImages.Free ;
  inherited;
end;

function TActionListBuilder.GetActionList: ISymphonyPlugInActionList;
Var
  i, j: Integer ;
  al: TSymphonyPlugInActionList ;
  act: TSymphonyPlugInAction ;
  smplAct: TsmplAction ;
  bmp: TBitmap ;
  il: TCustomImageList ;
begin
  al  := TSymphonyPlugInActionList.Create ;
  al.Caption  := Caption ;

  for i := 0 to FActions.Count - 1 do
  begin
    smplAct := FActions.Items[i] ;

    act                 := al.AddAction ;
    act.AutoStart       := smplAct.AutoStart ;
    act.Bar             := smplAct.Bar ;
    act.BeginGroup      := smplAct.BeginGroup ;
    act.Caption         := smplAct.Caption ;
    act.ContextName     := smplAct.ContextName ;
    act.FormCaption     := smplAct.FormCaption ;
    act.FrameClassName  := smplAct.FrameClassName ;
    act.PlugInMethodName:= smplAct.MethodName ;
    act.Name            := smplAct.Name ;
    act.TabCaption      := smplAct.TabCaption ;
    act.TabIndex        := smplAct.TabIndex ;
    act.Visible         := smplAct.Visible ;

    for j := 0 to Images.Count - 1 do
    begin
      il  := Images.Items[j].ImageList ;
      if smplAct.ImageIndex < il.Count then
      begin
        bmp := TBitmap.Create ;
        il.GetBitmap(smplAct.ImageIndex, bmp) ;
        act.AddActionIcon(bmp);
      end;
    end;
    //ImageList.GetIcon(smplAct.ItemIndex, act.Icon);

    act.Command.Command := smplAct.Command ;
    for j := 0 to smplAct.Params.Count - 1 do
    begin
      act.Command.AddParam(smplAct.Params[j].Name, smplAct.Params[j].Value) ;
    end;
  end;

  Result  := al ;
end;

procedure TActionListBuilder.ReadActions(Reader: TReader);
begin
  Reader.ReadCollection(FActions);
end;

procedure TActionListBuilder.ReadImages(Reader: TReader);
begin
  Reader.ReadCollection(FImages);
end;

procedure TActionListBuilder.SetActions(const Value: TsmplActionList);
begin
  FActions.Assign(Value) ;
end;

procedure TActionListBuilder.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TActionListBuilder.SetImages(const Value: TsmplImagesCollection);
begin
  FImages := Value;
end;

procedure TActionListBuilder.WriteActions(Writer: TWriter);
begin
  Writer.WriteCollection(FActions);
end;

procedure TActionListBuilder.WriteImages(Writer: TWriter);
begin
  Writer.WriteCollection(FImages);
end;

{$ENDREGION}

{ TsmplImageList }
{$REGION 'TsmplImageList'}
procedure TsmplImageList.Assign(Source: TPersistent);
begin
  inherited;
  ImageList := (Source as TsmplImageList).ImageList ;
end;

function TsmplImageList.GetDisplayName: string;
begin
  if ImageList = nil then Result  := 'Не определен'
  else Result := Format('%s  (Размер: %dх%d px)',
                          [ImageList.Name, ImageList.Width, ImageList.Height]) ;
end;

procedure TsmplImageList.SetImageList(const Value: TCustomImageList);
begin
  FImageList := Value;
end;

{$ENDREGION}

{ TsmplImagesCollection }
{$REGION 'TsmplImagesCollection'}
function TsmplImagesCollection.Add: TsmplImageList;
begin
  Result  := TsmplImageList(inherited Add) ;
end;

procedure TsmplImagesCollection.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

constructor TsmplImagesCollection.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  inherited Create(AOwner, ItemClass) ;
end;

function TsmplImagesCollection.GetItem(Index: Integer): TsmplImageList;
begin
  Result  := TsmplImageList(inherited Items[Index]) ;
end;

procedure TsmplImagesCollection.SetItem(Index: Integer; const Value: TsmplImageList);
begin
  TsmplImageList(inherited Items[Index]).Assign(Value);
end;

{$ENDREGION}

end.
