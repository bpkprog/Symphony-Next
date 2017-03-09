unit DBSetting.ImplORA.ReaderDataSet;

interface

uses XML.XMLIntf, DBSetting.Intf.MainUnit ;

Type
  TReaderDataSetSetting = class(TInterfacedObject, IReaderDataSetSetting)
  private
    FIDDataSet: Integer ;
    FXML: IXMLDocument ;
    FErrorMessage: String ;
  public
    function Read(IDDataSet: Integer): IXMLDocument ;
    function InitReader(ASession: TObject): Boolean ;
    function GetErrorMessage: String ;
    function GetData(IDDataSet: Integer): String ;

    property Data[IDdataSet: Integer]: String read GetData ;
    property ErrorMessage: String read GetErrorMessage ;
  end;

implementation

uses System.SysUtils, Ora, DBSetting.ImplORA.MainDM;


{ TReaderDataSetSetting }

function TReaderDataSetSetting.GetData(IDDataSet: Integer): String;
begin
  Result  := Read(IDDataSet).XML.Text ;
end;

function TReaderDataSetSetting.GetErrorMessage: String;
begin
  Result  := FErrorMessage ;
end;

function TReaderDataSetSetting.InitReader(ASession: TObject): Boolean;
begin
  if ASession is TOraSession then
         Result := dmORAMain.Init(ASession as TOraSession)
  else
  begin
    Result  := False ;
    FErrorMessage := Format('Не верный тип соединения с базой данных. Ожидается объект типа TOraSesion, а передан объект типа %s',
                                                        [ASession.ClassName]) ;
  end;
end;

function TReaderDataSetSetting.Read(IDDataSet: Integer): IXMLDocument;
begin
  if (FIDDataSet <> IDDataSet) or (FXML = nil) then
  begin
    Try
      FXML  := dmORAMain.GetDataSetSetting(IDDataSet) ;
      FIDDataSet  := IDDataSet ;
    Except on E: Exception do
      begin
        FErrorMessage := E.Message ;
        raise ;
      end;
    End;
  end;

  Result := FXML ;
end;

end.
