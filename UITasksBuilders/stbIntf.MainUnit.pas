unit stbIntf.MainUnit;

interface

Uses System.Classes, XML.XMLIntf, VCL.Forms, SymphonyPlugIn.ActionInterface ;

Type
  TEventList = record
    OnExecute: TNotifyEvent;
    OnClosePlugIn: TNotifyEvent ;
    OnEditTuner: TNotifyEvent ;
    OnPrint: TNotifyEvent ;
    OnExportExcel: TNotifyEvent ;
  end;

  ISymphonyUIManager = interface
    ['{F05A9AE3-72BB-4253-ADE7-615BEDF3EA66}']
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

implementation

end.
