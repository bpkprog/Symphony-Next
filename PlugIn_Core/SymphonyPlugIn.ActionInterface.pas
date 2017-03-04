unit SymphonyPlugIn.ActionInterface;

interface

uses VCL.Graphics, VCL.Forms, Generics.Collections,
     SymphonyPlugIn.ParamInterface ;

Type
  ISymphonyPlugInAction = interface ;

  // ������� ��� ��������� ��������� ������� �����:
  //    Handle ������ �������; �����, �� ������� ������������ ����� �������;
  //    ���������� � ����� ������ � �������������� ���������
  TSymphonyPlugInGetHandleFunc = function (Source: ISymphonyPlugInAction): NativeUInt of object ;
  TSymphonyPlugInGetOwnerFormFunc = function (Source: ISymphonyPlugInAction): TForm of object ;
  TSymphonyPlugInGetSessionFunc = function (Source: ISymphonyPlugInAction): TObject of object ;
  TSymphonyPlugInGetParamFunc = function (Source: ISymphonyPlugInAction): ISymphonyPlugInCommand of object ;

  TFormList = TList<TForm> ;

  ISymphonyPlugInAction = interface
    ['{B39489C5-978C-4957-8AA0-6AA60FE21308}']
    // ������� ������� � ��������� ������� ���������� �����
    function  GetCaption: String ;
    function  GetCommand: ISymphonyPlugInCommand ;
    function  GetFrameClassName: String ;
    function  GetPlugInMethodName: String ;
    function  GetIconCount: Integer ;
    function  GetIcon(Index: Integer): VCL.Graphics.TBitmap ;
    function  GetName: String ;
    function  GetBeginGroup: Boolean ;
    function  GetBar: String ;
    function  GetAutoStart: Boolean ;
    function  GetVisible: Boolean ;
    function  GetContextName: String ;
    function  GetTabCaption: String ;
    function  GetTabIndex: Integer ;
    function  GetFormCaption: String ;
    function  GetForms: TFormList ;

    // ��������� ��� ��������� ������� ��������� ��������� ������� �����
    procedure SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc) ;
    procedure SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc) ;
    procedure SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc) ;
    procedure SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc) ;

    // �������� � ����������� ������������
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function  GetTunerParams: ISymphonyPlugInCFGGroup;

    // �������� ������ ����� �������� ������ � ������� �����, ��� ������������ ������
    procedure ClearIcons ;
    function  Execute(CmdLine: String = ''): Boolean ;   // ������ ����� �� ����������
    procedure ShowForms ;                           // ���������� ����� �����
    function  IndexOfForm(AForm: TForm): Integer ;  // ���������� ������ ����� � ������ ����������� ��� ����� ����

    property AutoStart: Boolean read GetAutoStart;  // ����� �������� ������������� ��� �������� �������

    // �������� ������������ ������������ ��������� ����������������� ����������
    property Bar: String read GetBar ;                          // ��������� ������ ������������
    property BeginGroup: Boolean read GetBeginGroup ;           // ������� ���� ����� �������� ������� ������ ���������
    property Caption: String  read GetCaption ;                 // ��������� ��������
    property ContextName: String read GetContextName ;          // �������� ��� ������� ���������� ����� ������� �����
    property IconCount: Integer read GetIconCount ;             // ���������� ������ ����������� � �����
    property Icon[Index: Integer]: VCL.Graphics.TBitmap read GetIcon;          // ������ ��� ��������
    property TabCaption: String read GetTabCaption ;            // ��������� �������� ��� ��������� ������������� �� TdxRibbon
    property TabIndex: Integer read GetTabIndex ;               // ������ �������� ��� ��������� ������������� �� TdxRibbon
    property Visible: Boolean read GetVisible ;                 // ��������� ��������� �����

    // �������� ���������� �� �����, �� ������� ����� ������������� ������
    property FormCaption: String read GetFormCaption ;          // ��������� �����, �� ������� ������������� ������
    property Forms: TFormList read GetForms ;                   // ������ ����, �� ������� ���������� ������

    // �������� ���������� �� ���������� �����
    property FrameClassName: String read GetFrameClassName  ;   // ��� ������ ������, ������� ����� ������ � �������� �� ����� �� Forms
    property PlugInMethodName: String read GetPlugInMethodName ;// ��� ������ �������, ������� ����� ��������
    property Command: ISymphonyPlugInCommand read GetCommand  ; // ��������� ������������ ������ ��� ���������� ������

    property Name: String read GetName ;                        // ��� �����. ������������ ��� ������������ ����� ��������
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
  end;

  ISymphonyPlugInActionList = interface
    ['{8FC2541D-58A6-42DC-BF30-242C2AEAAC2B}']
    // ������� ������� � ��������� ������� ���������� �����
    function GetCaption: String ;
    function GetCount: Integer ;
    function GetBarCount: Integer ;
    function GetAction(Index: Integer): ISymphonyPlugInAction ;
    function FindAction(ActionName: String): ISymphonyPlugInAction ;
    function GetBar(Index: Integer): String ;

    // ��������� ��� ��������� ������� ��������� ��������� ������� ����� ��� ����� ������ �����
    procedure SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc) ;
    procedure SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc) ;
    procedure SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc) ;
    procedure SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc) ;

    // �������� � ����������� ������������
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function  GetTunerParams: ISymphonyPlugInCFGGroup;

    function  ExecAutoRun: Boolean ;                         // ������ ������������
    function  Execute(CmdLine: String): Boolean ;
    procedure ShowForms ;                           // ���������� ����� �����

    property Caption: String read GetCaption ;
    property Count: Integer read GetCount ;
    property Action[Index: Integer]: ISymphonyPlugInAction read GetAction ;
    property BarCount: Integer read GetBarCount ;
    property Bar[Index: Integer]: String read GetBar ;
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
  end;

  //TSymphonyPlugInActionListProc = function: ISymphonyPlugInActionList ;
  TSymphonyPlugInProc = function(ASession: TObject; AData: ISymphonyPlugInCommand): boolean ;

implementation

end.
