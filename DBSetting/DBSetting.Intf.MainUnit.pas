unit DBSetting.Intf.MainUnit;

interface

uses System.SysUtils, XML.XMLIntf ;

Const
  StrGUID_IReaderDataSetSetting = '{515680DA-16D3-423D-9433-4F4BCC6D2FBF}'  ;


Type
  ICustomReader = interface
    ['{9177925E-51C5-4A42-B603-73083ED66F02}']
    function InitReader(ASession: TObject): Boolean ;
    function GetErrorMessage: String ;

    property ErrorMessage: String read GetErrorMessage ;
  end;

  IReaderDataSetSetting = interface(ICustomReader)
    [StrGUID_IReaderDataSetSetting]
    function Read(IDDataSet: Integer): IXMLDocument ;
    function GetData(IDDataSet: Integer): String ;

    property Data[IDdataSet: Integer]: String read GetData ;
  end;


function GUID_IReaderDataSetSetting: TGUID ;

implementation

function GUID_IReaderDataSetSetting: TGUID ;
begin
  Result  := StringToGUID(StrGUID_IReaderDataSetSetting)  ;
end;

end.
