unit TemplateOraSymPlugInInfo;

interface

function GetPlugInFramesClassNames: String ; export ;

implementation

// ����� ��������� ������� ����� ������� ���� ������� �������������� �� ������.
// ����� ����������� ��������
function GetPlugInFramesClassNames: String ;
begin
  Result  := '*' ;
end;

exports GetPlugInFramesClassNames ;

end.
