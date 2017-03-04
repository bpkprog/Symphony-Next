unit SymphonyPlugIn.ParamInterface;

interface

Type
  // Базовый интерфейс с заголовком, описанием и наименованием
  ISymphonyPlugInNamedIntf = interface
    ['{8BA5C11F-C827-45C9-9B99-018AD68FB42F}']

    function GetName: String ;
    function GetCaption: String ;
    function GetDescription: String ;

    procedure SetName(const Value: String);
    procedure SetCaption(const Value: String);
    procedure SetDescription(const Value: String);

    property Caption: String read GetCaption write SetCaption ;
    property Description: String read GetDescription write SetDescription ;
    property Name: String read GetName write SetName ;
  end;

  //  Интерфейс абстрактного параметра с заголовком, описанием, наименованим и значением
  ISymphonyPlugInParam = interface(ISymphonyPlugInNamedIntf)
    ['{3BF57E54-A1D8-4C48-AEF9-D06F2D3D95D6}']

    procedure Assign(Param: ISymphonyPlugInParam) ;

    function GetValue: Variant ;
    function GetAsInteger: Integer ;
    function GetAsFloat: Double ;
    function GetAsDateTime: TDateTime ;
    function GetAsBoolean: Boolean ;
    function GetAsString: String ;

    procedure SetValue(const AValue: Variant);
    procedure SetAsInteger(const AValue: Integer);
    procedure SetAsFloat(const AValue: Double);
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsBoolean(const AValue: Boolean);
    procedure SetAsString(const AValue: String);

    property AsInteger: Integer read GetAsInteger write SetAsInteger ;
    property AsFloat: Double read GetAsFloat write SetAsFloat ;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime ;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean ;
    property AsString: String read GetAsString write SetAsString ;
    property Value: Variant read GetValue write SetValue ;
  end;

  // Интерфейс списка параметров
  ISymphonyPlugInParamList = interface(ISymphonyPlugInNamedIntf)
    ['{6DDCAAF4-0EC2-4CE9-8956-1A7D36891D34}']

    procedure Assign(ParamList: ISymphonyPlugInParamList) ;
    procedure Merge(ParamList: ISymphonyPlugInParamList) ;
    procedure ParseParams(CmdLine: String) ;
    function  IndexOf(ParamName: String): Integer ;

    function GetParamCount: Integer ;
    function GetParams(Index: Integer): ISymphonyPlugInParam ;
    function GetParamValue(ParamName: String): Variant ;
    function GetAsInteger(ParamName: String): Integer ;
    function GetAsFloat(ParamName: String): Double ;
    function GetAsDateTime(ParamName: String): TDateTime ;
    function GetAsBoolean(ParamName: String): Boolean ;
    function GetAsString(ParamName: String): String ;

    procedure SetParamValue(ParamName: String; Value: Variant) ;
    procedure SetAsInteger(ParamName: String; const AValue: Integer);
    procedure SetAsFloat(ParamName: String; const AValue: Double);
    procedure SetAsDateTime(ParamName: String; const AValue: TDateTime);
    procedure SetAsBoolean(ParamName: String; const AValue: Boolean);
    procedure SetAsString(ParamName: String; const AValue: String);

    function AddParam: ISymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String): ISymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String; ParamValue: Variant): ISymphonyPlugInParam ; overload ;

    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: ISymphonyPlugInParam read GetParams ;
    property ParamValue[ParamName: String]: Variant read GetParamValue write SetParamValue;
    property AsInteger[ParamName: String]: Integer read GetAsInteger write SetAsInteger ;
    property AsFloat[ParamName: String]: Double read GetAsFloat write SetAsFloat ;
    property AsDateTime[ParamName: String]: TDateTime read GetAsDateTime write SetAsDateTime ;
    property AsBoolean[ParamName: String]: Boolean read GetAsBoolean write SetAsBoolean ;
    property AsString[ParamName: String]: String read GetAsString write SetAsString ;
  end;

  // Команда предаваемая акции вместе со списком параметров
  ISymphonyPlugInCommand = interface(ISymphonyPlugInParamList)
    ['{0098401A-7973-433A-B7FD-760966055CA1}']

    procedure Assign(ACommand: ISymphonyPlugInCommand) ;

    function GetCommand: String ;
    procedure SetCommand(Value: String) ;

    property Command: String read GetCommand write SetCommand ;
  end;

  // Группа параметров настроек Симфонии или плагина
  ISymphonyPlugInCFGGroup = interface(ISymphonyPlugInNamedIntf)
    ['{B17092A4-2770-4902-AC97-EE92B54F08E2}']
    procedure Assign(CFGGroup: ISymphonyPlugInCFGGroup) ;
    procedure Merge(CFGGroup: ISymphonyPlugInCFGGroup) ;

    function GetCommonParams: ISymphonyPlugInParamList ;
    function GetPersonalParams: ISymphonyPlugInParamList ;

    property CommonParams: ISymphonyPlugInParamList read GetCommonParams ;
    property PersonalParams: ISymphonyPlugInParamList read GetPersonalParams ;
  end;

implementation

end.


