unit SymphonyPlugIn.MessageInterface;

interface

uses SymphonyPlugIn.ParamInterface;

Type
  ISymphonyPlugInMessage = interface
    ['{278DE7C5-B7CA-4117-8758-1148095F538F}']
    function GetDomain: String ;
    function GetEvent: String ;
    function GetParamCount: Integer ;
    function GetParams(Index: Integer): ISymphonyPlugInParam ;
    function GetParamValue(ParamName: String): Variant ;
    function GetResult: Variant ;
    procedure SetResult(Value: Variant) ;
    procedure SetDomain(Value: String) ;
    procedure SetEvent(Value: String) ;

    function AddParam: ISymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String): ISymphonyPlugInParam ; overload ;
    function AddParam(ParamName: String; ParamValue: Variant): ISymphonyPlugInParam ; overload ;

    property Domain: String read GetDomain write SetDomain ;
    property Event: String read GetEvent write SetEvent ;
    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: ISymphonyPlugInParam read GetParams ;
    property ParamValue[ParamName: String]: Variant read GetParamValue ;
    property Result: Variant read GetResult write SetResult ;
  end;

implementation

end.
