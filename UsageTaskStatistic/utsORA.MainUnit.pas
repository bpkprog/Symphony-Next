unit utsORA.MainUnit;

interface

uses SymphonyPlugIn.UsageTaskStatInterface, Ora ;

Type
  TUsageTaskStatistician = class(TInterfacedObject, IUsageTaskStatistician)
  private
    function GetUTSQuery(Session: TOraSession; IDTask: Integer): TOraQuery ;
  public
    procedure ExecuteTask(Session: TObject; IDTask: Integer) ;
  end;

function GetUTSInterface: IUsageTaskStatistician ; export ;

exports  GetUTSInterface ;

implementation

uses SysUtils ;

function GetUTSInterface: IUsageTaskStatistician ;
begin
  Result  := TUsageTaskStatistician.Create ;
end;

{ TUsageTaskStatistician }

procedure TUsageTaskStatistician.ExecuteTask(Session: TObject; IDTask: Integer);
Var
  Query: TOraQuery ;
begin
  Query := GetUTSQuery(Session as TOraSession, IDTask) ;
  Try
    try
      Query.ExecSQL ;
    except

    end;
  Finally
    Query.Free ;
  End;
end;

function TUsageTaskStatistician.GetUTSQuery(Session: TOraSession; IDTask: Integer): TOraQuery;
begin
  Result          := TOraQuery.Create(nil);
  Result.Session  := Session ;
  Result.SQL.Text := Format('begin p_usagestatistictask.onexecute(%d) ; end ;', [IDTask]) ;
end;

end.
