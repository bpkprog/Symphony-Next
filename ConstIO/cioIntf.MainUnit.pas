unit cioIntf.MainUnit;

interface

uses SymphonyPlugIn.ParamInterface ;

Type
  IConstIO = interface
    ['{E84A3545-C310-4E22-B01B-BF9DEBD7B6D1}']
    function LoadCFGGroup(GroupName: String): ISymphonyPlugInCFGGroup ;
    function SaveCFGGroup(Group: ISymphonyPlugInCFGGroup): Boolean ;
    function SaveConst(Group: ISymphonyPlugInCFGGroup; Param: ISymphonyPlugInParam; IsPersonalParam: Boolean): Boolean ;
  end;

implementation

end.
