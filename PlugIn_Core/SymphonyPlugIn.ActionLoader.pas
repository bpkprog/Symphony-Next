unit SymphonyPlugIn.ActionLoader;

interface

uses System.Classes, vcl.forms {dxBar, dxRibbon}, SymphonyPlugIn.ActionInterface ;

Type
  TPlugInActionLoader = class
  private
    FActList: TInterfaceList ;
{    FRibbon: TdxRibbon;
    FBarManager: TdxBarManager;
    procedure SetBarManager(const Value: TdxBarManager);
    procedure SetRibbon(const Value: TdxRibbon);
    procedure LoadAction(Action: ISymphonyPlugInAction) ;  }
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;

    procedure Execute(APkgHandle: NativeUInt) ;
//  published
{    property BarManager: TdxBarManager  read FBarManager write SetBarManager;
    property Ribbon: TdxRibbon  read FRibbon write SetRibbon;  }
  end;

implementation

uses WinAPI.Windows, Vcl.Controls;

{ TPlugInActionLoader }

constructor TPlugInActionLoader.Create(AOwner: TComponent);
begin
//  inherited Create(AOwner) ;
  FActList  := TInterfaceList.Create ;
end;

destructor TPlugInActionLoader.Destroy;
begin
  FActList.Free ;
  inherited;
end;

procedure TPlugInActionLoader.Execute(APkgHandle: NativeUInt);
Var
//  fn: TSymphonyPlugInActionListProc ;
//  ActList: ISymphonyPlugInActionList ;
  i: Integer ;
begin
//  if (APkgHandle = 0) or (BarManager = nil)  then
                                                 Exit ;
{  fn  := GetProcAddress(APkgHandle, 'GetActionList') ;
  if not Assigned(fn) then
                          Exit ;
  ActList  := fn ;
  for i := 0 to ActList.Count - 1 do
  begin
    LoadAction(ActList.Action[i]) ;
  end;  }
end;

{
procedure TPlugInActionLoader.LoadAction(Action: ISymphonyPlugInAction);
Var
  ImgList: TImageList ;
begin
  ImgList := bar
end;

procedure TPlugInActionLoader.SetBarManager(const Value: TdxBarManager);
begin
  FBarManager := Value;
end;

procedure TPlugInActionLoader.SetRibbon(const Value: TdxRibbon);
begin
  FRibbon := Value;
end;
}
end.
