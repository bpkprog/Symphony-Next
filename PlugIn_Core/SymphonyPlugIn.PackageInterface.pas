unit SymphonyPlugIn.PackageInterface;

interface

uses SymphonyPlugIn.ActionInterface ;

Type
  IPlugInPackage = interface
    function GetActionList: ISymphonyPlugInActionList ;
    function TunerFrameClassName: String ;
    function PackageDBType: String  ;
  end;

implementation

end.
