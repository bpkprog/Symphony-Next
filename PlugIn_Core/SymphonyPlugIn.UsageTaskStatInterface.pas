unit SymphonyPlugIn.UsageTaskStatInterface;

interface

Type
  IUsageTaskStatistician = interface
    procedure ExecuteTask(Session: TObject; IDTask: Integer) ;
  end;

  TGetUTSInterfaceFunc = function : IUsageTaskStatistician ;

implementation

end.
